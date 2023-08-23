module Data.Textile.Material exposing
    ( CFFData
    , Id(..)
    , Material
    , decodeList
    , encode
    , encodeId
    , findById
    , getDefaultSpinning
    , getRecyclingData
    , getSpinningElec
    , groupAll
    , idToString
    )

import Data.Country as Country
import Data.Split as Split exposing (Split)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Material =
    { id : Id
    , name : String
    , shortName : String
    , origin : Origin
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



---- Spinning


type Spinning
    = ConventionalSpinning
      -- TODO: when the user will be able to select the spinning process
      -- | UnconventionalSpinning
    | SyntheticSpinning


type alias SpinningProcessData =
    { normalization : Float, waste : Float }


spinningProcessesData : { conventional : SpinningProcessData, unconventional : SpinningProcessData, synthetic : SpinningProcessData }
spinningProcessesData =
    -- See https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#consommation-delectricite
    -- and https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#taux-de-pertes
    { conventional = { normalization = 4, waste = 0.12 }
    , unconventional = { normalization = 2, waste = 0.12 }
    , synthetic = { normalization = 1.5, waste = 0.03 }
    }


getDefaultSpinning : Origin -> Spinning
getDefaultSpinning origin =
    -- See https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#fabrication-du-fil-filature-vs-filage-1
    case origin of
        Origin.Synthetic ->
            SyntheticSpinning

        _ ->
            ConventionalSpinning


normalizationForSpinning : Spinning -> Float
normalizationForSpinning spinning =
    case spinning of
        ConventionalSpinning ->
            spinningProcessesData.conventional.normalization

        -- TODO: when the user will be able to select the spinning process
        -- UnconventionalSpinning ->
        --     spinningProcessesData.unconventional.normalization
        SyntheticSpinning ->
            spinningProcessesData.synthetic.normalization


getSpinningElec : Mass -> Unit.YarnSize -> Spinning -> Float
getSpinningElec mass yarnSize spinning =
    -- See the formula in https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#consommation-delectricite
    -- Formula : kWh(Process)=YarnSize(Nm)/50∗Normalization(Process)∗OutputMass(kg)
    let
        normalization =
            normalizationForSpinning spinning
    in
    (Unit.yarnSizeInKilometers yarnSize |> toFloat)
        / 50
        * normalization
        * Mass.inKilograms mass



---- Recycling


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Split
    , recycledQualityRatio : Split
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



---- Helpers


findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


groupAll :
    List Material
    -> ( List Material, List Material, List Material )
groupAll =
    List.sortBy .shortName >> groupByOrigins


fromOrigin : Origin -> List Material -> List Material
fromOrigin origin =
    List.filter (.origin >> (==) origin)


groupByOrigins : List Material -> ( List Material, List Material, List Material )
groupByOrigins materials =
    ( materials |> fromOrigin Origin.Natural
    , materials |> fromOrigin Origin.Synthetic
    , materials |> fromOrigin Origin.Artificial
    )


decode : List Process -> Decoder Material
decode processes =
    Decode.succeed Material
        |> JDP.required "id" (Decode.map Id Decode.string)
        |> JDP.required "name" Decode.string
        |> JDP.required "shortName" Decode.string
        |> JDP.required "origin" Origin.decode
        |> JDP.required "materialProcessUuid" (Process.decodeFromUuid processes)
        |> JDP.required "recycledProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> JDP.required "recycledFrom" (Decode.maybe (Decode.map Id Decode.string))
        |> JDP.required "spinningProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> JDP.required "geographicOrigin" Decode.string
        |> JDP.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> JDP.required "priority" Decode.int
        |> JDP.required "cff" (Decode.maybe decodeCFFData)


decodeCFFData : Decoder CFFData
decodeCFFData =
    Decode.succeed CFFData
        |> JDP.required "manufacturerAllocation" Split.decodeFloat
        |> JDP.required "recycledQualityRatio" Split.decodeFloat


decodeList : List Process -> Decoder (List Material)
decodeList processes =
    Decode.list (decode processes)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "id", encodeId v.id )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "origin", v.origin |> Origin.toString |> Encode.string )
        , ( "materialProcessUuid", Process.encodeUuid v.materialProcess.uuid )
        , ( "recycledProcessUuid"
          , v.recycledProcess |> Maybe.map (.uuid >> Process.encodeUuid) |> Maybe.withDefault Encode.null
          )
        , ( "recycledFrom", v.recycledFrom |> Maybe.map encodeId |> Maybe.withDefault Encode.null )
        , ( "spinningProcessUuid"
          , v.spinningProcess |> Maybe.map (.uuid >> Process.encodeUuid) |> Maybe.withDefault Encode.null
          )
        , ( "geographicOrigin", Encode.string v.geographicOrigin )
        , ( "defaultCountry", v.defaultCountry |> Country.codeToString |> Encode.string )
        , ( "priority", Encode.int v.priority )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


idToString : Id -> String
idToString (Id string) =
    string
