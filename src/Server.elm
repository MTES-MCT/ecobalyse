port module Server exposing (main)

import Data.Country as Country
import Data.Db as Db exposing (Db)
import Data.Inputs as Inputs
import Data.Process as Process
import Data.Product as Product
import Data.Simulator as Simulator exposing (Simulator)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db
    }


type alias Request =
    { expressQuery : Encode.Value
    , jsResponseHandler : Encode.Value
    }


type Msg
    = Received Request


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


type alias ExpressQuery =
    -- express.js native query parameters JSON format
    -- {
    --     mass: '0.17',
    --     product: '13',
    --     material: 'f211bbdb-415c-46fd-be4d-ddf199575b44',
    --     countries: [ 'CN', 'CN', 'CN', 'CN', 'FR' ],
    --     dyeingWeighting: '1.789',
    --     airTransportRatio: '0.1234',
    --     recycledRatio: '0.567',
    --     'customCountryMixes.fabric': '',
    --     'customCountryMixes.dyeing': '',
    --     'customCountryMixes.making': ''
    -- }
    { mass : Mass
    , product : Product.Id
    , material : Process.Uuid
    , countries : List Country.Code
    , dyeingWeighting : Maybe Float
    , airTransportRatio : Maybe Float
    , recycledRatio : Maybe Float
    , customCountryMixesFabric : Maybe Unit.Co2e
    , customCountryMixesDyeing : Maybe Unit.Co2e
    , customCountryMixesMaking : Maybe Unit.Co2e
    }


decodeExpressQuery : Decoder Inputs.Query
decodeExpressQuery =
    let
        decodeStringFLoat =
            Decode.string
                |> Decode.andThen (String.toFloat >> Result.fromMaybe "Invalid float" >> DecodeExtra.fromResult)
    in
    Decode.succeed ExpressQuery
        |> Pipe.required "mass" (decodeStringFLoat |> Decode.map Mass.kilograms)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "countries" (Decode.list (Decode.map Country.Code Decode.string))
        |> Pipe.optional "dyeingWeighting" (Decode.maybe decodeStringFLoat) Nothing
        |> Pipe.optional "airTransportRatio" (Decode.maybe decodeStringFLoat) Nothing
        |> Pipe.optional "recycledRatio" (Decode.maybe decodeStringFLoat) Nothing
        |> Pipe.optional "customCountryMixes.fabric" (Decode.maybe (decodeStringFLoat |> Decode.map Unit.kgCo2e)) Nothing
        |> Pipe.optional "customCountryMixes.dyeing" (Decode.maybe (decodeStringFLoat |> Decode.map Unit.kgCo2e)) Nothing
        |> Pipe.optional "customCountryMixes.making" (Decode.maybe (decodeStringFLoat |> Decode.map Unit.kgCo2e)) Nothing
        |> Decode.map expressQueryToInputsQuery


expressQueryToInputsQuery : ExpressQuery -> Inputs.Query
expressQueryToInputsQuery eq =
    { mass = eq.mass
    , material = eq.material
    , product = eq.product
    , countries = eq.countries
    , dyeingWeighting = eq.dyeingWeighting
    , airTransportRatio = eq.airTransportRatio
    , recycledRatio = eq.recycledRatio
    , customCountryMixes =
        { fabric = eq.customCountryMixesFabric
        , dyeing = eq.customCountryMixesDyeing
        , making = eq.customCountryMixesMaking
        }
    }


sendResponse : Int -> Encode.Value -> Encode.Value -> Cmd Msg
sendResponse httpStatus jsResponseHandler body =
    Encode.object
        [ ( "status", Encode.int httpStatus )
        , ( "body", body )
        , ( "jsResponseHandler", jsResponseHandler )
        ]
        |> output


toResponse : Encode.Value -> Result String Simulator -> Cmd Msg
toResponse jsResponseHandler result =
    case result of
        Ok simulator ->
            simulator
                |> Simulator.encode
                |> sendResponse 200 jsResponseHandler

        Err error ->
            Encode.object [ ( "error", Encode.string error ) ]
                |> sendResponse 400 jsResponseHandler


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.db ) of
        ( Received { expressQuery, jsResponseHandler }, Ok db ) ->
            ( model
            , expressQuery
                |> Decode.decodeValue decodeExpressQuery
                |> Result.mapError Decode.errorToString
                |> Result.andThen (Simulator.compute db)
                |> toResponse jsResponseHandler
            )

        ( Received { jsResponseHandler }, Err error ) ->
            ( model
            , Err error |> toResponse jsResponseHandler
            )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
