module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Impact.Definition as Definition
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
    {}


type Msg
    = UpdateEcotoxWeighting (Maybe Unit.Ratio)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( {}
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        UpdateEcotoxWeighting (Just ratio) ->
            ( model, session |> Session.updateEcotoxWeighting ratio, Cmd.none )

        UpdateEcotoxWeighting Nothing ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view { textileDb } _ =
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
                            , th [ scope "col" ] [ text "Pondération PEF" ]
                            , th [ scope "col" ] [ text "Pondération ECS" ]
                            ]
                        ]
                    , textileDb.impactDefinitions
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
                                                    [ case Maybe.map .weighting def.pefData of
                                                        Just pefWeighting ->
                                                            pefWeighting
                                                                |> Unit.ratioToFloat
                                                                |> (*) 100
                                                                |> Format.percent

                                                        Nothing ->
                                                            text "N/A"
                                                    ]
                                                , td [ class "text-end", style "max-width" "100px" ]
                                                    [ if def.trigram == Definition.EtfC then
                                                        input
                                                            [ type_ "number"
                                                            , class "form-control text-end"
                                                            , step "0.1"
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
                                                                    >> Maybe.map (clamp 0 25 >> Unit.ratio)
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
                , textileDb.impactDefinitions
                    |> Definition.toList
                    |> List.filterMap (.ecoscoreData >> Maybe.map (.weighting >> Unit.ratioToFloat))
                    |> List.sum
                    |> (*) 100
                    |> Format.percent
                ]
            ]
      ]
    )
