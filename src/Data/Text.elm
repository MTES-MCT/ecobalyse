module Data.Text exposing (search)

import String.Normalize as Normalize


type alias SearchConfig element comparable =
    { minQueryLength : Int
    , query : String
    , sortBy : Maybe (element -> comparable)
    , toString : element -> String
    }


search : SearchConfig element comparable -> List element -> List element
search { minQueryLength, query, sortBy, toString } elements =
    let
        trimmedQuery =
            String.trim query
    in
    if trimmedQuery == "" || String.length trimmedQuery < minQueryLength then
        elements

    else
        let
            searchWords =
                toWords trimmedQuery
        in
        elements
            |> List.map (\element -> ( toWords (toString element), element ))
            |> List.filter
                (\( words, _ ) ->
                    List.all (\w -> List.any (String.contains w) words) searchWords
                )
            |> (case sortBy of
                    Just sortBy_ ->
                        List.sortBy <| Tuple.second >> sortBy_

                    Nothing ->
                        identity
               )
            |> List.map Tuple.second


toWords : String -> List String
toWords =
    String.toLower
        >> Normalize.removeDiacritics
        >> String.foldl
            (\c acc ->
                if not (List.member c [ '(', ')' ]) then
                    String.cons c acc

                else
                    acc
            )
            ""
        >> String.split " "
