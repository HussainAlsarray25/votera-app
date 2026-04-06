# Votera Web — Deployment Guide

## Overview

The web deployment pipeline has three layers that work together:

```
Source code  →  CI builds Docker image  →  Registry stores it  →  Server runs it
(GitHub)         (GitHub Actions)           (ghcr.io)               (Docker + nginx)
```

Every push to the `web` branch triggers the pipeline automatically. The server never compiles code — it only pulls and runs a pre-built image.

---

## File Map

| File | Purpose |
|---|---|
| `Dockerfile` | Defines how the image is built (two stages: builder and runtime) |
| `docker-compose.yml` | Tells the server which image to run and how |
| `nginx.conf` | Configures the web server inside the container |
| `.dockerignore` | Prevents unnecessary files from entering the Docker build context |
| `.github/workflows/deploy-web.yml` | The CI pipeline that builds and deploys on every push |
| `.env.example` | Template for the `.env` file that lives only on the server |

---

## How the Dockerfile Works

The Dockerfile has two named stages.

### Stage 1 — `builder`

```
Base image: ghcr.io/cirruslabs/flutter:stable
```

1. Copies `pubspec.yaml` and `pubspec.lock` and runs `flutter pub get`.
   This step is cached by Docker. If the lock file did not change, this layer
   is reused on the next build — saving several minutes.
2. Copies the rest of the source code.
3. Runs `flutter build web --release`. This compiles the Dart code to
   JavaScript and produces static files under `build/web/`.

### Stage 2 — `runtime`

```
Base image: nginx:1.27-alpine
```

1. Copies `nginx.conf` into the nginx configuration directory.
2. Copies the compiled `build/web/` directory from the builder stage directly
   into the nginx html root.
3. Exposes port 80 and starts nginx.

The runtime stage is a self-contained image. It has no dependency on Flutter,
no build tools, and no source code — only the compiled static files and nginx.
This is the image that gets pushed to the registry and run on the server.

---

## How the CI Pipeline Works

File: `.github/workflows/deploy-web.yml`

The pipeline runs on every push to the `web` branch. It has two sequential jobs.

### Job 1 — `build`

Runs on GitHub's servers.

1. Checks out the code.
2. Logs into GitHub Container Registry (`ghcr.io`) using the built-in
   `GITHUB_TOKEN`. No extra secret is needed for pushing.
3. Sets up Docker Buildx, which enables advanced layer caching.
4. Builds the `runtime` stage of the Dockerfile and pushes two tags:
   - `ghcr.io/<owner>/votera-app:latest` — always points to the newest build
   - `ghcr.io/<owner>/votera-app:sha-<commit>` — permanent record of each build
5. The build cache is stored in GitHub Actions cache. On the next push,
   Docker reuses cached layers. If only Dart files changed, the
   `flutter pub get` layer is skipped entirely.

### Job 2 — `deploy`

Runs only after Job 1 succeeds.

1. SSHs into the server using the credentials in GitHub Secrets.
2. Forwards the workflow's own `GITHUB_TOKEN` to the server as `GH_TOKEN`.
   This token is ephemeral — it expires when the workflow ends — so no
   credentials are left on the server. No stored PAT is needed.
3. Logs into ghcr.io on the server using that token, pulls the new image,
   and immediately logs out.
4. Runs `docker compose up -d --force-recreate votera-web` to swap the
   running container with the new one.

The downtime during the container swap is approximately one second. The pull
step itself has no downtime — the old container continues serving while the
new image downloads.

---

## How nginx Works

File: `nginx.conf`

nginx serves the Flutter web app as a Single Page Application (SPA).

**Routing:**
All URLs that do not match a real file fall back to `index.html`. This is
required because go_router handles navigation inside the app — the server
does not know about those routes.

**Caching strategy:**

| Resource | Cache behaviour | Reason |
|---|---|---|
| `index.html` | Never cached | Must always be fresh so the browser picks up new builds |
| `flutter_service_worker.js` | Never cached | Service worker must update immediately |
| `/assets/*` | Cached for 1 year | Flutter gives these files content-hashed names, so old URLs never collide with new content |

