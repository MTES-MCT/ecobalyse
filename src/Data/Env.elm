module Data.Env exposing
    ( betagouvUrl
    , cguUrl
    , communityUrl
    , contactEmail
    , defaultDeadStock
    , gitbookUrl
    , githubRepository
    , githubUrl
    , maxMakingDeadStockRatio
    , maxMakingWasteRatio
    , maxMaterials
    , minMakingDeadStockRatio
    , minMakingWasteRatio
    , privacyPolicyUrl
    )

import Data.Split as Split exposing (Split)


betagouvUrl : String
betagouvUrl =
    "https://beta.gouv.fr/startups/ecobalyse.html"


cguUrl : String
cguUrl =
    "https://fabrique-numerique.gitbook.io/ecobalyse/conditions-dutilisation"


communityUrl : String
communityUrl =
    "https://fabrique-numerique.gitbook.io/ecobalyse/communaute"


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


minMakingWasteRatio : Split
minMakingWasteRatio =
    Split.zero


maxMakingWasteRatio : Split
maxMakingWasteRatio =
    Split.fourty


minMakingDeadStockRatio : Split
minMakingDeadStockRatio =
    Split.zero


maxMakingDeadStockRatio : Split
maxMakingDeadStockRatio =
    Split.thirty


defaultDeadStock : Split
defaultDeadStock =
    Split.fifteen


maxMaterials : Int
maxMaterials =
    5


privacyPolicyUrl : String
privacyPolicyUrl =
    "https://fabrique-numerique.gitbook.io/ecobalyse/politique-de-confidentialite-de-donnees-personnelles"
