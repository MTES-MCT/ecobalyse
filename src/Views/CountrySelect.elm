module Views.CountrySelect exposing (view)

import Data.Country as Country exposing (Country)
import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { attributes : List (Attribute msg)
    , countries : List Country
    , onSelect : Country.Code -> msg
    , scope : Scope
    , selectedCountry : Country.Code
    }


view : Config msg -> Html msg
view { attributes, countries, onSelect, scope, selectedCountry } =
    countries
        |> Scope.only scope
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
