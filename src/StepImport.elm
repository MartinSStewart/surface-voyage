module StepImport exposing (surface)

{-| Turn a STEP file (a solid exported from a CAD program) into a `Surface`.

Each face of the solid becomes a piece of the surface:

  - planes become flats, with their edges as lines and circular arcs
  - cylinders, cones, spheres and tori become features: their profile is an edge of the face that
    runs along the axis (or, for a full turn, the seam where the CAD program closed it up), and their
    sweep comes from an edge that runs around the axis

So a face can only have edges that are lines or circles, and the edges of a curved face have to run
either around its axis or along it. A face that doesn't is reported by its STEP id and what's wrong
with it. Fillets of the same radius where they meet give spheres and tori at the corners, which is
fine; a sharp edge between two fillets (a mitred corner) cuts a cylinder along an ellipse, which isn't.

Lengths are converted to meters from the file's length unit and then multiplied by `userScale`. CAD
programs have z up and the game has y up, so (x, y, z) in the file is (x, z, -y) in the game.

-}

import Angle
import Direction3d
import Frame3d
import Point2d
import Point3d
import Regex
import SketchPlane3d
import Step.Decode as Decode exposing (Decoder)
import Step.Types exposing (Entity)
import Surface exposing (FeatureSpec, FlatEdge(..), FlatSpec, ProfileSegment(..), Surface, Sweep(..))



---- WHAT'S READ FROM THE FILE ----


type alias Vec =
    { x : Float, y : Float, z : Float }


type alias Placement =
    { origin : Vec, axis : Maybe Vec, ref : Maybe Vec }


type Curve
    = LineCurve
    | CircleCurve { placement : Placement, radius : Float }


type alias Edge =
    { id : Int, start : Vec, end : Vec, curve : Curve, sameSense : Bool }


type alias Bound =
    { outer : Bool, sameSense : Bool, edges : List ( Edge, Bool ) }


type Geometry
    = Plane Placement
    | Cylinder Placement Float
    | Cone Placement Float Float
    | Sphere Placement Float
    | Torus Placement Float Float


type alias Face =
    { id : Int, bounds : List Bound, geometry : Geometry, sameSense : Bool }


point : Decoder Entity () Vec
point =
    Decode.simpleEntity2 (\( x, y, z ) -> { x = x, y = y, z = z })
        Decode.ignoreContext
        Decode.ignoreId
        "CARTESIAN_POINT"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.tuple3 Decode.float))


direction : Decoder Entity () Vec
direction =
    Decode.simpleEntity2 (\( x, y, z ) -> { x = x, y = y, z = z })
        Decode.ignoreContext
        Decode.ignoreId
        "DIRECTION"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.tuple3 Decode.float))


placement : Decoder Entity () Placement
placement =
    Decode.simpleEntity4 Placement
        Decode.ignoreContext
        Decode.ignoreId
        "AXIS2_PLACEMENT_3D"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.referenceTo point))
        (Decode.keep (Decode.optional (Decode.referenceTo direction)))
        (Decode.keep (Decode.optional (Decode.referenceTo direction)))


curve : Decoder Entity () Curve
curve =
    Decode.oneOf
        [ Decode.simpleEntity3 LineCurve
            Decode.ignoreContext
            Decode.ignoreId
            "LINE"
            (Decode.ignore Decode.string)
            (Decode.ignore Decode.referencedId)
            (Decode.ignore Decode.referencedId)
        , Decode.simpleEntity3 (\placement_ radius -> CircleCurve { placement = placement_, radius = radius })
            Decode.ignoreContext
            Decode.ignoreId
            "CIRCLE"
            (Decode.ignore Decode.string)
            (Decode.keep (Decode.referenceTo placement))
            (Decode.keep Decode.float)

        -- A curve on a surface (some programs write every edge like this): its 3D curve is what matters
        , surfaceCurve "SURFACE_CURVE"
        , surfaceCurve "SEAM_CURVE"
        ]


surfaceCurve : String -> Decoder Entity () Curve
surfaceCurve typeName =
    Decode.simpleEntity4 identity
        Decode.ignoreContext
        Decode.ignoreId
        typeName
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.referenceTo (Decode.lazy (\() -> curve))))
        (Decode.ignore (Decode.list Decode.referencedId))
        (Decode.ignore (Decode.enum [ ( "CURVE_3D", () ), ( "PCURVE_S1", () ), ( "PCURVE_S2", () ) ]))


