module Data.Textile.Inputs exposing
    ( Inputs
    , MaterialInput
    , MaterialQuery
    , Query
    , addMaterial
    , b64decode
    , b64encode
    , countryList
    , decodeQuery
    , defaultQuery
    , encode
    , encodeQuery
    , fromQuery
    , getMainMaterial
    , jupeCircuitAsie
    , parseBase64Query
    , presets
    , removeMaterial
    , tShirtCotonAsie
    , tShirtCotonFrance
    , toQuery
    , toString
    , toggleStep
    , updateMaterial
    , updateMaterialShare
    , updateProduct
    , updateStepCountry
    )

import Base64
import Data.Country as Country exposing (Country)
import Data.Split as Split exposing (Split)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.HeatSource as HeatSource exposing (HeatSource)
import Data.Textile.Knitting as Knitting exposing (Knitting)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)
import Views.Format as Format


type alias MaterialInput =
    { material : Material
    , share : Split
    }


type alias Inputs =
    { mass : Mass
    , materials : List MaterialInput
    , product : Product
    , countryMaterial : Country
    , countrySpinning : Country
    , countryFabric : Country
    , countryDyeing : Country
    , countryMaking : Country
    , countryDistribution : Country
    , countryUse : Country
    , countryEndOfLife : Country
    , airTransportRatio : Maybe Split
    , quality : Maybe Unit.Quality
    , reparability : Maybe Unit.Reparability
    , makingWaste : Maybe Split
    , makingComplexity : Maybe MakingComplexity
    , yarnSize : Maybe Unit.YarnSize
    , surfaceMass : Maybe Unit.SurfaceMass
    , knittingProcess : Maybe Knitting
    , disabledSteps : List Label
    , disabledFading : Maybe Bool
    , dyeingMedium : Maybe DyeingMedium
    , printing : Maybe Printing
    , ennoblingHeatSource : Maybe HeatSource
    }


type alias MaterialQuery =
    { id : Material.Id
    , share : Split
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
    , quality : Maybe Unit.Quality
    , reparability : Maybe Unit.Reparability
    , makingWaste : Maybe Split
    , makingComplexity : Maybe MakingComplexity
    , yarnSize : Maybe Unit.YarnSize
    , surfaceMass : Maybe Unit.SurfaceMass
    , knittingProcess : Maybe Knitting
    , disabledSteps : List Label
    , disabledFading : Maybe Bool
    , dyeingMedium : Maybe DyeingMedium
    , printing : Maybe Printing
    , ennoblingHeatSource : Maybe HeatSource
    }


toMaterialInputs : List Material -> List MaterialQuery -> Result String (List MaterialInput)
toMaterialInputs materials =
    List.map
        (\{ id, share } ->
            Material.findById id materials
                |> Result.map
                    (\material_ ->
                        { material = material_
                        , share = share
                        }
                    )
        )
        >> RE.combine


toMaterialQuery : List MaterialInput -> List MaterialQuery
toMaterialQuery =
    List.map (\{ material, share } -> { id = material.id, share = share })


getMainMaterial : List MaterialInput -> Result String Material
getMainMaterial =
    List.sortBy (.share >> Split.toFloat)
        >> List.reverse
        >> List.head
        >> Maybe.map .material
        >> Result.fromMaybe "La liste de matières est vide."


getMainMaterialCountry : List Country -> List MaterialInput -> Result String Country
getMainMaterialCountry countries =
    getMainMaterial
        >> Result.andThen
            (\{ defaultCountry } ->
                Country.findByCode defaultCountry countries
            )


fromQuery : Db -> Query -> Result String Inputs
fromQuery db query =
    let
        materials =
            query.materials
                |> toMaterialInputs db.materials

        franceResult =
            Country.findByCode (Country.Code "FR") db.countries

        mainMaterialCountry =
            materials |> Result.andThen (getMainMaterialCountry db.countries)
    in
    Ok Inputs
        |> RE.andMap (Ok query.mass)
        |> RE.andMap materials
        |> RE.andMap (db.products |> Product.findById query.product)
        -- Material country is constrained to be the first material's default country
        |> RE.andMap mainMaterialCountry
        -- Spinning country is either provided by query or fallbacks to material's default
        -- country, making the parameter optional
        |> RE.andMap
            (case query.countrySpinning of
                Just spinningCountryCode ->
                    Country.findByCode spinningCountryCode db.countries

                Nothing ->
                    mainMaterialCountry
            )
        |> RE.andMap (db.countries |> Country.findByCode query.countryFabric)
        |> RE.andMap (db.countries |> Country.findByCode query.countryDyeing)
        |> RE.andMap (db.countries |> Country.findByCode query.countryMaking)
        -- The distribution country is always France
        |> RE.andMap franceResult
        -- The use country is always France
        |> RE.andMap franceResult
        -- The end of life country is always France
        |> RE.andMap franceResult
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.quality)
        |> RE.andMap (Ok query.reparability)
        |> RE.andMap (Ok query.makingWaste)
        |> RE.andMap (Ok query.makingComplexity)
        |> RE.andMap (Ok query.yarnSize)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap (Ok query.knittingProcess)
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.disabledFading)
        |> RE.andMap (Ok query.dyeingMedium)
        |> RE.andMap (Ok query.printing)
        |> RE.andMap (Ok query.ennoblingHeatSource)


