module Triangle exposing (Triangle, andThen, edges, from, map, toList)


type alias Triangle a =
    ( a, a, a )


from : a -> a -> a -> Triangle a
from v0 v1 v2 =
    ( v0, v1, v2 )


map : (a -> b) -> Triangle a -> Triangle b
map mapFunc ( v0, v1, v2 ) =
    from (mapFunc v0) (mapFunc v1) (mapFunc v2)


andThen : (a -> Maybe b) -> Triangle a -> Maybe (Triangle b)
andThen andThenFunc ( v0, v1, v2 ) =
    Maybe.map3
        from
        (andThenFunc v0)
        (andThenFunc v1)
        (andThenFunc v2)


toList : Triangle a -> List a
toList ( v0, v1, v2 ) =
    [ v0, v1, v2 ]


edges : Triangle a -> List ( a, a )
edges ( v0, v1, v2 ) =
    [ ( v0, v1 ), ( v1, v2 ), ( v2, v0 ) ]
