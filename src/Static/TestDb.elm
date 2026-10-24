module Static.TestDb exposing (dbFromJsonStrings)

import Data.Db as Db exposing (Db)
import Static.TestJson as TestJson


{-| Test dedicated database, built from `src/Static/TestJson.elm`

IMPORTANT NOTE: this module should _never_ be imported by the Main module (the Web app), as it imports
all test db JSON strings statically, which may bloat the js build for no added value. The intended use of
this function is for tests only.

-}
dbFromJsonStrings : Result String Db
dbFromJsonStrings =
    Db.buildFromStrings
        { countries = TestJson.countriesJson
        , definitions = TestJson.impactsJson
        , food2Components = TestJson.food2ComponentsJson
        , food2Examples = TestJson.food2ExamplesJson
        , food2ProductCategories = TestJson.food2ProductCategoriesJson
        , foodIngredients = TestJson.foodIngredientsJson
        , foodProductExamples = TestJson.foodProductExamplesJson
        , objectComponents = TestJson.rawJsonComponents.objectComponents
        , objectExamples = TestJson.objectExamplesJson
        , objectProductCategories = TestJson.objectProductCategoriesJson
        , processes = TestJson.processesJson
        , textileComponents = TestJson.rawJsonComponents.textileComponents
        , textileMaterials = TestJson.textileMaterialsJson
        , textileProductExamples = TestJson.textileProductExamplesJson
        , textileProducts = TestJson.textileProductsJson
        , transports = TestJson.transportsJson
        , veliComponents = TestJson.rawJsonComponents.veliComponents
        , veliExamples = TestJson.veliExamplesJson
        , veliProductCategories = TestJson.veliProductCategoriesJson
        }
