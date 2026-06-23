module Static.Db exposing (dbFromStaticFiles)

import Data.Db as Db exposing (Db)
import Static.Json as StaticJson


dbFromStaticFiles : String -> Result String Db
dbFromStaticFiles processesJson =
    Db.buildDb
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