**Compression:**
Gzip is enabled for JavaScript, CSS, JSON, WASM, and SVG. The `gzip_proxied any`
directive ensures compression applies even when nginx sits behind another
reverse proxy (the main server nginx).

**Content Security Policy:**
A CSP header permits the Firebase SDK (which uses inline scripts) while
blocking other inline code and unauthorized external sources. If new external
services are added, the CSP `connect-src` directive must be updated.

---

## How docker-compose Works on the Server

File: `docker-compose.yml`

The server-side compose is intentionally minimal. It does no building.

```yaml
services:
  votera-web:
    image: ghcr.io/<owner>/votera-app:latest
    container_name: votera-web
    restart: unless-stopped
    networks:
      - votera_network

networks:
  votera_network:
    external: true
```

- `image` — pulls from the registry instead of building locally.
- `networks` — joins the existing `votera_network` Docker network so the
  main nginx can reach this container by name (`votera-web`).
- `restart: unless-stopped` — the container restarts automatically after
  a server reboot or crash. No port is exposed to the host — traffic arrives
  only from the main nginx through the shared network.

The `GHCR_OWNER` variable in the image name is read from the `.env` file
on the server.

---

## How the Main nginx Routes to This Container

File: `D:\8th course\votera-app\nginx.conf`

The main nginx has a server block for `app.votera.space` that proxies to
`votera-web:80`. Both containers share `votera_network`, so Docker's internal
DNS resolves the container name with no IP address or port mapping needed.

```nginx
server {
    listen 443 ssl;
    server_name app.votera.space;

    location / {
        resolver 127.0.0.11 valid=30s;
        set $upstream http://votera-web:80;
        proxy_pass $upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        # ...
    }
}
```

The `resolver 127.0.0.11 valid=30s` + variable pattern means the main nginx
starts cleanly even if `votera-web` is not running yet. Without this, nginx
would refuse to start if the upstream hostname cannot be resolved at startup.

SSL is terminated by the main nginx. The votera-web container itself runs
plain HTTP internally.

---

## Traffic Flow

```
User browser
    │  HTTPS  app.votera.space:443
    ▼
Main nginx container  (votera_network)
    │  HTTP  votera-web:80
    ▼
votera-web container  (nginx serving Flutter SPA)
    │
    └── index.html + compiled JS/WASM assets
```

---

## GitHub Configuration

### Secrets

Go to: repository → Settings → Secrets and variables → Actions → New repository secret

| Secret | Value | Notes |
|---|---|---|
| `SERVER_HOST` | IP address or hostname of the server | |
| `SERVER_USER` | SSH username on the server | e.g. `ubuntu`, `deploy` |
| `SERVER_SSH_KEY` | Private SSH key (PEM format, starts with `-----BEGIN`) | The matching public key must be in `~/.ssh/authorized_keys` on the server |
| `SERVER_APP_PATH` | Absolute path to the cloned repo on the server | e.g. `/opt/votera-app` |

`GITHUB_TOKEN` does **not** need to be added. It is provided automatically by
GitHub Actions and is used by both jobs — to push the image in Job 1, and to
pull it on the server in Job 2. No Personal Access Token is needed.

### Workflow Permissions

The workflow already declares the correct permissions per job:

- `build` job: `packages: write` — allows pushing to ghcr.io
- `deploy` job: `packages: read` — allows the forwarded token to pull from ghcr.io

These are set in the workflow file. No manual changes are needed in repository settings
unless your organization has disabled token permissions entirely (check under
Settings → Actions → General → Workflow permissions — it should be set to
"Read and write permissions" or at minimum allow workflows to set permissions).

### Container Registry (ghcr.io) Visibility

When the first CI run pushes the image, it is created as **private** by default.

The deploy job uses the workflow's own token to pull, so this works without any
additional setup. However, you can optionally make the package public so the server
can pull without any authentication at all:

1. Go to your GitHub profile → Packages → `votera-app`
2. Package settings → Change visibility → Public

If you make it public, the `docker login` and `docker logout` steps in the deploy
job become unnecessary (but they do not hurt anything if left in place).

