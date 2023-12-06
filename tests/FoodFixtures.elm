module FoodFixtures exposing (carrotCake)

import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Query exposing (Query)
import Data.Food.Retail as Retail
import Mass


carrotCake : Query
carrotCake =
    { ingredients =
        [ { id = Ingredient.idFromString "egg"
          , mass = Mass.grams 120
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , complements = Nothing
          }
        , { id = Ingredient.idFromString "wheat"
          , mass = Mass.grams 140
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , complements = Nothing
          }
        , { id = Ingredient.idFromString "milk"
          , mass = Mass.grams 60
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , complements = Nothing
          }
        , { id = Ingredient.idFromString "carrot"
          , mass = Mass.grams 225
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , complements = Nothing
          }
        ]
    , transform =
        Just
            { -- Cooking, industrial, 1kg of cooked product/ FR U
              code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 545
            }
    , packaging =
        [ { -- Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent
            code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 105
          }
        ]
    , distribution = Just Retail.ambient
    , preparation = [ Preparation.Id "refrigeration" ]
    }
