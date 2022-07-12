module Views.CountrySelect exposing (view)

import Data.Country as Country exposing (Country)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { attributes : List (Attribute msg)
    , selectedCountry : Country.Code
    , onSelect : Country.Code -> msg
    , countries : List Country
    }


view : Config msg -> Html msg
view { attributes, selectedCountry, onSelect, countries } =
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
            (class
                "form-select"
                :: onInput (Country.codeFromString >> onSelect)
                :: attributes
            )
