module Request.Gitbook exposing (..)

import Data.Gitbook as Gitbook
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)
import RemoteData.Http exposing (defaultConfig)


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
