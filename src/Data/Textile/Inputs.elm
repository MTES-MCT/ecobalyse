module Data.Textile.Inputs exposing
    ( Inputs
    , MaterialInput
    , computeMaterialTransport
    , geoZoneList
    , encode
    , fromQuery
    , getMaterialMicrofibersComplement
    , getOutOfEuropeEOLComplement
    , getOutOfEuropeEOLProbability
    , getTotalMicrofibersComplement
    , isFabricOfType
    , toQuery
    , toString
    )

import Data.Common.EncodeUtils as EU
import Data.Component as Component exposing (Item)
import Data.GeoZone as GeoZone exposing (GeoZone)
import Data.Impact as Impact
import Data.Process as Process
import Data.Split as Split exposing (Split)
import Data.Textile.Dyeing as Dyeing exposing (ProcessType)
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query exposing (MaterialQuery, Query)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Textile.WellKnown exposing (WellKnown)
import Data.Transport as Transport exposing (Distances, Transport)
import Data.Unit as Unit
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Static.Db exposing (Db)
import Views.Format as Format


type alias MaterialInput =
    { geoZone : Maybe GeoZone
    , material : Material
    , share : Split
    , spinning : Maybe Spinning
    }


type alias Inputs =
    { airTransportRatio : Maybe Split
    , business : Maybe Economics.Business
    , disabledSteps : List Label
    , dyeingProcessType : Maybe ProcessType
    , fabricProcess : Maybe Fabric
    , fading : Maybe Bool
    , geoZoneDistribution : GeoZone
    , geoZoneDyeing : GeoZone
    , geoZoneEndOfLife : GeoZone
    , geoZoneFabric : GeoZone
    , geoZoneMaking : GeoZone

    -- TODO: geoZoneMaterial isn't used anymore, but we still need it because `geoZoneList` uses it,
    -- which in turn is used to build the lifecycle, which needs a geographical zone for each step.
    , geoZoneMaterial : GeoZone
    , geoZoneSpinning : GeoZone
    , geoZoneUse : GeoZone
    , makingComplexity : Maybe MakingComplexity
    , makingDeadStock : Maybe Split
    , makingWaste : Maybe Split
    , mass : Mass
    , materials : List MaterialInput
    , numberOfReferences : Maybe Int
    , physicalDurability : Maybe Unit.PhysicalDurability
    , price : Maybe Economics.Price
    , printing : Maybe Printing
    , product : Product
    , surfaceMass : Maybe Unit.SurfaceMass
    , trims : List Item
    , upcycled : Bool
    , yarnSize : Maybe Unit.YarnSize
    }


fromMaterialQuery : List Material -> List GeoZone -> List MaterialQuery -> Result String (List MaterialInput)
fromMaterialQuery materials geoZones =
    List.map
        (\{ geoZone, id, share, spinning } ->
            let
                geoZoneResult =
                    case geoZone of
                        Just geoZoneCode ->
                            GeoZone.findByCode geoZoneCode geoZones
                                |> Result.map Just

                        Nothing ->
                            Ok Nothing
            in
            Result.map2
                (\material_ geoZone_ ->
                    { geoZone = geoZone_
                    , material = material_
                    , share = share
                    , spinning = spinning
                    }
                )
                (Material.findById id materials)
                geoZoneResult
        )
        >> RE.combine


toMaterialQuery : List MaterialInput -> List MaterialQuery
toMaterialQuery =
    List.map
        (\{ geoZone, material, share, spinning } ->
            { geoZone = geoZone |> Maybe.andThen (.code >> toQueryGeoZoneCode)
            , id = material.id
            , share = share
            , spinning = spinning
            }
        )


getMainMaterial : List MaterialInput -> Result String Material
getMainMaterial =
    List.sortBy (.share >> Split.toFloat)
        >> List.reverse
        >> List.head
        >> Maybe.map .material
        >> Result.fromMaybe "La liste de matières est vide."


getMainMaterialGeoZone : List GeoZone -> List MaterialInput -> Result String GeoZone
getMainMaterialGeoZone geoZones =
    getMainMaterial
        >> Result.andThen
            (\{ defaultGeoZone } ->
                GeoZone.findByCode defaultGeoZone geoZones
            )


