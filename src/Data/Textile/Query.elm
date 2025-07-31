module Data.Textile.Query exposing
    ( MaterialQuery
    , Query
    , addMaterial
    , b64decode
    , b64encode
    , buildApiQuery
    , decode
    , default
    , encode
    , handleUpcycling
    , isAdvancedQuery
    , jupeCotonAsie
    , materialWithId
    , parseBase64Query
    , regulatory
    , removeMaterial
    , tShirtCotonFrance
    , toggleStep
    , updateMaterial
    , updateMaterialSpinning
    , updateProduct
    , updateStepCountry
    , updateTrims
    , validateMaterials
    )

import Base64
import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Component as Component exposing (Item)
import Data.Country as Country
import Data.Split as Split exposing (Split)
import Data.Textile.Dyeing as Dyeing exposing (ProcessType)
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material, idFromString)
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Url.Parser as Parser exposing (Parser)


type alias MaterialQuery =
    { country : Maybe Country.Code
    , id : Material.Id
    , share : Split
    , spinning : Maybe Spinning
    }


materialWithId : Material.Id -> Split -> Maybe Spinning -> Maybe Country.Code -> MaterialQuery
materialWithId id share spinning country =
    { id = id
    , share = share
    , spinning = spinning
    , country = country
    }


type alias Query =
    { airTransportRatio : Maybe Split
    , business : Maybe Economics.Business
    , countryDyeing : Maybe Country.Code
    , countryFabric : Maybe Country.Code
    , countryMaking : Maybe Country.Code
    , countrySpinning : Maybe Country.Code
    , disabledSteps : List Label
    , dyeingProcessType : Maybe ProcessType
    , fabricProcess : Maybe Fabric
    , fading : Maybe Bool
    , makingComplexity : Maybe MakingComplexity
    , makingDeadStock : Maybe Split
    , makingWaste : Maybe Split
    , mass : Mass
    , materials : List MaterialQuery
    , numberOfReferences : Maybe Int
    , physicalDurability : Maybe Unit.PhysicalDurability
    , price : Maybe Economics.Price
    , printing : Maybe Printing
    , product : Product.Id
    , surfaceMass : Maybe Unit.SurfaceMass
    , trims : Maybe (List Item)
    , upcycled : Bool
    , yarnSize : Maybe Unit.YarnSize
    }


addMaterial : Material -> Query -> Query
addMaterial material query =
    let
        materialQuery =
            { country = Nothing
            , id = material.id
            , share = Split.zero
            , spinning = Nothing
            }
    in
    { query
        | materials =
            query.materials ++ [ materialQuery ]
    }


{-| Update query trims, falling back to product category defaults when none is defined yet
-}
updateTrims : List Product -> (List Item -> List Item) -> Query -> Query
updateTrims products fn query =
    let
        productDefaultTrims =
            products
                |> Product.findById query.product
                |> Result.map .trims
    in
    case ( query.trims, productDefaultTrims ) of
        -- The query has custom trims, and the product has default trims
        ( Just trims, Ok defaults ) ->
            { query
                | trims =
                    if fn trims == defaults then
                        Nothing

                    else
                        Just (fn trims)
            }

        -- The query has no custom trims, and the product has default trims
        ( Nothing, Ok defaults ) ->
            { query | trims = Just (fn defaults) }

        -- Product category not found, should never happen
        ( _, Err _ ) ->
            { query | trims = Nothing }


