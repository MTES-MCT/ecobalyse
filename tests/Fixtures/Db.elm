module Fixtures.Db exposing (componentConfigJson, db)

import Data.Db as Db exposing (Db)
import Fixtures.Json as FixturesJson


{-| Proxified for readability
-}
componentConfigJson : String
componentConfigJson =
    FixturesJson.componentConfigJson


{-| Test dedicated database, built from `tests/Fixtures/Json.elm`
-}
db : Result String Db
db =
    Db.build
        { countries = Db.rawJsonString FixturesJson.countriesJson
        , definitions = Db.rawJsonString FixturesJson.impactsJson
        , food2Components = Db.rawJsonString FixturesJson.food2ComponentsJson
        , food2Examples = Db.rawJsonString FixturesJson.food2ExamplesJson
        , food2ProductCategories = Db.rawJsonString FixturesJson.food2ProductCategoriesJson
        , foodIngredients = Db.rawJsonString FixturesJson.foodIngredientsJson
        , foodProductExamples = Db.rawJsonString FixturesJson.foodProductExamplesJson
        , objectComponents = Db.rawJsonString FixturesJson.rawJsonComponents.objectComponents
        , objectExamples = Db.rawJsonString FixturesJson.objectExamplesJson
        , objectProductCategories = Db.rawJsonString FixturesJson.objectProductCategoriesJson
        , processes = Db.rawJsonString FixturesJson.processesJson
        , textileComponents = Db.rawJsonString FixturesJson.rawJsonComponents.textileComponents
        , textileMaterials = Db.rawJsonString FixturesJson.textileMaterialsJson
        , textileProductExamples = Db.rawJsonString FixturesJson.textileProductExamplesJson
        , textileProducts = Db.rawJsonString FixturesJson.textileProductsJson
        , transports = Db.rawJsonString FixturesJson.transportsJson
        , veliComponents = Db.rawJsonString FixturesJson.rawJsonComponents.veliComponents
        , veliExamples = Db.rawJsonString FixturesJson.veliExamplesJson
        , veliProductCategories = Db.rawJsonString FixturesJson.veliProductCategoriesJson
        }
