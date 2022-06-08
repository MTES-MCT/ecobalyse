module Page.Stats exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Matomo as Matomo
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Ports
import RemoteData exposing (WebData)
import Request.Matomo
import Views.Alert as Alert
import Views.Container as Container
import Views.Spinner as Spinner


type alias Model =
    { apiStats : WebData (List Matomo.Stat)
    , webStats : WebData (List Matomo.Stat)
    }


type Msg
    = ApiStats (WebData (List Matomo.Stat))
    | WebStats (WebData (List Matomo.Stat))


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { apiStats = RemoteData.NotAsked
      , webStats = RemoteData.NotAsked
      }
    , session
    , Cmd.batch
        [ Request.Matomo.getApiStats session ApiStats
        , Request.Matomo.getWebStats session WebStats
        , Ports.scrollTo { x = 0, y = 0 }
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ApiStats apiStats ->
            ( { model | apiStats = apiStats }, session, Cmd.none )

        WebStats webStats ->
            ( { model | webStats = webStats }, session, Cmd.none )


viewStats : { heading : String, unit : String } -> WebData (List Matomo.Stat) -> Html Msg
viewStats { heading, unit } webData =
    case webData of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            Spinner.view

        RemoteData.Failure err ->
            Alert.httpError err

        RemoteData.Success stats ->
            node "chart-stats"
                [ attribute "heading" heading
                , attribute "unit" unit
                , attribute "height" "300"
                , stats
                    |> Encode.list
                        (\{ label, hits } ->
                            Encode.object
                                [ ( "y", Encode.int hits )
                                , ( "name", Encode.string label )
                                ]
                        )
                    |> Encode.encode 0
                    |> attribute "data"
                ]
                []


view : Session -> Model -> ( String, List (Html Msg) )
view _ { apiStats, webStats } =
    ( "Statistiques"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Statistiques" ]
            , webStats
                |> viewStats { heading = "Fréquentation", unit = "visite" }
            , apiStats
                |> viewStats { heading = "Traffic sur l'API", unit = "requête" }
            ]
      ]
    )
