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


{-| Filter a list of stringifyable items against provided search terms:

  - case and accented letters insensitive
  - exact matches listed first, partial matches second, rest is unlisted

-}
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

            checkAll fn element =
                searchWords
                    |> List.all (\word -> fn word (toWords (toString element)))

            exactWordMatches =
                elements
                    |> List.filter (checkAll (String.toLower >> List.member))

            partialWordsMatches =
                elements
                    |> List.filter
                        (\element ->
                            not (List.member element exactWordMatches)
                                && checkAll (String.contains >> List.any) element
                        )
        in
        exactWordMatches ++ partialWordsMatches


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
