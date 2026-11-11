#include <QtTest>
#include <QSettings>
#include <QTemporaryDir>
#include "backend.h"
class BackendTests: public QObject {
 Q_OBJECT
private slots:
 void routes() {
  QTemporaryDir config;
  QSettings::setDefaultFormat(QSettings::IniFormat);
  QSettings::setPath(QSettings::IniFormat,QSettings::UserScope,config.path());
  QCoreApplication::setOrganizationName("OzzieTest");
  QCoreApplication::setApplicationName("Routes");
  QSettings settings;
  settings.setValue("homeUrl","https://chatgpt.com/dots/test-dot");
  Backend b;
  QVERIFY(b.internalUrl(b.homeUrl()));
  QVERIFY(b.internalUrl(QUrl("https://chatgpt.com/plugins/plugin_test")));
  QVERIFY(b.internalUrl(QUrl("https://auth.openai.com/login")));
  QVERIFY(!b.internalUrl(QUrl("https://chatgpt.com/dots/test-dot-other")));
  QVERIFY(!b.internalUrl(QUrl("https://chatgpt.com/c/other-chat")));
  QVERIFY(!b.internalUrl(QUrl("https://chatgpt.com.evil.test/plugins")));
  QVERIFY(!b.internalUrl(QUrl("https://attacker@chatgpt.com/plugins")));
  QVERIFY(!b.externalUrl(QUrl("file:///etc/passwd")));
  QVERIFY(!b.externalUrl(QUrl("javascript:alert(1)")));
  QVERIFY(b.externalUrl(QUrl("https://example.com/")));
  settings.setValue("homeUrl","https://evil.test/dots/test-dot");
  QVERIFY(b.homeUrl().isEmpty());
  QVERIFY(!b.internalUrl(QUrl("https://chatgpt.com/c/other-chat")));
 }
};
QTEST_GUILESS_MAIN(BackendTests)
#include "backend-tests.moc"
