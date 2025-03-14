# Link Shortener - Implementation Guide

This document outlines the architectural approach, coding standards, and implementation guidelines for the Link Shortener project. It serves as a reference for all developers working on the project and should be consulted when making technical decisions.

## Table of Contents

1. [Architectural Approach](#architectural-approach)
2. [Project Structure](#project-structure)
3. [Domain-Driven Design Principles](#domain-driven-design-principles)
4. [Coding Standards](#coding-standards)
5. [Error Handling](#error-handling)
6. [Testing Strategy](#testing-strategy)
7. [Database Practices](#database-practices)
8. [API Design](#api-design)
9. [Authentication](#authentication)
10. [Frontend Implementation](#frontend-implementation)
11. [Deployment Considerations](#deployment-considerations)

## Architectural Approach

The Link Shortener project follows a **Domain-Driven Design (DDD)** approach with a **Hexagonal Architecture** (also known as Ports and Adapters). This architecture emphasizes:

- Clear separation of concerns
- Business logic isolation from external dependencies
- Testability and maintainability
- Flexibility to change implementations without affecting core business logic

### Key Architectural Layers

1. **Domain Layer**: Contains the core business logic and entities
2. **Application Layer**: Orchestrates use cases using domain entities
3. **Adapters Layer**: Implements interfaces defined in the domain layer
4. **Ports Layer**: Provides entry points to the application
5. **Service Layer**: Wires everything together

## Project Structure

### Detailed Structure

Below is a more realistic project structure showing the full range of files you might expect in a production implementation:

```
link-shortener/
├── cmd/                       
│   ├── api/                   
│   │   ├── main.go            # Entry point for API server
│   │   └── config.go          # API-specific configuration
│   └── cleaner/               
│       ├── main.go            # Entry point for cleaner service
│       └── config.go          # Cleaner-specific configuration
├── adapter/                   
│   ├── link_storage_pgx.go    # pgx implementation for link.Storage
│   ├── link_storage_pgx_test.go # Tests for link storage
│   ├── token_storage_pgx.go   # pgx implementation for token.Storage
│   ├── token_storage_pgx_test.go # Tests for token storage
│   ├── user_storage_pgx.go    # pgx implementation for user.Storage
│   ├── user_storage_pgx_test.go # Tests for user storage
│   ├── oauth_google.go        # Google OAuth implementation
│   ├── oauth_apple.go         # Apple OAuth implementation
│   ├── oauth_github.go        # GitHub OAuth implementation
│   └── metrics_prometheus.go  # Prometheus metrics implementation
├── app/                       
│   ├── command/               
│   │   ├── create_link.go     # Create link command
│   │   ├── create_link_test.go # Tests for create link command
│   │   ├── delete_link.go     # Delete link command
│   │   ├── delete_link_test.go # Tests for delete link command
│   │   ├── update_link_ttl.go # Update link TTL command
│   │   ├── update_link_ttl_test.go # Tests for update link TTL
│   │   ├── register_user.go   # Register user command
│   │   ├── register_user_test.go # Tests for register user
│   │   ├── logout_user.go     # Logout user command
│   │   ├── logout_user_test.go # Tests for logout user
│   │   ├── clean_expired_links.go # Clean expired links command
│   │   ├── clean_expired_links_test.go # Tests for clean expired links
│   │   └── validator.go       # Validation logic for commands
│   ├── query/                 
│   │   ├── get_link_by_hash.go # Get link by hash query
│   │   ├── get_link_by_hash_test.go # Tests for get link by hash
│   │   ├── list_user_links.go # List user links query
│   │   ├── list_user_links_test.go # Tests for list user links
│   │   ├── get_link_analytics.go # Get link analytics query
│   │   ├── get_link_analytics_test.go # Tests for get link analytics
│   │   ├── get_user_profile.go # Get user profile query
│   │   ├── get_user_profile_test.go # Tests for get user profile
│   │   └── validator.go       # Validation logic for queries
│   ├── app.go                 # App struct defines application
│   └── app_test.go            # Tests for app
├── domain/                    
│   ├── link/                  
│   │   ├── link.go            # Link entity definition
│   │   ├── link_test.go       # Tests for link entity
│   │   ├── storage.go         # Link storage interface
│   │   ├── hash.go            # URL shortening logic (using Sqids)
│   │   ├── hash_test.go       # Tests for hash functionality
│   │   ├── ttl.go             # TTL definitions and calculations
│   │   └── ttl_test.go        # Tests for TTL functionality
│   ├── user/                  
│   │   ├── user.go            # User entity definition
│   │   ├── user_test.go       # Tests for user entity
│   │   ├── storage.go         # User storage interface
│   │   ├── oauth.go           # OAuth provider interface
│   │   └── session.go         # User session management
│   └── token/                 
│       ├── token.go           # Token entity definition
│       ├── token_test.go      # Tests for token entity
│       └── storage.go         # Token storage interface
├── port/                      
│   ├── http_rest/             
│   │   ├── handler/           
│   │   │   ├── link.go        # Link-related handlers
│   │   │   ├── link_test.go   # Tests for link handlers
│   │   │   ├── user.go        # User-related handlers
│   │   │   ├── user_test.go   # Tests for user handlers
│   │   │   ├── auth.go        # Authentication handlers
│   │   │   ├── auth_test.go   # Tests for auth handlers
│   │   │   ├── health.go      # Health check handler
│   │   │   └── health_test.go # Tests for health handler
│   │   ├── middleware/        
│   │   │   ├── auth.go        # Authentication middleware
│   │   │   ├── auth_test.go   # Tests for auth middleware
│   │   │   ├── logging.go     # Request logging middleware
│   │   │   ├── logging_test.go # Tests for logging middleware
│   │   │   ├── metrics.go     # Metrics collection middleware
│   │   │   ├── metrics_test.go # Tests for metrics middleware
│   │   │   ├── rate_limit.go  # Rate limiting middleware
│   │   │   └── rate_limit_test.go # Tests for rate limit middleware
│   │   ├── router.go          # HTTP router setup
│   │   ├── router_test.go     # Tests for router
│   │   ├── server.go          # HTTP server setup
│   │   └── server_test.go     # Tests for server
├── service/                   
│   ├── api.go                 # API service builder
│   ├── api_test.go            # Tests for API service
│   ├── cleaner.go             # Cleaner service builder
│   └── cleaner_test.go        # Tests for cleaner service
├── sql/                       
│   ├── 000001_create_users_table.up.sql     # Create users table
│   ├── 000001_create_users_table.down.sql   # Drop users table
│   ├── 000002_create_tokens_table.up.sql    # Create tokens table
│   ├── 000002_create_tokens_table.down.sql  # Drop tokens table
│   ├── 000003_create_urls_table.up.sql      # Create URLs table
│   ├── 000003_create_urls_table.down.sql    # Drop URLs table
│   ├── 000004_create_url_stats_table.up.sql # Create URL stats table
│   └── 000004_create_url_stats_table.down.sql # Drop URL stats table
├── docker/                    
│   ├── api/                   
│   │   └── Dockerfile         # Dockerfile for API service
│   └── cleaner/               
│       └── Dockerfile         # Dockerfile for cleaner service
├── helm/                      
│   └── link-shortener/        
│       ├── Chart.yaml         # Chart metadata
│       ├── values.yaml        # Default values
│       ├── values-dev.yaml    # Development values
│       ├── values-prod.yaml   # Production values
│       └── templates/         
│           ├── deployment-api.yaml      # API deployment
│           ├── deployment-cleaner.yaml  # Cleaner deployment
│           ├── service.yaml             # Service definition
│           ├── ingress.yaml             # Ingress configuration
│           ├── configmap.yaml           # ConfigMap for configuration
│           ├── secret.yaml              # Secrets for sensitive data
│           └── hpa.yaml                 # Horizontal Pod Autoscaler
├── .github/                   
│   └── workflows/             
│       ├── ci.yml             # CI workflow
│       └── cd.yml             # CD workflow
├── web/                       # Frontend application (Flutter Web)
│   ├── lib/                   # Dart code
│   │   ├── main.dart          # Entry point
│   │   ├── models/            # Data models
│   │   ├── screens/           # UI screens
│   │   ├── widgets/           # Reusable widgets
│   │   ├── services/          # API services
│   │   └── blocs/             # BLoC state management
│   ├── pubspec.yaml           # Flutter dependencies
│   └── test/                  # Flutter tests
├── docs/                      
│   ├── implementation_guide.md  # Implementation guidelines
│   ├── technical_decisions.md   # Technical decisions documentation
│   ├── go-code-style.md         # Go code style guide
│   └── api.md                   # API documentation
├── go.mod                     # Go module definition
├── go.sum                     # Go module checksums
└── README.md                  # Project README
```

This expanded structure provides a more realistic view of what the project will look like when fully implemented, with each domain concept, command, query, and adapter having its own file, along with corresponding test files following Go's convention of placing tests alongside the code they test.

## Domain-Driven Design Principles

### Ubiquitous Language

- Use consistent terminology across code, documentation, and team communication
- Domain entities should reflect business concepts, not technical implementations
- Avoid technical jargon in domain layer

### Bounded Contexts

- Clearly define boundaries between different domains (e.g., link, user)
- Each bounded context has its own models and interfaces
- Contexts communicate through well-defined interfaces

### Entities and Value Objects

- **Entities**: Objects with identity (e.g., Link, User)
- **Value Objects**: Immutable objects without identity (e.g., URL, TTL)
- Use value objects for concepts that don't need identity

### Aggregates

- Group related entities and value objects
- Define clear aggregate roots that serve as entry points
- Enforce invariants within aggregates

## Coding Standards

We follow the Go code style guidelines defined in [go-code-style.md](go-code-style.md). Key points include:

### General Principles

- Prioritize readability and maintainability
- Follow Go's standard conventions
- Keep functions and methods small and focused
- Use meaningful names for variables, functions, and types

### Naming Conventions

- Use `CamelCase` for exported names and `camelCase` for non-exported names
- Use descriptive, meaningful names
- Avoid abbreviations unless they're widely understood

### Struct Initialization

- Use `&{}` instead of `new()`
- Example:
  ```go
  // Preferred
  user := &User{}
  
  // Avoid
  user := new(User)
  ```

### Public vs. Private Structures

- Make default-friendly structures public
- Make non-default-friendly structures private with public constructors
- Example:
  ```go
  // Public, default-friendly structure
  type DefaultFriendlyStruct struct {
      Something SomeInterface
  }
  
  // Private, non-default-friendly structure with public constructor
  type Doer interface {
      Do()
  }
  
  type notDefaultFriendlyStruct struct {
      something SomeInterface
  }
  
  func NewDoer(something SomeInterface) Doer {
      return &notDefaultFriendlyStruct{
          something: something,
      }
  }
  ```

## Error Handling

### Error Wrapping

- Always wrap errors with context using `fmt.Errorf()`
- Use the `%w` verb to allow unwrapping
- Example:
  ```go
  if err := verify(user); err != nil {
      return fmt.Errorf("user verification: %w", err)
  }
  ```

### Error Naming

- Use `err` for boilerplate error handling
- Use descriptive names for errors that need further processing
- Example:
  ```go
  _, doErr := doSomething(tx)
  if doErr != nil {
      if rollbackErr := tx.Rollback(ctx); rollbackErr != nil {
          return fmt.Errorf("%w: %v", doErr, rollbackErr)
      }
      return fmt.Errorf("do something: %w", doErr)
  }
  ```

### Error Grouping

- Group public API errors in one place
- Place private errors near the functions that return them

## Testing Strategy

### Unit Testing

- Test all application layer code
- Use table-driven tests with descriptive names
- Example:
  ```go
  tests := []struct {
      name    string
      args    args
      wantErr bool
  }{
      {
          name: "Return error if password is too short",
          args: args{
              password: "pwd",
          },
          wantErr: true,
      },
  }
  ```

### Integration Testing

- Test adapter implementations against real or containerized dependencies
- Focus on boundary behaviors

### Test Helpers

- Create helper functions for common test setup
- Name helper functions descriptively

## Database Practices

### Schema Naming

- Always specify schema name in SQL queries
- Example:
  ```go
  const selectFromTable = `SELECT * FROM schema_name.table_name;`
  ```

### Migrations

- Use versioned migrations in the `sql/` directory
- Each migration should be reversible when possible
- Use `golang-migrate` for migration management

### Query Organization

- Keep SQL queries close to their usage
- Use constants for query strings
- Consider using a query builder for complex queries

## API Design

### RESTful Principles

- Use appropriate HTTP methods (GET, POST, PUT, DELETE)
- Use meaningful resource paths
- Return appropriate status codes

### Endpoint Structure

- URL Redirection: `GET /:url_hash`
- URL Management:
  - `POST /api/restricted_urls` - Create URL for anonymous users
  - `POST /api/urls` - Create URL for authenticated users
  - `GET /api/urls` - List URLs for authenticated users
  - `GET /api/urls/:url_hash/analytics` - Get URL analytics
  - `PUT /api/urls/:url_hash` - Update URL TTL
  - `DELETE /api/urls/:url_hash` - Delete URL
- User Management:
  - `GET /api/user/profile` - Get user profile
- Authentication:
  - `GET /api/auth/:provider` - Initiate OAuth flow
  - `GET /api/auth/:provider/callback` - OAuth callback
  - `POST /api/auth/logout` - Log out

### Request/Response Format

- Use JSON for request and response bodies
- Include appropriate error messages in responses
- Use consistent response structures

## Authentication

### OAuth Integration

- Support Google, Apple, and GitHub OAuth providers
- Implement proper stateful session-based authorization
- Store only necessary user information

### Session Management

- Use secure, HTTP-only cookies for session tokens
- Implement proper session expiration
- Consider Redis for session storage

## Frontend Implementation

### Flutter Web

- Use Flutter Web for frontend development
- Follow Material Design principles
- Implement responsive design for all device sizes

### State Management

- Use BLoC pattern for state management
- Keep UI components stateless when possible
- Separate business logic from UI

## Deployment Considerations

### Containerization

- Use Docker for containerization
- Create separate containers for API and cleaner services
- Use multi-stage builds to minimize image size

### Kubernetes Deployment

- Deploy to Kubernetes cluster
- Use Kubernetes secrets for sensitive configuration
- Implement health checks and readiness probes

### Monitoring

- Set up Prometheus for metrics collection
- Use Grafana for visualization
- Implement RED metrics (Rate, Errors, Duration) for all endpoints

---

This guide is a living document and should be updated as the project evolves and new patterns or best practices are identified. 