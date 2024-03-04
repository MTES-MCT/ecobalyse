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
    , jupeCotonAsie
    , parseBase64Query
    , removeMaterial
    , tShirtCotonFrance
    , toggleStep
    , updateMaterial
    , updateMaterialSpinning
    , updateProduct
    , updateStepCountry
    )

import Base64
import Data.Country as Country
import Data.Split as Split exposing (Split)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Url.Parser as Parser exposing (Parser)


type alias MaterialQuery =
    { id : Material.Id
    , share : Split
    , spinning : Maybe Spinning
    , country : Maybe Country.Code
    }


type alias Query =
    { mass : Mass
    , materials : List MaterialQuery
    , product : Product.Id
    , countrySpinning : Maybe Country.Code
    , countryFabric : Country.Code
    , countryDyeing : Country.Code
    , countryMaking : Country.Code
    , airTransportRatio : Maybe Split
    , makingWaste : Maybe Split
    , makingDeadStock : Maybe Split
    , makingComplexity : Maybe MakingComplexity
    , yarnSize : Maybe Unit.YarnSize
    , surfaceMass : Maybe Unit.SurfaceMass
    , fabricProcess : Fabric
    , disabledSteps : List Label
    , fading : Maybe Bool
    , dyeingMedium : Maybe DyeingMedium
    , printing : Maybe Printing
    , business : Maybe Economics.Business
    , marketingDuration : Maybe Duration
    , numberOfReferences : Maybe Int
    , price : Maybe Economics.Price
    , traceability : Maybe Bool
    }


addMaterial : Material -> Query -> Query
addMaterial material query =
    let
        materialQuery =
            { id = material.id
            , share = Split.zero
            , spinning = Nothing
            , country = Nothing
            }
    in
    { query
        | materials =
            query.materials ++ [ materialQuery ]
    }


