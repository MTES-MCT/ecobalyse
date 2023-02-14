module Data.Food.Category exposing
    ( Bounds
    , Category
    , CategoryBounds
    , Id(..)
    , all
    , decodeId
    , encodeId
    , get
    , idFromString
    , idToString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type alias Category =
    { id : Id
    , name : String
    , bounds : CategoryBounds
    }


type Id
    = Id String


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


all : List Category
all =
    -- FIXME: This should ideally live in a JSON static file or API response
    [ { id = Id "meats"
      , name = "Viandes"
      , bounds =
            { all = { impact100 = 500, impact0 = 4000 }
            , climate = { impact100 = 75, impact0 = 846 }
            , biodiversity = { impact100 = 225, impact0 = 2537 }
            , resources = { impact100 = 50, impact0 = 564 }
            , health = { impact100 = 100, impact0 = 1128 }
            }
      }
    , { id = Id "fruitsAndVegetables"
      , name = "Fruits et légumes"
      , bounds =
            { all = { impact100 = 30, impact0 = 450 }
            , climate = { impact100 = 4.5, impact0 = 95 }
            , biodiversity = { impact100 = 13.5, impact0 = 285 }
            , resources = { impact100 = 3, impact0 = 63 }
            , health = { impact100 = 6, impact0 = 127 }
            }
      }
    , { id = Id "cakes"
      , name = "Gâteaux"
      , bounds =
            { all = { impact100 = 100, impact0 = 700 }
            , climate = { impact100 = 15, impact0 = 148 }
            , biodiversity = { impact100 = 45, impact0 = 444 }
            , resources = { impact100 = 10, impact0 = 99 }
            , health = { impact100 = 20, impact0 = 197 }
            }
      }
    ]


decodeId : Decoder Id
decodeId =
    Decode.string
        |> Decode.andThen (idFromString >> DE.fromResult)


encodeId : Id -> Encode.Value
encodeId (Id id) =
    Encode.string id


get : Id -> Result String Category
get id =
    all
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Invalide: " ++ idToString id)


idFromString : String -> Result String Id
idFromString string =
    if all |> List.map .id |> List.map idToString |> List.member string then
        Ok (Id string)

    else
        Err <| "Catégorie inconnue: " ++ string


idToString : Id -> String
idToString (Id string) =
    string
