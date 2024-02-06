module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import Views.Container as Container
import Views.Format as Format
import Views.Markdown as Markdown


type alias Model =
    { definitions : Definitions
    }


type Msg
    = Submit
    | UpdateEcotoxWeighting (Maybe Float)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { definitions = session.textileDb.impactDefinitions }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        Submit ->
            ( model
            , session
                |> Session.updateDbDefinitions model.definitions
                |> Session.notifyInfo "Coefficients de pondération mis à jour"
            , Ports.scrollTo { x = 0, y = 0 }
            )

        UpdateEcotoxWeighting (Just float) ->
            ( { model
                | definitions =
                    model.definitions
                        |> Definition.update Definition.EtfC
                            (\({ ecoscoreData } as definition) ->
                                { definition
                                    | ecoscoreData =
                                        ecoscoreData
                                            |> Maybe.map (\ecs -> { ecs | weighting = Unit.ratio float })
                                }
                            )
              }
            , session
            , Cmd.none
            )

        UpdateEcotoxWeighting Nothing ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ { definitions } =
    ( "Admin"
    , [ Container.centered [ class "pb-3" ]
            [ h1 [] [ text "Admin" ]
            , """Cette page permet de modifier les pondérations des impacts
                     composant le coût environnemental (ecs)."""
                |> Markdown.simple []
            , div [ class "table-responsive" ]
                [ table [ class "table table-striped align-middle" ]
                    [ thead []
                        [ tr []
                            [ th [ scope "col" ] [ text "Trigram" ]
                            , th [ scope "col" ] [ text "Nom" ]
                            , th [ scope "col" ] [ text "Source" ]
                            , th [ scope "col" ] [ text "Normalisation ECS" ]
                            , th [ scope "col" ] [ text "Pondération ECS" ]
                            ]
                        ]
                    , definitions
                        |> Definition.toList
                        |> List.filterMap
                            (\def ->
                                def.ecoscoreData
                                    |> Maybe.map
                                        (\ecoscoreData ->
                                            tr []
                                                [ th [] [ text <| Definition.toString def.trigram ]
                                                , td [] [ text def.label ]
                                                , td [] [ text def.source.label ]
                                                , td [ class "text-end" ]
                                                    [ ecoscoreData.normalization
                                                        |> Unit.impactToFloat
                                                        |> Format.formatFloat 2
                                                        |> text
                                                    ]
                                                , td [ class "text-end", style "max-width" "100px" ]
                                                    [ if def.trigram == Definition.EtfC then
                                                        input
                                                            [ type_ "number"
                                                            , class "form-control text-end"
                                                            , step "0.01"
                                                            , ecoscoreData.weighting
                                                                |> Unit.ratioToFloat
                                                                |> (*) 100
                                                                -- FIXME: move to some Math module?
                                                                |> ((*) 100 >> round >> (\x -> toFloat x / toFloat 100))
                                                                |> String.fromFloat
                                                                |> value
                                                            , onInput
                                                                (String.toFloat
                                                                    >> Maybe.map (\x -> x / toFloat 100)
                                                                    >> UpdateEcotoxWeighting
                                                                )
                                                            ]
                                                            []

                                                      else
                                                        ecoscoreData.weighting
                                                            |> Unit.ratioToFloat
                                                            |> (*) 100
                                                            |> Format.percent
                                                    ]
                                                ]
                                        )
                            )
                        |> tbody []
                    ]
                ]
            , div [ class "d-flex justify-content-end align-items-center gap-2", colspan 5 ]
                [ text "Total: "
                , definitions
                    |> Definition.toList
                    |> List.filterMap (.ecoscoreData >> Maybe.map (.weighting >> Unit.ratioToFloat))
                    |> List.sum
                    |> (*) 100
                    |> Format.percent
                , button
                    [ class "btn btn-secondary"
                    , onClick Submit
                    ]
                    [ text "Mettre à jour" ]
                ]
            ]
      ]
    )