vertex : Decoder Entity () Vec
vertex =
    Decode.simpleEntity2 identity
        Decode.ignoreContext
        Decode.ignoreId
        "VERTEX_POINT"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.referenceTo point))


edgeCurve : Decoder Entity () Edge
edgeCurve =
    Decode.simpleEntity5 Edge
        Decode.ignoreContext
        Decode.keepId
        "EDGE_CURVE"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.referenceTo vertex))
        (Decode.keep (Decode.referenceTo vertex))
        (Decode.keep (Decode.referenceTo curve))
        (Decode.keep Decode.bool)


orientedEdge : Decoder Entity () ( Edge, Bool )
orientedEdge =
    Decode.simpleEntity5 Tuple.pair
        Decode.ignoreContext
        Decode.ignoreId
        "ORIENTED_EDGE"
        (Decode.ignore Decode.string)
        (Decode.ignore (Decode.derivedValue ()))
        (Decode.ignore (Decode.derivedValue ()))
        (Decode.keep (Decode.referenceTo edgeCurve))
        (Decode.keep Decode.bool)


edgeLoop : Decoder Entity () (List ( Edge, Bool ))
edgeLoop =
    Decode.simpleEntity2 identity
        Decode.ignoreContext
        Decode.ignoreId
        "EDGE_LOOP"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.list (Decode.referenceTo orientedEdge)))


bound : Decoder Entity () Bound
bound =
    let
        ofType outer typeName =
            Decode.simpleEntity3 (\edges sameSense -> { outer = outer, sameSense = sameSense, edges = edges })
                Decode.ignoreContext
                Decode.ignoreId
                typeName
                (Decode.ignore Decode.string)
                (Decode.keep (Decode.referenceTo edgeLoop))
                (Decode.keep Decode.bool)
    in
    Decode.oneOf [ ofType True "FACE_OUTER_BOUND", ofType False "FACE_BOUND" ]


geometry : Decoder Entity () Geometry
geometry =
    Decode.oneOf
        [ Decode.simpleEntity2 Plane
            Decode.ignoreContext
            Decode.ignoreId
            "PLANE"
            (Decode.ignore Decode.string)
            (Decode.keep (Decode.referenceTo placement))
        , Decode.simpleEntity3 Cylinder
            Decode.ignoreContext
            Decode.ignoreId
            "CYLINDRICAL_SURFACE"
            (Decode.ignore Decode.string)
            (Decode.keep (Decode.referenceTo placement))
            (Decode.keep Decode.float)
        , Decode.simpleEntity4 Cone
            Decode.ignoreContext
            Decode.ignoreId
            "CONICAL_SURFACE"
            (Decode.ignore Decode.string)
            (Decode.keep (Decode.referenceTo placement))
            (Decode.keep Decode.float)
            (Decode.keep Decode.float)
        , Decode.simpleEntity3 Sphere
            Decode.ignoreContext
            Decode.ignoreId
            "SPHERICAL_SURFACE"
            (Decode.ignore Decode.string)
            (Decode.keep (Decode.referenceTo placement))
            (Decode.keep Decode.float)
        , Decode.simpleEntity4 Torus
            Decode.ignoreContext
            Decode.ignoreId
            "TOROIDAL_SURFACE"
            (Decode.ignore Decode.string)
            (Decode.keep (Decode.referenceTo placement))
            (Decode.keep Decode.float)
            (Decode.keep Decode.float)
        ]


face : Decoder Entity () Face
face =
    Decode.simpleEntity4 (\id bounds geometry_ sameSense -> { id = id, bounds = bounds, geometry = geometry_, sameSense = sameSense })
        Decode.ignoreContext
        Decode.keepId
        "ADVANCED_FACE"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.list (Decode.referenceTo bound)))
        (Decode.keep (Decode.referenceTo geometry))
        (Decode.keep Decode.bool)


shell : Decoder Entity () (List Face)
shell =
    Decode.simpleEntity2 identity
        Decode.ignoreContext
        Decode.ignoreId
        "CLOSED_SHELL"
        (Decode.ignore Decode.string)
        (Decode.keep (Decode.list (Decode.referenceTo face)))



---- READING THE FILE ----


