module Page.Home exposing (Model, Msg, init, update, view)

import Data.Inputs as Inputs
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Column as Column
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Markdown as Markdown
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
view { db } _ =
    ( "Accueil"
    , [ div [ class "d-flex flex-column gap-5" ]
            [ Container.centered []
                [ div [ class "row align-items-center", style "min-height" "57vh" ]
                    [ div [ class "col-lg-7 text-center" ]
                        [ h2 [ class "display-5" ]
                            [ text "Quels sont les impacts de nos achats sur la planète\u{00A0}?" ]
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
                            |> Simulator.compute db
                            |> SummaryView.view False
                        ]
                    ]
                ]
            , Container.full [ class "bg-primary-gradient shadow text-light-all" ]
                [ Container.centered []
                    [ Column.create
                        |> Column.add [ class "text-center px-3 px-sm-2" ]
                            [ blockquote [ class "fs-4 mb-1" ]
                                [ q [] [ text "74% des Français aimeraient avoir plus d’informations sur l’impact environnemental et sociétal des produits qu’ils achètent" ] ]
                            , p [ class "text-center" ]
                                [ text "Source\u{00A0}:\u{00A0}"
                                , Link.external
                                    [ class "text-light"
                                    , href "https://presse.ademe.fr/wp-content/uploads/2021/05/CP-Barometre-de-la-consommation-responsable-Version-Finale.pdf"
                                    ]
                                    [ text "14ème baromètre de la consommation responsable 2021" ]
                                ]
                            ]
                        |> Column.addMd [ class "fs-5 mt-1 px-4 px-sm-2" ]
                            """Répondant à cette demande, [la loi Climat et Résilience rend obligatoire l'affichage
                            environnemental](https://www.legifrance.gouv.fr/loda/article_lc/LEGIARTI000043957692).

                            La mise en œuvre de cette nouvelle obligation va prendre du temps et **nécessite un travail collectif**."""
                        |> Column.render [ class "d-flex align-items-start py-5" ]
                    ]
                ]
            , Container.full [ class "py-3" ]
                [ Container.centered []
                    [ Column.create
                        |> Column.add [ class "text-center px-lg-4" ]
                            [ h3 [ class "fw-light" ] [ span [ class "align-middle text-primary me-2" ] [ Icon.build ], text "Un projet en construction" ]
                            , hr [] []
                            , Markdown.simple [] """Incubé par la Fabrique Numérique du Ministère de la Transition Écologique et
                            [beta.gouv.fr](https://beta.gouv.fr/startups/wikicarbone.html), ce projet est en phase de construction depuis
                            le 1er juillet 2021.

                            Dans un premier temps, **les travaux se concentrent sur la filière textile**."""
                            ]
                        |> Column.add [ class "text-center px-lg-4" ]
                            [ h3 [ class "fw-light" ] [ span [ class "align-middle text-primary me-2" ] [ Icon.study ], text "Un outil pédagogique" ]
                            , hr [] []
                            , Markdown.simple [] """pour comprendre les **impacts environnementaux de nos produits**,
                            en s'appuyant sur les **méthodes de référence** (Base Impacts ADEME, PEF européen).

                            Il doit être **accessible à tous**, y compris des PME/TPE voire des consommateurs curieux."""
                            ]
                        |> Column.add [ class "text-center px-lg-4" ]
                            [ h3 [ class "fw-light" ] [ span [ class "align-middle text-primary me-2" ] [ Icon.globe ], text "Un commun numérique" ]
                            , hr [] []
                            , Markdown.simple [] """**Les producteurs et les entreprises textiles connaissent leurs produits**.

                            Au travers d'un **outil collaboratif**, leurs contributions sont nécessaires pour comprendre et évaluer au mieux les impacts."""
                            ]
                        |> Column.render []
                    ]
                ]
            , Container.full [ class "bg-info text-light-all py-5" ]
                [ Container.centered []
                    [ h2 [ class "fs-1 text-center fw-light mb-4" ] [ text "La démarche Wikicarbone" ]
                    , hr [ class "text-light" ] []
                    , Column.create
                        |> Column.addMd []
                            """Wikicarbone vise dans un premier temps à faire émerger des **valeurs d'impacts de référence**,
                            à partir de critères simples&nbsp;: matières, pays de confection, pays de teinture…

                            Ces valeurs ne doivent pas être regardées comme des évaluations précises d’impacts pour un produit
                            donné. Il s’agit tout au plus de **pré-évaluations**, de premiers éclairages&nbsp;: Quel est l’ordre
                            de grandeur&nbsp;? Comment le choix de pays peut influencer l’impact&nbsp;?…

                            Ces valeurs de référence doivent être **débattues** et devront ensuite être **confrontées** à des évaluations
                            précises pour en apprécier l’intérêt. Si elles apportent bien un premier éclairage pertinent, elles
                            seront **à la disposition de tous** pour informer les consommateurs, avant que chaque marque ne réalise une
                            évaluation précise de l’impact de ses produits."""
                        |> Column.addMd []
                            """Pour les produits alimentaires, c’est sur ce modèle qu’un collectif de 8 acteurs engagés du numérique
                            de l’alimentation ont proposé [un éco-score début 2021](https://fr.blog.openfoodfacts.org/news/lancement-de-l-eco-score-la-note-environnementale-des-produits-alimentaires).

                            Les valeurs d’impacts de référence de la base [Agribalyse](https://agribalyse.ademe.fr/), développée par
                            l’[ADEME](https://www.ademe.fr/), permettent d’approximer les impacts environnementaux de plus de 2500 produits&nbsp;:
                            pizza, jambon, fromage, croissant, yaourt au lait de chèvre…

                            Dans un premier temps, les travaux vont s’appuyer sur la méthodologie de référence française
                            ([Base Impacts ADEME](https://www.base-impacts.ademe.fr/)) et se concentrent sur les impacts des produits sur
                            **le changement climatique**. L’objectif est d’augmenter les informations proposées (impacts, bases de référence…)
                            pour rendre accessible un **maximum d’information** et **éclairer les débats**."""
                        |> Column.render []
                    ]
                ]
            ]
      ]
    )
