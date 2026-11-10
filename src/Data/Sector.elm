module Data.Sector exposing
    ( Dict
    , GenericSector(..)
    , Sector(..)
    , all
    , allGeneric
    , anyOf
    , decode
    , decodeDict
    , decodeGeneric
    , dictGet
    , dictGetMaybe
    , encode
    , encodeGeneric
    , fromString
    , isGeneric
    , parse
    , parseGeneric
    , toGenericSector
    , toLabel
    , toString
    , toStringGeneric
    )

import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type Sector
    = Food
    | Generic GenericSector
    | Textile


type GenericSector
    = Apparel
    | Food2
    | Furniture
    | Object
    | Veli


{-| A dict where keys are typed as `Sector`
-}
type alias Dict a =
    AnyDict String Sector a


all : List Sector
all =
    -- Legacy sectors
    [ Food, Textile ]
        -- Generic sectors
        ++ List.map Generic allGeneric


allGeneric : List GenericSector
allGeneric =
    [ Apparel
    , Food2
    , Furniture
    , Object
    , Veli
    ]


{-| Filter a list of sectored records against any passed allowed sectors
-}
anyOf : List Sector -> List { a | sectors : List Sector } -> List { a | sectors : List Sector }
anyOf sectors =
    List.filter <|
        .sectors
            >> List.any (\sector -> List.member sector sectors)


decode : Decoder Sector
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


decodeDict : Decoder a -> Decoder (Dict a)
decodeDict =
    AnyDict.decode_ (\key _ -> fromString key) toString


decodeGeneric : Decoder GenericSector
decodeGeneric =
    Decode.string
        |> Decode.andThen (fromStringGeneric >> DE.fromResult)


dictGet : Sector -> Dict a -> Maybe a
dictGet =
    AnyDict.get


dictGetMaybe : Sector -> Dict (Maybe a) -> Maybe a
dictGetMaybe sector dict =
    case dictGet sector dict of
        Just maybe ->
            maybe

        Nothing ->
            Nothing


encode : Sector -> Encode.Value
encode =
    toString >> Encode.string


encodeGeneric : GenericSector -> Encode.Value
encodeGeneric =
    toStringGeneric >> Encode.string


fromString : String -> Result String Sector
fromString string =
    case string of
        "food" ->
            Ok Food

        "textile" ->
            Ok Textile

        genericSectorString ->
            case fromStringGeneric genericSectorString of
                Err _ ->
                    Err <| "Couldn't decode unknown sector " ++ genericSectorString

                Ok genericSector ->
                    Ok (Generic genericSector)


fromStringGeneric : String -> Result String GenericSector
fromStringGeneric string =
    case Dict.get string genericNameDict of
        Just sector ->
            Ok sector

        Nothing ->
            Err <| "Couldn't decode unknown generic sector " ++ string


genericNameDict : Dict.Dict String GenericSector
genericNameDict =
    allGeneric
        |> List.foldl
            (\sector dict ->
                Dict.insert (toStringGeneric sector) sector dict
            )
            Dict.empty


isGeneric : Sector -> Bool
isGeneric sector =
    case sector of
        Generic _ ->
            True

        _ ->
            False


parse : Parser (Sector -> a) a
parse =
    Parser.custom "SECTOR" <|
        (fromString >> Result.toMaybe)


parseGeneric : Parser (GenericSector -> a) a
parseGeneric =
    Parser.custom "GENERIC_SECTOR" (fromStringGeneric >> Result.toMaybe)


toGenericSector : Sector -> Maybe GenericSector
toGenericSector sector =
    case sector of
        Generic genericSector ->
            Just genericSector

        _ ->
            Nothing


toLabel : Sector -> String
toLabel sector =
    case sector of
        Food ->
            "Alimentaire"

        Generic genericSector ->
            toLabelGeneric genericSector

        Textile ->
            "Textile"


toLabelGeneric : GenericSector -> String
toLabelGeneric genericSector =
    case genericSector of
        Apparel ->
            "Habillement"

        Food2 ->
            "Alimentaire BÉTA"

        Furniture ->
            "Ameublement"

        Object ->
            "Objets"

        Veli ->
            "Véhicules"


toString : Sector -> String
toString sector =
    case sector of
        Food ->
            "food"

        Generic genericSector ->
            toStringGeneric genericSector

        Textile ->
            "textile"


toStringGeneric : GenericSector -> String
toStringGeneric genericSector =
    case genericSector of
        Apparel ->
            "apparel"

        Food2 ->
            "food2"

        Furniture ->
            "furniture"

        Object ->
            "object"

        Veli ->
            "veli"
