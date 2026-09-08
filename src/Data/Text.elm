module Data.Text exposing
    ( buildCurlCommand
    , search
    , sortI18nStrings
    , toWords
    , yesNo
    )

import Regex
import String.Normalize as Normalize


type alias SearchConfig element =
    { minQueryLength : Int
    , query : String
    , toSearchableWords : element -> List String
    }


buildCurlCommand : Maybe String -> String -> String -> String
buildCurlCommand maybeToken json apiUrl =
    [ Just "curl -sS -X POST %apiUrl%"
    , Just "  -H \"accept: application/json\""
    , Just "  -H \"content-type: application/json\""
    , maybeToken |> Maybe.map (\token -> "  -H \"Authorization: Bearer " ++ token ++ "\"")
    , Just "  -d '%json%'"
    ]
        |> List.filterMap identity
        |> String.join " \\\n"
        |> String.replace "%apiUrl%" apiUrl
        |> String.replace "%json%" json


{-| Filter a list of stringifyable items against provided search terms:

  - case and accented letters insensitive
  - exact matches listed first, partial matches second, rest is unlisted

-}
search : SearchConfig element -> List element -> List element
search { minQueryLength, query, toSearchableWords } elements =
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

            checkMatches fn element =
                searchWords
                    |> List.all
                        (\word ->
                            element
                                |> toSearchableWords
                                |> fn word
                        )

            exactWordsMatches =
                elements
                    |> List.filter (checkMatches List.member)

            partialWordsMatches =
                elements
                    |> List.filter
                        (\element ->
                            not (List.member element exactWordsMatches)
                                && checkMatches (String.contains >> List.any) element
                        )
        in
        exactWordsMatches ++ partialWordsMatches


{-| Sort strings in a case and accent insensitive manner (useful for non-US alphabets).
-}
sortI18nStrings : List String -> List String
sortI18nStrings =
    List.sortBy (String.toLower >> Normalize.removeDiacritics)


toWords : String -> List String
toWords =
    String.toLower
        >> Normalize.removeDiacritics
        >> Regex.split
            (Regex.fromString "[\\W_]+"
                |> Maybe.withDefault Regex.never
            )


yesNo : Bool -> String
yesNo bool =
    if bool then
        "Oui"

    else
        "Non"
