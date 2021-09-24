module Page.Editorial exposing (..)

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.HttpClient as HttpClient
import Views.Container as Container
import Views.Markdown as Markdown


type Msg
    = ContentReceived (Result Http.Error String)


type State
    = Loading
    | Loaded String
    | Errored Http.Error


type alias Model =
    { slug : String
    , state : State
    }


init : String -> Session -> ( Model, Session, Cmd Msg )
init slug session =
    ( Model slug Loading
    , session
    , HttpClient.getMarkdownFile session (slug ++ ".md") ContentReceived
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ContentReceived (Ok content) ->
            ( { model | state = Loaded content }
            , session
            , Cmd.none
            )

        ContentReceived (Err error) ->
            ( { model | state = Errored error }
            , session
            , Cmd.none
            )


extractTitle : String -> String
extractTitle =
    String.split "\n"
        >> List.head
        >> Maybe.map (String.replace "# " "")
        >> Maybe.withDefault "À propos"


page : String -> List (Html msg) -> ( String, List (Html msg) )
page title content =
    ( title
    , [ Container.centered [ class "pb-5" ] content ]
    )


view : Session -> Model -> ( String, List (Html Msg) )
view _ { state } =
    case state of
        Loading ->
            page "Chargement…"
                [ div [ class "text-center" ] [ text "Chargement…" ] ]

        Loaded content ->
            page (extractTitle content)
                [ h1 [ class "mb-3" ] [ text "Méthodologie" ]
                , article [ class "row justify-content-center" ]
                    [ content
                        |> Markdown.view
                            [ class "md-content"
                            , style "columns" "30em"
                            , style "column-gap" "40px"
                            ]
                    ]
                ]

        Errored error ->
            page "Erreur"
                [ div [ class "alert alert-warning" ]
                    [ p [] [ strong [] [ text "Impossible de charger le contenu de cette page\u{00A0}:" ] ]
                    , p [ class "mb-0" ] [ text (HttpClient.errorToString error) ]
                    ]
                ]
