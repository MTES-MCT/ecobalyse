module Fixture.Db exposing (componentConfigJson, db)

import Data.Db as Db exposing (Db)
import Fixture.Json as FixtureJson


{-| Proxified for readability
-}
componentConfigJson : String
componentConfigJson =
    FixtureJson.componentConfigJson


{-| Test dedicated database, built from `tests/Fixture/Json.elm`
-}
db : Result String Db
db =
    Db.build
        { countries = Db.rawJsonString FixtureJson.countriesJson
        , definitions = Db.rawJsonString FixtureJson.impactsJson
        , food2Components = Db.rawJsonString FixtureJson.food2ComponentsJson
        , food2Examples = Db.rawJsonString FixtureJson.food2ExamplesJson
        , food2ProductCategories = Db.rawJsonString FixtureJson.food2ProductCategoriesJson
        , foodIngredients = Db.rawJsonString FixtureJson.foodIngredientsJson
        , foodProductExamples = Db.rawJsonString FixtureJson.foodProductExamplesJson
        , objectComponents = Db.rawJsonString FixtureJson.rawJsonComponents.objectComponents
        , objectExamples = Db.rawJsonString FixtureJson.objectExamplesJson
        , objectProductCategories = Db.rawJsonString FixtureJson.objectProductCategoriesJson
        , processes = Db.rawJsonString FixtureJson.processesJson
        , textileComponents = Db.rawJsonString FixtureJson.rawJsonComponents.textileComponents
        , textileMaterials = Db.rawJsonString FixtureJson.textileMaterialsJson
        , textileProductExamples = Db.rawJsonString FixtureJson.textileProductExamplesJson
        , textileProducts = Db.rawJsonString FixtureJson.textileProductsJson
        , transports = Db.rawJsonString FixtureJson.transportsJson
        , veliComponents = Db.rawJsonString FixtureJson.rawJsonComponents.veliComponents
        , veliExamples = Db.rawJsonString FixtureJson.veliExamplesJson
        , veliProductCategories = Db.rawJsonString FixtureJson.veliProductCategoriesJson
        }
