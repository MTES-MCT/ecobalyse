module Request.Common exposing (..)

import Http exposing (..)


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
