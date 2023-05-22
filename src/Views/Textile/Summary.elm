module Views.Textile.Summary exposing (view)

import Array
import Chart.Item as CI
import Data.Country as Country
import Data.Env as Env
import Data.Impact as Impact
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
import Views.Link as Link
import Views.Textile.BarChart as Chart
import Views.Textile.ComparativeChart as Comparator
import Views.Textile.Step as StepView
import Views.Transport as TransportView


type alias Config msg =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional
    , reusable : Bool
    , hovering : List (CI.Many Comparator.Entry CI.Any)
    , onHover : List (CI.Many Comparator.Entry CI.Any) -> msg
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
mainSummaryView { session, impact, funit } { inputs, impacts, daysOfWear, lifeCycle } =
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
                |> LifeCycle.computeTotalTransportImpacts session.db
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
summaryChartsView { session, impact, funit, reusable, hovering, onHover } ({ inputs } as simulator) =
    div [ class "card shadow-sm" ]
        [ details [ class "card-body p-2 border-bottom" ]
            [ summary [ class "text-muted fs-7" ] [ text "Détails des postes" ]
            , Chart.view
                { simulator = simulator
                , impact = impact
                , funit = funit
                }
            ]
        , div
            [ class "d-none d-sm-block card-body" ]
            -- TODO: how/where to render this for smaller viewports?
            [ Comparator.view
                { session = session
                , impact = impact
                , funit = funit
                , simulator = simulator
                , hovering = hovering
                , onHover = onHover
                }
            ]
        , div [ class "d-none d-sm-block card-body text-center text-muted fs-7 px-2 py-2" ]
            [ [ text "Comparaison pour"
              , text <| simulator.inputs.product.name ++ ", "
              , viewMaterials simulator.inputs.materials
              , text "de"
              , Format.kg simulator.inputs.mass
              , span [ class "text-nowrap" ]
                    [ funit |> Unit.functionalToString |> text
                    , Link.smallPillExternal
                        [ class "ms-0"
                        , title "Accéder à la documentation"
                        , href (Env.gitbookUrl ++ "/methodologie/echelle-comparative")
                        ]
                        [ Icon.info ]
                    ]
              ]
                |> List.intersperse (text " ")
                |> span []
            ]
        , if reusable then
            div [ class "card-footer text-center" ]
                [ a
                    [ class "btn btn-primary"
                    , Route.href
                        (inputs
                            |> Inputs.toQuery
                            |> Just
                            |> Route.TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple
                        )
                    ]
                    [ text "Reprendre cette simulation" ]
                ]

          else
            text ""
        ]


view : Config msg -> Result String Simulator -> Html msg
view config result =
    case result of
        Ok simulator ->
            div [ class "stacked-card" ]
                [ mainSummaryView config simulator
                , summaryChartsView config simulator
                ]

        Err error ->
            Alert.simple
                { level = Alert.Info
                , content = [ text error ]
                , title = Just "Impossible de charger l'exemple"
                , close = Nothing
                }