surface : Float -> String -> Result String (Surface coordinates)
surface userScale text =
    case Decode.parse text of
        Ok file ->
            case Decode.all shell file () of
                Ok [ faces ] ->
                    let
                        units =
                            unitsOf text

                        convert =
                            { point = \p -> { x = p.x, y = p.z, z = -p.y } |> scale (units.length * userScale)
                            , direction = \d -> { x = d.x, y = d.z, z = -d.y }
                            , length = \l -> l * units.length * userScale
                            , angle = \a -> a * units.angle
                            }
                    in
                    faces
                        |> List.map (convertFace convert)
                        |> List.map (\face_ -> pieceOf face_ |> Result.mapError (\message -> "Face #" ++ String.fromInt face_.id ++ ": " ++ message))
                        |> combine
                        |> Result.andThen
                            (\pieces ->
                                Surface.build
                                    (List.filterMap
                                        (\piece ->
                                            case piece of
                                                FlatPiece flat ->
                                                    Just flat

                                                FeaturePiece _ ->
                                                    Nothing
                                        )
                                        pieces
                                    )
                                    (List.filterMap
                                        (\piece ->
                                            case piece of
                                                FlatPiece _ ->
                                                    Nothing

                                                FeaturePiece feature ->
                                                    Just feature
                                        )
                                        pieces
                                    )
                                    |> Result.mapError (\error -> "The faces don't fit together: " ++ Surface.errorToString error)
                            )

                Ok [] ->
                    Err "The file has no solid in it (a closed shell)"

                Ok shells ->
                    Err ("The file has " ++ String.fromInt (List.length shells) ++ " solids in it; export just one")

                Err message ->
                    Err (explain text message)

        Err message ->
            Err message


{-| The decoder's errors name the chain of entities it was in when it failed. Say which face that was
and what the entity it couldn't read is, which is usually a kind of surface or curve that can't be
imported.
-}
explain : String -> String -> String
explain text message =
    let
        ids =
            Regex.find (regex "#(\\d+)") (String.split ":" message |> List.head |> Maybe.withDefault "")
                |> List.filterMap (.submatches >> List.head >> Maybe.andThen identity)

        typeOf id =
            Regex.find (regex ("(?:^|[;\\s])#" ++ id ++ "\\s*=\\s*([A-Z0-9_]*)")) text
                |> List.head
                |> Maybe.andThen (.submatches >> List.head >> Maybe.andThen identity)
                |> Maybe.withDefault "?"

        faceId =
            List.filter (\id -> typeOf id == "ADVANCED_FACE") ids |> List.head
    in
    case ( faceId, List.reverse ids |> List.head ) of
        ( Just faceId_, Just last ) ->
            let
                lastType =
                    typeOf last
            in
            if String.contains "unexpected type" message then
                "Face #"
                    ++ faceId_
                    ++ " uses "
                    ++ (if List.any (\vowel -> String.startsWith vowel lastType) [ "A", "E", "I", "O", "U" ] then
                            "an "

                        else
                            "a "
                       )
                    ++ lastType
                    ++ " (#"
                    ++ last
                    ++ "), which can't be imported: only planes, cylinders, cones, spheres and tori with edges that are lines or circles can"

            else
                "Face #" ++ faceId_ ++ ": " ++ message

        _ ->
            message


regex : String -> Regex.Regex
regex string =
    Regex.fromString string |> Maybe.withDefault Regex.never


{-| How many meters the file's length unit is, and how many radians its angle unit is.
-}
unitsOf : String -> { length : Float, angle : Float }
unitsOf text =
    let
        compact =
            String.filter (\c -> c /= ' ' && c /= '\n' && c /= '\u{000D}' && c /= '\t') text

        unitEntity kind =
            Regex.find (regex ("\\(([^;]*" ++ kind ++ "\\(\\)[^;]*)\\);")) compact
                |> List.head
                |> Maybe.andThen (.submatches >> List.head >> Maybe.andThen identity)
                |> Maybe.withDefault ""

        siPrefix entity =
            case Regex.find (regex "SI_UNIT\\(\\.(\\w+)\\.,") entity |> List.head |> Maybe.andThen (.submatches >> List.head >> Maybe.andThen identity) of
                Just "MILLI" ->
                    0.001

                Just "CENTI" ->
                    0.01

                Just "DECI" ->
                    0.1

                Just "KILO" ->
                    1000

                Just "MICRO" ->
                    1.0e-6

                _ ->
                    1

        conversion entity =
            Regex.find (regex "CONVERSION_BASED_UNIT\\('([^']*)'") entity
                |> List.head
                |> Maybe.andThen (.submatches >> List.head >> Maybe.andThen identity)
                |> Maybe.map String.toUpper

        length =
            let
                entity =
                    unitEntity "LENGTH_UNIT"
            in
            case conversion entity of
                Just "INCH" ->
                    0.0254

                Just "FOOT" ->
                    0.3048

                Just "MILLIMETRE" ->
                    0.001

                Just "MILLIMETER" ->
                    0.001

                _ ->
                    siPrefix entity

        angle =
            case conversion (unitEntity "PLANE_ANGLE_UNIT") of
                Just "DEGREE" ->
                    pi / 180

                Just "DEGREES" ->
                    pi / 180

                _ ->
                    1
    in
    { length = length, angle = angle }


