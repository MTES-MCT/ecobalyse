module Views.Comparator exposing (..)

import Chart as C
import Chart.Attributes as CA
import Data.Co2 as Co2
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Inputs as Inputs
import Data.LifeCycle as LifeCycle
import Data.Material as Material
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
import Views.Button as Button
import Views.Format as Format
import Views.Icon as Icon


type alias Config msg =
    { session : Session
    , simulator : Simulator
    , openDocModal : Gitbook.Path -> msg
    }


type alias Entry =
    { label : String
    , highlight : Bool
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


toIndiaTurkeyPartiallyRecycled : Inputs.Query -> ( String, Inputs.Query )
toIndiaTurkeyPartiallyRecycled query =
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
                >> Result.fromMaybe "Impact d'étape non trouvé"
    in
    query
        |> Simulator.compute db
        |> Result.andThen
            (\{ lifeCycle, transport, co2 } ->
                Ok (Entry label highlight (Co2.inKgCo2e co2))
                    |> RE.andMap (stepCo2Float Step.MaterialAndSpinning lifeCycle)
                    |> RE.andMap (stepCo2Float Step.WeavingKnitting lifeCycle)
                    |> RE.andMap (stepCo2Float Step.Ennoblement lifeCycle)
                    |> RE.andMap (stepCo2Float Step.Making lifeCycle)
                    |> RE.andMap (Ok (Co2.inKgCo2e transport.co2))
            )


getEntries : Db -> Inputs.Query -> Result String (List Entry)
getEntries db query =
    [ createEntry db True ( "Votre simulation", query )
    , query |> toRecycledFrance |> createEntry db False
    , query |> toNonRecycledFrance |> createEntry db False
    , query |> toIndiaTurkeyPartiallyRecycled |> createEntry db False
    , query |> toRecycledIndia |> createEntry db False
    , query |> toNonRecycledIndia |> createEntry db False
    ]
        |> RE.combine
        |> Result.map (List.sortBy .kgCo2e)


view : Config msg -> Html msg
view ({ session, simulator } as config) =
    case simulator.inputs |> Inputs.toQuery |> getEntries session.db of
        Ok result ->
            viewComparator config simulator.inputs result

        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = "Erreur"
                , content = [ text error ]
                }


onlyChart : Session -> Simulator -> Html msg
onlyChart session simulator =
    case simulator.inputs |> Inputs.toQuery |> getEntries session.db of
        Ok entries ->
            chart entries

        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = "Erreur"
                , content = [ text error ]
                }


viewComparator : Config msg -> Inputs.Inputs -> List Entry -> Html msg
viewComparator config inputs entries =
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ [ inputs.product.name
              , "en"
              , Material.fullName inputs.recycledRatio inputs.material
              , "de "
              ]
                |> String.join " "
                |> text
            , Format.kg inputs.mass
            , Button.smallPill
                [ onClick (config.openDocModal Gitbook.ComparativeScale) ]
                [ Icon.question ]
            ]
        , div [ class "card-body", style "padding" "20px 0 30px 40px" ]
            [ chart entries
            ]
        ]


{-| Create vertical labels from percentages on the x-axis.
-}
fillLabels : List String -> List (C.Element data msg)
fillLabels labels =
    let
        ( baseWidth, leftPadding ) =
            ( 100 / toFloat (clamp 1 100 (List.length labels))
            , 4.2
            )
    in
    labels
        |> List.indexedMap (\i label -> ( label, toFloat i * baseWidth + leftPadding ))
        |> List.map
            (\( label, x ) ->
                C.labelAt (CA.percent x)
                    (CA.percent 0)
                    [ CA.rotate 90, CA.attrs [ SA.fontSize "13", SA.style "text-anchor: start" ] ]
                    [ S.text label ]
            )


chart : List Entry -> Html msg
chart entries =
    let
        barStyleVariation _ { highlight } =
            if not highlight then
                [ CA.striped [] ]

            else
                []

        bars =
            [ entries
                |> C.bars [ CA.margin 0.32 ]
                    -- There's an unfortunate bug in elm-charts where legend colors are inverted
                    -- see https://github.com/terezka/elm-charts/issues/101
                    -- FIXME: once an official fix is released, the right implementation is:
                    -- [ [ ( "Matière", .materialAndSpinning )
                    --   , ( "Tissage/Tricotage", .weavingKnitting )
                    --   , ( "Teinture", .dyeing )
                    --   , ( "Confection", .making )
                    --   , ( "Transport", .transport )
                    --   ]
                    --     |> List.map
                    --         (\( label, getter ) ->
                    --             C.bar getter []
                    --                 |> C.named label
                    --                 |> C.variation barStyleVariation
                    --         )
                    --     |> C.stacked
                    -- ]
                    [ [ "Matière"
                      , "Tissage/Tricotage"
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
                [ CA.moveDown 23, CA.attrs [ SA.fontSize "12" ] ]
            ]

        yLabels =
            [ C.yLabels [ CA.withGrid, CA.fontSize 13 ] ]

        legends =
            [ C.legendsAt
                (\{ min } -> min - 0.3)
                (\{ max } -> max * 1.15)
                [ CA.spacing 7 ]
                [ CA.spacing 2, CA.fontSize 11 ]
            ]

        verticalLabels =
            entries |> List.map .label |> fillLabels
    in
    (xLabels ++ yLabels ++ bars ++ legends ++ verticalLabels)
        |> C.chart
            [ CA.height 250
            , CA.width 550
            , CA.margin { top = 20, bottom = 20, left = 22, right = -10 }
            ]
