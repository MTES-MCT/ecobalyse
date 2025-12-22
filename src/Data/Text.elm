module Data.Text exposing
    ( search
    , toWords
    )

import Regex
import String.Normalize as Normalize


type alias SearchConfig element =
    { minQueryLength : Int
    , query : String
    , toString : element -> String
    }


search : SearchConfig element -> List element -> List element
search { minQueryLength, query, toString } elements =
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
                    -- List.all (\w -> List.member (String.toLower w) words) searchWords
                    List.all (\w -> List.any (String.contains w) words) searchWords
                )
            |> List.map Tuple.second


toWords : String -> List String
toWords =
    String.toLower
        >> Normalize.removeDiacritics
        >> String.trim
        >> (case Regex.fromString "[\\W_-]+" of
                Just regex ->
                    Regex.replace regex (always " ")

                Nothing ->
                    identity
           )
        >> String.split " "
