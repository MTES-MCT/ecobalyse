module Views.Comparator exposing (view)

import Chart as C
import Chart.Attributes as CA
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle
import Data.Product as Product
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Quantity
import Result.Extra as RE
import Svg as S
import Svg.Attributes as SA
import Views.Alert as Alert
import Views.Format as Format


type alias Config =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional
    , simulator : Simulator
    }


type alias Entry =
    { label : String
    , highlight : Bool
    , knitted : Bool
    , score : Float
    , materialAndSpinning : Float
    , weavingKnitting : Float
    , dyeing : Float
    , making : Float
    , use : Float
    , endOfLife : Float
    , transport : Float
    }


toRecycledFrance : Inputs.Query -> ( String, Inputs.Query )
toRecycledFrance query =
    ( "France 100% recyclé"
    , { query
        | countryFabric = Country.Code "FR"
        , countryDyeing = Country.Code "FR"
        , countryMaking = Country.Code "FR"
        , dyeingWeighting = Just (Unit.ratio 0)
        , airTransportRatio = Just (Unit.ratio 0)
        , recycledRatio = Just (Unit.ratio 1)
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledFrance : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledFrance query =
    ( "France 0% recyclé"
    , { query
        | countryFabric = Country.Code "FR"
        , countryDyeing = Country.Code "FR"
        , countryMaking = Country.Code "FR"
        , dyeingWeighting = Just (Unit.ratio 0)
        , airTransportRatio = Just (Unit.ratio 0)
        , recycledRatio = Just (Unit.ratio 0)
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toPartiallyRecycledIndiaTurkey : Inputs.Query -> ( String, Inputs.Query )
toPartiallyRecycledIndiaTurkey query =
    ( "Inde-Turquie 20% recyclé"
    , { query
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "TR"
        , countryMaking = Country.Code "TR"
        , dyeingWeighting = Just (Unit.ratio 0.5)
        , airTransportRatio = Just (Unit.ratio 0)
        , recycledRatio = Just (Unit.ratio 0.2)
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledIndiaTurkey : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledIndiaTurkey query =
    ( "Inde-Turquie 0% recyclé"
    , { query
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "TR"
        , countryMaking = Country.Code "TR"
        , dyeingWeighting = Just (Unit.ratio 0.5)
        , airTransportRatio = Just (Unit.ratio 0)
        , recycledRatio = Just (Unit.ratio 0)
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toRecycledIndia : Inputs.Query -> ( String, Inputs.Query )
toRecycledIndia query =
    ( "Inde 100% recyclé"
    , { query
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "IN"
        , countryMaking = Country.Code "IN"
        , dyeingWeighting = Just (Unit.ratio 1)
        , airTransportRatio = Just (Unit.ratio 1)
        , recycledRatio = Just (Unit.ratio 1)
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledIndia : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledIndia query =
    ( "Inde 0% recyclé"
    , { query
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "IN"
        , countryMaking = Country.Code "IN"
        , dyeingWeighting = Just (Unit.ratio 1)
        , airTransportRatio = Just (Unit.ratio 1)
        , recycledRatio = Just (Unit.ratio 0)
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


createEntry : Db -> Unit.Functional -> Impact.Definition -> Bool -> ( String, Inputs.Query ) -> Result String Entry
createEntry db funit { trigram } highlight ( label, query ) =
    query
        |> Simulator.compute db
        |> Result.map
            (\({ lifeCycle, inputs, transport } as simulator) ->
                let
                    daysOfWear =
                        case funit of
                            Unit.PerDayOfWear ->
                                inputs.product
                                    |> Product.customDaysOfWear inputs.useNbCycles

                            Unit.PerItem ->
                                1

                    stepScore stepLabel =
                        lifeCycle
                            |> LifeCycle.getStepProp stepLabel
                                (.impacts >> Impact.getImpact trigram)
                                Quantity.zero
                            |> Quantity.divideBy (toFloat daysOfWear)
                            |> Unit.impactToFloat
                in
                { label = label
                , highlight = highlight
                , knitted = inputs.product.knitted
                , score = Impact.grabImpactFloat trigram simulator
                , materialAndSpinning = stepScore Step.MaterialAndSpinning
                , weavingKnitting = stepScore Step.WeavingKnitting
                , dyeing = stepScore Step.Ennoblement
                , making = stepScore Step.Making
                , use = stepScore Step.Use
                , endOfLife = stepScore Step.EndOfLife
                , transport = Impact.grabImpactFloat trigram transport
                }
            )


getEntries : Db -> Unit.Functional -> Impact.Definition -> Inputs -> Result String (List Entry)
getEntries db funit impact ({ material } as inputs) =
    let
        query =
            Inputs.toQuery inputs

        createEntry_ =
            createEntry db funit impact

        entries =
            if material.recycledProcess /= Nothing then
                [ ( "Votre simulation", query ) |> createEntry_ True -- user simulation
                , query |> toRecycledFrance |> createEntry_ False
                , query |> toNonRecycledFrance |> createEntry_ False
                , query |> toPartiallyRecycledIndiaTurkey |> createEntry_ False
                , query |> toRecycledIndia |> createEntry_ False
                , query |> toNonRecycledIndia |> createEntry_ False
                ]

            else
                [ ( "Votre simulation", query ) |> createEntry_ True -- user simulation
                , query |> toNonRecycledFrance |> createEntry_ False
                , query |> toNonRecycledIndiaTurkey |> createEntry_ False
                , query |> toNonRecycledIndia |> createEntry_ False
                ]
    in
    entries
        |> RE.combine
        |> Result.map (List.sortBy .score)


view : Config -> Html msg
view { session, impact, funit, simulator } =
    case simulator.inputs |> getEntries session.db funit impact of
        Ok entries ->
            chart impact entries

        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = Just "Erreur"
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


formatLabel : Impact.Definition -> Float -> { x : String, y : String }
formatLabel { unit } num =
    { x = Format.formatFloat 2 num ++ "\u{202F}" ++ unit
    , y = Format.formatFloat 2 num
    }


chart : Impact.Definition -> List Entry -> Html msg
chart impact entries =
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
            -- , ( "Utilisation", .use )
            -- ]
            [ "Matière"
            , if knitted then
                "Tricotage"

              else
                "Tissage"
            , "Teinture"
            , "Confection"
            , "Transport"
            , "Utilisation"
            , "Fin de vie"
            ]
                |> LE.zip
                    (List.reverse
                        [ .materialAndSpinning
                        , .weavingKnitting
                        , .dyeing
                        , .making
                        , .transport
                        , .use
                        , .endOfLife
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
            [ C.binLabels (.score >> formatLabel impact >> .x)
                [ CA.moveDown 23
                , CA.color chartTextColor
                , CA.rotate 12
                , CA.attrs [ SA.fontSize "12" ]
                ]
            ]

        yLabels =
            [ C.yLabels
                [ CA.withGrid
                , CA.fontSize 11
                , CA.color chartTextColor
                , CA.format (formatLabel impact >> .y)
                ]
            ]

        legends =
            [ C.legendsAt
                .min
                .max
                [ CA.alignMiddle
                , CA.htmlAttrs [ class "ComparatorChartLegends" ]
                , CA.moveDown 20
                ]
                [ CA.spacing 3
                , CA.fontSize 12
                , CA.htmlAttrs [ class "ComparatorChartLegend" ]
                ]
            ]

        verticalLabels =
            fillLabels entries
    in
    [ xLabels, yLabels, bars, legends, verticalLabels ]
        |> List.concat
        |> C.chart
            [ CA.height 250
            , CA.width 550
            , CA.margin { top = 22, bottom = 10, left = 40, right = 0 }
            , CA.htmlAttrs [ class "ComparatorChart" ]
            ]
