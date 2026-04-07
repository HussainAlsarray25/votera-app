{{flutter_js}}
{{flutter_build_config}}

// Detect iOS — all iOS browsers (Safari, Chrome, Firefox) use WebKit.
// iPadOS 13+ reports itself as Macintosh, so check touch support as well.
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
  (/Macintosh/.test(navigator.userAgent) && navigator.maxTouchPoints > 1);

// canvasKitForceCpuOnly and other CanvasKit options MUST be passed in the
// top-level "config" object of _flutter.loader.load() — NOT inside
// initializeEngine(). Passing them to initializeEngine() silently ignores them.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  config: isIOS
    ? {
        // iOS Safari WebGL is missing required extensions (e.g. WEBGL_polygon_mode).
        // Forcing CPU-only rendering bypasses WebGL entirely, eliminating the
        // extension errors and the resulting blank white screen on iPhone/iPad.
        canvasKitForceCpuOnly: true,
      }
    : {},
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  },
});