type alias Convert =
    { point : Vec -> Vec, direction : Vec -> Vec, length : Float -> Float, angle : Float -> Float }


convertFace : Convert -> Face -> Face
convertFace convert face_ =
    let
        placement_ p =
            { origin = convert.point p.origin, axis = Maybe.map convert.direction p.axis, ref = Maybe.map convert.direction p.ref }

        curve_ c =
            case c of
                LineCurve ->
                    LineCurve

                CircleCurve circle ->
                    CircleCurve { placement = placement_ circle.placement, radius = convert.length circle.radius }

        edge e =
            { e | start = convert.point e.start, end = convert.point e.end, curve = curve_ e.curve }
    in
    { face_
        | bounds = List.map (\b -> { b | edges = List.map (Tuple.mapFirst edge) b.edges }) face_.bounds
        , geometry =
            case face_.geometry of
                Plane p ->
                    Plane (placement_ p)

                Cylinder p r ->
                    Cylinder (placement_ p) (convert.length r)

                Cone p r semiAngle ->
                    Cone (placement_ p) (convert.length r) (convert.angle semiAngle)

                Sphere p r ->
                    Sphere (placement_ p) (convert.length r)

                Torus p major minor ->
                    Torus (placement_ p) (convert.length major) (convert.length minor)
    }



---- FACES TO PIECES ----


type Piece coordinates
    = FlatPiece (FlatSpec coordinates)
    | FeaturePiece (FeatureSpec coordinates)


{-| An edge as it's gone along in a loop of a face: from `start` to `end`, and whether that's the way
the edge's curve goes (`forward`).
-}
type alias Run =
    { start : Vec, end : Vec, curve : Curve, forward : Bool, id : Int }


runsOf : Bound -> List Run
runsOf bound_ =
    let
        runs =
            List.map
                (\( edge, sameSense ) ->
                    if sameSense then
                        { start = edge.start, end = edge.end, curve = edge.curve, forward = edge.sameSense, id = edge.id }

                    else
                        { start = edge.end, end = edge.start, curve = edge.curve, forward = not edge.sameSense, id = edge.id }
                )
                bound_.edges
    in
    if bound_.sameSense then
        runs

    else
        List.reverse runs |> List.map reverseRun


reverseRun : Run -> Run
reverseRun run =
    { run | start = run.end, end = run.start, forward = not run.forward }


pieceOf : Face -> Result String (Piece coordinates)
pieceOf face_ =
    let
        sense =
            if face_.sameSense then
                1

            else
                -1

        frameOf p =
            let
                axis =
                    Maybe.withDefault (Vec 0 0 1) p.axis |> normalize

                ref =
                    Maybe.withDefault (perpendicularTo axis) p.ref

                x =
                    sub ref (scale (dot ref axis) axis) |> normalize
            in
            { origin = p.origin, axis = axis, x = x }

        radialFrom frame p =
            let
                d =
                    sub p frame.origin
            in
            sub d (scale (dot d frame.axis) frame.axis)
    in
    case face_.geometry of
        Plane p ->
            flatOf (frameOf p) sense face_.bounds |> Result.map FlatPiece

        Cylinder p _ ->
            let
                frame =
                    frameOf p
            in
            featureOf frame (\q -> radialFrom frame q |> normalize |> scale sense) face_.bounds |> Result.map FeaturePiece

        Cone p _ semiAngle ->
            let
                frame =
                    frameOf p
            in
            featureOf frame
                (\q -> sub (radialFrom frame q |> normalize) (scale (tan semiAngle) frame.axis) |> normalize |> scale sense)
                face_.bounds
                |> Result.map FeaturePiece

        Torus p major _ ->
            let
                frame =
                    frameOf p
            in
            featureOf frame
                (\q -> sub q (add frame.origin (scale major (radialFrom frame q |> normalize))) |> normalize |> scale sense)
                face_.bounds
                |> Result.map FeaturePiece

        Sphere p _ ->
            let
                outward q =
                    sub q p.origin |> normalize |> scale sense

                -- Any axis through the center will do, as long as the edges go around it or along it
                circleAxes =
                    face_.bounds
                        |> List.concatMap runsOf
                        |> List.filterMap
                            (\run ->
                                case run.curve of
                                    CircleCurve circle ->
                                        circle.placement.axis

                                    LineCurve ->
                                        Nothing
                            )

                tryAxes axes =
                    case axes of
                        axis :: rest ->
                            case featureOf (frameOf { p | axis = Just axis }) outward face_.bounds of
                                Ok feature ->
                                    Ok feature

                                Err error ->
                                    if List.isEmpty rest then
                                        Err error

                                    else
                                        tryAxes rest

                        [] ->
                            Err "a sphere with no edges"
            in
            tryAxes ((p.axis |> Maybe.map List.singleton |> Maybe.withDefault []) ++ circleAxes) |> Result.map FeaturePiece


