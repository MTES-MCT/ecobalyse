module Request.Gitbook exposing (getPage)

import Data.Env as Env
import Data.Gitbook as Gitbook
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)


getPage : Session -> Gitbook.Path -> (WebData Gitbook.Page -> msg) -> Cmd msg
getPage _ path event =
    Http.get
        { url =
            "https://raw.githubusercontent.com/"
                ++ Env.githubRepository
                ++ "/docs/"
                ++ Gitbook.pathToString path
                ++ ".md"
        , expect =
            Http.expectString
                (RemoteData.fromResult
                    >> RemoteData.map (Gitbook.fromMarkdown path)
                    >> event
                )
        }
