module Request.HttpClient exposing (errorToString, getMarkdownFile)

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


getMarkdownFile : Session -> String -> (Result Error String -> msg) -> Cmd msg
getMarkdownFile _ file event =
    Http.get
        { url = file
        , expect = Http.expectString event
        }
