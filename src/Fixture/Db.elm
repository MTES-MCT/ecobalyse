module Fixture.Db exposing (componentConfigJson, db)

import Data.Db as Db exposing (Db)
import Fixture.Json as FixtureJson


{-| Proxified for readability
-}
componentConfigJson : String
componentConfigJson =
    FixtureJson.componentConfigJson


{-| Test dedicated database, built from `src/Fixture/Json.elm`
-}
db : Result String Db
db =
    Db.buildFromStrings
        { countries = FixtureJson.countriesJson
        , definitions = FixtureJson.impactsJson
        , food2Components = FixtureJson.food2ComponentsJson
        , food2Examples = FixtureJson.food2ExamplesJson
        , food2ProductCategories = FixtureJson.food2ProductCategoriesJson
        , foodIngredients = FixtureJson.foodIngredientsJson
        , foodProductExamples = FixtureJson.foodProductExamplesJson
        , objectComponents = FixtureJson.rawJsonComponents.objectComponents
        , objectExamples = FixtureJson.objectExamplesJson
        , objectProductCategories = FixtureJson.objectProductCategoriesJson
        , processes = FixtureJson.processesJson
        , textileComponents = FixtureJson.rawJsonComponents.textileComponents
        , textileMaterials = FixtureJson.textileMaterialsJson
        , textileProductExamples = FixtureJson.textileProductExamplesJson
        , textileProducts = FixtureJson.textileProductsJson
        , transports = FixtureJson.transportsJson
        , veliComponents = FixtureJson.rawJsonComponents.veliComponents
        , veliExamples = FixtureJson.veliExamplesJson
        , veliProductCategories = FixtureJson.veliProductCategoriesJson
        }
