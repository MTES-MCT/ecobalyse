module Data.AutocompleteSelector exposing (init)

import Autocomplete exposing (Autocomplete)
import String.Normalize as Normalize
import Task


init : (element -> String) -> List element -> Autocomplete element
init toString availableElements =
    Autocomplete.init
        { query = ""
        , choices = List.sortBy toString availableElements
        , ignoreList = []
        }
        (\lastChoices ->
            Task.succeed
                { lastChoices
                    | choices =
                        availableElements
                            |> getChoices toString lastChoices.query
                }
        )


getChoices : (element -> String) -> String -> List element -> List element
getChoices toString query =
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
    List.map (\element -> ( toWords (toString element), element ))
        >> List.filter
            (\( words, _ ) ->
                query == "" || List.all (\w -> List.any (String.contains w) words) searchWords
            )
        >> List.sortBy (Tuple.second >> toString)
        >> List.map Tuple.second
