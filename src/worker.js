const cacheName = 'tracktask.io';
const filesToCache = [
	'../',
	'../index.html',
	'../dist/index.js',
];

self.addEventListener('install', evt => {
	console.log('[ServiceWorker] Install', caches);
	evt.waitUntil(
		caches.open(cacheName).then(cache => {
			console.log('[ServiceWorker] Caching app shell');
			return cache.addAll(filesToCache);
		}),
	);
});

self.addEventListener('activate', evt => {
	event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', evt => {
	evt.respondWith(
		caches.match(evt.request)
		.then(response => {
			return response || fetch(evt.request);
		}),
	);
});
