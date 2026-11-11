QT += core testlib
CONFIG += c++17 testcase console
TEMPLATE = app
TARGET = backend-tests
INCLUDEPATH += ../src
SOURCES += backend-tests.cpp ../src/backend.cpp
HEADERS += ../src/backend.h
