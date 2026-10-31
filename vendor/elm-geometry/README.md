The `src` folder of https://github.com/ianmackenzie/elm-geometry at version 3.1.0 (commit 778d91cc4fb1d87541aafe303f7bb10e5306d6a5), without the test helpers (`Geometry/Test.elm`, `Geometry/Fuzz.elm`, `Geometry/Expect.elm`, `Geometry/Examples/`) and `Polygon2d/Random.elm`.

It is vendored instead of used as a package because its types are opaque, and Lamdera's wire check
rejects opaque package types in `FrontendModel` and `FrontendMsg`. elm-geometry-linear-algebra-interop
and elm-3d-camera depend on elm-geometry, so they are vendored too.
