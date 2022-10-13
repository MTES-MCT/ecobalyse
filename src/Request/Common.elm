module Request.Common exposing (errorToString, getJson)

import Http
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultTaskConfig)
import Task exposing (Task)


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "URL invalide: " ++ url

        Http.Timeout ->
            "Délai dépassé."

        Http.NetworkError ->
            "Erreur de communication réseau. Êtes-vous connecté ?"

        Http.BadStatus status_code ->
            "Erreur HTTP " ++ String.fromInt status_code

        Http.BadBody body ->
            "Échec de l'interprétation de la réponse HTTP: " ++ body


getJson : Decoder a -> String -> Task () (WebData a)
getJson decoder file =
    Http.getTaskWithConfig taskConfig ("data/" ++ file) decoder


taskConfig : Http.TaskConfig
taskConfig =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultTaskConfig | headers = [] }
