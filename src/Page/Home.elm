module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Data.Env as Env
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Key as Key
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode
import Ports
import RemoteData exposing (WebData)
import Request.Gitbook exposing (getPage)
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Link as Link
import Views.Markdown as Markdown
import Views.Modal as ModalView


type alias Model =
    { content : WebData Gitbook.Page
    , modal : Modal
    }


type Msg
    = GitbookContentReceived (WebData Gitbook.Page)
    | CloseModal
    | NoOp
    | OpenCalculatorPickerModal


type Modal
    = NoModal
    | CalculatorPickerModal


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { content = RemoteData.Loading
      , modal = NoModal
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
        CloseModal ->
            ( { model | modal = NoModal }, session, Cmd.none )

        GitbookContentReceived gitbookData ->
            ( { model | content = gitbookData }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OpenCalculatorPickerModal ->
            ( { model | modal = CalculatorPickerModal }, session, Cmd.none )


viewHero : Modal -> Html Msg
viewHero modal =
    Container.centered [ class "pb-5" ]
        [ h2 [ class "display-5" ]
            [ text "Entreprises"
            , br [] []
            , text "Calculez l'impact écologique de vos produits"
            ]
        , div [ class "fs-4 text-muted mt-4 mb-5" ]
            [ text "Écobalyse permet aux marques de comprendre et de calculer les impacts écologiques des produits distribués en France." ]
        , div [ class "row mb-4" ]
            [ div [ class "col-md-6 text-center text-md-end py-2" ]
                [ button
                    [ class "btn btn-lg btn-primary w-50"
                    , onClick OpenCalculatorPickerModal
                    ]
                    [ text "Lancer le calculateur" ]
                ]
            , div [ class "col-md-6 text-center text-md-start py-2" ]
                [ Link.external
                    [ class "btn btn-lg btn-primary w-50"
                    , href Env.gitbookUrl
                    ]
                    [ text "Découvrir Écobalyse" ]
                ]
            ]
        , case modal of
            NoModal ->
                text ""

            CalculatorPickerModal ->
                ModalView.view
                    { size = ModalView.Large
                    , close = CloseModal
                    , noOp = NoOp
                    , title = "Sélectionnez le secteur concerné"
                    , formAction = Nothing
                    , content =
                        [ calculatorPickerModalContent ]
                    , footer = []
                    }
        ]


calculatorPickerModalContent : Html Msg
calculatorPickerModalContent =
    div
        [ class "row d-flex text-center align-items-stretch justify-content-evenly py-5 w-100" ]
        [ div [ class "col-sm-3" ]
            [ div [ class "card align-items-center" ]
                [ img
                    [ class "w-50"
                    , src "img/picto_textile.png"
                    , alt "Lancer le calculateur du textile"
                    ]
                    []
                , div
                    [ class "card-body" ]
                    [ a
                        [ class "btn btn-primary"
                        , Route.href (Route.TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple Nothing)
                        ]
                        [ text "Textile" ]
                    ]
                ]
            ]
        , div [ class "col-sm-3" ]
            [ div [ class "card align-items-center" ]
                [ img
                    [ class "w-50"
                    , src "img/picto_alimentaire.png"
                    , alt "Lancer le calculateur de l'alimentaire"
                    ]
                    []
                , div [ class "card-body" ]
                    [ a
                        [ class "btn btn-primary"
                        , Route.href (Route.FoodBuilder Impact.defaultFoodTrigram Nothing)
                        ]
                        [ text "Alimentaire" ]
                    ]
                ]
            ]
        , div [ class "col-sm-3" ]
            [ div [ class "card h-100 justify-content-center" ]
                [ text "Autre secteur,"
                , br [] []
                , Link.external
                    [ href "https://fabrique-numerique.gitbook.io/ecobalyse/textile/nous-contacter" ]
                    [ text "contactez-nous" ]
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
    Container.full [ class "bg-info shadow pt-3 pb-5", id "github-pages-content" ]
        [ Container.centered []
            [ div [ class "row" ]
                [ div [ class "col-sm-6" ] [ viewIsIsntColumn True is ]
                , div [ class "col-sm-6" ] [ viewIsIsntColumn False isnt ]
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ { content, modal } =
    ( "Accueil"
    , [ div [ class "d-flex flex-column" ]
            [ viewHero modal
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


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        _ ->
            Browser.Events.onKeyDown (Key.escape CloseModal)
