module Views.Textile.Summary exposing (view)

import Array
import Data.Country as Country
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definition)
import Data.Session exposing (Session)
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Product as Product
import Data.Textile.Simulator exposing (Simulator)
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode
import Route
import Views.Alert as Alert
import Views.Component.Summary as SummaryComp
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Textile.Step as StepView
import Views.Transport as TransportView


type alias Config msg =
    { session : Session
    , impact : Definition
    , funit : Unit.Functional
    , reusable : Bool
    , activeImpactsTab : ImpactTabs.Tab
    , switchImpactsTab : ImpactTabs.Tab -> msg
    }


viewMaterials : List Inputs.MaterialInput -> Html msg
viewMaterials materials =
    materials
        |> List.map
            (\{ material, share } ->
                span []
                    [ Format.splitAsPercentage share
                    , text " "
                    , text material.shortName
                    ]
            )
        |> List.intersperse (text ", ")
        |> span []


mainSummaryView : Config msg -> Simulator -> Html msg
mainSummaryView { impact, funit } { inputs, impacts, daysOfWear, lifeCycle } =
    SummaryComp.view
        { header =
            [ span [ class "text-nowrap" ]
                [ strong [] [ text inputs.product.name ] ]
            , span
                [ class "text-truncate" ]
                [ viewMaterials inputs.materials
                ]
            , span [ class "text-nowrap" ]
                [ Format.kg inputs.mass ]
            , span [ class "text-nowrap" ]
                [ Icon.day, Format.days daysOfWear ]
            ]
        , body =
            [ div [ class "d-flex justify-content-center align-items-center" ]
                [ img
                    [ src <| "img/product/" ++ Product.idToString inputs.product.id ++ ".svg"
                    , alt <| inputs.product.name
                    , class "SummaryProductImage invert me-2"
                    ]
                    []
                , div [ class "SummaryScore d-flex flex-column" ]
                    [ div [ class "display-5" ]
                        [ impacts
                            |> Format.formatTextileSelectedImpact funit daysOfWear impact
                        ]
                    , small [ class "SummaryScoreFunit text-end" ]
                        [ Unit.functionalToString funit
                            |> text
                        ]
                    ]
                ]
            , lifeCycle
                |> Array.toList
                |> List.filter .enabled
                |> List.take 5
                |> List.map
                    (\{ label, country } ->
                        li
                            [ class "cursor-help"
                            , title <| Label.toString label ++ ": " ++ country.name
                            ]
                            [ span [ class "d-flex gap-1 align-items-center" ]
                                [ span [ class "fs-6" ] [ StepView.stepIcon label ]
                                , text <| Country.codeToString country.code
                                ]
                            ]
                    )
                |> ul [ class "Chevrons" ]
            , lifeCycle
                |> LifeCycle.computeTotalTransportImpacts
                |> TransportView.view
                    { fullWidth = False
                    , hideNoLength = False
                    , onlyIcons = False
                    , airTransportLabel = Just "Transport aérien total"
                    , seaTransportLabel = Just "Transport maritime total"
                    , roadTransportLabel = Just "Transport routier total"
                    }
            ]
        , footer = []
        }


summaryChartsView : Config msg -> Simulator -> Html msg
summaryChartsView { session, impact, reusable, activeImpactsTab, switchImpactsTab } ({ inputs } as simulator) =
    div []
        [ simulator
            |> ImpactTabs.textileSimulatorToImpactTabsConfig session.db.impactDefinitions impact.trigram
            |> ImpactTabs.view session.db.impactDefinitions activeImpactsTab switchImpactsTab
        , if reusable then
            div [ class "card-footer text-center" ]
                [ a
                    [ class "btn btn-primary w-100"
                    , Route.href
                        (inputs
                            |> Inputs.toQuery
                            |> Just
                            |> Route.TextileSimulator Impact.default Unit.PerItem ViewMode.Simple
                        )
                    ]
                    [ text "Reprendre cette simulation" ]
                ]

          else
            text ""
        ]


view : Config msg -> Result String Simulator -> List (Html msg)
view config result =
    case result of
        Ok simulator ->
            [ mainSummaryView config simulator
            , summaryChartsView config simulator
            ]

        Err error ->
            [ Alert.simple
                { level = Alert.Info
                , content = [ text error ]
                , title = Just "Impossible de charger l'exemple"
                , close = Nothing
                }
            ]
