{{flutter_js}}
{{flutter_build_config}}

// All iOS browsers (Safari, Chrome, Firefox) use WebKit. Explicitly select
// the canvaskit renderer on iOS to avoid skwasm's WASM threading requirements,
// which need COOP/COEP headers that break Firebase auth popups.
// Desktop and Android receive no renderer config — Flutter auto-detects best.
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
  // iPadOS 13+ reports itself as Macintosh — detect by touch support.
  (/Macintosh/.test(navigator.userAgent) && navigator.maxTouchPoints > 1);

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine(
        isIOS ? { renderer: 'canvaskit' } : {},
      );
      await appRunner.runApp();
    } catch (e) {
      // Fallback: if renderer config fails (e.g. option removed in a future
      // Flutter version), retry with default engine settings so the app still
      // loads rather than staying on a blank white screen.
      console.warn('Engine init with config failed, retrying with defaults:', e);
      const appRunner = await engineInitializer.initializeEngine({});
      await appRunner.runApp();
    }
  },
});