fromQuery : Db -> Query -> Result String Inputs
fromQuery { geoZones, textile } query =
    let
        materials_ =
            query.materials
                |> fromMaterialQuery textile.materials geoZones

        franceResult =
            GeoZone.findByCode (GeoZone.Code "FR") geoZones

        unknownGeoZoneResult =
            GeoZone.findByCode GeoZone.unknownGeoZoneCode geoZones

        mainMaterialGeoZone =
            materials_
                |> Result.andThen (getMainMaterialGeoZone geoZones)
                |> RE.orElse unknownGeoZoneResult

        getGeoZoneResult fallbackResult maybeCode =
            case maybeCode of
                Just code ->
                    GeoZone.findByCode code geoZones

                Nothing ->
                    fallbackResult

        trims =
            case query.trims of
                Just customTrims ->
                    Ok customTrims

                Nothing ->
                    textile.products
                        |> Product.findById query.product
                        |> Result.map .trims
    in
    Ok Inputs
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.business)
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.dyeingProcessType)
        |> RE.andMap (Ok query.fabricProcess)
        |> RE.andMap (Ok query.fading)
        -- The distribution geographical zone is always France
        |> RE.andMap franceResult
        |> RE.andMap (getGeoZoneResult unknownGeoZoneResult query.geoZoneDyeing)
        -- The end of life geographical zone is always France
        |> RE.andMap franceResult
        |> RE.andMap (getGeoZoneResult unknownGeoZoneResult query.geoZoneFabric)
        |> RE.andMap (getGeoZoneResult unknownGeoZoneResult query.geoZoneMaking)
        -- The material geographical zone is constrained to be the first material's default geographical zone
        |> RE.andMap mainMaterialGeoZone
        |> RE.andMap (getGeoZoneResult unknownGeoZoneResult query.geoZoneSpinning)
        -- The use geographical zone is always France
        |> RE.andMap franceResult
        |> RE.andMap (Ok query.makingComplexity)
        |> RE.andMap (Ok query.makingDeadStock)
        |> RE.andMap (Ok query.makingWaste)
        |> RE.andMap (Ok query.mass)
        |> RE.andMap materials_
        |> RE.andMap (Ok query.numberOfReferences)
        |> RE.andMap (Ok query.physicalDurability)
        |> RE.andMap (Ok query.price)
        |> RE.andMap (Ok query.printing)
        |> RE.andMap (textile.products |> Product.findById query.product)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap trims
        |> RE.andMap (Ok query.upcycled)
        |> RE.andMap (Ok query.yarnSize)


toQuery : Inputs -> Query
toQuery inputs =
    { airTransportRatio = inputs.airTransportRatio
    , business = inputs.business
    , disabledSteps = inputs.disabledSteps
    , dyeingProcessType = inputs.dyeingProcessType
    , fabricProcess = inputs.fabricProcess
    , fading = inputs.fading
    , geoZoneDyeing = toQueryGeoZoneCode inputs.geoZoneDyeing.code
    , geoZoneFabric = toQueryGeoZoneCode inputs.geoZoneFabric.code
    , geoZoneMaking = toQueryGeoZoneCode inputs.geoZoneMaking.code
    , geoZoneSpinning = toQueryGeoZoneCode inputs.geoZoneSpinning.code
    , makingComplexity = inputs.makingComplexity
    , makingDeadStock = inputs.makingDeadStock
    , makingWaste = inputs.makingWaste
    , mass = inputs.mass
    , materials = toMaterialQuery inputs.materials
    , numberOfReferences = inputs.numberOfReferences
    , physicalDurability = inputs.physicalDurability
    , price = inputs.price
    , printing = inputs.printing
    , product = inputs.product.id
    , surfaceMass = inputs.surfaceMass
    , trims =
        if inputs.trims == inputs.product.trims then
            Nothing

        else
            Just inputs.trims
    , upcycled = inputs.upcycled
    , yarnSize = inputs.yarnSize
    }


toQueryGeoZoneCode : GeoZone.Code -> Maybe GeoZone.Code
toQueryGeoZoneCode c =
    if c == GeoZone.unknownGeoZoneCode then
        Nothing

    else
        Just c


