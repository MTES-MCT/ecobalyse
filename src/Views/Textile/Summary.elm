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
import Views.ImpactTabs as ImpactTabs
import Views.Score as ScoreView


type alias Config msg =
    { session : Session
    , impact : Definition
    , activeImpactsTab : ImpactTabs.Tab
    , switchImpactsTab : ImpactTabs.Tab -> msg
    }


summaryChartsView : Config msg -> Simulator -> List (Html msg)
summaryChartsView { session, impact, activeImpactsTab, switchImpactsTab } ({ inputs } as simulator) =
    [ simulator
        |> ImpactTabs.configForTextile session.textileDb.impactDefinitions impact.trigram
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


view : Config msg -> Simulator -> List (Html msg)
view config simulator =
    ScoreView.view
        { impactDefinition = config.impact
        , score = simulator.impacts
        , mass = simulator.inputs.mass
        }
        :: summaryChartsView config simulator