toQuery : Inputs -> Query
toQuery inputs =
    { mass = inputs.mass
    , materials = toMaterialQuery inputs.materials
    , product = inputs.product.id
    , countrySpinning =
        if
            -- Discard custom spinning country if same as material default country
            (getMainMaterial inputs.materials |> Result.map .defaultCountry)
                == Ok inputs.countrySpinning.code
        then
            Nothing

        else
            Just inputs.countrySpinning.code
    , countryFabric = inputs.countryFabric.code
    , countryDyeing = inputs.countryDyeing.code
    , countryMaking = inputs.countryMaking.code
    , airTransportRatio = inputs.airTransportRatio
    , quality = inputs.quality
    , reparability = inputs.reparability
    , makingWaste = inputs.makingWaste
    , makingComplexity = inputs.makingComplexity
    , yarnSize = inputs.yarnSize
    , surfaceMass = inputs.surfaceMass
    , knittingProcess = inputs.knittingProcess
    , disabledSteps = inputs.disabledSteps
    , disabledFading = inputs.disabledFading
    , dyeingMedium = inputs.dyeingMedium
    , printing = inputs.printing
    , ennoblingHeatSource = inputs.ennoblingHeatSource
    }


toString : Inputs -> String
toString inputs =
    let
        ifStepEnabled label list =
            if not (List.member label inputs.disabledSteps) then
                list

            else
                []
    in
    [ [ inputs.product.name ++ " de " ++ Format.kgToString inputs.mass ]
    , [ materialsToString inputs.materials ]
    , ifStepEnabled Label.Material
        [ "matière"
        , inputs.countryMaterial.name
        ]
    , ifStepEnabled Label.Spinning
        [ "filature"
        , inputs.countrySpinning.name
        ]
    , case inputs.yarnSize of
        Just yarnSize ->
            [ "Titrage", String.fromInt (Unit.yarnSizeInKilometers yarnSize) ++ "Nm" ]

        Nothing ->
            []
    , ifStepEnabled Label.Fabric
        (case inputs.product.fabric of
            Product.Knitted _ ->
                [ "tricotage", inputs.knittingProcess |> Maybe.withDefault Knitting.Mix |> Knitting.toString, inputs.countryFabric.name ]

            Product.Weaved _ ->
                [ "tissage", inputs.countryFabric.name ]
        )
    , ifStepEnabled Label.Ennobling
        [ case inputs.dyeingMedium of
            Just dyeingMedium ->
                "teinture sur " ++ DyeingMedium.toLabel dyeingMedium

            Nothing ->
                "teinture"
        , inputs.countryDyeing.name
        ]
    , ifStepEnabled Label.Ennobling
        [ case inputs.printing of
            Just printing ->
                "impression " ++ Printing.toFullLabel printing

            Nothing ->
                "pas d'impression"
        , inputs.countryDyeing.name
        ]
    , ifStepEnabled Label.Making
        [ "confection"
        , inputs.countryMaking.name ++ makingOptionsToString inputs
        ]
    , ifStepEnabled Label.Distribution
        [ "distribution"
        , inputs.countryDistribution.name
        ]
    , ifStepEnabled Label.Use
        [ "utilisation"
        , inputs.countryUse.name ++ useOptionsToString inputs.quality inputs.reparability
        ]
    , ifStepEnabled Label.EndOfLife
        [ "fin de vie"
        , inputs.countryEndOfLife.name
        ]
    ]
        |> List.filter (not << List.isEmpty)
        |> List.map (String.join "\u{00A0}: ")
        |> String.join ", "


materialsToString : List MaterialInput -> String
materialsToString materials =
    materials
        |> List.filter (\{ share } -> Split.toFloat share > 0)
        |> List.map
            (\{ material, share } ->
                Split.toPercentString share
                    ++ "% "
                    ++ material.shortName
            )
        |> String.join ", "


