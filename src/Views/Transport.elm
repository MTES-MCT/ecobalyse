module Views.Transport exposing (view)

import Data.Transport exposing (Transport)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
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
            [ ( "d-flex fs-7 gap-3", True )
            , ( "w-100", fullWidth )
            , ( "justify-content-between", fullWidth )
            , ( "justify-content-center", not fullWidth )
            ]
        ]
        [ air
            |> entry (Maybe.withDefault "Transport aérien" airTransportLabel) Icon.plane
        , sea
            |> entry (Maybe.withDefault "Transport maritime" seaTransportLabel) Icon.boat
        , road
            |> entry (Maybe.withDefault "Transport routier" roadTransportLabel) Icon.bus
        ]


entry : String -> Html msg -> Length -> Html msg
entry label icon distance =
    span [ class "d-flex align-items-center gap-1", title label ]
        [ span [ style "cursor" "help" ] [ icon ]
        , Format.km distance
        ]
