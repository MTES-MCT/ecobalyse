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
    ( { impact = Impact.trg "cch"
      , funit = Unit.PerItem
      }
    , session
    , Cmd.none
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
                    |> Result.withDefault Impact.default
            , funit = funit
            , reusable = True
            }
        |> (\v -> div [ class "col" ] [ v ])


viewExamples : Session -> Model -> Html Msg
viewExamples session { impact, funit } =
    div []
        [ div [ class "row mb-3 mb-sm-0" ]
            [ div [ class "col-md-7 col-lg-8 col-xl-9" ]
                [ h1 [ class "mb-3" ] [ text "Exemples de simulation" ]
                ]
            , div [ class "col-md-5 col-lg-4 col-xl-3 text-center text-md-end" ]
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


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Exemples"
    , [ Container.centered [ class "pb-5" ]
            [ viewExamples session model
            ]
      ]
    )
