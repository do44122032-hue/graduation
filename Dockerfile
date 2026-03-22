# Stage 1: Build the Flutter web app
FROM ubuntu:22.04 AS build-env

# Install dependencies needed by Flutter
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Download and Setup Flutter SDK (stable branch)
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Clear out any old doctor issues just to be safe
RUN flutter doctor -v

# Copy source code to the container
WORKDIR /app
COPY . .

# Fetch dependencies
RUN flutter pub get

# Build the Web Application
RUN flutter build web

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy the generated web files from the build environment
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Replace the default nginx configuration with our own
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
