module Views.Transport exposing (entry, view, viewDetails)

import Data.Transport exposing (Transport)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Views.Format as Format
import Views.Icon as Icon


type alias Config =
    { fullWidth : Bool
    , hideNoLength : Bool
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
viewDetails { hideNoLength, airTransportLabel, seaTransportLabel, roadTransportLabel } { air, sea, road } =
    [ { distance = air, icon = Icon.plane, label = Maybe.withDefault "Transport aérien" airTransportLabel }
    , { distance = sea, icon = Icon.boat, label = Maybe.withDefault "Transport maritime" seaTransportLabel }
    , { distance = road, icon = Icon.bus, label = Maybe.withDefault "Transport routier" roadTransportLabel }
    ]
        |> List.filterMap
            (\{ distance, icon, label } ->
                if Length.inKilometers distance == 0 && hideNoLength then
                    Nothing

                else
                    Just <| entry distance icon label
            )


entry : Length -> Html msg -> String -> Html msg
entry distance icon label =
    span
        [ class "d-flex align-items-center gap-1", title label ]
        [ span [ style "cursor" "help" ] [ icon ]
        , Format.km distance
        ]
