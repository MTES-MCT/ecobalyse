module Page.Examples exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Container as Container
import Views.Impact as ImpactView
import Views.Summary as SummaryView


type alias Model =
    { impact : Impact.Trigram
    , funit : Unit.Functional
    }


type Msg
    = SwitchImpact Impact.Trigram
    | SwitchFunctionalUnit Unit.Functional


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { impact = Impact.defaultTrigram
      , funit = Unit.PerItem
      }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        SwitchImpact impact ->
            ( { model | impact = impact }, session, Cmd.none )

        SwitchFunctionalUnit funit ->
            ( { model | funit = funit }, session, Cmd.none )


viewExample : Session -> Unit.Functional -> Impact.Trigram -> Inputs.Query -> Html msg
viewExample session funit impact query =
    query
        |> Simulator.compute session.db
        |> SummaryView.view
            { session = session
            , impact =
                Impact.getDefinition impact session.db.impacts
                    |> Result.withDefault Impact.invalid
            , funit = funit
            , reusable = True
            }
        |> (\v -> div [ class "col" ] [ v ])


view : Session -> Model -> ( String, List (Html Msg) )
view session { impact, funit } =
    ( "Exemples"
    , [ Container.centered [ class "pb-3" ]
            [ div [ class "row" ]
                [ div [ class "col-md-7 mb-2" ]
                    [ h1 [] [ text "Exemples de simulation" ] ]
                , div [ class "col-md-5 mb-2 d-flex align-items-center" ]
                    [ ImpactView.selector
                        { impacts = session.db.impacts
                        , selectedImpact = impact
                        , switchImpact = SwitchImpact
                        , selectedFunctionalUnit = funit
                        , switchFunctionalUnit = SwitchFunctionalUnit
                        }
                    ]
                ]
            , session.db.impacts
                |> Impact.getDefinition impact
                |> Result.map ImpactView.viewDefinition
                |> Result.withDefault (text "")
            , Inputs.presets
                |> List.map (viewExample session funit impact)
                |> div [ class "row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4" ]
            ]
      ]
    )
