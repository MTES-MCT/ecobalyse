module Views.Textile.Comparator exposing
    ( Entry
    , chart
    , createEntry
    , view
    )

import Chart as C
import Chart.Attributes as CA
import Data.Country as Country
import Data.Impact as Impact
import Data.Session exposing (Session)
import Data.Textile.Db exposing (Db)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Product as Product
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Duration exposing (Duration)
import Html exposing (..)
import Html.Attributes exposing (..)
import Quantity
import Result.Extra as RE
import Svg as S
import Svg.Attributes as SA
import Views.Alert as Alert
import Views.Dataviz as Dataviz
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
    , material : Float
    , spinning : Float
    , weavingKnitting : Float
    , ennobling : Float
    , making : Float
    , use : Float
    , endOfLife : Float
    , transport : Float
    }


createEntry :
    Db
    -> Unit.Functional
    -> Impact.Definition
    -> { highlight : Bool, label : String }
    -> Inputs.Query
    -> Result String Entry
createEntry db funit { trigram } { highlight, label } query =
    query
        |> Simulator.compute db
        |> Result.map
            (\({ lifeCycle, inputs, daysOfWear, transport } as simulator) ->
                let
                    stepScore stepLabel =
                        lifeCycle
                            |> LifeCycle.getStepProp stepLabel
                                (.impacts >> Impact.getImpact trigram)
                                Quantity.zero
                            |> Unit.inFunctionalUnit funit daysOfWear
                            |> Unit.impactToFloat
                in
                { label = label
                , highlight = highlight
                , knitted = Product.isKnitted inputs.product
                , score = Impact.grabImpactFloat funit daysOfWear trigram simulator
                , material = stepScore Label.Material
                , spinning = stepScore Label.Spinning
                , weavingKnitting = stepScore Label.Fabric
                , ennobling = stepScore Label.Ennobling
                , making = stepScore Label.Making
                , use = stepScore Label.Use
                , endOfLife = stepScore Label.EndOfLife
                , transport = Impact.grabImpactFloat funit daysOfWear trigram transport
                }
            )


fromUserQuery : Inputs.Query -> Inputs.Query
fromUserQuery query =
    { query
        | airTransportRatio = Nothing
        , quality = Just Unit.standardQuality
        , reparability = Just Unit.standardReparability
        , makingWaste = Nothing
        , picking = Nothing
        , surfaceMass = Nothing
        , disabledSteps = []
        , disabledFading = Nothing
        , dyeingMedium = Nothing
        , printing = Nothing
    }


toCountry : Country.Code -> Inputs.Query -> Inputs.Query
toCountry code query =
    { query
        | countryFabric = code
        , countryDyeing = code
        , countryMaking = code
    }


getEntries : Db -> Unit.Functional -> Impact.Definition -> Inputs -> Result String (List Entry)
getEntries db funit impact inputs =
    let
        query =
            Inputs.toQuery inputs

        currentName =
            "Votre simulation, Q="
                ++ (query.quality
                        |> Maybe.withDefault Unit.standardQuality
                        |> Unit.qualityToFloat
                        |> String.fromFloat
                   )
                ++ ", R="
                ++ (query.reparability
                        |> Maybe.withDefault Unit.standardReparability
                        |> Unit.reparabilityToFloat
                        |> String.fromFloat
                   )

        createEntry_ =
            createEntry db funit impact

        entries =
            [ query
                |> createEntry_ { highlight = True, label = currentName }
            , fromUserQuery query
                |> toCountry (Country.Code "FR")
                |> createEntry_ { highlight = False, label = "France, Q=1" }
            , fromUserQuery query
                |> toCountry (Country.Code "PT")
                |> createEntry_ { highlight = False, label = "Portugal, Q=1" }
            , fromUserQuery query
                |> toCountry (Country.Code "IN")
                |> createEntry_ { highlight = False, label = "Inde, Q=1" }
            ]
    in
    entries
        |> RE.combine
        |> Result.map (List.sortBy .score)


view : Config -> Html msg
view { session, impact, funit, simulator } =
    case simulator.inputs |> getEntries session.db funit impact of
        Ok entries ->
            entries
                |> chart
                    { funit = funit
                    , impact = impact
                    , daysOfWear = simulator.daysOfWear
                    , size = Nothing
                    , margins = Nothing
                    }

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


ellipsis : Int -> String -> String
ellipsis n str =
    if n < String.length str then
        String.slice 0 n str ++ "…"

    else
        str


{-| Create vertical labels from percentages on the x-axis.
-}
fillLabels : List Entry -> List (C.Element data msg)
fillLabels entries =
    let
        baseWidth =
            100 / toFloat (clamp 1 100 (List.length entries))

        leftPadding =
            baseWidth / 4.5

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
                        SA.fontWeight "500"

                      else
                        SA.fontWeight "normal"
                    ]
                ]
                [ label
                    |> ellipsis 58
                    |> S.text
                ]
    in
    entries
        |> List.indexedMap (\i entry -> ( entry, toFloat i * baseWidth + leftPadding ))
        |> List.map createLabel


formatLabel : Unit.Functional -> Impact.Definition -> Duration -> Float -> { x : String, y : String }
formatLabel funit { unit } daysOfWear num =
    let
        inFunctionalUnit =
            case funit of
                Unit.PerDayOfWear ->
                    num / Duration.inDays daysOfWear

                Unit.PerItem ->
                    num
    in
    { x = Format.formatFloat 2 inFunctionalUnit ++ "\u{202F}" ++ unit
    , y = Format.formatFloat 2 inFunctionalUnit
    }


type alias ChartOptions =
    { funit : Unit.Functional
    , impact : Impact.Definition
    , daysOfWear : Duration
    , size : Maybe ( Float, Float )
    , margins : Maybe { top : Float, bottom : Float, left : Float, right : Float }
    }


chart : ChartOptions -> List Entry -> Html msg
chart { funit, impact, daysOfWear, size, margins } entries =
    let
        knitted =
            entries |> List.head |> Maybe.map .knitted |> Maybe.withDefault False

        barStyleVariation _ { highlight } =
            if not highlight then
                [ CA.opacity 0.35 ]

            else
                []

        bars =
            [ entries
                |> C.bars [ CA.margin 0.28 ]
                    [ Dataviz.stepsLegendData { knitted = knitted }
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
            [ C.binLabels (.score >> formatLabel funit impact daysOfWear >> .x)
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
                , CA.format (formatLabel funit impact daysOfWear >> .y)
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
            [ CA.width (size |> Maybe.map Tuple.first |> Maybe.withDefault 550)
            , CA.height (size |> Maybe.map Tuple.second |> Maybe.withDefault 250)
            , CA.margin (margins |> Maybe.withDefault { top = 22, bottom = 10, left = 40, right = 0 })
            , CA.htmlAttrs [ class "ComparatorChart" ]
            ]
