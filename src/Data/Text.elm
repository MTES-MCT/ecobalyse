module Data.Text exposing
    ( buildCurlCommand
    , isDigitsOnly
    , search
    , sortI18nStrings
    , toSearchable
    , toWords
    , yesNo
    )

import Regex
import String.Normalize as Normalize


type alias SearchConfig element =
    { minQueryLength : Int
    , query : String
    , toSearchableText : element -> String
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


isDigitsOnly : String -> Bool
isDigitsOnly =
    String.all Char.isDigit


containsEveryWord : (String -> String -> Bool) -> List String -> String -> Bool
containsEveryWord contains searchWords searchableText =
    searchWords
        |> List.all (\word -> contains word searchableText)


containsWholeWord : String -> String -> Bool
containsWholeWord word searchableText =
    String.contains (" " ++ word ++ " ") (" " ++ searchableText ++ " ")


containsWord : String -> String -> Bool
containsWord =
    String.contains


nonWord : Regex.Regex
nonWord =
    Regex.fromString "[\\W_]+"
        |> Maybe.withDefault Regex.never


{-| Filter a list of stringifyable items against provided search terms:

  - case and accented letters insensitive
  - exact matches listed first, partial matches second, rest is unlisted

-}
search : SearchConfig element -> List element -> List element
search { minQueryLength, query, toSearchableText } elements =
    let
        trimmedQuery =
            String.trim query
    in
    if trimmedQuery == "" || String.length trimmedQuery < minQueryLength then
        elements

    else
        let
            searchWords =
                trimmedQuery
                    |> toWords
                    |> List.filter (String.isEmpty >> not)

            ( exactMatches, rest ) =
                elements
                    |> List.map (\element -> ( toSearchableText element, element ))
                    |> List.partition (Tuple.first >> containsEveryWord containsWholeWord searchWords)

            ( partialMatches, _ ) =
                rest
                    |> List.partition (Tuple.first >> containsEveryWord containsWord searchWords)
        in
        List.map Tuple.second exactMatches ++ List.map Tuple.second partialMatches


{-| Sort strings in a case and accent insensitive manner (useful for non-US alphabets).
-}
sortI18nStrings : List String -> List String
sortI18nStrings =
    List.sortBy (String.toLower >> Normalize.removeDiacritics)


toSearchable : String -> String
toSearchable =
    String.toLower
        >> Normalize.removeDiacritics
        >> Regex.replace nonWord (\_ -> " ")
        >> String.trim


toWords : String -> List String
toWords =
    String.toLower
        >> Normalize.removeDiacritics
        >> Regex.split nonWord


yesNo : Bool -> String
yesNo bool =
    if bool then
        "Oui"

    else
        "Non"
