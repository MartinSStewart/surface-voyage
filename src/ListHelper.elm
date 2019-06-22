module ListHelper exposing (dropLast, foldFast, pairwise, reversibleRange)

{-| Helper functions for List
-}


{-| Drops the last element of a list
-}
dropLast : List a -> List a
dropLast =
    List.reverse >> List.drop 1 >> List.reverse


{-| Acts the same as List.range except it doesn't return an empty list if the
first parameter is larger than the second.
-}
reversibleRange : Int -> Int -> List Int
reversibleRange start end =
    List.range (min start end) (max start end)


pairwise : List a -> List ( a, a )
pairwise list =
    pairwiseHelper list [] |> List.reverse


pairwiseHelper : List a -> List ( a, a ) -> List ( a, a )
pairwiseHelper remaining newList =
    case remaining of
        a :: b :: rest ->
            pairwiseHelper (b :: rest) (( a, b ) :: newList)

        _ ->
            newList


foldFast : (a -> b -> Maybe b) -> b -> List a -> b
foldFast fold initial list =
    case list of
        head :: rest ->
            case fold head initial of
                Just continue ->
                    foldFast fold continue rest

                Nothing ->
                    initial

        [] ->
            initial
