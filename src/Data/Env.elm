module Data.Env exposing
    ( betagouvUrl
    , contactEmail
    , gitbookUrl
    , githubRepository
    , githubUrl
    )


betagouvUrl : String
betagouvUrl =
    "https://beta.gouv.fr/startups/ecobalyse.html"


contactEmail : String
contactEmail =
    "ecobalyse@beta.gouv.fr"


gitbookUrl : String
gitbookUrl =
    "https://fabrique-numerique.gitbook.io/ecobalyse"


githubRepository : String
githubRepository =
    "MTES-MCT/ecobalyse"


githubUrl : String
githubUrl =
    "https://github.com/" ++ githubRepository
