module Views.Summary exposing (view)

import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.LifeCycle as LifeCycle
import Data.Material as Material
import Data.Session exposing (Session)
import Data.Simulator exposing (Simulator)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route(..))
import Views.Alert as Alert
import Views.BarChart as Chart
import Views.Comparator as Comparator
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link
import Views.Transport as TransportView


type alias Config =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional
    , reusable : Bool
    }


summaryView : Config -> Simulator -> Html msg
summaryView { session, impact, funit, reusable } ({ inputs, lifeCycle } as simulator) =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header text-white bg-primary d-flex justify-content-between" ]
            [ span [ class "text-nowrap" ] [ strong [] [ text inputs.product.name ] ]
            , span
                [ class "text-truncate", title inputs.material.name ]
                [ text <| "\u{00A0}" ++ Material.fullName inputs.recycledRatio inputs.material ++ "\u{00A0}" ]
            , span [ class "text-nowrap" ] [ Format.kg inputs.mass ]
            , span [ class "text-nowrap" ] [ Icon.day, Format.days simulator.daysOfWear ]
            ]
        , div [ class "card-body px-1 py-2 py-sm-3 d-grid gap-2 gap-sm-3 text-white bg-primary" ]
            [ div [ class "d-flex justify-content-center align-items-center" ]
                [ img
                    [ src <| "img/product/" ++ inputs.product.name ++ ".svg"
                    , alt <| inputs.product.name
                    , class "SummaryProductImage invert me-2"
                    ]
                    []
                , div [ class "SummaryScore d-flex flex-column" ]
                    [ div [ class "display-5" ]
                        [ simulator.impacts
                            |> Format.formatImpact funit impact simulator.daysOfWear
                        ]
                    , small [ class "SummaryScoreFunit text-end" ]
                        [ Unit.functionalToString funit
                            |> text
                        ]
                    ]
                ]
            , inputs
                |> Inputs.countryList
                |> List.take 5
                |> List.map (\{ name } -> li [] [ span [] [ text name ] ])
                |> ul [ class "Chevrons" ]
            , lifeCycle
                |> LifeCycle.computeTotalTransportImpacts session.db
                |> TransportView.view
                    { fullWidth = False
                    , airTransportLabel = Just "Transport aérien total"
                    , seaTransportLabel = Just "Transport maritime total"
                    , roadTransportLabel = Just "Transport routier total"
                    }
            ]
        , details [ class "card-body p-2 border-bottom" ]
            [ summary [ class "text-muted fs-7" ] [ text "Détails des postes" ]
            , Chart.view
                { simulator = simulator
                , impact = impact
                , funit = funit
                }
            ]

        -- , div [ class "d-none d-sm-block card-body" ]
        --     -- TODO: how/where to render this for smaller viewports?
        --     [ Comparator.view
        --         { session = session
        --         , impact = impact
        --         , funit = funit
        --         , simulator = simulator
        --         }
        --     ]
        , div [ class "d-none d-sm-block card-body text-center text-muted fs-7 px-2 py-2" ]
            [ [ text "Comparaison pour"
              , text simulator.inputs.product.name
              , text "en"
              , simulator.inputs.material |> Material.fullName simulator.inputs.recycledRatio |> text
              , text "de"
              , Format.kg simulator.inputs.mass
              , span [ class "text-nowrap" ]
                    [ funit |> Unit.functionalToString |> text
                    , Link.smallPillExternal
                        [ class "ms-0"
                        , href "https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/echelle-comparative"
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
                            |> Route.Simulator Impact.defaultTrigram Unit.PerItem
                        )
                    ]
                    [ text "Reprendre cette simulation" ]
                ]

          else
            text ""
        ]


view : Config -> Result String Simulator -> Html msg
view config result =
    case result of
        Ok simulator ->
            summaryView config simulator

        Err error ->
            Alert.simple
                { level = Alert.Info
                , content = [ text error ]
                , title = Just "Impossible de charger l'exemple"
                , close = Nothing
                }
