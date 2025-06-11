module Request.BackendHttp.Error exposing
    ( Error(..)
    , ErrorResponse
    , decodeErrorResponse
    , errorToString
    , mapErrorResponse
    )

import Data.Common.DecodeUtils as DU
import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP


{-| A custom backend HTTP API error.

Note: we don't use the native `Http.Error` type because it doesn't handle the detailed JSON
error responses our backend API returns along with a bad status code (eg. 400, 409, etc).

-}
type Error
    = BadBody ErrorResponse
    | BadStatus ErrorResponse
    | BadUrl String
    | NetworkError
    | Timeout


{-| A detailed backend API error response
-}
type alias ErrorResponse =
    { detail : String
    , headers : Dict String String
    , statusCode : Int
    , title : Maybe String
    , url : String
    }


decodeErrorResponse : Http.Metadata -> Decoder ErrorResponse
decodeErrorResponse { headers, url } =
    Decode.succeed ErrorResponse
        |> DU.strictOptionalWithDefault "detail" Decode.string "No details were given"
        |> JDP.hardcoded headers
        |> JDP.required "status" Decode.int
        |> DU.strictOptional "title" Decode.string
        |> JDP.hardcoded url


{-| Convert an Http error to a string
-}
errorToString : Error -> String
errorToString error =
    case error of
        BadBody { detail } ->
            "Échec de l'interprétation de la réponse HTTP: " ++ detail

        BadStatus { detail, statusCode } ->
            "Erreur HTTP " ++ String.fromInt statusCode ++ ": " ++ detail

        BadUrl url ->
            "URL invalide: " ++ url

        NetworkError ->
            "Erreur de communication réseau. Êtes-vous connecté ?"

        Timeout ->
            "Délai dépassé."


mapErrorResponse : Error -> ErrorResponse
mapErrorResponse error =
    case error of
        BadBody errorResponse ->
            errorResponse

        BadStatus errorResponse ->
            errorResponse

        BadUrl url ->
            { detail = "L'URL semble mal formée et n'a pas pu être chargée\u{00A0}: " ++ url
            , headers = Dict.empty
            , statusCode = 0
            , title = Nothing
            , url = url
            }

        NetworkError ->
            { detail = "Erreur de communication réseau. Êtes-vous connecté\u{00A0}?"
            , headers = Dict.empty
            , statusCode = 0
            , title = Nothing
            , url = ""
            }

        Timeout ->
            { detail = "Le temps maximum d'attente de la réponse a été dépassé."
            , headers = Dict.empty
            , statusCode = 0
            , title = Nothing
            , url = ""
            }
