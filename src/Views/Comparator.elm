module Views.Comparator exposing (..)

import Chart as C
import Chart.Attributes as CA
import Data.Co2 as Co2
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Result.Extra as RE
import Svg as S
import Svg.Attributes as SA
import Views.Alert as Alert
import Views.Format as Format


type alias Config =
    { session : Session
    , simulator : Simulator
    }


type alias Entry =
    { label : String
    , highlight : Bool
    , knitted : Bool
    , kgCo2e : Float
    , materialAndSpinning : Float
    , weavingKnitting : Float
    , dyeing : Float
    , making : Float
    , transport : Float
    }


toRecycledFrance : Inputs.Query -> ( String, Inputs.Query )
toRecycledFrance query =
    ( "France 100% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0
        , airTransportRatio = Just 0
        , recycledRatio = Just 1
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledFrance : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledFrance query =
    ( "France 0% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0
        , airTransportRatio = Just 0
        , recycledRatio = Just 0
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toPartiallyRecycledIndiaTurkey : Inputs.Query -> ( String, Inputs.Query )
toPartiallyRecycledIndiaTurkey query =
    ( "Inde-Turquie 20% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "TR"
            , Country.Code "TR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0.5
        , airTransportRatio = Just 0
        , recycledRatio = Just 0.2
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledIndiaTurkey : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledIndiaTurkey query =
    ( "Inde-Turquie 0% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "TR"
            , Country.Code "TR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0.5
        , airTransportRatio = Just 0
        , recycledRatio = Just 0
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toRecycledIndia : Inputs.Query -> ( String, Inputs.Query )
toRecycledIndia query =
    ( "Inde 100% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 1
        , airTransportRatio = Just 1
        , recycledRatio = Just 1
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledIndia : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledIndia query =
    ( "Inde 0% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 1
        , airTransportRatio = Just 1
        , recycledRatio = Just 0
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


createEntry : Db -> Bool -> ( String, Inputs.Query ) -> Result String Entry
createEntry db highlight ( label, query ) =
    let
        stepCo2Float stepLabel =
            LifeCycle.getStepCo2 stepLabel
                >> Maybe.map Co2.inKgCo2e
                >> Result.fromMaybe ("Impact d'étape non trouvé: " ++ Step.labelToString stepLabel)
    in
    query
        |> Simulator.compute db
        |> Result.andThen
            (\{ lifeCycle, inputs, transport, co2 } ->
                Ok (Entry label highlight inputs.product.knitted (Co2.inKgCo2e co2))
                    |> RE.andMap (stepCo2Float Step.MaterialAndSpinning lifeCycle)
                    |> RE.andMap (stepCo2Float Step.WeavingKnitting lifeCycle)
                    |> RE.andMap (stepCo2Float Step.Ennoblement lifeCycle)
                    |> RE.andMap (stepCo2Float Step.Making lifeCycle)
                    |> RE.andMap (Ok (Co2.inKgCo2e transport.co2))
            )


getEntries : Db -> Inputs -> Result String (List Entry)
getEntries db ({ material } as inputs) =
    let
        query =
            Inputs.toQuery inputs

        entries =
            if material.recycledProcess /= Nothing then
                [ ( "Votre simulation", query ) |> createEntry db True -- user simulation
                , query |> toRecycledFrance |> createEntry db False
                , query |> toNonRecycledFrance |> createEntry db False
                , query |> toPartiallyRecycledIndiaTurkey |> createEntry db False
                , query |> toRecycledIndia |> createEntry db False
                , query |> toNonRecycledIndia |> createEntry db False
                ]

            else
                [ ( "Votre simulation", query ) |> createEntry db True -- user simulation
                , query |> toNonRecycledFrance |> createEntry db False
                , query |> toNonRecycledIndiaTurkey |> createEntry db False
                , query |> toNonRecycledIndia |> createEntry db False
                ]
    in
    entries
        |> RE.combine
        |> Result.map (List.sortBy .kgCo2e)


view : Config -> Html msg
view { session, simulator } =
    case simulator.inputs |> getEntries session.db of
        Ok entries ->
            chart entries

        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = "Erreur"
                , content = [ text error ]
                }


chartTextColor : String
chartTextColor =
    "#5d5b7e"


{-| Create vertical labels from percentages on the x-axis.
-}
fillLabels : List Entry -> List (C.Element data msg)
fillLabels entries =
    let
        ( baseWidth, leftPadding ) =
            ( 100 / toFloat (clamp 1 100 (List.length entries))
            , 3.8
            )

        createLabel ( { label, highlight }, xPosition ) =
            C.labelAt
                (CA.percent xPosition)
                (CA.percent 0)
                [ CA.rotate 90
                , CA.color chartTextColor
                , CA.attrs
                    [ SA.fontSize "14"
                    , SA.style "text-anchor: start"
                    , if highlight then
                        SA.fontWeight "bold"

                      else
                        SA.fontWeight "normal"
                    ]
                ]
                [ S.text label ]
    in
    entries
        |> List.indexedMap (\i entry -> ( entry, toFloat i * baseWidth + leftPadding ))
        |> List.map createLabel


chart : List Entry -> Html msg
chart entries =
    let
        knitted =
            entries |> List.head |> Maybe.map .knitted |> Maybe.withDefault False

        barStyleVariation _ { highlight } =
            if not highlight then
                [ CA.opacity 0.35 ]

            else
                []

        barsData =
            -- There's an unfortunate bug in elm-charts where legend colors are inverted
            -- see https://github.com/terezka/elm-charts/issues/101
            -- FIXME: once an official fix is released, the expected implementation is:
            -- [ ( "Matière", .materialAndSpinning )
            -- , ( if knitted then
            --       "Tricotage"
            --     else
            --       "Tissage"
            --   , .weavingKnitting
            --   )
            -- , ( "Teinture", .dyeing )
            -- , ( "Confection", .making )
            -- , ( "Transport", .transport )
            -- ]
            [ "Matière"
            , if knitted then
                "Tricotage"

              else
                "Tissage"
            , "Teinture"
            , "Confection"
            , "Transport"
            ]
                |> LE.zip
                    (List.reverse
                        [ .materialAndSpinning
                        , .weavingKnitting
                        , .dyeing
                        , .making
                        , .transport
                        ]
                    )

        bars =
            [ entries
                |> C.bars [ CA.margin 0.28 ]
                    [ barsData
                        |> List.map
                            (\( getter, label ) ->
                                C.bar getter []
                                    |> C.named label
                                    |> C.variation barStyleVariation
                            )
                        |> C.stacked
                    ]
            ]

        xLabels =
            [ C.binLabels (\{ kgCo2e } -> Format.formatFloat 2 kgCo2e ++ "\u{202F}kgCO₂e")
                [ CA.moveDown 23, CA.color chartTextColor, CA.attrs [ SA.fontSize "12" ] ]
            ]

        yLabels =
            [ C.yLabels [ CA.withGrid, CA.fontSize 13, CA.color chartTextColor ] ]

        legends =
            [ C.legendsAt
                (\{ max } -> max / 2)
                (\{ max } -> max * 1.15)
                [ CA.alignMiddle ]
                [ CA.spacing 2, CA.fontSize 11 ]
            ]

        verticalLabels =
            fillLabels entries
    in
    [ xLabels, yLabels, bars, legends, verticalLabels ]
        |> List.concat
        |> C.chart
            [ CA.height 250
            , CA.width 550
            , CA.margin { top = 22, bottom = 10, left = 22, right = -10 }
            ]