buildApiQuery : String -> Query -> String
buildApiQuery clientUrl query =
    """curl -sS -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "api/textile/simulator")
        |> String.replace "%json%" (encode query |> Encode.encode 0)


decode : Decoder Query
decode =
    Decode.succeed Query
        |> DU.strictOptional "airTransportRatio" Split.decodeFloat
        |> DU.strictOptional "business" Economics.decodeBusiness
        |> DU.strictOptional "countryDyeing" Country.decodeCode
        |> DU.strictOptional "countryFabric" Country.decodeCode
        |> DU.strictOptional "countryMaking" Country.decodeCode
        |> DU.strictOptional "countrySpinning" Country.decodeCode
        |> Pipe.optional "disabledSteps" (Decode.list Label.decodeFromCode) []
        |> DU.strictOptional "dyeingProcessType" Dyeing.decode
        |> DU.strictOptional "fabricProcess" Fabric.decode
        |> DU.strictOptional "fading" Decode.bool
        |> DU.strictOptional "makingComplexity" MakingComplexity.decode
        |> DU.strictOptional "makingDeadStock" Split.decodeFloat
        |> DU.strictOptional "makingWaste" Split.decodeFloat
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "materials" (Decode.list decodeMaterialQuery)
        |> DU.strictOptional "numberOfReferences" Decode.int
        |> DU.strictOptional "physicalDurability" Unit.decodePhysicalDurability
        |> DU.strictOptional "price" Economics.decodePrice
        |> DU.strictOptional "printing" Printing.decode
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> DU.strictOptional "surfaceMass" Unit.decodeSurfaceMass
        |> DU.strictOptional "trims" (Decode.list Component.decodeItem)
        |> Pipe.optional "upcycled" Decode.bool False
        |> DU.strictOptional "yarnSize" Unit.decodeYarnSize


decodeMaterialQuery : Decoder MaterialQuery
decodeMaterialQuery =
    Decode.succeed MaterialQuery
        |> DU.strictOptional "country" Country.decodeCode
        |> Pipe.required "id" Material.decodeId
        |> Pipe.required "share" Split.decodeFloat
        |> DU.strictOptional "spinning" Spinning.decode


encode : Query -> Encode.Value
encode query =
    EU.optionalPropertiesObject
        [ ( "airTransportRatio", query.airTransportRatio |> Maybe.map Split.encodeFloat )
        , ( "business", query.business |> Maybe.map Economics.encodeBusiness )
        , ( "countryDyeing", query.countryDyeing |> Maybe.map Country.encodeCode )
        , ( "countryFabric", query.countryFabric |> Maybe.map Country.encodeCode )
        , ( "countryMaking", query.countryMaking |> Maybe.map Country.encodeCode )
        , ( "countrySpinning", query.countrySpinning |> Maybe.map Country.encodeCode )
        , ( "disabledSteps"
          , case query.disabledSteps of
                [] ->
                    Nothing

                list ->
                    Encode.list Label.encode list |> Just
          )
        , ( "dyeingProcessType", query.dyeingProcessType |> Maybe.map Dyeing.encode )
        , ( "fabricProcess", query.fabricProcess |> Maybe.map Fabric.encode )
        , ( "fading", query.fading |> Maybe.map Encode.bool )
        , ( "makingComplexity", query.makingComplexity |> Maybe.map (MakingComplexity.toString >> Encode.string) )
        , ( "makingDeadStock", query.makingDeadStock |> Maybe.map Split.encodeFloat )
        , ( "makingWaste", query.makingWaste |> Maybe.map Split.encodeFloat )
        , ( "mass", query.mass |> Mass.inKilograms |> Encode.float |> Just )
        , ( "materials", query.materials |> Encode.list encodeMaterialQuery |> Just )
        , ( "numberOfReferences", query.numberOfReferences |> Maybe.map Encode.int )
        , ( "physicalDurability", query.physicalDurability |> Maybe.map Unit.encodePhysicalDurability )
        , ( "price", query.price |> Maybe.map Economics.encodePrice )
        , ( "printing", query.printing |> Maybe.map Printing.encode )
        , ( "product", query.product |> Product.idToString |> Encode.string |> Just )
        , ( "surfaceMass", query.surfaceMass |> Maybe.map Unit.encodeSurfaceMass )
        , ( "trims", query.trims |> Maybe.map (Encode.list Component.encodeItem) )
        , ( "upcycled", Encode.bool query.upcycled |> Just )
        , ( "yarnSize", query.yarnSize |> Maybe.map Unit.encodeYarnSize )
        ]


encodeMaterialQuery : MaterialQuery -> Encode.Value
encodeMaterialQuery v =
    EU.optionalPropertiesObject
        [ ( "country", v.country |> Maybe.map Country.encodeCode )
        , ( "id", Material.encodeId v.id |> Just )
        , ( "share", Split.encodeFloat v.share |> Just )
        , ( "spinning", v.spinning |> Maybe.map Spinning.encode )
        ]


removeMaterial : Material.Id -> Query -> Query
removeMaterial materialId query =
    { query | materials = query.materials |> List.filter (\m -> m.id /= materialId) }
        |> (\newQuery ->
                -- set share to 100% when a single material remains
                if List.length newQuery.materials == 1 then
                    newQuery.materials
                        |> List.head
                        |> Maybe.map (\m -> updateMaterialShare m.id Split.full newQuery)
                        |> Maybe.withDefault newQuery

                else
                    newQuery
           )


{-| Handle the case of upcycling: when a garment is upcycled, we disable the Material, Spinning,
Fabric and Ennobling steps and enforce the use of a high making complexity
-}
handleUpcycling : Query -> Query
handleUpcycling query =
    if query.upcycled then
        { query
            | disabledSteps = LE.unique <| Label.upcyclables ++ query.disabledSteps
            , makingComplexity = query.makingComplexity |> Maybe.withDefault MakingComplexity.High |> Just
        }

    else
        query


isAdvancedQuery : Query -> Bool
isAdvancedQuery query =
    List.any identity
        [ query.dyeingProcessType /= Nothing && query.dyeingProcessType /= Just Dyeing.Average
        , query.fabricProcess /= Nothing
        , query.makingComplexity /= Nothing
        , query.makingDeadStock /= Nothing
        , query.makingWaste /= Nothing
        , query.materials |> List.any (.spinning >> (/=) Nothing)
        , query.physicalDurability /= Nothing
        , query.surfaceMass /= Nothing
        , query.trims /= Nothing
        , not query.upcycled && List.length query.disabledSteps > 0
        , query.yarnSize /= Nothing
        ]


{-| Resets a query to use only regulatory-level fields.
-}
regulatory : Query -> Query
regulatory query =
    { query
        | disabledSteps = []
        , dyeingProcessType = Nothing
        , fabricProcess = Nothing
        , makingComplexity = Nothing
        , makingDeadStock = Nothing
        , makingWaste = Nothing
        , materials = query.materials |> List.map (\m -> { m | spinning = Nothing })
        , physicalDurability = Nothing
        , surfaceMass = Nothing
        , trims = Nothing
        , yarnSize = Nothing
    }


toggleStep : Label -> Query -> Query
toggleStep label query =
    { query
        | disabledSteps =
            if List.member label query.disabledSteps then
                List.filter ((/=) label) query.disabledSteps

            else
                label :: query.disabledSteps
    }


updateMaterial : Material.Id -> MaterialQuery -> Query -> Query
updateMaterial oldMaterialId newMaterial =
    updateMaterialQuery oldMaterialId
        (\materialQuery ->
            { materialQuery
                | country = newMaterial.country
                , id = newMaterial.id
                , share = newMaterial.share
                , spinning = Nothing
            }
        )


updateMaterialQuery : Material.Id -> (MaterialQuery -> MaterialQuery) -> Query -> Query
updateMaterialQuery materialId update query =
    { query | materials = query.materials |> LE.updateIf (.id >> (==) materialId) update }


updateMaterialShare : Material.Id -> Split -> Query -> Query
updateMaterialShare materialId share =
    updateMaterialQuery materialId
        (\materialQuery -> { materialQuery | share = share })


updateMaterialSpinning : Material -> Spinning -> Query -> Query
updateMaterialSpinning material spinning query =
    { query
        | materials =
            query.materials
                |> List.map
                    (\materialQuery ->
                        if materialQuery.id == material.id then
                            { materialQuery | spinning = Just spinning }

                        else
                            materialQuery
                    )
    }


updateProduct : Product -> Query -> Query
updateProduct product query =
    if product.id /= query.product then
        -- Product category has changed, reset a bunch of related query params
        { query
            | dyeingProcessType = Nothing
            , fabricProcess = Nothing
            , makingComplexity = Nothing
            , makingDeadStock = Nothing
            , makingWaste = Nothing
            , price = Nothing
            , printing = Nothing
            , product = product.id
            , surfaceMass = Nothing
            , trims = Nothing
            , yarnSize = Nothing
        }

    else
        query


updateStepCountry : Label -> Country.Code -> Query -> Query
updateStepCountry label code query =
    let
        maybeCode =
            if code == Country.unknownCountryCode then
                Nothing

            else
                Just code
    in
    case label of
        Label.Ennobling ->
            { query | countryDyeing = maybeCode }

        Label.Fabric ->
            { query | countryFabric = maybeCode }

        Label.Making ->
            { query
                | airTransportRatio =
                    if query.countryMaking /= maybeCode then
                        -- reset custom value as we just switched country
                        Nothing

                    else
                        query.airTransportRatio
                , countryMaking = maybeCode
            }

        Label.Spinning ->
            { query | countrySpinning = maybeCode }

        _ ->
            query


validateMaterials : List MaterialQuery -> Result String (List MaterialQuery)
validateMaterials materials =
    if materials == [] then
        Ok []

    else
        let
            total =
                materials
                    |> List.map (.share >> Split.toFloat)
                    |> List.sum
        in
        -- Note: taking care of float number rounding precision errors https://en.wikipedia.org/wiki/Round-off_error
        if not (List.member total [ 1, 0.6 + 0.3 + 0.1 ]) then
            Err <|
                "La somme des parts de matières doit être égale à 1 (ici : "
                    ++ String.fromFloat total
                    ++ ")"

        else
            Ok materials



-- Sample data


default : Query
default =
    { airTransportRatio = Nothing
    , business = Nothing
    , countryDyeing = Just (Country.Code "CN")
    , countryFabric = Just (Country.Code "CN")
    , countryMaking = Just (Country.Code "CN")
    , countrySpinning = Just (Country.Code "CN")
    , disabledSteps = []
    , dyeingProcessType = Nothing
    , fabricProcess = Nothing
    , fading = Nothing
    , makingComplexity = Nothing
    , makingDeadStock = Nothing
    , makingWaste = Nothing
    , mass = Mass.kilograms 0.17
    , materials =
        case Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84" of
            Ok id ->
                [ materialWithId id Split.full Nothing Nothing ]

            Err _ ->
                []
    , numberOfReferences = Nothing
    , physicalDurability = Nothing
    , price = Nothing
    , printing = Nothing
    , product = Product.Id "tshirt"
    , surfaceMass = Nothing
    , trims = Nothing
    , upcycled = False
    , yarnSize = Nothing
    }


jupeCotonAsie : Query
jupeCotonAsie =
    { default
        | fabricProcess = Just Fabric.Weaving
        , mass = Mass.kilograms 0.3
        , product = Product.Id "jupe"
    }


tShirtCotonFrance : Query
tShirtCotonFrance =
    { default
        | countryDyeing = Just (Country.Code "FR")
        , countryFabric = Just (Country.Code "FR")
        , countryMaking = Just (Country.Code "FR")
        , countrySpinning = Just (Country.Code "FR")
    }



-- Parser


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decode
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encode >> Encode.encode 0 >> Base64.encode


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just
