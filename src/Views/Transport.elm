module Views.Transport exposing (entry, viewDetails)

import Data.Transport exposing (Transport)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Views.Format as Format
import Views.Icon as Icon


type alias Config =
    { airTransportLabel : Maybe String
    , fullWidth : Bool
    , hideNoLength : Bool
    , onlyIcons : Bool
    , roadTransportLabel : Maybe String
    , seaTransportLabel : Maybe String
    }


viewDetails : Config -> Transport -> List (Html msg)
viewDetails { airTransportLabel, hideNoLength, onlyIcons, roadTransportLabel, seaTransportLabel } { air, road, roadCooled, sea, seaCooled } =
    [ { distance = air, icon = Icon.plane, label = Maybe.withDefault "Transport aérien" airTransportLabel }
    , { distance = sea, icon = Icon.boat, label = Maybe.withDefault "Transport maritime" seaTransportLabel }
    , { distance = seaCooled, icon = Icon.boatCooled, label = "Transport maritime réfrigéré" }
    , { distance = road, icon = Icon.bus, label = Maybe.withDefault "Transport routier" roadTransportLabel }
    , { distance = roadCooled, icon = Icon.busCooled, label = "Transport routier réfrigéré" }
    ]
        |> List.filterMap
            (\{ distance, icon, label } ->
                if Length.inKilometers distance == 0 && hideNoLength then
                    Nothing

                else
                    Just <| entry { distance = distance, icon = icon, label = label, onlyIcons = onlyIcons }
            )


type alias EntryConfig msg =
    { distance : Length
    , icon : Html msg
    , label : String
    , onlyIcons : Bool
    }


entry : EntryConfig msg -> Html msg
entry { distance, icon, label, onlyIcons } =
    span
        [ class "d-flex align-items-center gap-1", title label ]
        [ span [ style "cursor" "help" ] [ icon ]
        , if onlyIcons then
            text ""

          else
            Format.km distance
        ]
