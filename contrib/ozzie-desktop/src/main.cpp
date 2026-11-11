#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QTimer>
#include <QQuickWindow>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include "backend.h"
#include "translator.h"
int main(int argc,char **argv) {
 QtWebEngineQuick::initialize();
 QGuiApplication app(argc,argv);
 app.setApplicationName("ozzie-desktop");
 app.setOrganizationName("ECHO");
 app.setDesktopFileName("ozzie-desktop");
 app.setWindowIcon(QIcon(":/ozzie-desktop.png"));
 QQuickStyle::setStyle("Material");
 Backend backend;
 Translator translator;
 app.installTranslator(&translator);
 QQmlApplicationEngine engine;
 QObject::connect(&translator,&Translator::changed,&engine,&QQmlEngine::retranslate);
 engine.rootContext()->setContextProperty("backend",&backend);
 bool smoke=app.arguments().contains("--smoke-test");
 engine.rootContext()->setContextProperty("smokeTest",smoke);
 engine.load(QUrl("qrc:/Main.qml"));
 if(engine.rootObjects().isEmpty()) return 1;
 if(smoke) QTimer::singleShot(2200,&app,[&]{
  auto window=qobject_cast<QQuickWindow*>(engine.rootObjects().first());
  if(window) window->grabWindow().save(qEnvironmentVariable("OZZIE_TEST_SCREENSHOT","/tmp/ozzie-smoke.png"));
  app.quit();
 });
 return app.exec();
}
