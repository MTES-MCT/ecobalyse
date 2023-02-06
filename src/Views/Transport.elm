module Views.Transport exposing (view, viewDetails)

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
view ({ fullWidth } as config) transport =
    div
        [ classList
            [ ( "d-flex fs-7 gap-3", True )
            , ( "w-100", fullWidth )
            , ( "justify-content-between", fullWidth )
            , ( "justify-content-center", not fullWidth )
            ]
        ]
        (viewDetails config transport)


viewDetails : Config -> Transport -> List (Html msg)
viewDetails { airTransportLabel, seaTransportLabel, roadTransportLabel } { road, air, sea } =
    [ airTransportLabel
        |> Maybe.withDefault "Transport aérien"
        |> entry air Icon.plane
    , seaTransportLabel
        |> Maybe.withDefault "Transport maritime"
        |> entry sea Icon.boat
    , roadTransportLabel
        |> Maybe.withDefault "Transport routier"
        |> entry road Icon.bus
    ]


entry : Length -> Html msg -> String -> Html msg
entry distance icon label =
    span [ class "d-flex align-items-center gap-1", title label ]
        [ span [ style "cursor" "help" ] [ icon ]
        , Format.km distance
        ]
