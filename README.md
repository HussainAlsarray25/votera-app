# votera

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Web Deployment With Docker Compose

This repository includes a production-oriented setup to build and serve the
Flutter web app using Docker and Nginx.

### Build and run

```bash
docker compose up -d --build
```

Then open: `http://localhost:8080`

### Stop

```bash
docker compose down
```

### Notes

- The image is multi-stage: Flutter build in `Dockerfile`, static serving in Nginx.
- Deep links are supported via SPA fallback in `nginx.conf` (`try_files ... /index.html`).
- Current app API host is configured in `lib/core/config/app_config.dart`.
- If you deploy under a sub-path (for example `/votera/`), set `FLUTTER_BASE_HREF`
	in `docker-compose.yml` to `/votera/` and ensure your reverse proxy uses the same path.
