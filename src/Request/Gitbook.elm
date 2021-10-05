module Request.Gitbook exposing (..)

import Data.Gitbook as Gitbook
import Data.Session exposing (Session)
import Http exposing (Error(..))


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl url ->
            "Bad url: " ++ url

        Timeout ->
            "Request timed out."

        NetworkError ->
            "Network error. Are you online?"

        BadStatus status_code ->
            "HTTP error " ++ String.fromInt status_code

        BadBody body ->
            "Unable to parse response body: " ++ body


getPage : Session -> String -> (Result Error Gitbook.Page -> msg) -> Cmd msg
getPage _ page event =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" "Bearer UTZvYmUzbXRLWVA1a3hGMFdwcXpJbW1iSWkwMjotTWxDSm9nelJQQTF6VkFFQTFVQi0tTWxDSm9oLTVkd09ocUM3bFNIRw" ]
        , url = "https://api-beta.gitbook.com/v1/spaces/-MexpTrvmqKNzuVtxdad/content/v/master/url/" ++ page ++ "?format=markdown"
        , body = Http.emptyBody
        , expect = Http.expectJson event (Gitbook.decodePage page)
        , timeout = Nothing
        , tracker = Nothing
        }
