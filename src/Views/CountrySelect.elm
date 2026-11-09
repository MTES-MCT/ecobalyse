module Views.CountrySelect exposing (view)

import Data.Country exposing (Country)
import Data.Country.Code as CountryCode
import Data.Sector as Sector exposing (Sector)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { attributes : List (Attribute msg)
    , countries : List Country
    , onSelect : CountryCode.Code -> msg
    , sector : Sector
    , selectedCountry : CountryCode.Code
    }


view : Config msg -> Html msg
view { attributes, countries, onSelect, sector, selectedCountry } =
    countries
        |> Sector.anyOf [ sector ]
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (selectedCountry == code)
                    , value <| CountryCode.toString code
                    ]
                    [ text name ]
            )
        |> select
            (class
                "form-select"
                :: onInput (CountryCode.fromString >> onSelect)
                :: attributes
            )
