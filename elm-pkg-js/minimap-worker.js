// Works out what the minimap shows in a web worker (public/minimap-worker.js), so that the game keeps
// drawing frames while it does. The game asks for one drawing at a time.

exports.init = async function init(app) {
  const worker = new Worker('/minimap-worker.js')
  worker.onmessage = (event) => app.ports.minimapDrawn.send(event.data)
  app.ports.drawMinimap.subscribe((point) => worker.postMessage(point))
}
