monitor-con v2.0 — Linux Performance Monitor
=============================================

A consolidated Linux system monitor that collects CPU, Memory, Network,
and Disk metrics from /proc and serves them over the network. Built
entirely in Java — server and GUI client.

What's in this package
----------------------
  jmonitor-server.jar    — Java server (fat JAR, all transports)
  monitor-server.sh      — Linux/Mac launcher for the server
  jmonitor-server.ini    — Server JAVA_HOME fallback config

  monitor_client.jar     — Java Swing GUI client (fat JAR)
  monitor-client.sh      — Linux/Mac launcher for the GUI
  monitor-client.bat     — Windows launcher for the GUI
  monitor_client.ini     — Client JAVA_HOME fallback config
  monitor_resource.xml   — Browser path for help links

Transports
----------
  All four transports are supported by both server and client:

    udp   — UDP datagrams (fire-and-forget, lowest overhead)
    tcp   — TCP stream, newline-delimited JSON
    http  — HTTP GET /metrics
    grpc  — gRPC with protobuf serialization

Quick start — Server (Linux)
------------------------------
  Prerequisite: JDK 21 or later on your PATH.

    ./monitor-server.sh -P udp -p 2019 -e

  Options:
    -P udp|tcp|http|grpc    Transport (required)
    -p <port>               Port (default 2019)
    -e                      Echo mode — print each request to stdout

  If 'java' is not on your PATH, edit jmonitor-server.ini and
  set JAVA_HOME to your JDK installation directory.

Quick start — GUI client (Linux / macOS / Windows)
---------------------------------------------------
  Prerequisite: JDK 21 or later on your PATH.

  Linux/macOS:
    ./monitor-client.sh -h <host> -p 2019 -P udp

  Windows:
    .\monitor-client.bat -h <host> -p 2019 -P udp

  If 'java' is not on your PATH, edit monitor_client.ini and
  set JAVA_HOME to your JDK 21 installation directory.

Build from source
-----------------
  git clone https://github.com/amahasintunan/monitor-con.git
  cd monitor-con/jserver && ./build.sh              # Java server
  cd monitor-con/jclient-gui && mvn clean package   # Java GUI

More info
---------
  https://github.com/amahasintunan/monitor-con
