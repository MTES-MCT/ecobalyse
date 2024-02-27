module Data.Textile.Inputs exposing
    ( Inputs
    , MaterialInput
    , computeMaterialTransport
    , countryList
    , encode
    , fromQuery
    , getMaterialMicrofibersComplement
    , getMaterialsOriginShares
    , getOutOfEuropeEOLComplement
    , getOutOfEuropeEOLProbability
    , getTotalMicrofibersComplement
    , isFaded
    , toQuery
    , toString
    )

import Data.Country as Country exposing (Country)
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
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
import Data.Transport as Transport exposing (Distances, Transport)
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Views.Format as Format


type alias MaterialInput =
    { material : Material
    , share : Split
    , spinning : Maybe Spinning
    , country : Maybe Country
    }


type alias Inputs =
    { mass : Mass
    , materials : List MaterialInput
    , product : Product

    -- TODO: countryMaterial isn't used anymore, but we still need it because `countryList` uses it,
    -- which in turn is used to build the lifecycle, which needs a country for each step.
    , countryMaterial : Country
    , countrySpinning : Country
    , countryFabric : Country
    , countryDyeing : Country
    , countryMaking : Country
    , countryDistribution : Country
    , countryUse : Country
    , countryEndOfLife : Country
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


isFaded : Inputs -> Bool
isFaded inputs =
    inputs.fading == Just True || (inputs.fading == Nothing && Product.isFadedByDefault inputs.product)


fromMaterialQuery : List Material -> List Country -> List MaterialQuery -> Result String (List MaterialInput)
fromMaterialQuery materials countries =
    List.map
        (\{ id, share, spinning, country } ->
            let
                countryResult =
                    case country of
                        Just countryCode ->
                            Country.findByCode countryCode countries
                                |> Result.map Just

                        Nothing ->
                            Ok Nothing
            in
            Result.map2
                (\material_ country_ ->
                    { material = material_
                    , share = share
                    , spinning = spinning
                    , country = country_
                    }
                )
                (Material.findById id materials)
                countryResult
        )
        >> RE.combine


toMaterialQuery : List MaterialInput -> List MaterialQuery
toMaterialQuery =
    List.map
        (\{ material, share, spinning, country } ->
            { id = material.id
            , share = share
            , spinning = spinning
            , country = country |> Maybe.map .code
            }
        )


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


fromQuery : List Country -> List Material -> List Product -> Query -> Result String Inputs
fromQuery countries materials products query =
    let
        materials_ =
            query.materials
                |> fromMaterialQuery materials countries

        franceResult =
            Country.findByCode (Country.Code "FR") countries

        -- TODO: we don't use the main material country anymore as each material can specify
        -- its own country. We still need a country per step though, so we'll just default
        -- to using France.
        mainMaterialCountry =
            materials_
                |> Result.andThen (getMainMaterialCountry countries)
                |> RE.orElse franceResult
    in
    Ok Inputs
        |> RE.andMap (Ok query.mass)
        |> RE.andMap materials_
        |> RE.andMap (products |> Product.findById query.product)
        -- Material country is constrained to be the first material's default country
        |> RE.andMap mainMaterialCountry
        -- Spinning country is either provided by query or fallbacks to material's default
        -- country, making the parameter optional
        |> RE.andMap
            (case query.countrySpinning of
                Just spinningCountryCode ->
                    Country.findByCode spinningCountryCode countries

                Nothing ->
                    mainMaterialCountry
            )
        |> RE.andMap (countries |> Country.findByCode query.countryFabric)
        |> RE.andMap (countries |> Country.findByCode query.countryDyeing)
        |> RE.andMap (countries |> Country.findByCode query.countryMaking)
        -- The distribution country is always France
        |> RE.andMap franceResult
        -- The use country is always France
        |> RE.andMap franceResult
        -- The end of life country is always France
        |> RE.andMap franceResult
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.makingWaste)
        |> RE.andMap (Ok query.makingDeadStock)
        |> RE.andMap (Ok query.makingComplexity)
        |> RE.andMap (Ok query.yarnSize)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap (Ok query.fabricProcess)
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.fading)
        |> RE.andMap (Ok query.dyeingMedium)
        |> RE.andMap (Ok query.printing)
        |> RE.andMap (Ok query.business)
        |> RE.andMap (Ok query.marketingDuration)
        |> RE.andMap (Ok query.numberOfReferences)
        |> RE.andMap (Ok query.price)
        |> RE.andMap (Ok query.traceability)


