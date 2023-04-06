module Data.Env exposing
    ( betagouvUrl
    , contactEmail
    , gitbookUrl
    , githubRepository
    , githubUrl
    , mattermostUrl
    , maxMakingWasteRatio
    , maxMaterials
    , minMakingWasteRatio
    )

import Data.Split as Split exposing (Split)


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


mattermostUrl : String
mattermostUrl =
    "https://chat.ecobalyse.fr/"


minMakingWasteRatio : Split
minMakingWasteRatio =
    Split.zero


maxMakingWasteRatio : Split
maxMakingWasteRatio =
    Split.fourty


maxMaterials : Int
maxMaterials =
    5