makingOptionsToString : Inputs -> String
makingOptionsToString { product, makingWaste, makingComplexity, airTransportRatio, disabledFading } =
    [ makingWaste
        |> Maybe.map (Split.toPercentString >> (\s -> s ++ "\u{202F}% de perte"))
    , makingComplexity
        |> Maybe.map (\complexity -> "complexité de confection " ++ MakingComplexity.toLabel complexity)
    , airTransportRatio
        |> Maybe.andThen
            (\ratio ->
                if Split.toPercent ratio == 0 then
                    Nothing

                else
                    Just (Split.toPercentString ratio ++ " de transport aérien")
            )
    , if product.making.fadable && disabledFading == Just True then
        Just "non-délavé"

      else
        Nothing
    ]
        |> List.filterMap identity
        |> String.join ", "
        |> (\s ->
                if s /= "" then
                    " (" ++ s ++ ")"

                else
                    ""
           )


useOptionsToString : Maybe Unit.Quality -> Maybe Unit.Reparability -> String
useOptionsToString maybeQuality maybeReparability =
    let
        ( quality, reparability ) =
            ( maybeQuality
                |> Maybe.map (Unit.qualityToFloat >> String.fromFloat)
                |> Maybe.withDefault "standard"
            , maybeReparability
                |> Maybe.map (Unit.reparabilityToFloat >> String.fromFloat)
                |> Maybe.withDefault "standard"
            )
    in
    if quality /= "standard" || reparability /= "standard" then
        " (qualité " ++ quality ++ ", réparabilité " ++ reparability ++ ")"

    else
        ""


countryList : Inputs -> List Country
countryList inputs =
    [ inputs.countryMaterial
    , inputs.countrySpinning
    , inputs.countryFabric
    , inputs.countryDyeing
    , inputs.countryMaking
    , inputs.countryDistribution
    , inputs.countryUse
    , inputs.countryEndOfLife
    ]


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


toggleStep : Label -> Query -> Query
toggleStep label query =
    { query
        | disabledSteps =
            if List.member label query.disabledSteps then
                List.filter ((/=) label) query.disabledSteps

            else
                label :: query.disabledSteps
    }


addMaterial : Db -> Query -> Query
addMaterial db query =
    let
        ( length, polyester, elasthanne ) =
            ( List.length query.materials
            , Material.Id "pet"
            , Material.Id "pu"
            )

        notUsed id =
            query.materials
                |> List.map .id
                |> List.member id
                |> not

        newMaterialId =
            if length == 1 && notUsed polyester then
                Just polyester

            else if length == 2 && notUsed elasthanne then
                Just elasthanne

            else
                db.materials
                    |> List.filter (.id >> notUsed)
                    |> List.sortBy .priority
                    |> List.map .id
                    |> LE.last
    in
    case newMaterialId of
        Just id ->
            { query
                | materials =
                    query.materials ++ [ { id = id, share = Split.zero } ]
            }

        Nothing ->
            query


updateMaterialAt : Int -> (MaterialQuery -> MaterialQuery) -> Query -> Query
updateMaterialAt index update query =
    { query | materials = query.materials |> LE.updateAt index update }


updateMaterial : Int -> Material -> Query -> Query
updateMaterial index { id } =
    -- Note: The first material country is always extracted and applied in `fromQuery`.
    updateMaterialAt index (\({ share } as m) -> { m | id = id, share = share })


updateMaterialShare : Int -> Split -> Query -> Query
updateMaterialShare index share =
    updateMaterialAt index (\m -> { m | share = share })


removeMaterial : Int -> Query -> Query
removeMaterial index query =
    { query | materials = query.materials |> LE.removeAt index }
        |> (\({ materials } as q) ->
                -- set share to 100% when a single material remains
                if List.length materials == 1 then
                    updateMaterialShare 0 Split.full q

                else
                    q
           )


updateProduct : Product -> Query -> Query
updateProduct product query =
    if product.id /= query.product then
        -- Product has changed, reset a bunch of related query params
        { query
            | product = product.id
            , mass = product.mass
            , quality = Nothing
            , reparability = Nothing
            , makingWaste = Nothing
            , makingComplexity = Nothing
            , yarnSize = Nothing
            , surfaceMass = Nothing
            , knittingProcess = Nothing
            , disabledFading = Nothing
            , dyeingMedium = Nothing
            , printing = Nothing
            , ennoblingHeatSource = Nothing
        }

    else
        query


defaultQuery : Query
defaultQuery =
    tShirtCotonIndia


