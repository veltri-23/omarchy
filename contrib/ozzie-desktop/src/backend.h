#pragma once
#include <QObject>
#include <QUrl>
#include <QFileSystemWatcher>
class Backend : public QObject {
 Q_OBJECT
 Q_PROPERTY(QUrl homeUrl READ homeUrl CONSTANT)
 Q_PROPERTY(QString focusScript READ focusScript CONSTANT)
 Q_PROPERTY(QString accent READ accent NOTIFY themeChanged)
public:
 explicit Backend(QObject *parent=nullptr);
 QUrl homeUrl() const;
 QString focusScript() const;
 QString accent() const { return m_accent; }
 Q_INVOKABLE bool internalUrl(const QUrl &url) const;
 Q_INVOKABLE bool externalUrl(const QUrl &url) const;
signals:
 void themeChanged();
private:
 void reloadTheme();
 QFileSystemWatcher m_watcher;
 QString m_accent="#FFD60A";
};
