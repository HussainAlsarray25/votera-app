{{flutter_js}}
{{flutter_build_config}}

// Detect iOS — all iOS browsers (Safari, Chrome, Firefox) use WebKit.
// iPadOS 13+ reports itself as Macintosh, so check touch support as well.
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
  (/Macintosh/.test(navigator.userAgent) && navigator.maxTouchPoints > 1);

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine(
        isIOS
          ? {
              renderer: 'canvaskit',
              // iOS Safari WebGL does not support the WEBGL_polygon_mode
              // extension that CanvasKit requires. Forcing CPU-only rendering
              // bypasses WebGL entirely, eliminating the extension error and
              // the associated white screen crash on all iPhone/iPad browsers.
              canvasKitForceCpuOnly: true,
            }
          : {},
      );
      await appRunner.runApp();
    } catch (e) {
      // Fallback: if the engine config fails for any reason, retry with
      // defaults so the app still loads rather than showing a white screen.
      console.warn('Engine init with config failed, retrying with defaults:', e);
      const appRunner = await engineInitializer.initializeEngine({});
      await appRunner.runApp();
    }
  },
});