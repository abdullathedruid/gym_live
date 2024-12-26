const sw = self;
const config = {
  debug: false,
}

const { debug } = config;

sw.addEventListener('install', handleInstall);

function handleInstall(event) {
  debug && console.log('[Service Worker] Installed.');
}

sw.addEventListener('fetch', handleFetch);

function handleFetch(event) {
  // Ignore non-GET requests
  if (event.request.method.toUpperCase() !== 'GET') { return; }

  // Ignore requests from Chrome extensions
  if (event.request.url.startsWith("chrome-extension://")) { return; }
  
  const url = new URL(event.request.url);
  // Ignore LiveReloader - only requested in dev
  if (url.pathname === "/phoenix/live_reload/frame") { return; }

  debug && console.log('[Service Worker] Handling fetch:', event.request.url);
  event.respondWith(fetch(event.request));
}
