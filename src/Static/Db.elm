module Static.Db exposing (dbFromStaticFiles)

import Data.Db as Db exposing (Db)
import Static.Json as StaticJson


{-| Build a Db from static file strings.

IMPORTANT NOTE: this module should _never_ be imported by the Main module (the Web app), as it imports
all the db JSON strings statically, which bloats the js build for no added value. The intended use of
this function is for Server and Tests.

-}
dbFromStaticFiles : String -> Result String Db
dbFromStaticFiles processesJson =
    Db.build
        { countries = Db.rawJsonString StaticJson.countriesJson
        , definitions = Db.rawJsonString StaticJson.impactsJson
        , food2Examples = Db.rawJsonString StaticJson.food2ExamplesJson
        , foodIngredients = Db.rawJsonString StaticJson.foodIngredientsJson
        , foodProductExamples = Db.rawJsonString StaticJson.foodProductExamplesJson
        , objectComponents = Db.rawJsonString StaticJson.rawJsonComponents.objectComponents
        , objectExamples = Db.rawJsonString StaticJson.objectExamplesJson
        , processes = Db.rawJsonString processesJson
        , textileComponents = Db.rawJsonString StaticJson.rawJsonComponents.textileComponents
        , textileMaterials = Db.rawJsonString StaticJson.textileMaterialsJson
        , textileProductExamples = Db.rawJsonString StaticJson.textileProductExamplesJson
        , textileProducts = Db.rawJsonString StaticJson.textileProductsJson
        , transports = Db.rawJsonString StaticJson.transportsJson
        , veliComponents = Db.rawJsonString StaticJson.rawJsonComponents.veliComponents
        , veliExamples = Db.rawJsonString StaticJson.veliExamplesJson
        }
