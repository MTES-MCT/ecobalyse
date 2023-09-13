module Views.Textile.Summary exposing (view)

import Data.Impact as Impact
import Data.Impact.Definition exposing (Definition)
import Data.Session exposing (Session)
import Data.Textile.Inputs as Inputs
import Data.Textile.Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode
import Route
import Views.Alert as Alert
import Views.Component.Summary as SummaryComp
import Views.Format as Format
import Views.ImpactTabs as ImpactTabs


type alias Config msg =
    { session : Session
    , impact : Definition
    , activeImpactsTab : ImpactTabs.Tab
    , switchImpactsTab : ImpactTabs.Tab -> msg
    }


mainSummaryView : Config msg -> Simulator -> Html msg
mainSummaryView { impact } { inputs, impacts } =
    SummaryComp.view
        { header = []
        , body =
            [ div [ class "d-flex flex-column m-auto gap-1 px-2 text-center text-nowrap" ]
                [ div [ class "display-3 lh-1" ]
                    [ impacts
                        |> Format.formatImpact impact
                    ]
                ]
            ]
        , footer =
            [ div [ class "w-100" ]
                [ div [ class "text-center" ]
                    [ text "Pour "
                    , Format.kg inputs.mass
                    ]
                ]
            ]
        }


summaryChartsView : Config msg -> Simulator -> List (Html msg)
summaryChartsView { session, impact, activeImpactsTab, switchImpactsTab } ({ inputs } as simulator) =
    [ simulator
        |> ImpactTabs.textileSimulatorToImpactTabsConfig session.textileDb.impactDefinitions impact.trigram
        |> ImpactTabs.view session.textileDb.impactDefinitions activeImpactsTab switchImpactsTab
    , div [ class "card-footer text-center" ]
        [ a
            [ class "btn btn-primary w-100"
            , inputs
                |> Inputs.toQuery
                |> Just
                |> Route.TextileSimulator Impact.default ViewMode.Simple
                |> Route.href
            ]
            [ text "Reprendre cette simulation" ]
        ]
    ]


view : Config msg -> Result String Simulator -> List (Html msg)
view config result =
    case result of
        Ok simulator ->
            mainSummaryView config simulator
                :: summaryChartsView config simulator

        Err error ->
            [ Alert.simple
                { level = Alert.Info
                , content = [ text error ]
                , title = Just "Impossible de charger l'exemple"
                , close = Nothing
                }
            ]