flatOf : { origin : Vec, axis : Vec, x : Vec } -> Float -> List Bound -> Result String (FlatSpec coordinates)
flatOf frame sense bounds =
    let
        normal =
            scale sense frame.axis

        x =
            frame.x

        y =
            cross normal x

        to2d p =
            let
                d =
                    sub p frame.origin
            in
            ( dot d x, dot d y )

        edgeOf run =
            case run.curve of
                LineCurve ->
                    { start = to2d run.start, edge = Straight (point2d (to2d run.start)), samples = [ to2d run.start ] }

                CircleCurve circle ->
                    let
                        center =
                            circle.placement.origin

                        axis =
                            Maybe.withDefault normal circle.placement.axis |> normalize

                        swept =
                            sweptAround center axis run
                                * (if dot axis normal < 0 then
                                    -1

                                   else
                                    1
                                  )

                        ( cx, cy ) =
                            to2d center

                        ( sx, sy ) =
                            to2d run.start

                        a0 =
                            atan2 (sy - cy) (sx - cx)

                        r =
                            sqrt ((sx - cx) ^ 2 + (sy - cy) ^ 2)
                    in
                    { start = ( sx, sy )
                    , edge = Arc { start = point2d ( sx, sy ), center = point2d ( cx, cy ), sweptAngle = Angle.radians swept }
                    , samples = List.range 0 15 |> List.map (\i -> a0 + swept * toFloat i / 16 |> (\a -> ( cx + r * cos a, cy + r * sin a )))
                    }

        loops =
            List.map
                (\bound_ ->
                    let
                        runs =
                            runsOf bound_
                    in
                    { outer = bound_.outer
                    , runs = runs
                    , area = List.concatMap (edgeOf >> .samples) runs |> signedArea
                    }
                )
                bounds

        outer =
            case List.filter .outer loops of
                first :: _ ->
                    Just first

                [] ->
                    List.sortBy (.area >> abs >> negate) loops |> List.head

        -- Outer loops go counterclockwise, holes clockwise, whichever way the file had them
        oriented wantPositive loop =
            if (loop.area > 0) == wantPositive then
                loop.runs

            else
                List.reverse loop.runs |> List.map reverseRun
    in
    case outer of
        Just outer_ ->
            Ok
                { plane =
                    SketchPlane3d.unsafe
                        { originPoint = Point3d.fromMeters frame.origin
                        , xDirection = Direction3d.unsafe x
                        , yDirection = Direction3d.unsafe y
                        }
                , boundary =
                    (oriented True outer_ |> List.map (edgeOf >> .edge))
                        :: (loops |> List.filter (\loop -> loop /= outer_) |> List.map (oriented False >> List.map (edgeOf >> .edge)))
                }

        Nothing ->
            Err "a plane with no edges"


