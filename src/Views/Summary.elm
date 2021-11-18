module Views.Summary exposing (..)

import Data.Inputs as Inputs
import Data.LifeCycle as LifeCycle
import Data.Material as Material
import Data.Session exposing (Session)
import Data.Simulator exposing (Simulator)
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
    , reusable : Bool
    }


summaryView : Config -> Simulator -> Html msg
summaryView { session, reusable } ({ inputs, lifeCycle } as simulator) =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header text-white bg-primary d-flex justify-content-between" ]
            [ span [ class "text-nowrap" ] [ strong [] [ text inputs.product.name ] ]
            , span
                [ class "text-truncate", title inputs.material.name ]
                [ text <| "\u{00A0}" ++ Material.fullName inputs.recycledRatio inputs.material ++ "\u{00A0}" ]
            , span [ class "text-nowrap" ] [ strong [] [ Format.kg inputs.mass ] ]
            ]
        , div [ class "card-body px-1 d-grid gap-3 text-white bg-primary" ]
            [ div [ class "d-flex justify-content-center align-items-center" ]
                [ img
                    [ src <| "img/product/" ++ inputs.product.name ++ ".svg"
                    , alt <| inputs.product.name
                    , class "invert me-2"
                    , style "width" "3em"
                    , style "height" "3em"
                    ]
                    []
                , div [ class "display-5" ]
                    [ Format.kgCo2 2 simulator.co2 ]
                ]
            , inputs.countries
                |> List.map (\{ name } -> li [] [ span [] [ text name ] ])
                |> ul [ class "Chevrons" ]
            , lifeCycle
                |> LifeCycle.computeTotalTransports
                |> TransportView.view { fullWidth = False }
            ]
        , details [ class "d-none d-sm-block card-body p-2 border-bottom" ]
            -- TODO: render an horiz stacked barchart for smaller viewports?
            [ summary [ class "text-muted fs-7" ] [ text "Détails des postes" ]
            , Chart.view simulator
            ]
        , div [ class "d-none d-sm-block card-body" ]
            -- TODO: how/where to render this for smaller viewports?
            [ Comparator.view { session = session, simulator = simulator }
            ]
        , div [ class "d-none d-sm-block card-body text-center text-muted fs-7 px-2 py-2" ]
            [ [ "Comparaison pour"
              , simulator.inputs.product.name
              , "en"
              , Material.fullName simulator.inputs.recycledRatio simulator.inputs.material
              , "de "
              ]
                |> String.join " "
                |> text
            , Format.kg simulator.inputs.mass
            , Link.smallPillExternal
                [ href "https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/echelle-comparative" ]
                [ Icon.info ]
            ]
        , if reusable then
            div [ class "card-footer text-center" ]
                [ a
                    [ class "btn btn-primary"
                    , Route.href (Route.Simulator (inputs |> Inputs.toQuery |> Just))
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
                { level = Alert.Warning
                , content = [ text error ]
                , title = "Impossible de charger l'exemple"
                , close = Nothing
                }
