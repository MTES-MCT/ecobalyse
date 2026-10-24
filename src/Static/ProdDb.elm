module Static.ProdDb exposing (dbFromStaticFiles)

import Data.Db as Db exposing (Db)
import Static.ProdJson as ProdJson


{-| Build a Db from static file strings.

IMPORTANT NOTE: this module should _never_ be imported by the Main module (the Web app), as it imports
all the db JSON strings statically, which bloats the js build for no added value. The intended use of
this function is for the API Server (tests load Static.TestDb instead)

-}
dbFromStaticFiles : String -> Result String Db
dbFromStaticFiles processesJson =
    Db.buildFromStrings
        { countries = ProdJson.countriesJson
        , definitions = ProdJson.impactsJson
        , food2Components = ProdJson.food2ComponentsJson
        , food2Examples = ProdJson.food2ExamplesJson
        , food2ProductCategories = ProdJson.food2ProductCategoriesJson
        , foodIngredients = ProdJson.foodIngredientsJson
        , foodProductExamples = ProdJson.foodProductExamplesJson
        , objectComponents = ProdJson.rawJsonComponents.objectComponents
        , objectExamples = ProdJson.objectExamplesJson
        , objectProductCategories = ProdJson.objectProductCategoriesJson
        , processes = processesJson
        , textileComponents = ProdJson.rawJsonComponents.textileComponents
        , textileMaterials = ProdJson.textileMaterialsJson
        , textileProductExamples = ProdJson.textileProductExamplesJson
        , textileProducts = ProdJson.textileProductsJson
        , transports = ProdJson.transportsJson
        , veliComponents = ProdJson.rawJsonComponents.veliComponents
        , veliExamples = ProdJson.veliExamplesJson
        , veliProductCategories = ProdJson.veliProductCategoriesJson
        }
