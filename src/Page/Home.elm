module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Session exposing (Session)
import Data.Textile.Inputs as Inputs
import Data.Textile.Simulator as Simulator
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook exposing (getPage)
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Markdown as Markdown
import Views.Textile.Summary as SummaryView


type alias Model =
    { content : WebData Gitbook.Page
    }


type Msg
    = GitbookContentReceived (WebData Gitbook.Page)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { content = RemoteData.Loading
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
                            , Route.href (Route.TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple Nothing)
                            ]
                            [ text "Faire une simulation" ]
                        ]
                    , div [ class "col-md-6 text-center text-md-start py-2" ]
                        [ a [ class "btn btn-lg btn-secondary", Route.href Route.TextileExamples ]
                            [ text "voir des exemples" ]
                        ]
                    ]
                ]
            , div [ class "col-lg-5" ]
                [ Inputs.tShirtCotonFrance
                    |> Simulator.compute session.db
                    |> SummaryView.view
                        { session = session
                        , impact =
                            session.db.impacts
                                |> Impact.getDefinition (Impact.trg "pef")
                                |> Result.withDefault (Impact.invalid Scope.Textile)
                        , funit = Unit.PerItem
                        , reusable = False
                        }
                ]
            ]
        ]


viewIsIsntColumn : Bool -> ( String, List ( String, String ) ) -> Html Msg
viewIsIsntColumn positive ( title, sections ) =
    div [ class "d-flex flex-column gap-3 mt-1" ]
        [ h2 [ class "h3 fw-light text-light text-center" ]
            [ span [ class "text-white me-1" ]
                [ if positive then
                    Icon.check

                  else
                    Icon.times
                ]
            , title |> String.replace "## " "" |> text
            ]
        , sections
            |> List.map
                (\( sectionTitle, markdown ) ->
                    div [ class "card" ]
                        [ div [ class "card-body" ]
                            [ h3 [ class "h5 d-flex gap-2" ]
                                [ if positive then
                                    span [ class "text-success" ] [ Icon.check ]

                                  else
                                    span [ class "text-danger" ] [ Icon.times ]
                                , sectionTitle
                                    |> Markdown.simple [ class "fw-normal inline-paragraphs" ]
                                ]
                            , markdown
                                |> Markdown.simple []
                            ]
                        ]
                )
            |> div [ class "d-flex flex-column gap-3" ]
        ]


viewIsIsnt : Gitbook.IsIsnt -> Html Msg
viewIsIsnt { is, isnt } =
    Container.full [ class "bg-info shadow pt-3 pb-5" ]
        [ Container.centered []
            [ div [ class "row" ]
                [ div [ class "col-sm-6" ] [ viewIsIsntColumn True is ]
                , div [ class "col-sm-6" ] [ viewIsIsntColumn False isnt ]
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session { content } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ viewHero session
            , content
                |> RemoteData.map
                    (\{ markdown } ->
                        case Gitbook.parseIsIsnt markdown of
                            Ok parsed ->
                                viewIsIsnt parsed

                            Err error ->
                                Alert.simple
                                    { level = Alert.Info
                                    , close = Nothing
                                    , title = Nothing
                                    , content =
                                        [ div [ class "d-flex justify-content-center align-items-center gap-1" ]
                                            [ Icon.warning
                                            , text error
                                            ]
                                        ]
                                    }
                    )
                |> RemoteData.withDefault (text "")
            ]
      ]
    )
