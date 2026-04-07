FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Resolve dependencies first to maximize Docker layer caching.
COPY pubspec.* ./
RUN flutter pub get

# Copy project and build web artifacts.
COPY . .
ARG FLUTTER_BASE_HREF=/
# Use canvaskit renderer for broad browser compatibility, including iOS Safari.
# canvaskit is JS-based (no WASM threads) so it does not require COOP/COEP headers,
# which would otherwise break Firebase auth popups on all platforms.
RUN flutter build web --release --base-href ${FLUTTER_BASE_HREF} --web-renderer canvaskit

# At container start, export the compiled artifacts into the shared dist volume
# so the separate nginx service can pick them up without re-building.
CMD ["sh", "-c", "cp -r /app/build/web/. /dist/"]

FROM nginx:1.27-alpine AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]