toQuery : Inputs -> Query
toQuery inputs =
    { mass = inputs.mass
    , materials = toMaterialQuery inputs.materials
    , product = inputs.product.id
    , countrySpinning = Just inputs.countrySpinning.code
    , countryFabric = inputs.countryFabric.code
    , countryDyeing = inputs.countryDyeing.code
    , countryMaking = inputs.countryMaking.code
    , airTransportRatio = inputs.airTransportRatio
    , makingWaste = inputs.makingWaste
    , makingDeadStock = inputs.makingDeadStock
    , makingComplexity = inputs.makingComplexity
    , yarnSize = inputs.yarnSize
    , surfaceMass = inputs.surfaceMass
    , fabricProcess = inputs.fabricProcess
    , disabledSteps = inputs.disabledSteps
    , fading = inputs.fading
    , dyeingMedium = inputs.dyeingMedium
    , printing = inputs.printing
    , business = inputs.business
    , marketingDuration = inputs.marketingDuration
    , numberOfReferences = inputs.numberOfReferences
    , price = inputs.price
    , traceability = inputs.traceability
    }


stepsToStrings : Inputs -> List (List String)
stepsToStrings inputs =
    let
        ifStepEnabled label list =
            if not (List.member label inputs.disabledSteps) then
                list

            else
                []
    in
    [ [ inputs.product.name, Format.kgToString inputs.mass ]
    , ifStepEnabled Label.Material
        [ "matière"
        , materialsToString inputs.materials
        ]
    , ifStepEnabled Label.Spinning
        [ "filature"
        , inputs.countrySpinning.name
        ]
    , case inputs.yarnSize of
        Just yarnSize ->
            [ "titrage", String.fromInt (Unit.yarnSizeInKilometers yarnSize) ++ "Nm" ]

        Nothing ->
            []
    , ifStepEnabled Label.Fabric
        [ Fabric.toLabel inputs.fabricProcess
        , inputs.countryFabric.name
        ]
    , ifStepEnabled Label.Ennobling
        [ case inputs.dyeingMedium of
            Just dyeingMedium ->
                "ennoblissement\u{00A0}: teinture sur " ++ DyeingMedium.toLabel dyeingMedium

            Nothing ->
                "ennoblissement"
        , inputs.countryDyeing.name
        ]
    , ifStepEnabled Label.Ennobling
        [ "impression"
        , case inputs.printing of
            Just printing ->
                "impression " ++ Printing.toFullLabel printing ++ "\u{00A0}: " ++ inputs.countryDyeing.name

            Nothing ->
                "non"
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
        , inputs.countryUse.name
        ]
    , ifStepEnabled Label.EndOfLife
        [ "fin de vie"
        , inputs.countryEndOfLife.name
        ]
    ]
        |> List.filter (not << List.isEmpty)


toString : Inputs -> String
toString inputs =
    inputs
        |> stepsToStrings
        |> List.map (String.join "\u{00A0}: ")
        |> String.join ", "


materialsToString : List MaterialInput -> String
materialsToString materials =
    materials
        |> List.filter (\{ share } -> Split.toFloat share > 0)
        |> List.map
            (\{ material, share, country } ->
                let
                    countryName =
                        country
                            |> Maybe.map .name
                            |> Maybe.withDefault (" par défaut (" ++ material.geographicOrigin ++ ")")
                in
                Split.toPercentString share
                    ++ "% "
                    ++ material.shortName
                    ++ " provenance "
                    ++ countryName
            )
        |> String.join ", "


