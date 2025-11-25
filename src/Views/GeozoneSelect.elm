module Views.GeozoneSelect exposing (view)

import Data.Geozone as Geozone exposing (Geozone)
import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { attributes : List (Attribute msg)
    , geozones : List Geozone
    , onSelect : Geozone.Code -> msg
    , scope : Scope
    , selectedGeozone : Geozone.Code
    }


view : Config msg -> Html msg
view { attributes, geozones, onSelect, scope, selectedGeozone } =
    geozones
        |> Scope.anyOf [ scope ]
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (selectedGeozone == code)
                    , value <| Geozone.codeToString code
                    ]
                    [ text name ]
            )
        |> select
            (class
                "form-select"
                :: onInput (Geozone.codeFromString >> onSelect)
                :: attributes
            )
