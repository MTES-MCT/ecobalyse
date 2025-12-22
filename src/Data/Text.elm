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

            exactWordMatches =
                elements
                    |> List.filter
                        (\element ->
                            List.all (\w -> List.member (String.toLower w) (toWords (toString element))) searchWords
                        )
        in
        List.concat
            [ -- Full word matches first
              exactWordMatches

            -- Partial word matches last
            , elements
                |> List.filter
                    (\element ->
                        not (List.member element exactWordMatches)
                            && List.all (\w -> List.any (String.contains w) (toWords (toString element))) searchWords
                    )
            ]


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
