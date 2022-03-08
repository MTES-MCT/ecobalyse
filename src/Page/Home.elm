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
import Page.Simulator.ViewMode as ViewMode
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook exposing (getPage)
import Route
import Views.Container as Container
import Views.Icon as Icon
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
                    [ "Accélérer la mise en place de l’affichage environnemental" |> Markdown.simple [] ]
                , div [ class "fs-4 text-muted mt-4 mb-5" ]
                    [ "autour d’un calculateur pédagogique et collaboratif" |> Markdown.simple [] ]
                , div [ class "row mb-4" ]
                    [ div [ class "col-md-6 text-center text-md-end py-2" ]
                        [ a
                            [ class "btn btn-lg btn-primary"
                            , Route.href (Route.Simulator Impact.defaultTrigram Unit.PerItem ViewMode.Simple Nothing)
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


viewIsIsntColumn : Bool -> Maybe Int -> ( String, List ( String, String ) ) -> Html Msg
viewIsIsntColumn positive isIsntSectionIndex ( title, sections ) =
    div [ class "mt-3" ]
        [ h2 [ class "h3 fw-light text-light text-center mb-3" ]
            [ span [ class "text-white me-1" ]
                [ if positive then
                    Icon.check

                  else
                    Icon.times
                ]
            , text title
            ]
        , sections
            |> List.indexedMap
                (\index ( sectionTitle, markdown ) ->
                    div [ class "accordion-item" ]
                        [ h3 [ class "accordion-header" ]
                            [ button
                                [ type_ "button"
                                , class "AccordionButton accordion-button fw-bold py-0"
                                , classList [ ( "collapsed", isIsntSectionIndex /= Just index ) ]
                                , onClick (ToggleIsIsntIndex index)
                                ]
                                [ span [ class "d-flex align-items-start lh-base" ]
                                    [ if positive then
                                        span [ class "text-success me-1" ] [ Icon.check ]

                                      else
                                        span [ class "text-danger me-1" ] [ Icon.times ]
                                    , Markdown.simple [ class "fw-normal inline-paragraphs" ] sectionTitle
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
    Container.full [ class "bg-info shadow pt-3 pb-5" ]
        [ Container.centered []
            [ div [ class "row" ]
                [ div [ class "col-sm-6" ] [ viewIsIsntColumn True isIsntSectionIndex is ]
                , div [ class "col-sm-6" ] [ viewIsIsntColumn False isIsntSectionIndex isnt ]
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session { content, isIsntSectionIndex } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ viewHero session
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
