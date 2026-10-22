module Static.Db exposing (dbFromStaticFiles)

import Data.Db as Db exposing (Db)
import Static.Json as StaticJson


{-| Build a Db from static file strings.

IMPORTANT NOTE: this module should _never_ be imported by the Main module (the Web app), as it imports
all the db JSON strings statically, which bloats the js build for no added value. The intended use of
this function is for the API Server (tests load Fixture.Db instead)

-}
dbFromStaticFiles : String -> Result String Db
dbFromStaticFiles processesJson =
    Db.buildFromStrings
        { countries = StaticJson.countriesJson
        , definitions = StaticJson.impactsJson
        , food2Components = StaticJson.food2ComponentsJson
        , food2Examples = StaticJson.food2ExamplesJson
        , food2ProductCategories = StaticJson.food2ProductCategoriesJson
        , foodIngredients = StaticJson.foodIngredientsJson
        , foodProductExamples = StaticJson.foodProductExamplesJson
        , objectComponents = StaticJson.rawJsonComponents.objectComponents
        , objectExamples = StaticJson.objectExamplesJson
        , objectProductCategories = StaticJson.objectProductCategoriesJson
        , processes = processesJson
        , textileComponents = StaticJson.rawJsonComponents.textileComponents
        , textileMaterials = StaticJson.textileMaterialsJson
        , textileProductExamples = StaticJson.textileProductExamplesJson
        , textileProducts = StaticJson.textileProductsJson
        , transports = StaticJson.transportsJson
        , veliComponents = StaticJson.rawJsonComponents.veliComponents
        , veliExamples = StaticJson.veliExamplesJson
        , veliProductCategories = StaticJson.veliProductCategoriesJson
        }
