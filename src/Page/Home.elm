module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Session exposing (Session)
import Data.Simulator as Simulator
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook exposing (getPage)
import Route
import Views.Column as Column
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Markdown as Markdown
import Views.Summary as SummaryView


type alias Model =
    { content : WebData Gitbook.Page
    , isIsntSectionIndex : Maybe Int
    }


type Msg
    = GitbookContentReceived (WebData Gitbook.Page)
    | ToggleIsIsntIndex Int


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { content = RemoteData.Loading
      , isIsntSectionIndex = Nothing
      }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , getPage session Gitbook.Home GitbookContentReceived
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        GitbookContentReceived gitbookData ->
            ( { model | content = gitbookData }, session, Cmd.none )

        ToggleIsIsntIndex index ->
            ( { model
                | isIsntSectionIndex =
                    if model.isIsntSectionIndex == Just index then
                        Nothing

                    else
                        Just index
              }
            , session
            , Cmd.none
            )


viewHero : Session -> Html Msg
viewHero session =
    Container.centered [ class "pb-5" ]
        [ div [ class "row align-items-center", style "min-height" "57vh" ]
            [ div [ class "col-lg-7 text-center" ]
                [ h2 [ class "display-5" ]
                    [ text "Quels sont les impacts de nos achats sur la planète\u{00A0}?" ]
                , p [ class "fs-4 text-muted my-5" ]
                    [ text "Comprendre, contribuer et faire émerger des valeurs de référence" ]
                , div [ class "row mb-4" ]
                    [ div [ class "col-md-6 text-center text-md-end py-2" ]
                        [ a
                            [ class "btn btn-lg btn-primary"
                            , Route.href (Route.Simulator Impact.defaultTrigram Unit.PerItem { detailed = False } Nothing)
                            ]
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
                    |> Simulator.compute session.db
                    |> SummaryView.view
                        { session = session
                        , impact = Impact.default
                        , funit = Unit.PerItem
                        , reusable = False
                        }
                ]
            ]
        ]


viewPitch : Html Msg
viewPitch =
    Container.full [ class "bg-primary-gradient shadow text-light-all" ]
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


viewIsIsntColumn : Bool -> Maybe Int -> ( String, List ( String, String ) ) -> Html Msg
viewIsIsntColumn positive isIsntSectionIndex ( title, sections ) =
    div [ class "mt-3" ]
        [ h2 [ class "h3 fw-light text-center mb-3" ]
            [ if positive then
                span [ class "text-success me-1" ] [ Icon.check ]

              else
                span [ class "text-danger me-1" ] [ Icon.times ]
            , title |> String.replace "*" "" |> text
            ]
        , sections
            |> List.indexedMap
                (\index ( sectionTitle, markdown ) ->
                    div [ class "accordion-item" ]
                        [ h3 [ class "accordion-header" ]
                            [ button
                                [ type_ "button"
                                , class "accordion-button fw-bold"
                                , classList [ ( "collapsed", isIsntSectionIndex /= Just index ) ]
                                , onClick (ToggleIsIsntIndex index)
                                ]
                                [ span [ class "d-flex align-items-start" ]
                                    [ if positive then
                                        span [ class "text-success me-1" ] [ Icon.check ]

                                      else
                                        span [ class "text-danger me-1" ] [ Icon.times ]
                                    , span []
                                        [ index + 1 |> String.fromInt |> text
                                        , text ". "
                                        , sectionTitle |> String.replace "*" "" |> text
                                        ]
                                    ]
                                ]
                            ]
                        , markdown
                            |> Markdown.simple
                                [ class "accordion-collapse collapse p-3"
                                , classList [ ( "show", isIsntSectionIndex == Just index ) ]
                                ]
                        ]
                )
            |> div [ class "accordion" ]
        ]


viewIsIsnt : Maybe Int -> Gitbook.IsIsnt -> Html Msg
viewIsIsnt isIsntSectionIndex { is, isnt } =
    Container.full [ class "bg-light pt-3 pb-5" ]
        [ Container.centered []
            [ div [ class "row" ]
                [ div [ class "col-sm-6" ] [ viewIsIsntColumn True isIsntSectionIndex is ]
                , div [ class "col-sm-6" ] [ viewIsIsntColumn False isIsntSectionIndex isnt ]
                ]
            ]
        ]


viewFeatures : Html Msg
viewFeatures =
    Container.full [ class "py-5" ]
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


view : Session -> Model -> ( String, List (Html Msg) )
view session { content, isIsntSectionIndex } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ viewHero session
            , viewPitch
            , viewFeatures
            , content
                |> RemoteData.map
                    (.markdown
                        >> Gitbook.parseIsIsnt
                        >> Maybe.map (viewIsIsnt isIsntSectionIndex)
                        >> Maybe.withDefault (text "")
                    )
                |> RemoteData.withDefault (text "")
            ]
      ]
    )