stepsToStrings : WellKnown -> Inputs -> List (List String)
stepsToStrings wellKnown inputs =
    let
        ifStepEnabled label list =
            if not (List.member label inputs.disabledSteps) then
                list

            else
                []
    in
    [ [ inputs.product.name
            ++ (if inputs.upcycled then
                    " remanufacturé"

                else
                    ""
               )
            ++ (case inputs.physicalDurability of
                    Just physicalDurability ->
                        ", durabilité physique " ++ String.fromFloat (Unit.physicalDurabilityToFloat physicalDurability)

                    Nothing ->
                        ""
               )
      , Format.kgToString inputs.mass
      ]
    , ifStepEnabled Label.Material
        [ "matière"
        , materialsToString inputs.materials
        ]
    , ifStepEnabled Label.Spinning
        [ "filature"
        , inputs.geoZoneSpinning.name
        ]
    , case inputs.yarnSize of
        Just yarnSize ->
            [ "titrage", String.fromFloat (Unit.yarnSizeInKilometers yarnSize) ++ "Nm" ]

        Nothing ->
            []
    , ifStepEnabled Label.Fabric
        [ inputs.fabricProcess
            |> Maybe.withDefault inputs.product.fabric
            |> Fabric.toLabel
        , inputs.geoZoneFabric.name
        ]
    , ifStepEnabled Label.Ennobling
        [ "ennoblissement\u{00A0}: "
            ++ (inputs.dyeingProcessType
                    |> Dyeing.toProcess wellKnown
                    |> Process.getDisplayName
               )
        , inputs.geoZoneDyeing.name
        ]
    , ifStepEnabled Label.Ennobling
        [ "impression"
        , case inputs.printing of
            Just printing ->
                "impression " ++ Printing.toFullLabel printing ++ "\u{00A0}: " ++ inputs.geoZoneDyeing.name

            Nothing ->
                "non"
        ]
    , ifStepEnabled Label.Making
        [ "confection"
        , inputs.geoZoneMaking.name ++ makingOptionsToString inputs
        ]
    , ifStepEnabled Label.Distribution
        [ "distribution"
        , inputs.geoZoneDistribution.name
        ]
    , ifStepEnabled Label.Use
        [ "utilisation"
        , inputs.geoZoneUse.name
        ]
    , ifStepEnabled Label.EndOfLife
        [ "fin de vie"
        , inputs.geoZoneEndOfLife.name
        ]
    ]
        |> List.filter (not << List.isEmpty)


toString : WellKnown -> Inputs -> String
toString wellKnown inputs =
    inputs
        |> stepsToStrings wellKnown
        |> List.map (String.join "\u{00A0}: ")
        |> String.join ", "


materialsToString : List MaterialInput -> String
materialsToString materials =
    materials
        |> List.filter (\{ share } -> Split.toFloat share > 0)
        |> List.map
            (\{ geoZone, material, share } ->
                let
                    geoZoneName =
                        geoZone
                            |> Maybe.map .name
                            |> Maybe.withDefault (" par défaut (" ++ material.geographicOrigin ++ ")")
                in
                Split.toPercentString 0 share
                    ++ "% "
                    ++ material.name
                    ++ " provenance "
                    ++ geoZoneName
            )
        |> String.join ", "


