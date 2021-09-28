port module Server exposing (main)


type alias Model =
    ()


type Msg
    = Received Float


init : () -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received value ->
            ( model, output (value + 42) )


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Float -> msg) -> Sub msg


port output : Float -> Cmd msg
