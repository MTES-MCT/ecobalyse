module Request.Gitbook exposing (..)

import Data.Gitbook as Gitbook
import Data.Session exposing (Session)
import Http exposing (Error(..))
import RemoteData exposing (WebData)
import RemoteData.Http exposing (defaultConfig)


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl url ->
            "URL invalide: " ++ url

        Timeout ->
            "Délai dépassé."

        NetworkError ->
            "Erreur de communication réseau. Êtes-vous connecté ?"

        BadStatus status_code ->
            "Erreur HTTP " ++ String.fromInt status_code

        BadBody body ->
            "Échec de l'interprétation de la réponse HTTP: " ++ body


config : RemoteData.Http.Config
config =
    { defaultConfig
        | headers =
            [ Http.header "Authorization"
                "Bearer UTZvYmUzbXRLWVA1a3hGMFdwcXpJbW1iSWkwMjotTWxDSm9nelJQQTF6VkFFQTFVQi0tTWxDSm9oLTVkd09ocUM3bFNIRw"
            ]
    }


getPage : Session -> String -> (WebData Gitbook.Page -> msg) -> Cmd msg
getPage _ page event =
    RemoteData.Http.getWithConfig config
        ("https://api-beta.gitbook.com/v1/spaces/-MexpTrvmqKNzuVtxdad/content/v/master/url/" ++ page ++ "?format=markdown")
        event
        (Gitbook.decodePage page)
