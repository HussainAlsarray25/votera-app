{{flutter_js}}
{{flutter_build_config}}

// Detect iOS devices. All iOS browsers (Safari, Chrome, Firefox) use WebKit,
// which has strict memory limits and limited WASM threading support.
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine(
      // On iOS: force canvaskit (JS-based). This avoids skwasm's WASM
      // threading which requires COOP/COEP headers that break Firebase auth.
      // On desktop and Android: pass no config and let Flutter auto-detect
      // the best renderer — no performance degradation on those platforms.
      isIOS ? { renderer: 'canvaskit' } : {},
    );
    await appRunner.runApp();
  },
});