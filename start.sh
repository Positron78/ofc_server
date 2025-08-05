#!/bin/bash

# Organic Fresh Coffee Game Server Start Script
# This script starts the game server using Docker Compose

set -e  # Exit on error

echo "🎮 Starting Organic Fresh Coffee Game Server..."
echo "=============================================="

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Please run ./setup.sh first."
    exit 1
fi

# Load environment variables
source .env

# Check required environment variables
if [ -z "$AUTH_SERVER_URL" ]; then
    echo "⚠️  AUTH_SERVER_URL is not set in .env file, using default: http://localhost:3001"
fi

# Check if service account key exists
# Note: This server no longer needs Firebase service account keys
# Authentication is handled by calling the auth server

# Build and start services
echo "🔨 Building and starting services..."
docker compose down  # Stop any existing containers
docker compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🏥 Checking service health..."

# Check MongoDB
if docker compose ps mongodb | grep -q "Up"; then
    echo "✅ MongoDB is running"
else
    echo "❌ MongoDB failed to start"
    docker compose logs mongodb
    exit 1
fi

# Check Game Server
if docker compose ps game-server | grep -q "Up"; then
    echo "✅ Game Server is running"
else
    echo "❌ Game Server failed to start"
    docker compose logs game-server
    exit 1
fi

# Test server health endpoint
echo "🔍 Testing server health..."
sleep 5  # Give server more time to start

if curl -f http://localhost:3002/health &> /dev/null; then
    echo "✅ Server health check passed"
else
    echo "⚠️  Server health check failed, but container is running"
    echo "Check logs with: docker compose logs game-server"
fi

echo ""
echo "🎉 Game Server started successfully!"
echo ""
echo "Server Information:"
echo "  🌐 HTTP API: http://localhost:3002"
echo "  📡 WebSocket: ws://localhost:3002/game"
echo "  🏥 Health Check: http://localhost:3002/health"
echo ""
echo "Database Information:"
echo "  🗃️  MongoDB: mongodb://admin:password@localhost:27017/gamedb"
echo "  🖥️  MongoDB Express: http://localhost:8081 (admin/password)"
echo ""
echo "Useful Commands:"
echo "  docker compose logs -f                # View all logs"
echo "  docker compose logs -f game-server   # View server logs"
echo "  docker compose logs -f mongodb       # View database logs"
echo "  docker compose stop                  # Stop all services"
echo "  docker compose down                  # Stop and remove containers"
echo "  docker compose restart game-server   # Restart server only"
echo ""
echo "🎮 Ready for game clients to connect!"
