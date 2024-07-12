module Data.Food.Fixtures exposing (..)

import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Query exposing (Query)
import Data.Food.Retail as Retail
import Mass


royalPizza : Query
royalPizza =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 97
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 89
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 70
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "cooked-ham"
          , mass = Mass.grams 16
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 5
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mushroom-eu"
          , mass = Mass.grams 31
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 16
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "black-pepper"
          , mass = Mass.grams 1
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 22
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.identifierFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 363
            }
    , packaging =
        [ { code = Process.identifierFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }
