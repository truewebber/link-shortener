# Link Shortener

A modern URL shortening service with enhanced features for registered users.

## Project Overview

Link Shortener is a web application that allows users to create shortened URLs for easier sharing and tracking. The service aims to provide a simple, reliable way to convert long URLs into compact, manageable links while offering enhanced features for registered users.

### Key Features

- Simple and intuitive URL shortening
- Responsive design that works on mobile, tablet, and desktop
- OAuth authentication (Google, Apple, GitHub)
- URL management for registered users
- Usage statistics and analytics
- Customizable link expiration

## Technology Stack

### Backend
- Go (Golang)
- PostgreSQL
- Domain-Driven Design architecture

### Frontend
- Flutter Web / Dart
- Material Design

### Infrastructure
- Docker
- Kubernetes
- GitHub Actions for CI/CD

## Development Setup

### Prerequisites
- Go 1.24+
- Docker and Docker Compose
- Flutter SDK

### Local Development
1. Clone the repository
2. Run `docker-compose up -d` to start the PostgreSQL database
3. Run `go run cmd/api/main.go` to start the backend API
4. Navigate to the `web` directory and run `flutter run -d chrome` to start the frontend

## Project Structure

The project follows Domain-Driven Design principles with a hexagonal architecture:

```
link-shortener/
├── cmd/                       # Application entry points
├── adapter/                   # Implementations of interfaces
├── app/                       # Application layer
│   ├── command/               # Command handlers
│   └── query/                 # Query handlers
├── domain/                    # Domain models and interfaces
├── port/                      # Entry points to the application
├── service/                   # Service wiring
├── sql/                       # Database migrations
└── web/                       # Frontend application
```

## License

[MIT License](LICENSE) 