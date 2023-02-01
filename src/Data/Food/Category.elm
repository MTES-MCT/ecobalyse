module Data.Food.Category exposing
    ( Bounds
    , Categories
    , Category
    , CategoryBounds
    , Id
    , all
    , getCategoryBounds
    )

import Dict exposing (Dict)


type alias Category =
    { name : String
    , bounds : CategoryBounds
    }


type alias Categories =
    Dict Id Category


type alias Id =
    String


type alias Bounds =
    { impact100 : Float
    , impact0 : Float
    }


type alias CategoryBounds =
    { all : Bounds
    , climate : Bounds
    , biodiversity : Bounds
    , resources : Bounds
    , health : Bounds
    }


all : Categories
all =
    -- FIXME: This should ideally live in a JSON static file or API response
    Dict.fromList
        [ ( "meats"
          , { name = "Viandes"
            , bounds =
                { all = { impact100 = 500, impact0 = 4000 }
                , climate = { impact100 = 75, impact0 = 846 }
                , biodiversity = { impact100 = 225, impact0 = 2537 }
                , resources = { impact100 = 50, impact0 = 564 }
                , health = { impact100 = 100, impact0 = 1128 }
                }
            }
          )
        , ( "fruitsAndVegetables"
          , { name = "Fruits et légumes"
            , bounds =
                { all = { impact100 = 30, impact0 = 450 }
                , climate = { impact100 = 4.5, impact0 = 95 }
                , biodiversity = { impact100 = 13.5, impact0 = 285 }
                , resources = { impact100 = 3, impact0 = 63 }
                , health = { impact100 = 6, impact0 = 127 }
                }
            }
          )
        , ( "cakes"
          , { name = "Gâteaux"
            , bounds =
                { all = { impact100 = 100, impact0 = 700 }
                , climate = { impact100 = 15, impact0 = 148 }
                , biodiversity = { impact100 = 45, impact0 = 444 }
                , resources = { impact100 = 10, impact0 = 99 }
                , health = { impact100 = 20, impact0 = 197 }
                }
            }
          )
        ]


get : Id -> Result String Category
get id =
    all
        |> Dict.get id
        |> Result.fromMaybe ("Invalide: " ++ id)


getCategoryBounds : (CategoryBounds -> Bounds) -> Id -> Result String Bounds
getCategoryBounds getter id =
    get id
        |> Result.map (.bounds >> getter)
