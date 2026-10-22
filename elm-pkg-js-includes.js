// Lamdera runs these with the app once it starts, to hook up its ports.
// See https://github.com/lamdera/elm-pkg-js

const minimapWorker = require('./elm-pkg-js/minimap-worker')

exports.init = async function init(app) {
  minimapWorker.init(app)
}
