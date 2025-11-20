module Views.GeoZoneSelect exposing (view)

import Data.GeoZone as GeoZone exposing (GeoZone)
import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { attributes : List (Attribute msg)
    , geoZones : List GeoZone
    , onSelect : GeoZone.Code -> msg
    , scope : Scope
    , selectedGeoZone : GeoZone.Code
    }


view : Config msg -> Html msg
view { attributes, geoZones, onSelect, scope, selectedGeoZone } =
    geoZones
        |> Scope.anyOf [ scope ]
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (selectedGeoZone == code)
                    , value <| GeoZone.codeToString code
                    ]
                    [ text name ]
            )
        |> select
            (class
                "form-select"
                :: onInput (GeoZone.codeFromString >> onSelect)
                :: attributes
            )
