module Request.HttpClient exposing (..)

import Data.Session exposing (Session)
import Http exposing (Error(..))


getMarkdownFile : Session -> String -> (Result Error String -> msg) -> Cmd msg
getMarkdownFile _ file event =
    Http.get
        { url = "markdown/" ++ file
        , expect = Http.expectString event
        }