tShirtCotonFrance : Query
tShirtCotonFrance =
    -- T-shirt circuit France
    { mass = Mass.kilograms 0.17
    , materials = [ { id = Material.Id "coton", share = Split.full } ]
    , product = Product.Id "tshirt"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "FR"
    , countryDyeing = Country.Code "FR"
    , countryMaking = Country.Code "FR"
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , makingComplexity = Nothing
    , yarnSize = Nothing
    , surfaceMass = Nothing
    , knittingProcess = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    , dyeingMedium = Nothing
    , printing = Nothing
    , ennoblingHeatSource = Nothing
    }


tShirtCotonEurope : Query
tShirtCotonEurope =
    -- T-shirt circuit Europe
    { tShirtCotonFrance
        | countryFabric = Country.Code "TR"
        , countryDyeing = Country.Code "TN"
        , countryMaking = Country.Code "ES"
    }


tShirtCotonIndia : Query
tShirtCotonIndia =
    -- T-shirt circuit Inde
    { tShirtCotonFrance
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "IN"
        , countryMaking = Country.Code "IN"
    }


tShirtCotonAsie : Query
tShirtCotonAsie =
    -- T-shirt circuit Asie
    { tShirtCotonFrance
        | countryFabric = Country.Code "CN"
        , countryDyeing = Country.Code "CN"
        , countryMaking = Country.Code "CN"
    }


jupeCircuitAsie : Query
jupeCircuitAsie =
    -- Jupe circuit Asie
    { mass = Mass.kilograms 0.3
    , materials = [ { id = Material.Id "acrylique", share = Split.full } ]
    , product = Product.Id "jupe"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "CN"
    , countryDyeing = Country.Code "CN"
    , countryMaking = Country.Code "CN"
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , makingComplexity = Nothing
    , yarnSize = Nothing
    , surfaceMass = Nothing
    , knittingProcess = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    , dyeingMedium = Nothing
    , printing = Nothing
    , ennoblingHeatSource = Nothing
    }


manteauCircuitEurope : Query
manteauCircuitEurope =
    -- Manteau circuit Europe
    { mass = Mass.kilograms 0.95
    , materials = [ { id = Material.Id "cachemire", share = Split.full } ]
    , product = Product.Id "manteau"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "TR"
    , countryDyeing = Country.Code "TN"
    , countryMaking = Country.Code "ES"
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , makingComplexity = Nothing
    , yarnSize = Nothing
    , surfaceMass = Nothing
    , knittingProcess = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    , dyeingMedium = Nothing
    , printing = Nothing
    , ennoblingHeatSource = Nothing
    }


pantalonCircuitEurope : Query
pantalonCircuitEurope =
    -- Pantalon circuit Europe
    { mass = Mass.kilograms 0.45
    , materials = [ { id = Material.Id "lin-filasse", share = Split.full } ]
    , product = Product.Id "pantalon"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "TR"
    , countryDyeing = Country.Code "TR"
    , countryMaking = Country.Code "TR"
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , makingComplexity = Nothing
    , yarnSize = Nothing
    , surfaceMass = Nothing
    , knittingProcess = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    , dyeingMedium = Nothing
    , printing = Nothing
    , ennoblingHeatSource = Nothing
    }


