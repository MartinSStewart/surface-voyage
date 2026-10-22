// The web worker that works out what the minimap shows (see elm-pkg-js/minimap-worker.js).
// minimap-worker-elm.js is compiled from src/MinimapWorker.elm:
//
//     lamdera make src/MinimapWorker.elm --optimize --output=public/minimap-worker-elm.js

importScripts('/minimap-worker-elm.js')

const app = Elm.MinimapWorker.init()
self.onmessage = (event) => app.ports.drawMinimap.send(event.data)
app.ports.minimapDrawn.subscribe((drawing) => self.postMessage(drawing))
