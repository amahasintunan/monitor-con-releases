#!/bin/bash
#
# monitor-client.sh — Launcher for the Java Swing GUI monitor client.
#
# JAVA_HOME resolution order:
#   1. $JAVA_HOME from the environment (if set and the dir exists)
#   2. `java` found on PATH (if it's JDK 21+)
#   3. JAVA_HOME read from monitor_client.ini
#   4. Error — ask the user to install JDK 21+ or edit the ini file.
#
# Usage:  ./monitor-client.sh -h <host> -p 2019 -P tcp

set -euo pipefail

cd "$(dirname "$0")"

# ── Helper: is this a JDK 21+? ────────────────────────────────────────────────
is_jdk21() {
  local java_cmd="$1"
  local version
  version=$("$java_cmd" -version 2>&1 | head -1) || return 1
  # Accept "21.", "22.", "23." etc. — anything from 21 upward
  if echo "$version" | grep -qE '"[2-9][1-9]\.'; then
    return 0  # JDK 21+
  fi
  # Also accept 17-20 (close enough — may still work with --release 21)
  if echo "$version" | grep -qE '"(1[7-9]|20)\.'; then
    return 0
  fi
  return 1
}

JAVA_CMD=""

# ── Step 1: $JAVA_HOME from environment ──────────────────────────────────────
if [ -n "${JAVA_HOME:-}" ] && [ -d "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA_CMD="$JAVA_HOME/bin/java"
fi

# ── Step 2: java on PATH ─────────────────────────────────────────────────────
if [ -z "$JAVA_CMD" ]; then
  if path_java=$(command -v java 2>/dev/null) && [ -n "$path_java" ]; then
    JAVA_CMD="$path_java"
  fi
fi

# ── Step 3: JAVA_HOME from ini file ──────────────────────────────────────────
if [ -z "$JAVA_CMD" ]; then
  INI_FILE="monitor_client.ini"
  if [ -f "$INI_FILE" ]; then
    INI_JAVA_HOME=$(grep -E '^JAVA_HOME=' "$INI_FILE" 2>/dev/null | head -1 | cut -d'=' -f2-)
    if [ -n "${INI_JAVA_HOME:-}" ] && [ -d "$INI_JAVA_HOME" ] && [ -x "$INI_JAVA_HOME/bin/java" ]; then
      JAVA_CMD="$INI_JAVA_HOME/bin/java"
    fi
  fi
fi

# ── Validate ──────────────────────────────────────────────────────────────────
if [ -z "$JAVA_CMD" ]; then
  echo "ERROR: Could not find JDK 21+."
  echo ""
  echo "Options:"
  echo "  1. Install JDK 21+ and add 'java' to your PATH"
  echo "  2. Set JAVA_HOME in your shell:  export JAVA_HOME=/path/to/jdk-21"
  echo "  3. Edit monitor_client.ini and set JAVA_HOME there"
  echo ""
  exit 1
fi

if ! is_jdk21 "$JAVA_CMD"; then
  echo "WARNING: $(basename "$JAVA_CMD") may not be JDK 21+. Trying anyway..."
fi

# ── JAR file ──────────────────────────────────────────────────────────────────
JAR_FILE="monitor_client.jar"
if [ ! -f "$JAR_FILE" ]; then
  echo "ERROR: $JAR_FILE not found in $(pwd)"
  echo "Build it with:  mvn clean package"
  exit 1
fi

# ── Launch ────────────────────────────────────────────────────────────────────
LOOK_AND_FEEL="-Dswing.defaultlaf=javax.swing.plaf.nimbus.NimbusLookAndFeel"
echo "Using: $JAVA_CMD"
"$JAVA_CMD" -fullversion 2>&1 | head -1
exec "$JAVA_CMD" $LOOK_AND_FEEL -jar "$JAR_FILE" "$@"
