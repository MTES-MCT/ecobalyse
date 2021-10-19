module Data.Product exposing (..)

import Data.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Product =
    { id : Id
    , name : String
    , mass : Mass
    , pcrWaste : Float -- PCR product waste ratio
    , ppm : Int -- pick per meter
    , grammage : Int -- grammes per kg
    , knitted : Bool -- True: Tricotage (Knitting); False: Tissage (Weaving)
    , makingProcessUuid : Process.Uuid
    }


type Id
    = Id String


choices : List Product
choices =
    -- Making process uuid:
    -- - Confection (jeans);1f428a50-73c0-4fc1-ab39-00fd312458ee
    -- - Confection (gilet, jupe, pantalon, pull);387059fc-72cb-4a92-b1e7-2ef9242f8380
    -- - Confection (débardeur, tee-shirt, combinaison);26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5
    -- - Confection (chemisier, manteau, veste, cape, robe);7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe
    -- - Confection (ceinture, châle, chapeau, sac, écharpe);0a260a3f-260e-4b43-a0df-0cf673fda960
    [ { id = Id "1"
      , name = "Cape"
      , mass = Mass.kilograms 0.95
      , pcrWaste = 0.2
      , ppm = 1600
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe"
      }
    , { id = Id "2"
      , name = "Châle"
      , mass = Mass.kilograms 0.11
      , pcrWaste = 0.1
      , ppm = 1600
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "0a260a3f-260e-4b43-a0df-0cf673fda960"
      }
    , { id = Id "3"
      , name = "Chemisier"
      , mass = Mass.kilograms 0.25
      , pcrWaste = 0.2
      , ppm = 5000
      , grammage = 40
      , knitted = False
      , makingProcessUuid = Process.Uuid "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe"
      }
    , { id = Id "4"
      , name = "Débardeur"
      , mass = Mass.kilograms 0.17
      , pcrWaste = 0.15
      , ppm = 0
      , grammage = 0
      , knitted = True
      , makingProcessUuid = Process.Uuid "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5"
      }
    , { id = Id "5"
      , name = "Echarpe"
      , mass = Mass.kilograms 0.11
      , pcrWaste = 0.1
      , ppm = 1600
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "0a260a3f-260e-4b43-a0df-0cf673fda960"
      }
    , { id = Id "6"
      , name = "Gilet"
      , mass = Mass.kilograms 0.5
      , pcrWaste = 0.2
      , ppm = 0
      , grammage = 0
      , knitted = True
      , makingProcessUuid = Process.Uuid "387059fc-72cb-4a92-b1e7-2ef9242f8380"
      }
    , { id = Id "7"
      , name = "Jean"
      , mass = Mass.kilograms 0.45
      , pcrWaste = 0.22
      , ppm = 3000
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "1f428a50-73c0-4fc1-ab39-00fd312458ee"
      }
    , { id = Id "8"
      , name = "Jupe"
      , mass = Mass.kilograms 0.3
      , pcrWaste = 0.2
      , ppm = 5000
      , grammage = 40
      , knitted = False
      , makingProcessUuid = Process.Uuid "387059fc-72cb-4a92-b1e7-2ef9242f8380"
      }
    , { id = Id "9"
      , name = "Manteau"
      , mass = Mass.kilograms 0.95
      , pcrWaste = 0.2
      , ppm = 1600
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe"
      }
    , { id = Id "10"
      , name = "Pantalon"
      , mass = Mass.kilograms 0.45
      , pcrWaste = 0.2
      , ppm = 3000
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "387059fc-72cb-4a92-b1e7-2ef9242f8380"
      }
    , { id = Id "11"
      , name = "Pull"
      , mass = Mass.kilograms 0.5
      , pcrWaste = 0.2
      , ppm = 0
      , grammage = 0
      , knitted = True
      , makingProcessUuid = Process.Uuid "387059fc-72cb-4a92-b1e7-2ef9242f8380"
      }
    , { id = Id "12"
      , name = "Robe"
      , mass = Mass.kilograms 0.3
      , pcrWaste = 0.2
      , ppm = 5000
      , grammage = 40
      , knitted = False
      , makingProcessUuid = Process.Uuid "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe"
      }
    , tShirt
    , { id = Id "14"
      , name = "Veste"
      , mass = Mass.kilograms 0.95
      , pcrWaste = 0.2
      , ppm = 3000
      , grammage = 140
      , knitted = False
      , makingProcessUuid = Process.Uuid "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe"
      }
    ]


findById : Id -> Product
findById id =
    choices
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Maybe.withDefault invalid


findById2 : Id -> List Product -> Result String Product
findById2 id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id)


findByName : String -> Product
findByName name =
    choices
        |> List.filter (.name >> (==) name)
        |> List.head
        |> Maybe.withDefault invalid


tShirt : Product
tShirt =
    { id = Id "13"
    , name = "T-shirt"
    , mass = Mass.kilograms 0.17
    , pcrWaste = 0.15
    , ppm = 0
    , grammage = 0
    , knitted = True
    , makingProcessUuid = Process.Uuid "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5"
    }


invalid : Product
invalid =
    { id = Id ""
    , name = "<invalide>"
    , mass = Mass.kilograms 0.17
    , pcrWaste = 0.15
    , ppm = 0
    , grammage = 0
    , knitted = True
    , makingProcessUuid = Process.Uuid "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5"
    }


getWeavingKnittingProcess : Product -> Process
getWeavingKnittingProcess { knitted } =
    if knitted then
        Process.findByName "Tricotage"

    else
        Process.findByName "Tissage (habillement)"


idToString : Id -> String
idToString (Id string) =
    string


decode : Decoder Product
decode =
    Decode.map8 Product
        (Decode.field "id" (Decode.map Id Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "pcrWaste" Decode.float)
        (Decode.field "ppm" Decode.int)
        (Decode.field "grammage" Decode.int)
        (Decode.field "knitted" Decode.bool)
        (Decode.field "makingProcessUuid" (Decode.map Process.Uuid Decode.string))


decodeList : Decoder (List Product)
decodeList =
    Decode.list decode


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string (idToString v.id) )
        , ( "name", Encode.string v.name )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "pcrWaste", Encode.float v.pcrWaste )
        , ( "ppm", Encode.int v.ppm )
        , ( "grammage", Encode.int v.grammage )
        , ( "knitted", Encode.bool v.knitted )
        , ( "makingProcessUuid", Encode.string (Process.uuidToString v.makingProcessUuid) )
        ]
