module Views.Transport exposing (view)

import Data.Transport exposing (Transport)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format
import Views.Icon as Icon


type alias Config =
    { fullWidth : Bool
    , airTransportLabel : Maybe String
    , seaTransportLabel : Maybe String
    , roadTransportLabel : Maybe String
    }


view : Config -> Transport -> Html msg
view { fullWidth, airTransportLabel, seaTransportLabel, roadTransportLabel } { road, air, sea } =
    div
        [ classList
            [ ( "d-flex fs-7", True )
            , ( "justify-content-between", fullWidth )
            , ( "justify-content-center", not fullWidth )
            ]
        ]
        [ span [ class "mx-2", airTransportLabel |> Maybe.withDefault "" |> title ]
            [ span [ class "me-1", style "cursor" "help" ] [ Icon.plane ]
            , Format.km air
            ]
        , span [ class "mx-2", seaTransportLabel |> Maybe.withDefault "" |> title ]
            [ span [ class "me-1", style "cursor" "help" ] [ Icon.boat ]
            , Format.km sea
            ]
        , span [ class "mx-2", roadTransportLabel |> Maybe.withDefault "" |> title ]
            [ span [ class "me-1", style "cursor" "help" ] [ Icon.bus ]
            , Format.km road
            ]
        ]
