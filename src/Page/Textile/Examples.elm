module Page.Textile.Examples exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope as Scope
import Data.Session exposing (Session)
import Data.Textile.Inputs as Inputs
import Data.Textile.Simulator as Simulator
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Container as Container
import Views.Impact as ImpactView
import Views.Textile.ComparativeChart as ComparativeChart
import Views.Textile.Summary as SummaryView


type alias Model =
    { impact : Definition.Trigram
    , funit : Unit.Functional
    , chartHovering : ComparativeChart.Stacks
    }


type Msg
    = OnChartHover ComparativeChart.Stacks
    | SwitchImpact (Maybe Definition.Trigram)
    | SwitchFunctionalUnit Unit.Functional


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { impact = Impact.defaultTextileTrigram
      , funit = Unit.PerItem
      , chartHovering = []
      }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        OnChartHover chartHovering ->
            ( { model | chartHovering = chartHovering }
            , session
            , Cmd.none
            )

        SwitchImpact (Just impact) ->
            ( { model | impact = impact }, session, Cmd.none )

        SwitchImpact Nothing ->
            ( model, session, Cmd.none )

        SwitchFunctionalUnit funit ->
            ( { model | funit = funit }, session, Cmd.none )


viewExample : Session -> Model -> Unit.Functional -> Definition.Trigram -> Inputs.Query -> Html Msg
viewExample session model funit impact query =
    query
        |> Simulator.compute session.db
        |> SummaryView.view
            { session = session
            , impact = Definition.get impact
            , funit = funit
            , reusable = True
            , chartHovering = model.chartHovering
            , onChartHover = OnChartHover
            }
        |> (\v -> div [ class "col" ] [ v ])


view : Session -> Model -> ( String, List (Html Msg) )
view session ({ impact, funit } as model) =
    ( "Exemples"
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "row" ]
                [ div [ class "col-md-7 mb-2" ]
                    [ h1 [] [ text "Exemples de simulation" ] ]
                , div [ class "col-md-5 mb-2 d-flex align-items-center" ]
                    [ ImpactView.selector
                        { selectedImpact = impact
                        , switchImpact = SwitchImpact
                        , selectedFunctionalUnit = funit
                        , switchFunctionalUnit = SwitchFunctionalUnit
                        , scope = Scope.Textile
                        }
                    ]
                ]
            , Definition.get impact
                |> ImpactView.viewDefinition
            , Inputs.presets
                |> List.map (viewExample session model funit impact)
                |> div [ class "row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4" ]
            ]
      ]
    )
