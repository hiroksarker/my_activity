#!/bin/bash

# Create web directory if it doesn't exist
mkdir -p web

# Find and copy sqlite3.js
SQLITE3_JS=$(find ~/.pub-cache -name "sqlite3.js" | head -n 1)
if [ -n "$SQLITE3_JS" ]; then
  cp "$SQLITE3_JS" web/
  echo "Copied sqlite3.js to web directory"
else
  echo "Error: sqlite3.js not found"
  exit 1
fi

# Find and copy sqflite_sw.js
SQFLITE_SW_JS=$(find ~/.pub-cache -name "sqflite_sw.js" | head -n 1)
if [ -n "$SQFLITE_SW_JS" ]; then
  cp "$SQFLITE_SW_JS" web/
  echo "Copied sqflite_sw.js to web directory"
else
  echo "Error: sqflite_sw.js not found"
  exit 1
fi

echo "SQLite web worker files copied successfully" 