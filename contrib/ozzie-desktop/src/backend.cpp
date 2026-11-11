#include "backend.h"
#include <QFile>
#include <QDir>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QJsonArray>
#include <QSettings>
Backend::Backend(QObject *parent): QObject(parent) {
 connect(&m_watcher,&QFileSystemWatcher::fileChanged,this,[this]{reloadTheme();});
 connect(&m_watcher,&QFileSystemWatcher::directoryChanged,this,[this]{reloadTheme();});
 reloadTheme();
}
QUrl Backend::homeUrl() const {
 QSettings settings;
 const QUrl url(settings.value("homeUrl").toString());
 if(url.scheme()=="https" && url.host()=="chatgpt.com" && url.userInfo().isEmpty() && url.path().startsWith("/dots/")) return url;
 return QUrl();
}
bool Backend::internalUrl(const QUrl &url) const {
 if(url.scheme()!="https" || !url.userInfo().isEmpty()) return false;
 const auto host=url.host();
 if(host=="auth.openai.com" || host=="auth0.openai.com" || host=="accounts.google.com" || host=="login.microsoftonline.com" || host=="appleid.apple.com") return true;
 if(host!="chatgpt.com") return false;
 const auto p=url.path();
 for(const QString &base: {homeUrl().path(),QString("/plugins"),QString("/auth"),QString("/api/auth"),QString("/connector"),QString("/settings")})
  if(!base.isEmpty() && (p==base || p.startsWith(base+"/"))) return true;
 return p=="/" || p.isEmpty();
}
bool Backend::externalUrl(const QUrl &url) const {
 return (url.scheme()=="https" || url.scheme()=="http" || url.scheme()=="mailto") && url.userInfo().isEmpty();
}
QString Backend::focusScript() const {
 QFile f(":/focus.js"); if(!f.open(QIODevice::ReadOnly)) return {};
 QString code=QString::fromUtf8(f.readAll());
 const QByteArray json=QJsonDocument(QJsonArray{homeUrl().toString()}).toJson(QJsonDocument::Compact);
 return "const OZZIE_HOME = "+QString::fromUtf8(json)+"[0];\n"+code;
}
void Backend::reloadTheme() {
 const QString base=QDir::homePath()+"/.local/state/omarchy/current";
 const QString path=base+"/theme/colors.toml";
 QFile f(path);
 if(f.open(QIODevice::ReadOnly)) {
  const QRegularExpression re(R"re(^\s*accent\s*=\s*["'](#[0-9a-fA-F]{6})["'])re",QRegularExpression::MultilineOption);
  auto m=re.match(QString::fromUtf8(f.readAll()));
  if(m.hasMatch() && m.captured(1)!=m_accent) {m_accent=m.captured(1);emit themeChanged();}
 }
 for(const auto &p: {base,base+"/theme",path}) if(!m_watcher.files().contains(p) && !m_watcher.directories().contains(p)) m_watcher.addPath(p);
}
