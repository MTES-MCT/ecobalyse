module Data.AutocompleteSelector exposing (init)

import Autocomplete exposing (Autocomplete)
import Data.Text as Text
import Task


init : (element -> String) -> List element -> Autocomplete element
init toString availableElements =
    Autocomplete.init
        { choices = availableElements
        , ignoreList = []
        , query = ""
        }
        (\lastChoices ->
            Task.succeed
                { lastChoices
                    | choices =
                        availableElements
                            |> Text.search
                                { minQueryLength = 1
                                , query = lastChoices.query
                                , sortBy = Nothing
                                , toString = toString
                                }
                }
        )