buildApiQuery : String -> Query -> String
buildApiQuery clientUrl query =
    """curl -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "api/textile/simulator")
        |> String.replace "%json%" (encode query |> Encode.encode 0)


decode : Decoder Query
decode =
    Decode.succeed Query
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "materials" (Decode.list decodeMaterialQuery)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.optional "countrySpinning" (Decode.maybe Country.decodeCode) Nothing
        |> Pipe.required "countryFabric" Country.decodeCode
        |> Pipe.required "countryDyeing" Country.decodeCode
        |> Pipe.required "countryMaking" Country.decodeCode
        |> Pipe.optional "airTransportRatio" (Decode.maybe Split.decodeFloat) Nothing
        |> Pipe.optional "makingWaste" (Decode.maybe Split.decodeFloat) Nothing
        |> Pipe.optional "makingDeadStock" (Decode.maybe Split.decodeFloat) Nothing
        |> Pipe.optional "makingComplexity" (Decode.maybe MakingComplexity.decode) Nothing
        |> Pipe.optional "yarnSize" (Decode.maybe Unit.decodeYarnSize) Nothing
        |> Pipe.optional "surfaceMass" (Decode.maybe Unit.decodeSurfaceMass) Nothing
        |> Pipe.required "fabricProcess" Fabric.decode
        |> Pipe.optional "disabledSteps" (Decode.list Label.decodeFromCode) []
        |> Pipe.optional "fading" (Decode.maybe Decode.bool) Nothing
        |> Pipe.optional "dyeingMedium" (Decode.maybe DyeingMedium.decode) Nothing
        |> Pipe.optional "printing" (Decode.maybe Printing.decode) Nothing
        |> Pipe.optional "business" (Decode.maybe Economics.decodeBusiness) Nothing
        |> Pipe.optional "marketingDuration" (Decode.maybe (Decode.map Duration.days Decode.float)) Nothing
        |> Pipe.optional "numberOfReferences" (Decode.maybe Decode.int) Nothing
        |> Pipe.optional "price" (Decode.maybe Economics.decodePrice) Nothing
        |> Pipe.optional "traceability" (Decode.maybe Decode.bool) Nothing


decodeMaterialQuery : Decoder MaterialQuery
decodeMaterialQuery =
    Decode.succeed MaterialQuery
        |> Pipe.required "id" (Decode.map Material.Id Decode.string)
        |> Pipe.required "share" Split.decodeFloat
        |> Pipe.optional "spinning" (Decode.maybe Spinning.decode) Nothing
        |> Pipe.optional "country" (Decode.maybe Country.decodeCode) Nothing


encode : Query -> Encode.Value
encode query =
    [ ( "mass", query.mass |> Mass.inKilograms |> Encode.float |> Just )
    , ( "materials", query.materials |> Encode.list encodeMaterialQuery |> Just )
    , ( "product", query.product |> Product.idToString |> Encode.string |> Just )
    , ( "countrySpinning", query.countrySpinning |> Maybe.map Country.encodeCode )
    , ( "countryFabric", query.countryFabric |> Country.encodeCode |> Just )
    , ( "countryDyeing", query.countryDyeing |> Country.encodeCode |> Just )
    , ( "countryMaking", query.countryMaking |> Country.encodeCode |> Just )
    , ( "airTransportRatio", query.airTransportRatio |> Maybe.map Split.encodeFloat )
    , ( "makingWaste", query.makingWaste |> Maybe.map Split.encodeFloat )
    , ( "makingDeadStock", query.makingDeadStock |> Maybe.map Split.encodeFloat )
    , ( "makingComplexity", query.makingComplexity |> Maybe.map (MakingComplexity.toString >> Encode.string) )
    , ( "yarnSize", query.yarnSize |> Maybe.map Unit.encodeYarnSize )
    , ( "surfaceMass", query.surfaceMass |> Maybe.map Unit.encodeSurfaceMass )
    , ( "fabricProcess", query.fabricProcess |> Fabric.encode |> Just )
    , ( "disabledSteps"
      , case query.disabledSteps of
            [] ->
                Nothing

            list ->
                Encode.list Label.encode list |> Just
      )
    , ( "fading", query.fading |> Maybe.map Encode.bool )
    , ( "dyeingMedium", query.dyeingMedium |> Maybe.map DyeingMedium.encode )
    , ( "printing", query.printing |> Maybe.map Printing.encode )
    , ( "business", query.business |> Maybe.map Economics.encodeBusiness )
    , ( "marketingDuration", query.marketingDuration |> Maybe.map (Duration.inDays >> Encode.float) )
    , ( "numberOfReferences", query.numberOfReferences |> Maybe.map Encode.int )
    , ( "price", query.price |> Maybe.map Economics.encodePrice )
    , ( "traceability", query.traceability |> Maybe.map Encode.bool )
    ]
        -- For concision, drop keys where no param is defined
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeMaterialQuery : MaterialQuery -> Encode.Value
encodeMaterialQuery v =
    [ ( "id", Material.encodeId v.id |> Just )
    , ( "share", Split.encodeFloat v.share |> Just )
    , ( "spinning", v.spinning |> Maybe.map Spinning.encode )
    , ( "country", v.country |> Maybe.map Country.encodeCode )
    ]
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


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
                | id = newMaterial.id
                , share = newMaterial.share
                , spinning = Nothing
                , country = newMaterial.country
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
        -- Product has changed, reset a bunch of related query params
        { query
            | product = product.id
            , mass = product.mass
            , makingWaste = Nothing
            , makingDeadStock = Nothing
            , makingComplexity = Nothing
            , yarnSize = Nothing
            , surfaceMass = Nothing
            , fabricProcess = product.fabric
            , fading = Nothing
            , dyeingMedium = Nothing
            , printing = Nothing
        }

    else
        query


updateStepCountry : Label -> Country.Code -> Query -> Query
updateStepCountry label code query =
    case label of
        Label.Spinning ->
            { query | countrySpinning = Just code }

        Label.Fabric ->
            { query | countryFabric = code }

        Label.Ennobling ->
            { query | countryDyeing = code }

        Label.Making ->
            { query
                | countryMaking = code
                , airTransportRatio =
                    if query.countryMaking /= code then
                        -- reset custom value as we just switched country
                        Nothing

                    else
                        query.airTransportRatio
            }

        _ ->
            query



-- Sample data


default : Query
default =
    { mass = Mass.kilograms 0.17
    , materials = [ { id = Material.Id "coton", share = Split.full, spinning = Nothing, country = Nothing } ]
    , product = Product.Id "tshirt"
    , countrySpinning = Just (Country.Code "CN")
    , countryFabric = Country.Code "CN"
    , countryDyeing = Country.Code "CN"
    , countryMaking = Country.Code "CN"
    , airTransportRatio = Nothing
    , makingWaste = Nothing
    , makingDeadStock = Nothing
    , makingComplexity = Nothing
    , yarnSize = Nothing
    , surfaceMass = Nothing
    , fabricProcess = Fabric.KnittingMix
    , disabledSteps = []
    , fading = Nothing
    , dyeingMedium = Nothing
    , printing = Nothing
    , business = Nothing
    , marketingDuration = Nothing
    , numberOfReferences = Nothing
    , price = Nothing
    , traceability = Nothing
    }


jupeCotonAsie : Query
jupeCotonAsie =
    { default
        | mass = Mass.kilograms 0.3
        , product = Product.Id "jupe"
        , fabricProcess = Fabric.Weaving
    }


tShirtCotonFrance : Query
tShirtCotonFrance =
    { default
        | countrySpinning = Just (Country.Code "FR")
        , countryFabric = Country.Code "FR"
        , countryDyeing = Country.Code "FR"
        , countryMaking = Country.Code "FR"
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
