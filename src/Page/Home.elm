module Page.Home exposing (Model, Msg, init, update, view)

import Data.Inputs as Inputs
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Column as Column
import Views.Container as Container
import Views.Summary as SummaryView


type alias Model =
    ()


type Msg
    = NoOp


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( (), session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ _ =
    ( "Accueil"
    , [ div [ class "d-flex flex-column gap-5" ]
            [ Container.centered []
                [ div [ class "row align-items-center", style "min-height" "52vh" ]
                    [ div [ class "col-lg-7 text-center" ]
                        [ h2 [ class "display-5" ]
                            [ text "Quels sont les impacts de nos achats sur la planète ?" ]
                        , p [ class "fs-4 text-muted my-5" ]
                            [ text "Comprendre, contribuer et faire émerger des valeurs de référence" ]
                        , div [ class "row mb-4" ]
                            [ div [ class "col-md-6 text-center text-md-end py-2" ]
                                [ a [ class "btn btn-lg btn-primary", Route.href (Route.Simulator Nothing) ]
                                    [ text "Faire une simulation" ]
                                ]
                            , div [ class "col-md-6 text-center text-md-start py-2" ]
                                [ a [ class "btn btn-lg btn-secondary", Route.href Route.Examples ]
                                    [ text "voir des exemples" ]
                                ]
                            ]
                        ]
                    , div [ class "col-lg-5" ]
                        [ Inputs.tShirtCotonFrance
                            |> Simulator.compute
                            |> SummaryView.view False
                        ]
                    ]
                ]
            , Container.full [ class "bg-primary shadow-lg text-light-all" ]
                [ Container.centered []
                    [ Column.create []
                        [ blockquote [ class "fs-5" ]
                            [ p [] [ text "74% des Français aimeraient avoir plus d’informations sur l’impact environnemental et sociétal des produits qu’ils achètent" ]
                            ]
                        , p [ class "text-center fs-7 mb-0" ]
                            [ a
                                [ class "text-light"
                                , target "_blank"
                                , href "https://presse.ademe.fr/wp-content/uploads/2021/05/CP-Barometre-de-la-consommation-responsable-Version-Finale.pdf"
                                ]
                                [ text "14ème baromètre de la consommation responsable Greenflex et ADEME - 2021" ]
                            ]
                        ]
                        |> Column.addMd []
                            [ "Répondant à cette demande, [la loi Climat et Résilience rend obligatoire l'affichage environnemental](https://www.legifrance.gouv.fr/loda/article_lc/LEGIARTI000043957692)."
                            , "La mise en œuvre de cette nouvelle obligation va prendre du temps et **nécessite un travail collectif**."
                            ]
                        |> Column.render [ class "d-flex align-items-center py-5" ]
                    ]
                ]
            , Container.full []
                [ Container.centered []
                    [ Column.createMd []
                        [ """Wikicarbone est un projet de la **Fabrique Numérique du ministère de la transition écologique**, avec l'appui de
                             [beta.gouv.fr](https://beta.gouv.fr), l'incubateur des services publics numériques. Il est en phase de construction
                             depuis le 1er juillet 2021."""
                        , "Tout est provisoire, y compris le nom ! Dans un premier temps, **les travaux se concentrent sur la filière textile**."
                        ]
                        |> Column.addMd []
                            [ """Wikicarbone doit être un **outil pédagogique** pour mieux comprendre les **impacts environnementaux de nos produits**,
                                 en s'appuyant sur les **méthodes de référence** (Base Impacts ADEME, PEF européen)."""
                            , "Il doit être **accessible à tous**, y compris des PME/TPE voire des consommateurs curieux."
                            ]
                        |> Column.render [ class "d-flex align-items-center" ]
                    ]
                ]
            ]
      ]
    )
