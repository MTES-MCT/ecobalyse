module Data.Env exposing
    ( betagouvUrl
    , contactEmail
    , gitbookUrl
    , githubRepository
    , githubUrl
    , maxMakingWasteRatio
    , maxMaterials
    , minMakingWasteRatio
    )

import Data.Unit as Unit


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


minMakingWasteRatio : Unit.Ratio
minMakingWasteRatio =
    Unit.ratio 0


maxMakingWasteRatio : Unit.Ratio
maxMakingWasteRatio =
    Unit.ratio 0.4


maxMaterials : Int
maxMaterials =
    5
