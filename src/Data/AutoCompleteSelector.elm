module Data.AutoCompleteSelector exposing (init)

-- import Autocomplete.View as AutocompleteView

import Autocomplete exposing (Autocomplete)
import String.Normalize as Normalize
import Task


type alias Element a =
    { a | name : String }


init : List (Element a) -> Autocomplete (Element a)
init availableElements =
    Autocomplete.init
        { query = ""
        , choices = List.sortBy .name availableElements
        , ignoreList = []
        }
        (\lastChoices ->
            Task.succeed
                { lastChoices
                    | choices =
                        availableElements
                            |> getChoices lastChoices.query
                }
        )


getChoices : String -> List (Element a) -> List (Element a)
getChoices query =
    let
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

        searchWords =
            toWords (String.trim query)
    in
    List.map (\element -> ( toWords element.name, element ))
        >> List.filter
            (\( words, _ ) ->
                query == "" || List.all (\w -> List.any (String.contains w) words) searchWords
            )
        >> List.sortBy (Tuple.second >> .name)
        >> List.map Tuple.second
