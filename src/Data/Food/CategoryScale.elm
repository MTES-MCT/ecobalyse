module Data.Food.CategoryScale exposing
    ( CategoryScale
    , CategoryScales
    , Id
    , all
    )

import Dict exposing (Dict)


type alias CategoryScale =
    { name : String
    , bounds : { impact100 : Int, impact0 : Int }
    }


type alias CategoryScales =
    Dict Id CategoryScale


type alias Id =
    String


all : CategoryScales
all =
    Dict.fromList
        [ ( "meats"
          , { name = "Viandes"
            , bounds = { impact100 = 500, impact0 = 4000 }
            }
          )
        , ( "fruitsAndVegetables"
          , { name = "Fruits et légumes"
            , bounds = { impact100 = 30, impact0 = 450 }
            }
          )
        , ( "cakes"
          , { name = "Gâteaux"
            , bounds = { impact100 = 100, impact0 = 700 }
            }
          )
        ]
