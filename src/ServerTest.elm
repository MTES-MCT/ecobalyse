module ServerTest exposing (main)

import Server.Worker as Worker
import Static.TestDb as TestDb
import Static.TestJson as TestJson


{-| API server compiled against the fixture database. Used by the Jest API suite.

Note: imports the test static database, so the web app and the production server must _not_
import this module.

-}
main : Program () Worker.Model Worker.Msg
main =
    Worker.worker TestDb.dbFromJsonStrings TestJson.componentConfigJson
