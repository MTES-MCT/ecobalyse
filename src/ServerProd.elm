module ServerProd exposing (main)

import Server.Worker as Worker
import Static.ProdDb as ProdDb
import Static.ProdJson as ProdJson


{-| Production API server. Imports the production static database.

Note: the web app must _not_ import this module, as it would bloat the resulting
js bundle for no added value (web app loads data over HTTP, not from static files)

-}
main : Program () Worker.Model Worker.Msg
main =
    Worker.worker ProdDb.dbFromJsonStrings ProdJson.componentConfigJson
