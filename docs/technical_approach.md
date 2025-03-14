# Link Shortener - Technical Approach

## System Architecture

### Overview
The Link Shortener application will follow a modern web application architecture with separate frontend and backend components:

1. **Frontend**: Single-page application built with Dart
2. **Backend**: API service (REST or gRPC depending on gRPC-web compatibility)
3. **Database**: PostgreSQL for users, links, and analytics with potential migration to ClickHouse for high load
4. **Authentication**: Integration with third-party OAuth providers

### Architecture Diagram
```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│             │      │             │      │  OAuth      │
│  Frontend   │<────>│  Backend    │<────>│  Providers  │
│  (Dart)     │      │  (Go)       │      │             │
└─────────────┘      └─────────────┘      └─────────────┘
                           ^
                           │
                           v
                    ┌─────────────┐
                    │             │
                    │  PostgreSQL │
                    │             │
                    └─────────────┘
```

## Technology Stack

### Frontend
- **Framework**: Flutter Web or AngularDart
- **State Management**: Provider or Bloc pattern
- **Styling**: Material Design or custom theme
- **HTTP Client**: Dart http package or dio
- **Testing**: Dart test package

### Backend
- **Language**: Go
- **API**: REST API (with potential for gRPC if gRPC-web compatibility is confirmed)
- **Authentication**: session-based, stateful
- **OAuth**: Integration with Google, Apple, and GitHub
- **URL Shortening**: Sqids (https://sqids.org/go) for ID to hash conversion
- **Validation**: Custom validators for URL format

### Database
- **Primary Database**: PostgreSQL
- **High-Load Solution**: Potential migration to ClickHouse for analytics
- **Migrations**: golang-migrate

### DevOps
- **Containerization**: Docker
- **CI/CD**: GitHub Actions
- **Hosting**: Self-hosted Kubernetes
- **Monitoring**: Prometheus and Grafana

## Database Schema

### Tables

#### Users
```
users
├── id (BIGINT, PK, NOT NULL)
├── name (String, NOT NULL)
├── created_at (Timestamp, NOT NULL)
├── updated_at (Timestamp, NOT NULL)
├── deleted (Boolean, NOT NULL)
```

#### User Sessions
```
user_sessions
├── user_id (BIGINT, FK to users.id, NOT NULL)
├── token (String, NOT NULL)
├── expires_at (Timestamp, NOT NULL)
├── created_at (Timestamp, NOT NULL)
├── updated_at (Timestamp, NOT NULL)
├── deleted (Boolean, NOT NULL)
```

#### User Authentication
```
user_sessions
├── user_id (BIGINT, FK to users.id, NOT NULL)
├── [columns for auth provider data] (NOT NULL)
├── created_at (Timestamp, NOT NULL)
├── updated_at (Timestamp, NOT NULL)
├── deleted (Boolean, NOT NULL)
```

#### URLs
```
urls
├── id (BIGINT, PK, NOT NULL)
├── user_id (BIGINT, FK to users.id, NOT NULL)
├── redirect_to_url (String, NOT NULL)
├── expires_type (SMALLINT, NOT NULL) // Code for 3m, 6m, 12m, unlimited
├── expires_at (Timestamp, nullable)
├── created_at (Timestamp, NOT NULL)
├── updated_at (Timestamp, NOT NULL)
├── deleted (Boolean, NOT NULL)
```

#### URL Stats (Visit Facts)
```
url_stats
├── url_id (BIGINT, FK to urls.id, NOT NULL)
├── user_agent (String, NOT NULL)
├── visited_at (Timestamp, NOT NULL)
├── created_at (Timestamp, NOT NULL)
├── deleted (Boolean, NOT NULL)
```
*Note: This table will be partitioned by url_id*

## Key Implementation Details

### Anonymous User Handling
- Create a special "anonymous" user in the system
- Attach all non-authenticated user links to this anonymous user
- Apply standard 3-month TTL to all links created by the anonymous user

### URL Shortening Algorithm
- Use Sqids (https://sqids.org/go) for converting numeric IDs to short hashes
- The URL format will be: https://[app domain]/[sqids hash]
- This provides short, URL-safe identifiers without exposing sequential IDs

### URL Validation
1. Check for valid HTTP/HTTPS schema
2. Validate hostname and path structure
3. Ensure the URL is properly formatted and reachable

### TTL Management
1. Store expiration type as a code (SMALLINT):
   - 1: 3 months
   - 2: 6 months
   - 3: 12 months
   - 4: No expiration (unlimited)
2. Calculate and store the actual expiration timestamp based on creation date and TTL type
3. Run a scheduled job to mark expired links as deleted
4. Check expiration on redirect and return 404 if expired

## API Endpoints

### URL Redirection
- `GET /:url_hash` - Redirect to the original URL

### URL Management
- `POST /api/restricted_urls` - Create a new shortened URL (for NON authenticated users)
- `POST /api/urls` - Create a new shortened URL (for authenticated users)
- `GET /api/urls` - List URLs (for authenticated users)
- `GET /api/urls/:url_hash/analytics` (for authenticated users)
- `PUT /api/urls` - Update URL TTL (for authenticated users)
- `DELETE /api/urls` - Delete a URL (for authenticated users)

### User Management
- `GET /api/user/profile` - Get user profile (for authenticated users)

### Authentication
- `GET /api/auth/:provider` - Initiate OAuth flow with provider
- `GET /api/auth/:provider/callback` - OAuth callback endpoint
- `POST /api/auth/logout` - Log out the current user

## Security Considerations

### Authentication
- Use industry-standard OAuth flows
- Implement proper stateful session-based authorization
- Store only necessary user information

### Data Protection
- Sanitize and validate all user inputs
- Implement rate limiting for URL creation and redirection
- Use HTTPS for all communications

## Performance Optimization

### Clean deleted rows
- Daemon which is going to delete rows where deleted is true
- Configure auto vacuum

### Database Optimization
- Partitioning for url_stats table based on url_id
- Indexes on frequently queried columns
- Regular database maintenance

## Testing Strategy

### Unit Testing
- Test all application layer of app

## Deployment and Operations

### Deployment Pipeline
1. Build and test in CI environment
3. Run automated tests

### Monitoring
- RED metrics for every endpoint
- Set up alerts for error rates and latency
