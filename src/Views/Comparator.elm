module Views.Comparator exposing (..)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Inputs as Inputs
import Data.Material as Material
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Alert as Alert
import Views.Format as Format
import Views.Icon as Icon


type alias Config msg =
    { session : Session
    , simulator : Simulator
    , openDocModal : Gitbook.Path -> msg
    }


documentationPillLink : Config msg -> Gitbook.Path -> Html msg
documentationPillLink { openDocModal } path =
    button
        [ class "btn btn-sm text-secondary text-decoration-none btn-link p-0 ms-1"
        , onClick (openDocModal path)
        ]
        [ Icon.question ]


getComparatorData : Db -> Inputs.Query -> Result String ( Simulator, Simulator, Simulator )
getComparatorData db query =
    Result.map3 (\a b c -> ( a, b, c ))
        (Simulator.compute db
            { query
                | countries =
                    [ Country.Code "CN"
                    , Country.Code "FR"
                    , Country.Code "FR"
                    , Country.Code "FR"
                    , Country.Code "FR"
                    ]
                , dyeingWeighting = Just 0
                , airTransportRatio = Just 0
            }
        )
        (Simulator.compute db
            { query
                | countries =
                    [ Country.Code "CN"
                    , Country.Code "TR"
                    , Country.Code "TR"
                    , Country.Code "TR"
                    , Country.Code "FR"
                    ]
                , dyeingWeighting = Just 0.5
                , airTransportRatio = Just 0
            }
        )
        (Simulator.compute db
            { query
                | countries =
                    [ Country.Code "CN"
                    , Country.Code "IN"
                    , Country.Code "IN"
                    , Country.Code "IN"
                    , Country.Code "FR"
                    ]
                , dyeingWeighting = Just 1
                , airTransportRatio = Just 1
            }
        )


view : Config msg -> Html msg
view ({ session, simulator } as config) =
    case simulator.inputs |> Inputs.toQuery |> getComparatorData session.db of
        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = "Erreur"
                , content = [ text error ]
                }

        Ok result ->
            viewComparator config simulator result


viewComparator : Config msg -> Simulator -> ( Simulator, Simulator, Simulator ) -> Html msg
viewComparator config { inputs, co2 } ( good, middle, bad ) =
    let
        scale =
            bad.co2 - good.co2

        ( p, pMiddle ) =
            ( (co2 - good.co2) / scale * 100
            , (middle.co2 - good.co2) / scale * 100
            )
    in
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ text <| "Comparaison pour " ++ inputs.product.name ++ " en " ++ Material.shortName inputs.material ++ " de "
            , Format.kg inputs.mass
            , documentationPillLink config Gitbook.ComparativeScale
            ]
        , div [ class "card-body" ]
            [ if p <= 50 then
                div
                    [ class "text-muted ps-1"
                    , style "font-size" ".75em"
                    , style "border-left" "1px solid #bbb"
                    , style "margin-left" <| String.fromFloat p ++ "%"
                    ]
                    [ Format.kgCo2 2 co2 ]

              else
                div
                    [ class "text-muted text-end pe-1"
                    , style "font-size" ".75em"
                    , style "border-right" "1px solid #bbb"
                    , style "width" <| String.fromFloat p ++ "%"
                    ]
                    [ Format.kgCo2 2 co2 ]
            , div [ class "progress rounded-0 mt-0" ]
                [ div
                    [ class "progress-bar progress-bar-striped progress-bar-animated"
                    , style "background-color" (percentageToHsl p 120 0)
                    , style "width" <| String.fromFloat p ++ "%"
                    ]
                    []
                ]
            , div [ class "d-flex" ]
                [ div
                    [ style "width" <| String.fromFloat pMiddle ++ "%"
                    , style "height" ".65em"
                    , style "border-left" "1px solid #bbb"
                    ]
                    []
                , div
                    [ class "flex-fill"
                    , style "height" ".65em"
                    , style "border-left" "1px solid #bbb"
                    ]
                    []
                , div
                    [ style "height" ".65em"
                    , style "border-right" "1px solid #bbb"
                    ]
                    []
                ]
            , div [ class "d-flex justify-content-between fs-7" ]
                [ div [ class "text-center" ]
                    [ div [] [ text "Circuit France" ]
                    , Format.kgCo2 2 good.co2
                    ]
                , div [ class "text-center" ]
                    [ div [] [ text "Circuit Turquie moyen" ]
                    , Format.kgCo2 2 middle.co2
                    ]
                , div [ class "text-center" ]
                    [ div [] [ text "Circuit Inde majorant" ]
                    , Format.kgCo2 2 bad.co2
                    ]
                ]
            ]
        ]


percentageToHsl : Float -> Int -> Int -> String
percentageToHsl p h0 h1 =
    -- Source: https://jsfiddle.net/r438s65s/
    "hsl(" ++ String.fromFloat ((p / 100 * (toFloat h1 - toFloat h0)) + toFloat h0) ++ ", 45%, 55%)"
