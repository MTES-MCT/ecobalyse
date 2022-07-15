module Data.Textile.Material exposing
    ( CFFData
    , Id(..)
    , Material
    , codec
    , findById
    , getRecyclingData
    , groupAll
    , idCodec
    , idToString
    , listCodec
    )

import Codec exposing (Codec)
import Data.Country as Country
import Data.Textile.Material.Category as Category exposing (Category)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit


type alias Material =
    { id : Id
    , name : String
    , shortName : String
    , category : Category
    , materialProcess : Process
    , recycledProcess : Maybe Process
    , recycledFrom : Maybe Id
    , spinningProcess : Maybe Process -- Optional, as some materials are not spinned (eg. Neoprene)
    , geographicOrigin : String -- A textual information about the geographic origin of the material
    , defaultCountry : Country.Code -- Default country for Material and Spinning steps
    , priority : Int -- Used to sort materials
    , cffData : Maybe CFFData
    }


type Id
    = Id String


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Unit.Ratio
    , recycledQualityRatio : Unit.Ratio
    }


getRecyclingData : Material -> List Material -> Maybe ( Material, CFFData )
getRecyclingData material materials =
    -- If material is non-recycled, retrieve relevant recycled equivalent material & CFF data
    Maybe.map2 Tuple.pair
        (material.recycledFrom
            |> Maybe.andThen
                (\id ->
                    findById id materials
                        |> Result.toMaybe
                )
        )
        material.cffData


findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


groupAll :
    List Material
    -> ( List Material, List Material, List Material )
groupAll =
    List.sortBy .shortName >> groupByCategories


fromCategory : Category -> List Material -> List Material
fromCategory category =
    List.filter (.category >> (==) category)


groupByCategories : List Material -> ( List Material, List Material, List Material )
groupByCategories materials =
    ( materials |> fromCategory Category.Natural
    , materials |> fromCategory Category.Synthetic
    , materials |> fromCategory Category.Recycled
    )


codec : List Process -> Codec Material
codec processes =
    Codec.object Material
        |> Codec.field "id" .id idCodec
        |> Codec.field "name" .name Codec.string
        |> Codec.field "shortName" .shortName Codec.string
        |> Codec.field "category" .category Category.codec
        |> Codec.field "materialProcessUuid" .materialProcess (Process.processUuidCodec processes)
        |> Codec.field "recycledProcessUuid" .recycledProcess (Codec.maybe (Process.processUuidCodec processes))
        |> Codec.field "recycledFrom" .recycledFrom (Codec.maybe idCodec)
        |> Codec.field "spinningProcessUuid" .spinningProcess (Codec.maybe (Process.processUuidCodec processes))
        |> Codec.field "geographicOrigin" .geographicOrigin Codec.string
        |> Codec.field "defaultCountry" .defaultCountry Country.codeCodec
        |> Codec.field "priority" .priority Codec.int
        |> Codec.field "cff" .cffData (Codec.maybe cffDataCodec)
        |> Codec.buildObject


listCodec : List Process -> Codec (List Material)
listCodec processes =
    Codec.list (codec processes)


cffDataCodec : Codec CFFData
cffDataCodec =
    Codec.object CFFData
        |> Codec.field "manufacturerAllocation" .manufacturerAllocation Unit.ratioCodec
        |> Codec.field "recycledQualityRatio" .recycledQualityRatio Unit.ratioCodec
        |> Codec.buildObject


idCodec : Codec Id
idCodec =
    Codec.map Id idToString Codec.string


idToString : Id -> String
idToString (Id string) =
    string
