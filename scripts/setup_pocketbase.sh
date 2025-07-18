#!/bin/bash

# Daily Explorer Activities - PocketBase Setup Script
# This script downloads and sets up PocketBase with the required schema

set -e

echo "🚀 Setting up PocketBase for Daily Explorer Activities..."

# Create backend directory if it doesn't exist
mkdir -p backend

# Download PocketBase if not already present
if [ ! -f "backend/pocketbase" ]; then
    echo "📥 Downloading PocketBase..."
    cd backend
    
    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    # Download appropriate version
    POCKETBASE_VERSION="0.20.0"
    DOWNLOAD_URL="https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_${OS}_${ARCH}.zip"
    
    echo "📦 Downloading from: $DOWNLOAD_URL"
    curl -L -o pocketbase.zip "$DOWNLOAD_URL"
    
    # Extract and cleanup
    unzip pocketbase.zip
    rm pocketbase.zip
    chmod +x pocketbase
    
    cd ..
    echo "✅ PocketBase downloaded successfully!"
else
    echo "✅ PocketBase already exists"
fi

# Start PocketBase in the background
echo "🔄 Starting PocketBase server..."
cd backend
./pocketbase serve --http=127.0.0.1:8090 &
POCKETBASE_PID=$!

# Wait for PocketBase to start
echo "⏳ Waiting for PocketBase to start..."
sleep 5

# Check if PocketBase is running
if ! curl -s http://localhost:8090/api/health > /dev/null; then
    echo "❌ PocketBase failed to start"
    kill $POCKETBASE_PID 2>/dev/null || true
    exit 1
fi

echo "✅ PocketBase is running on http://localhost:8090"

# Create admin user if needed
echo "👤 Setting up admin user..."
curl -X POST http://localhost:8090/api/admins \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123456",
    "passwordConfirm": "admin123456"
  }' 2>/dev/null || echo "Admin user may already exist"

echo "🎉 PocketBase setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open http://localhost:8090/_/ to access the admin panel"
echo "2. Login with: admin@example.com / admin123456"
echo "3. Import the schema from backend/pb_schema.json"
echo "4. Run 'flutter pub get' to install dependencies"
echo "5. Run your Flutter app!"
echo ""
echo "🔧 To stop PocketBase: kill $POCKETBASE_PID"
echo "💾 PocketBase PID saved to: backend/pocketbase.pid"

# Save PID for later cleanup
echo $POCKETBASE_PID > backend/pocketbase.pid

cd ..