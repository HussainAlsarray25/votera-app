FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Resolve dependencies first to maximize Docker layer caching.
COPY pubspec.* ./
RUN flutter pub get

# Copy project and build web artifacts.
COPY . .
ARG FLUTTER_BASE_HREF=/
# --no-web-resources-cdn bundles CanvasKit (the rendering engine WASM) locally
# instead of fetching it from Google's CDN (gstatic.com) at runtime.
# On iPhone, iOS ITP, content blockers, and Low Data Mode aggressively block
# or throttle third-party CDN requests at the network level, causing the app
# to show a permanent white screen before Flutter even starts. Bundling
# CanvasKit locally eliminates this CDN dependency entirely.
# Confirmed fix for Flutter issues #83076 and #148713.
RUN flutter build web --release --base-href ${FLUTTER_BASE_HREF} --no-web-resources-cdn

# At container start, export the compiled artifacts into the shared dist volume
# so the separate nginx service can pick them up without re-building.
CMD ["sh", "-c", "cp -r /app/build/web/. /dist/"]

FROM nginx:1.27-alpine AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]