makingOptionsToString : Inputs -> String
makingOptionsToString { airTransportRatio, fading, makingComplexity, makingDeadStock, makingWaste } =
    [ makingWaste
        |> Maybe.map (Split.toPercentString 0 >> (\s -> s ++ "\u{202F}% de perte"))
    , makingDeadStock
        |> Maybe.map (Split.toPercentString 0 >> (\s -> s ++ "\u{202F}% de stocks dormants"))
    , makingComplexity
        |> Maybe.map (\complexity -> "complexité de confection " ++ MakingComplexity.toLabel complexity)
    , airTransportRatio
        |> Maybe.andThen
            (\ratio ->
                if Split.toPercent ratio == 0 then
                    Nothing

                else
                    Just (Split.toPercentString 0 ratio ++ " de transport aérien")
            )
    , if fading == Just True then
        Just "délavé"

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


geoZoneList : Inputs -> List GeoZone
geoZoneList inputs =
    [ inputs.geoZoneMaterial
    , inputs.geoZoneSpinning
    , inputs.geoZoneFabric
    , inputs.geoZoneDyeing
    , inputs.geoZoneMaking
    , inputs.geoZoneDistribution
    , inputs.geoZoneUse
    , inputs.geoZoneEndOfLife
    ]


getMaterialMicrofibersComplement : Mass -> MaterialInput -> Unit.Impact
getMaterialMicrofibersComplement finalProductMass { material, share } =
    -- Note: Impact is computed against the final product mass, because microfibers
    --       are always released in the environment from finished products.
    let
        materialMassInKg =
            share
                |> Split.applyToQuantity finalProductMass
                |> Mass.inKilograms
    in
    Origin.toMicrofibersComplement material.origin
        |> Quantity.multiplyBy materialMassInKg


getTotalMicrofibersComplement : Inputs -> Unit.Impact
getTotalMicrofibersComplement { mass, materials } =
    materials
        |> List.map (getMaterialMicrofibersComplement mass)
        |> Quantity.sum


getMaterialCategoryShare : Origin -> List MaterialInput -> Split
getMaterialCategoryShare origin =
    List.filterMap
        (\{ material, share } ->
            if material.origin == origin then
                Just (Split.toPercent share)

            else
                Nothing
        )
        >> List.sum
        >> Split.fromPercent
        >> Result.withDefault Split.zero


getOutOfEuropeEOLProbability : List MaterialInput -> Split
getOutOfEuropeEOLProbability materialInputs =
    -- We consider that the garment enters the "synthetic materials" category as
    -- soon as synthetic materials represent more than 10% of its composition.
    let
        syntheticMaterialsShare =
            materialInputs
                |> getMaterialCategoryShare Origin.Synthetic
    in
    Split.fromFloat
        (if Split.toPercent syntheticMaterialsShare >= 50 then
            0.121

         else
            0.049
        )
        |> Result.withDefault Split.zero


getOutOfEuropeEOLComplement : Inputs -> Unit.Impact
getOutOfEuropeEOLComplement { mass, materials } =
    -- Note: this complement is a malus, hence the minus sign
    Unit.impact
        -(Split.toFloat (getOutOfEuropeEOLProbability materials)
            * Mass.inKilograms mass
            * 5000
         )


computeMaterialTransport : Distances -> GeoZone.Code -> MaterialInput -> Transport
computeMaterialTransport distances nextGeoZoneCode { geoZone, material, share } =
    if share /= Split.zero then
        let
            emptyImpacts =
                Impact.empty

            geoZoneCode =
                geoZone
                    |> Maybe.map .code
                    |> Maybe.withDefault material.defaultGeoZone
        in
        distances
            |> Transport.getTransportBetween emptyImpacts geoZoneCode nextGeoZoneCode

    else
        Transport.default Impact.empty


isFabricOfType : Fabric -> Inputs -> Bool
isFabricOfType fabric { fabricProcess, product } =
    fabric == Maybe.withDefault product.fabric fabricProcess


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "airTransportRatio", inputs.airTransportRatio |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "business", inputs.business |> Maybe.map Economics.encodeBusiness |> Maybe.withDefault Encode.null )
        , ( "geoZoneDyeing", GeoZone.encode inputs.geoZoneDyeing )
        , ( "geoZoneFabric", GeoZone.encode inputs.geoZoneFabric )
        , ( "geoZoneMaking", GeoZone.encode inputs.geoZoneMaking )
        , ( "disabledSteps", Encode.list Label.encode inputs.disabledSteps )
        , ( "dyeingProcessType", inputs.dyeingProcessType |> Maybe.map Dyeing.encode |> Maybe.withDefault Encode.null )
        , ( "fabricProcess", inputs.fabricProcess |> Maybe.map Fabric.encode |> Maybe.withDefault Encode.null )
        , ( "fading", inputs.fading |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        , ( "makingComplexity", inputs.makingComplexity |> Maybe.map (MakingComplexity.toString >> Encode.string) |> Maybe.withDefault Encode.null )
        , ( "makingDeadStock", inputs.makingDeadStock |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "makingWaste", inputs.makingWaste |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "materials", Encode.list encodeMaterialInput inputs.materials )
        , ( "numberOfReferences", inputs.numberOfReferences |> Maybe.map Encode.int |> Maybe.withDefault Encode.null )
        , ( "physicalDurability", inputs.physicalDurability |> Maybe.map Unit.encodePhysicalDurability |> Maybe.withDefault Encode.null )
        , ( "price", inputs.price |> Maybe.map Economics.encodePrice |> Maybe.withDefault Encode.null )
        , ( "printing", inputs.printing |> Maybe.map Printing.encode |> Maybe.withDefault Encode.null )
        , ( "product", Product.encode inputs.product )
        , ( "surfaceMass", inputs.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        , ( "trims", Encode.list Component.encodeItem inputs.trims )
        , ( "upcycled", Encode.bool inputs.upcycled )
        , ( "yarnSize", inputs.yarnSize |> Maybe.map Unit.encodeYarnSize |> Maybe.withDefault Encode.null )
        ]


encodeMaterialInput : MaterialInput -> Encode.Value
encodeMaterialInput v =
    EU.optionalPropertiesObject
        [ ( "geoZone", v.geoZone |> Maybe.map (.code >> GeoZone.encodeCode) )
        , ( "material", Material.encode v.material |> Just )
        , ( "share", Split.encodeFloat v.share |> Just )
        , ( "spinning", v.spinning |> Maybe.map Spinning.encode )
        ]