makingOptionsToString : Inputs -> String
makingOptionsToString { makingWaste, makingDeadStock, makingComplexity, airTransportRatio, fading } =
    [ makingWaste
        |> Maybe.map (Split.toPercentString >> (\s -> s ++ "\u{202F}% de perte"))
    , makingDeadStock
        |> Maybe.map (Split.toPercentString >> (\s -> s ++ "\u{202F}% de stocks dormants"))
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


getMaterialsOriginShares : List MaterialInput -> Origin.Shares
getMaterialsOriginShares materialInputs =
    { artificialFromInorganic = materialInputs |> getMaterialCategoryShare Origin.ArtificialFromInorganic
    , artificialFromOrganic = materialInputs |> getMaterialCategoryShare Origin.ArtificialFromOrganic
    , naturalFromAnimal = materialInputs |> getMaterialCategoryShare Origin.NaturalFromAnimal
    , naturalFromVegetal = materialInputs |> getMaterialCategoryShare Origin.NaturalFromVegetal
    , synthetic = materialInputs |> getMaterialCategoryShare Origin.Synthetic
    }


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
        (if Split.toPercent syntheticMaterialsShare >= 10 then
            0.11

         else
            0.06
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


computeMaterialTransport : Distances -> Country.Code -> MaterialInput -> Transport
computeMaterialTransport distances nextCountryCode { material, country, share } =
    if share /= Split.zero then
        let
            emptyImpacts =
                Impact.empty

            countryCode =
                country
                    |> Maybe.map .code
                    |> Maybe.withDefault material.defaultCountry
        in
        distances
            |> Transport.getTransportBetween
                Scope.Textile
                emptyImpacts
                countryCode
                nextCountryCode

    else
        Transport.default Impact.empty


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
        , ( "makingWaste", inputs.makingWaste |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "makingDeadStock", inputs.makingDeadStock |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "makingComplexity", inputs.makingComplexity |> Maybe.map (MakingComplexity.toString >> Encode.string) |> Maybe.withDefault Encode.null )
        , ( "yarnSize", inputs.yarnSize |> Maybe.map Unit.encodeYarnSize |> Maybe.withDefault Encode.null )
        , ( "surfaceMass", inputs.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        , ( "fabricProcess", inputs.fabricProcess |> Fabric.encode )
        , ( "disabledSteps", Encode.list Label.encode inputs.disabledSteps )
        , ( "fading", inputs.fading |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        , ( "dyeingMedium", inputs.dyeingMedium |> Maybe.map DyeingMedium.encode |> Maybe.withDefault Encode.null )
        , ( "printing", inputs.printing |> Maybe.map Printing.encode |> Maybe.withDefault Encode.null )
        , ( "business", inputs.business |> Maybe.map Economics.encodeBusiness |> Maybe.withDefault Encode.null )
        , ( "marketingDuration", inputs.marketingDuration |> Maybe.map (Duration.inDays >> Encode.float) |> Maybe.withDefault Encode.null )
        , ( "numberOfReferences", inputs.numberOfReferences |> Maybe.map Encode.int |> Maybe.withDefault Encode.null )
        , ( "price", inputs.price |> Maybe.map Economics.encodePrice |> Maybe.withDefault Encode.null )
        , ( "traceability", inputs.traceability |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        ]


encodeMaterialInput : MaterialInput -> Encode.Value
encodeMaterialInput v =
    [ ( "material", Material.encode v.material |> Just )
    , ( "share", Split.encodeFloat v.share |> Just )
    , ( "spinning", v.spinning |> Maybe.map Spinning.encode )
    , ( "country", v.country |> Maybe.map (.code >> Country.encodeCode) )
    ]
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object
