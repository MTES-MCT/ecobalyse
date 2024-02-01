module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Impact.Definition as Definition exposing (Definitions, Trigram)
import Data.Session exposing (Session)
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
    = UpdateEcoscoreWeighting Trigram (Maybe Float)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { definitions = session.textileDb.impactDefinitions }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        UpdateEcoscoreWeighting trigram (Just float) ->
            ( { model
                | definitions =
                    model.definitions
                        |> Definition.update trigram
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

        UpdateEcoscoreWeighting _ Nothing ->
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
                                                , td []
                                                    [ input
                                                        [ type_ "number"
                                                        , class "form-control"
                                                        , step "0.0001"
                                                        , Unit.ratioToFloat ecoscoreData.weighting
                                                            |> String.fromFloat
                                                            |> value
                                                        , onInput (String.toFloat >> UpdateEcoscoreWeighting def.trigram)
                                                        ]
                                                        []
                                                    ]
                                                ]
                                        )
                            )
                        |> tbody []
                    , tbody []
                        [ tr []
                            [ td [ class "text-end", colspan 4 ] []
                            , td []
                                [ text "Total: "
                                , definitions
                                    |> Definition.toList
                                    |> List.filterMap (.ecoscoreData >> Maybe.map (.weighting >> Unit.ratioToFloat))
                                    |> List.sum
                                    |> String.fromFloat
                                    |> text
                                ]
                            ]
                        , tr []
                            [ td [ class "text-end", colspan 4 ] []
                            , td []
                                [ button
                                    [ class "btn btn-secondary w-100" ]
                                    [ text "Mettre à jour" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
      ]
    )