{-| A surface of revolution around `frame.axis`, whose outward normal at a point is `outward`.
-}
featureOf : { origin : Vec, axis : Vec, x : Vec } -> (Vec -> Vec) -> List Bound -> Result String (FeatureSpec coordinates)
featureOf frame outward bounds =
    let
        axis =
            frame.axis

        y =
            cross axis frame.x

        relative p =
            sub p frame.origin

        radial p =
            let
                d =
                    relative p
            in
            sub d (scale (dot d axis) axis)

        profilePoint p =
            ( lengthOf (radial p), dot (relative p) axis )

        theta p =
            atan2 (dot (relative p) y) (dot (relative p) frame.x)

        offAxis p =
            lengthOf (radial p)

        -- Not counting edges that have shrunk to a point (at a pole, say)
        runs =
            List.concatMap runsOf bounds
                |> List.filter (\run -> distance run.start run.end > tolerance || run.curve /= LineCurve)

        isParallel run =
            case run.curve of
                CircleCurve circle ->
                    lengthOf (cross (Maybe.withDefault axis circle.placement.axis |> normalize) axis)
                        < angleTolerance
                        && offAxis circle.placement.origin
                        < tolerance

                LineCurve ->
                    False

        isMeridian run =
            let
                far =
                    if offAxis run.start > offAxis run.end then
                        run.start

                    else
                        run.end
            in
            if offAxis far < tolerance then
                False

            else
                let
                    planeNormal =
                        cross axis (radial far) |> normalize

                    inPlane p =
                        abs (dot (relative p) planeNormal) < tolerance && dot (radial p) (radial far) >= -tolerance
                in
                inPlane run.start
                    && inPlane run.end
                    && (case run.curve of
                            LineCurve ->
                                True

                            CircleCurve circle ->
                                inPlane circle.placement.origin
                                    && (lengthOf (cross (Maybe.withDefault planeNormal circle.placement.axis |> normalize) planeNormal) < angleTolerance)
                       )

        parallels =
            List.filter isParallel runs

        meridians =
            List.filter isMeridian runs

        stray =
            List.filter (\run -> not (isParallel run) && not (isMeridian run)) runs

        sweep =
            case parallels of
                run :: _ ->
                    if distance run.start run.end < tolerance then
                        Ok FullTurn

                    else
                        let
                            circleAxis =
                                case run.curve of
                                    CircleCurve circle ->
                                        Maybe.withDefault axis circle.placement.axis

                                    LineCurve ->
                                        axis

                            -- Which way round the axis the run goes
                            around =
                                if run.forward == (dot circleAxis axis > 0) then
                                    1

                                else
                                    -1

                            ( from, to ) =
                                if around > 0 then
                                    ( theta run.start, theta run.end )

                                else
                                    ( theta run.end, theta run.start )
                        in
                        Ok (PartTurn { from = Angle.radians from, to = Angle.radians (from + positiveAngle (to - from)) })

                [] ->
                    Err "none of its edges go around its axis, so how far round it goes isn't known"

        profile =
            case meridians of
                run :: _ ->
                    let
                        points =
                            case run.curve of
                                LineCurve ->
                                    [ ( run.end, Nothing ) ]

                                CircleCurve circle ->
                                    let
                                        center =
                                            circle.placement.origin

                                        circleAxis =
                                            Maybe.withDefault axis circle.placement.axis |> normalize

                                        swept =
                                            sweptAround center circleAxis run
                                    in
                                    if abs swept > 0.99 * pi then
                                        [ ( rotateAround center circleAxis (swept / 2) run.start, Just center ), ( run.end, Just center ) ]

                                    else
                                        [ ( run.end, Just center ) ]

                        -- Halfway along, to see which way round the profile has to go
                        ( middle, tangent ) =
                            case run.curve of
                                LineCurve ->
                                    ( scale 0.5 (add run.start run.end), sub run.end run.start )

                                CircleCurve circle ->
                                    let
                                        circleAxis =
                                            Maybe.withDefault axis circle.placement.axis |> normalize

                                        swept =
                                            sweptAround circle.placement.origin circleAxis run

                                        m =
                                            rotateAround circle.placement.origin circleAxis (swept / 2) run.start
                                    in
                                    ( m, cross circleAxis (sub m circle.placement.origin) |> scale swept )

                        out =
                            radial middle |> normalize

                        n =
                            outward middle

                        -- The outside is on the right going along the profile
                        rightWay =
                            (dot tangent axis * dot n out - dot tangent out * dot n axis) >= 0

                        toProfile p =
                            profilePoint p |> point2d

                        segments start rest =
                            List.foldl
                                (\( end, center ) ( _, acc ) ->
                                    ( end
                                    , acc
                                        ++ [ case center of
                                                Just c ->
                                                    Circle { end = toProfile end, center = toProfile c }

                                                Nothing ->
                                                    Line { end = toProfile end }
                                           ]
                                    )
                                )
                                ( start, [] )
                                rest
                                |> Tuple.second
                    in
                    if rightWay then
                        Ok { start = toProfile run.start, segments = segments run.start points }

                    else
                        let
                            -- The same points the other way, each segment keeping its center
                            nodes =
                                run.start :: List.map Tuple.first points

                            centers =
                                List.map Tuple.second points

                            reversedPoints =
                                List.map2 Tuple.pair (List.reverse nodes |> List.drop 1) (List.reverse centers)
                        in
                        Ok { start = toProfile run.end, segments = segments run.end reversedPoints }

                [] ->
                    Err "none of its edges go along its axis, so its profile isn't known"
    in
    case stray of
        run :: _ ->
            Err ("edge #" ++ String.fromInt run.id ++ " neither goes around its axis nor along it (two fillets meeting at a sharp corner make edges like this)")

        [] ->
            Result.map2
                (\sweep_ profile_ ->
                    { frame =
                        Frame3d.unsafe
                            { originPoint = Point3d.fromMeters frame.origin
                            , xDirection = Direction3d.unsafe frame.x
                            , yDirection = Direction3d.unsafe y
                            , zDirection = Direction3d.unsafe axis
                            }
                    , profile = profile_
                    , sweep = sweep_
                    }
                )
                sweep
                profile



