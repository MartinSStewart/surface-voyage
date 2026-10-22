# surface-voyage

Built with [Lamdera](https://dashboard.lamdera.app/docs/download).

Run `lamdera live` and open http://localhost:8000. The game itself lives in `src/Main.elm`; `src/Frontend.elm` just hosts it, and the backend does nothing yet.

The minimap is worked out in a web worker so the game doesn't stutter while it does (see `src/MinimapWorker.elm`). Lamdera doesn't build the worker, so after changing anything it uses (`Minimap`, `Surface`, `Shapes`, `MeshData`, ...) rebuild it and commit the result:

    lamdera make src/MinimapWorker.elm --optimize --output=public/minimap-worker-elm.js
