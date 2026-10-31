The `src` folder of https://github.com/ianmackenzie/elm-3d-camera at version 2.0.2 (commit 82b792ea8df273e3b8a7507dd9a63442533bccc7).

It is vendored instead of used as a package because its types are opaque, and Lamdera's wire check
rejects opaque package types in `FrontendModel` and `FrontendMsg`. elm-geometry-linear-algebra-interop
and elm-3d-camera depend on elm-geometry, so they are vendored too.
