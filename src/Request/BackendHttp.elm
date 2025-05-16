module Request.BackendHttp exposing
    ( Error
    , errorToString
    , expectApiJson
    , expectApiWhatever
    )

import Http
import Json.Decode as Decode exposing (Decoder)


{-| A custom backend API error response
-}
type alias ErrorResponse =
    { detail : String
    , statusCode : Int
    }


{-| A custom backend HTTP API error.

Note: we don't use the `Http.Error` type because it doesn't handle the detailed JSON
error responses our backend API returns along a bad status code (eg. 400, 409, etc).

-}
type Error
    = BadBody String
    | BadStatus ErrorResponse
    | BadUrl String
    | NetworkError
    | Timeout


decodeErrorResponse : Decoder ErrorResponse
decodeErrorResponse =
    Decode.map2 ErrorResponse
        (Decode.field "detail" Decode.string)
        (Decode.field "status_code" Decode.int)


{-| Convert an Http error to a string
-}
errorToString : Error -> String
errorToString error =
    case error of
        BadBody body ->
            "Échec de l'interprétation de la réponse HTTP: " ++ body

        BadStatus { detail, statusCode } ->
            "Erreur HTTP " ++ String.fromInt statusCode ++ ": " ++ detail

        BadUrl url ->
            "URL invalide: " ++ url

        NetworkError ->
            "Erreur de communication réseau. Êtes-vous connecté ?"

        Timeout ->
            "Délai dépassé."


{-| Handle custom JSON error responses from our backend JSON API
-}
expectApiJson : (Result Error value -> msg) -> Decoder value -> Http.Expect msg
expectApiJson toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadStatus_ metadata body ->
                    case Decode.decodeString decodeErrorResponse body of
                        -- FIXME: handle error
                        Err decodeError ->
                            Err <|
                                BadStatus
                                    { detail = Decode.errorToString decodeError
                                    , statusCode = metadata.statusCode
                                    }

                        Ok errorResponse ->
                            -- How to use decoded error?
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


expectApiWhatever : (Result Error () -> msg) -> Http.Expect msg
expectApiWhatever toMsg =
    expectApiJson toMsg (Decode.succeed ())
