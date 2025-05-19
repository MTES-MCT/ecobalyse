module Request.BackendHttp exposing
    ( WebData
    , delete
    , expectJson
    , get
    , patch
    , post
    )

import Data.Session exposing (Session)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import RemoteData exposing (RemoteData)
import Request.BackendHttp.Error as BackendError exposing (Error(..))


{-| Our own implementation of RemoteData.WebData, because the native one enforces
use of Http.Error, which doesn't natively expose detailed error response bodies
-}
type alias WebData a =
    RemoteData Error a


authHeaders : Session -> List Http.Header
authHeaders session =
    case session.store.auth2 of
        Just { accessTokenData } ->
            [ Http.header "Authorization" <| "Bearer " ++ accessTokenData.accessToken ]

        Nothing ->
            []


{-| Handle custom JSON error responses from our backend JSON API
-}
expectJson : (Result Error value -> msg) -> Decoder value -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadStatus_ metadata body ->
                    case Decode.decodeString (BackendError.decodeErrorResponse metadata) body of
                        Err decodeError ->
                            -- If decoding the JSON error fails, expose the reason
                            Err <|
                                BadStatus
                                    { detail = "Couldn't decode error response: " ++ Decode.errorToString decodeError
                                    , headers = metadata.headers
                                    , statusCode = metadata.statusCode
                                    , title = Nothing
                                    , url = metadata.url
                                    }

                        Ok errorResponse ->
                            Err <| BadStatus errorResponse

                Http.BadUrl_ url ->
                    Err (BadUrl url)

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString decoder body of
                        Err err ->
                            Err <| BadBody (Decode.errorToString err)

                        Ok value ->
                            Ok value

                Http.NetworkError_ ->
                    Err NetworkError

                Http.Timeout_ ->
                    Err Timeout


expectWhatever : (Result Error () -> msg) -> Http.Expect msg
expectWhatever toMsg =
    expectJson toMsg (Decode.succeed ())


getApiUrl : Session -> String -> String
getApiUrl session path =
    String.join "/" [ session.backendApiUrl, "api", path ]


delete : Session -> String -> (WebData () -> msg) -> Cmd msg
delete session path event =
    Http.request
        { body = Http.emptyBody
        , expect = expectWhatever (RemoteData.fromResult >> event)
        , headers = authHeaders session
        , method = "DELETE"
        , timeout = Nothing
        , tracker = Nothing
        , url = getApiUrl session path
        }


get : Session -> String -> (WebData data -> msg) -> Decoder data -> Cmd msg
get session path event decoder =
    Http.request
        { body = Http.emptyBody
        , expect = expectJson (RemoteData.fromResult >> event) decoder
        , headers = authHeaders session
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = getApiUrl session path
        }


patch : Session -> String -> (WebData data -> msg) -> Decoder data -> Encode.Value -> Cmd msg
patch session path event decoder body =
    Http.request
        { body = Http.jsonBody body
        , expect = expectJson (RemoteData.fromResult >> event) decoder
        , headers = authHeaders session
        , method = "PATCH"
        , timeout = Nothing
        , tracker = Nothing
        , url = getApiUrl session path
        }


post : Session -> String -> (WebData data -> msg) -> Decoder data -> Encode.Value -> Cmd msg
post session path event decoder body =
    Http.request
        { body = Http.jsonBody body
        , expect = expectJson (RemoteData.fromResult >> event) decoder
        , headers = authHeaders session
        , method = "POST"
        , timeout = Nothing
        , tracker = Nothing
        , url = getApiUrl session path
        }
