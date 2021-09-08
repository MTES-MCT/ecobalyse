module Views.Transport exposing (..)

import Data.Transport as Transport
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format
import Views.Icon as Icon


view : Bool -> Transport.Summary -> Html msg
view fullWidth { road, air, sea } =
    div
        [ classList
            [ ( "d-flex fs-7", True )
            , ( "justify-content-between", fullWidth )
            , ( "justify-content-center", not fullWidth )
            ]
        ]
        [ span [ class "mx-2" ]
            [ span [ class "me-1" ] [ Icon.plane ]
            , air |> Format.formatInt "km" |> text
            ]
        , span [ class "mx-2" ]
            [ span [ class "me-1" ] [ Icon.boat ]
            , sea |> Format.formatInt "km" |> text
            ]
        , span [ class "mx-2" ]
            [ span [ class "me-1" ] [ Icon.bus ]
            , road |> Format.formatInt "km" |> text
            ]
        ]