---- GEOMETRY ----


{-| In meters, and as the sine of an angle.
-}
tolerance : Float
tolerance =
    1.0e-6


angleTolerance : Float
angleTolerance =
    1.0e-6


{-| How far a run goes round a circle with this center and axis, counterclockwise looking down the
axis being positive. A run that ends where it starts goes all the way round.
-}
sweptAround : Vec -> Vec -> Run -> Float
sweptAround center axis run =
    let
        a =
            sub run.start center

        b =
            sub run.end center

        ccw =
            atan2 (dot axis (cross a b)) (dot a b) |> positiveAngle

        cw =
            atan2 (dot axis (cross b a)) (dot a b) |> positiveAngle
    in
    if run.forward then
        ccw

    else
        -cw


{-| An angle in (0, 2 pi], with angles of about 0 counting as all the way round.
-}
positiveAngle : Float -> Float
positiveAngle angle =
    let
        wrapped =
            angle - 2 * pi * toFloat (floor (angle / (2 * pi)))
    in
    if wrapped < 1.0e-9 then
        2 * pi

    else
        wrapped


rotateAround : Vec -> Vec -> Float -> Vec -> Vec
rotateAround center axis angle p =
    let
        d =
            sub p center

        along =
            scale (dot d axis) axis

        across =
            sub d along
    in
    add center (add along (add (scale (cos angle) across) (scale (sin angle) (cross axis across))))


signedArea : List ( Float, Float ) -> Float
signedArea points =
    List.map2 (\( x0, y0 ) ( x1, y1 ) -> x0 * y1 - x1 * y0) points (List.drop 1 points ++ List.take 1 points)
        |> List.sum
        |> (*) 0.5


perpendicularTo : Vec -> Vec
perpendicularTo v =
    if abs v.x < 0.9 then
        cross v (Vec 1 0 0) |> normalize

    else
        cross v (Vec 0 1 0) |> normalize


point2d : ( Float, Float ) -> Point2d.Point2d units coordinates
point2d ( x, y ) =
    Point2d.unsafe { x = x, y = y }


combine : List (Result e a) -> Result e (List a)
combine results =
    List.foldr (Result.map2 (::)) (Ok []) results


add : Vec -> Vec -> Vec
add a b =
    { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z }


sub : Vec -> Vec -> Vec
sub a b =
    { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }


scale : Float -> Vec -> Vec
scale s a =
    { x = s * a.x, y = s * a.y, z = s * a.z }


dot : Vec -> Vec -> Float
dot a b =
    a.x * b.x + a.y * b.y + a.z * b.z


cross : Vec -> Vec -> Vec
cross a b =
    { x = a.y * b.z - a.z * b.y
    , y = a.z * b.x - a.x * b.z
    , z = a.x * b.y - a.y * b.x
    }


lengthOf : Vec -> Float
lengthOf a =
    sqrt (dot a a)


distance : Vec -> Vec -> Float
distance a b =
    lengthOf (sub a b)


normalize : Vec -> Vec
normalize a =
    let
        l =
            lengthOf a
    in
    if l > 0 then
        scale (1 / l) a

    else
        a