presets : List Query
presets =
    [ tShirtCotonFrance
    , tShirtCotonEurope
    , tShirtCotonAsie
    , jupeCircuitAsie
    , manteauCircuitEurope
    , pantalonCircuitEurope
    ]


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "materials", Encode.list encodeMaterialInput inputs.materials )
        , ( "product", Product.encode inputs.product )
        , ( "countryFabric", Country.encode inputs.countryFabric )
        , ( "countryDyeing", Country.encode inputs.countryDyeing )
        , ( "countryMaking", Country.encode inputs.countryMaking )
        , ( "airTransportRatio", inputs.airTransportRatio |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "quality", inputs.quality |> Maybe.map Unit.encodeQuality |> Maybe.withDefault Encode.null )
        , ( "reparability", inputs.reparability |> Maybe.map Unit.encodeReparability |> Maybe.withDefault Encode.null )
        , ( "makingWaste", inputs.makingWaste |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "makingComplexity", inputs.makingComplexity |> Maybe.map (MakingComplexity.toString >> Encode.string) |> Maybe.withDefault Encode.null )
        , ( "yarnSize", inputs.yarnSize |> Maybe.map Unit.encodeYarnSize |> Maybe.withDefault Encode.null )
        , ( "surfaceMass", inputs.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        , ( "knittingProcess", inputs.knittingProcess |> Maybe.map Knitting.encode |> Maybe.withDefault Encode.null )
        , ( "disabledSteps", Encode.list Label.encode inputs.disabledSteps )
        , ( "disabledFading", inputs.disabledFading |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        , ( "dyeingMedium", inputs.dyeingMedium |> Maybe.map DyeingMedium.encode |> Maybe.withDefault Encode.null )
        , ( "printing", inputs.printing |> Maybe.map Printing.encode |> Maybe.withDefault Encode.null )
        , ( "ennoblingHeatSource", inputs.ennoblingHeatSource |> Maybe.map HeatSource.encode |> Maybe.withDefault Encode.null )
        ]


encodeMaterialInput : MaterialInput -> Encode.Value
encodeMaterialInput v =
    Encode.object
        [ ( "material", Material.encode v.material )
        , ( "share", Split.encodeFloat v.share )
        ]


decodeQuery : Decoder Query
decodeQuery =
    Decode.succeed Query
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "materials" (Decode.list decodeMaterialQuery)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.optional "countrySpinning" (Decode.maybe Country.decodeCode) Nothing
        |> Pipe.required "countryFabric" Country.decodeCode
        |> Pipe.required "countryDyeing" Country.decodeCode
        |> Pipe.required "countryMaking" Country.decodeCode
        |> Pipe.optional "airTransportRatio" (Decode.maybe Split.decodeFloat) Nothing
        |> Pipe.optional "quality" (Decode.maybe Unit.decodeQuality) Nothing
        |> Pipe.optional "reparability" (Decode.maybe Unit.decodeReparability) Nothing
        |> Pipe.optional "makingWaste" (Decode.maybe Split.decodeFloat) Nothing
        |> Pipe.optional "makingComplexity" (Decode.maybe MakingComplexity.decode) Nothing
        |> Pipe.optional "yarnSize" (Decode.maybe Unit.decodeYarnSize) Nothing
        |> Pipe.optional "surfaceMass" (Decode.maybe Unit.decodeSurfaceMass) Nothing
        |> Pipe.optional "knittingProcess" (Decode.maybe Knitting.decode) Nothing
        |> Pipe.optional "disabledSteps" (Decode.list Label.decodeFromCode) []
        |> Pipe.optional "disabledFading" (Decode.maybe Decode.bool) Nothing
        |> Pipe.optional "dyeingMedium" (Decode.maybe DyeingMedium.decode) Nothing
        |> Pipe.optional "printing" (Decode.maybe Printing.decode) Nothing
        |> Pipe.optional "ennoblingHeatSource" (Decode.maybe HeatSource.decode) Nothing


decodeMaterialQuery : Decoder MaterialQuery
decodeMaterialQuery =
    Decode.succeed MaterialQuery
        |> Pipe.required "id" (Decode.map Material.Id Decode.string)
        |> Pipe.required "share" Split.decodeFloat


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "materials", Encode.list encodeMaterialQuery query.materials )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countrySpinning", query.countrySpinning |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        , ( "countryFabric", query.countryFabric |> Country.encodeCode )
        , ( "countryDyeing", query.countryDyeing |> Country.encodeCode )
        , ( "countryMaking", query.countryMaking |> Country.encodeCode )
        , ( "airTransportRatio", query.airTransportRatio |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "quality", query.quality |> Maybe.map Unit.encodeQuality |> Maybe.withDefault Encode.null )
        , ( "reparability", query.reparability |> Maybe.map Unit.encodeReparability |> Maybe.withDefault Encode.null )
        , ( "makingWaste", query.makingWaste |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "makingComplexity", query.makingComplexity |> Maybe.map (MakingComplexity.toString >> Encode.string) |> Maybe.withDefault Encode.null )
        , ( "yarnSize", query.yarnSize |> Maybe.map Unit.encodeYarnSize |> Maybe.withDefault Encode.null )
        , ( "surfaceMass", query.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        , ( "knittingProcess", query.knittingProcess |> Maybe.map Knitting.encode |> Maybe.withDefault Encode.null )
        , ( "disabledSteps", Encode.list Label.encode query.disabledSteps )
        , ( "disabledFading", query.disabledFading |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        , ( "dyeingMedium", query.dyeingMedium |> Maybe.map DyeingMedium.encode |> Maybe.withDefault Encode.null )
        , ( "printing", query.printing |> Maybe.map Printing.encode |> Maybe.withDefault Encode.null )
        , ( "ennoblingHeatSource", query.ennoblingHeatSource |> Maybe.map HeatSource.encode |> Maybe.withDefault Encode.null )
        ]


encodeMaterialQuery : MaterialQuery -> Encode.Value
encodeMaterialQuery v =
    Encode.object
        [ ( "id", Material.encodeId v.id )
        , ( "share", Split.encodeFloat v.share )
        ]


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decodeQuery
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encodeQuery >> Encode.encode 0 >> Base64.encode



-- Parser


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just
