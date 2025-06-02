#!/bin/bash

# Create web directory if it doesn't exist
mkdir -p web

# Download SQLite web worker files
echo "Downloading SQLite web worker files..."

# Download sqlite3.js
curl -L "https://github.com/simolus3/sqlite3.dart/raw/main/sqlite3/wasm/sqlite3.js" -o web/sqlite3.js
if [ $? -eq 0 ]; then
  echo "Downloaded sqlite3.js"
else
  echo "Error downloading sqlite3.js"
  exit 1
fi

# Download sqflite_sw.js
curl -L "https://github.com/simolus3/sqlite3.dart/raw/main/sqlite3/wasm/sqflite_sw.js" -o web/sqflite_sw.js
if [ $? -eq 0 ]; then
  echo "Downloaded sqflite_sw.js"
else
  echo "Error downloading sqflite_sw.js"
  exit 1
fi

echo "SQLite web worker files downloaded successfully" 