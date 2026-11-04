module Data.Env exposing
    ( betagouvUrl
    , cguUrl
    , communityUrl
    , contactEmail
    , defaultDeadStock
    , explorerCommentExcerptLength
    , explorerTableMaxDisplayedRows
    , feedbackUrl
    , gitbookUrl
    , githubUrl
    , maxMakingDeadStockRatio
    , maxMakingWasteRatio
    , maxMaterials
    , minMakingDeadStockRatio
    , minMakingWasteRatio
    , stableTextileVersionPath
    , usageThreshold
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


{-| Length of the excerpt of a comment in the explorer table.
-}
explorerCommentExcerptLength : Int
explorerCommentExcerptLength =
    80


{-| Maximum number of rows rendered at once in the explorer table.
-}
explorerTableMaxDisplayedRows : Int
explorerTableMaxDisplayedRows =
    100


feedbackUrl : String
feedbackUrl =
    "https://jedonnemonavis.numerique.gouv.fr/Demarches/4223?button=4973"


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


stableTextileVersionPath : String
stableTextileVersionPath =
    "/versions/v7.0.0/"


defaultDeadStock : Split
defaultDeadStock =
    Split.fifteen


maxMaterials : Int
maxMaterials =
    5


{-| Number of simulator actions after which a feedback prompt modal is shown
-}
usageThreshold : Int
usageThreshold =
    100
