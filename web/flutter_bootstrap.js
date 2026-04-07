{{flutter_js}}
{{flutter_build_config}}

// iPhone has a hard ~256MB WebGL memory limit. CanvasKit (which uses WebGL)
// frequently exceeds this on content-heavy screens and causes a silent GPU
// context loss that produces a blank white screen. The HTML renderer avoids
// WebGL entirely and is the only reliable option for iPhone browsers.
// iPad and macOS Safari have much higher memory ceilings so they can use
// CanvasKit safely without any performance degradation.
const userAgent = navigator.userAgent;
const isIPhone = /iPhone|iPod/.test(userAgent) && !window.MSStream;
const isIPad = /iPad/.test(userAgent) ||
  // iPadOS 13+ reports itself as Macintosh — detect by touch support.
  (/Macintosh/.test(userAgent) && navigator.maxTouchPoints > 1);

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    let engineConfig = {};

    if (isIPhone) {
      // HTML renderer: no WebGL, low memory footprint — required for iPhone.
      engineConfig = { renderer: 'html' };
    } else if (isIPad) {
      // CanvasKit on iPad: more memory available, better visual quality.
      engineConfig = { renderer: 'canvaskit' };
    }
    // Desktop (macOS, Windows, Linux) and Android: use Flutter's default
    // auto-detection — no config needed, full performance preserved.

    const appRunner = await engineInitializer.initializeEngine(engineConfig);
    await appRunner.runApp();
  },
});