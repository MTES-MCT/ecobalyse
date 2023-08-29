module Request.Common exposing (errorToString)

import Http


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
