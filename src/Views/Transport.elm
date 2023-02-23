module Views.Transport exposing (view, viewFoodTransport)

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


viewFoodTransport : Config -> Transport -> Html msg
viewFoodTransport { airTransportLabel, seaTransportLabel, roadTransportLabel } { road, air, sea } =
    span [ class "text-muted d-flex fs-7 gap-3 justify-content-left IngredientTransportDistances" ]
        ([ { label =
                airTransportLabel
                    |> Maybe.withDefault "Transport aérien"
           , distance = air
           , icon = Icon.plane
           }
         , { label =
                seaTransportLabel
                    |> Maybe.withDefault "Transport maritime"
           , distance = sea
           , icon = Icon.boat
           }
         , { label =
                roadTransportLabel
                    |> Maybe.withDefault "Transport routier"
           , distance = road
           , icon = Icon.bus
           }
         ]
            |> List.filterMap
                (\{ label, distance, icon } ->
                    if Length.inKilometers distance == 0 then
                        Nothing

                    else
                        entry distance icon label
                            |> Just
                )
        )


entry : Length -> Html msg -> String -> Html msg
entry distance icon label =
    span
        [ class "d-flex align-items-center gap-1", title label ]
        [ span [ style "cursor" "help" ] [ icon ]
        , Format.km distance
        ]
