The `src` folder of https://github.com/ianmackenzie/elm-geometry-linear-algebra-interop at version 2.0.1 (commit 413c274f22abc6592bd02b61abed7f6cbd25f742).

It is vendored instead of used as a package because its types are opaque, and Lamdera's wire check
rejects opaque package types in `FrontendModel` and `FrontendMsg`. elm-geometry-linear-algebra-interop
and elm-3d-camera depend on elm-geometry, so they are vendored too.
