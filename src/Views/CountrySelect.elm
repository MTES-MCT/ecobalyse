module Views.CountrySelect exposing (view)

import Data.Country as Country exposing (Country)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : List (Attribute msg) -> Country.Code -> (Country.Code -> msg) -> List Country -> Html msg
view attributes selectedCountry onSelect countries =
    countries
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (selectedCountry == code)
                    , value <| Country.codeToString code
                    ]
                    [ text name ]
            )
        |> select
            ([ class "form-select"
             , onInput (Country.codeFromString >> onSelect)
             ]
                ++ attributes
            )
