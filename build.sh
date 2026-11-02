#!/bin/bash
# Agervis Desktop App - Setup and Build Script

echo "=== Agervis Desktop App Builder ==="
echo "Installing dependencies..."

npm install

echo "Building Electron app..."
npm run build:electron

echo "Building React app..."
npm run build:react

echo "Build complete!"
echo "To package for your platform:"
echo "  npm run package:win    # Windows"
echo "  npm run package:mac    # macOS"
echo "  npm run package:linux  # Linux"
