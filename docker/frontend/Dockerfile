# Build stage
FROM dart:stable AS builder

WORKDIR /app

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy pubspec files
COPY web/pubspec.yaml web/pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application
COPY web .

# Build the application
RUN flutter build web --release

# Serve stage
FROM nginx:alpine

# Copy the build output to nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 