### Branch Protection (Recommended)

To prevent broken code from reaching production, protect the `web` branch:

1. Repository → Settings → Branches → Add rule
2. Branch name pattern: `web`
3. Enable: "Require status checks to pass before merging"
4. Add the `Build and push Docker image` job as a required check
5. Enable: "Require branches to be up to date before merging"

---

## First-Time Server Setup

These steps are done once before the first deployment.

```bash
# 1. Clone the repository on the server.
git clone <repo-url> /opt/votera-app
cd /opt/votera-app
git checkout web

# 2. Create the .env file from the template.
cp .env.example .env
# Edit .env and set GHCR_OWNER to your GitHub username (lowercase).
nano .env

# 3. Verify the votera_network exists (it is created by the main compose stack).
docker network ls | grep votera_network
```

After the first CI run pushes the image, bring the service up:

```bash
docker compose pull
docker compose up -d
```

To reload the main nginx after the server block for `app.votera.space` was added:

```bash
cd /path/to/votera-app   # the main stack folder
docker compose exec nginx nginx -s reload
```

---

## Deployment Flow Summary

```
Developer pushes to web branch
        │
        ▼
GitHub Actions starts
        │
        ├── Job 1: build  (packages: write)
        │     │
        │     ├── docker buildx builds Dockerfile (target: runtime)
        │     │    ├── Stage 1 (builder): flutter pub get + flutter build web
        │     │    └── Stage 2 (runtime): nginx + compiled static files
        │     │
        │     └── Pushes to ghcr.io/owner/votera-app:latest + :sha-<commit>
        │
        └── Job 2: deploy  (packages: read, runs after Job 1)
              │
              ├── SSH into server
              ├── docker login ghcr.io  (using ephemeral GITHUB_TOKEN)
              ├── docker compose pull votera-web
              ├── docker compose up -d --force-recreate votera-web  (~1 s downtime)
              └── docker logout ghcr.io
```

---

## Known Issues and Required Configuration

The items below are not yet complete. They will cause missing functionality or
broken behaviour on web if not addressed before going live.

### Critical — will break the app

| Issue | Location | What to do |
|---|---|---|
| Firebase Web credentials are wrong | `lib/firebase_options.dart` lines 44–50 | The `_web` block uses the Android `appId` (`1:...:android:...`). Register a Web app in Firebase Console → Project Settings → Add app → Web. Then run `flutterfire configure` or paste the web-specific values manually. |
| VAPID key not set for FCM on web | `lib/core/services/firebase_push_service.dart` line 49 | After registering the Firebase web app, get the VAPID key from Firebase Console → Cloud Messaging → Web Push certificates. Pass it as `_messaging.getToken(vapidKey: 'YOUR_KEY')`. |
| Firebase FCM service worker missing | `web/` directory | Create `web/firebase-messaging-sw.js` so the browser can receive background push notifications. Without it, foreground FCM works but background messages are silently dropped. |
| Backend CORS does not include web domain | `D:\8th course\votera-app\.env` line 37 | `FRONTEND_URL` is set to `https://votera.space`. Update it to `https://app.votera.space` (or extend it to allow both, depending on how the backend reads this variable). Restart the backend container after changing it. |
| DNS record missing | DNS provider | `app.votera.space` must have an A record pointing to the server's public IP. Without this, no traffic reaches the server. |

### Informational — works but with caveats

| Issue | Notes |
|---|---|
| `flutter_secure_storage` on web | Already guarded. On web it uses the browser's Web Crypto API with IndexedDB. Less secure than mobile Keychain/Keystore, but acceptable for tokens. |
| `flutter_local_notifications` on web | Already fully guarded with `kIsWeb` checks in `firebase_push_service.dart`. No changes needed. |
| Geolocator on web | Requires HTTPS (handled by main nginx) and a browser permission prompt. No code changes needed. |
| `share_plus` on web | Uses the Web Share API. Falls back gracefully in browsers that do not support it. |
| `app_links` deep links on web | go_router handles web URLs via the browser address bar. The nginx SPA fallback (`try_files`) already supports this. No additional setup needed. |
