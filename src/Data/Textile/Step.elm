module Data.Textile.Step exposing
    ( Step
    , airTransportDisabled
    , airTransportRatioToString
    , computeMaterialTransportAndImpact
    , computeTransports
    , create
    , encode
    , getInputSurface
    , getOutputSurface
    , getTotalImpactsWithoutComplements
    , getTransportedMass
    , initMass
    , makingDeadStockToString
    , makingWasteToString
    , surfaceMassToString
    , updateDeadStock
    , updateFromInputs
    , updateWasteAndMasses
    , yarnSizeToString
    )

import Area exposing (Area)
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Textile.Db as Textile
import Data.Textile.DyeingMedium exposing (DyeingMedium)
import Data.Textile.Fabric as Fabric
import Data.Textile.Formula as Formula
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.MakingComplexity exposing (MakingComplexity)
import Data.Textile.Printing exposing (Printing)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Static.Db exposing (Db)
import Views.Format as Format


type alias Step =
    { label : Label
    , enabled : Bool
    , country : Country
    , editable : Bool
    , inputMass : Mass
    , outputMass : Mass
    , waste : Mass
    , deadstock : Mass
    , transport : Transport
    , impacts : Impacts
    , complementsImpacts : Impact.ComplementsImpacts
    , heat : Energy
    , kwh : Energy
    , processInfo : ProcessInfo
    , airTransportRatio : Split -- FIXME: why not Maybe?
    , durability : Unit.NonPhysicalDurability
    , makingComplexity : Maybe MakingComplexity
    , makingWaste : Maybe Split
    , makingDeadStock : Maybe Split
    , picking : Maybe Unit.PickPerMeter
    , threadDensity : Maybe Unit.ThreadDensity
    , yarnSize : Maybe Unit.YarnSize
    , surfaceMass : Maybe Unit.SurfaceMass
    , dyeingMedium : Maybe DyeingMedium
    , printing : Maybe Printing
    }


type alias ProcessInfo =
    { countryElec : Maybe String
    , countryHeat : Maybe String
    , airTransportRatio : Maybe String
    , airTransport : Maybe String
    , seaTransport : Maybe String
    , roadTransport : Maybe String
    , useIroning : Maybe String
    , useNonIroning : Maybe String
    , passengerCar : Maybe String
    , endOfLife : Maybe String
    , fabric : Maybe String
    , dyeing : Maybe String
    , making : Maybe String
    , distribution : Maybe String
    , fading : Maybe String
    , printing : Maybe String
    }


create : { label : Label, editable : Bool, country : Country, enabled : Bool } -> Step
create { label, editable, country, enabled } =
    let
        defaultImpacts =
            Impact.empty
    in
    { label = label
    , enabled = enabled
    , country = country
    , editable = editable
    , inputMass = Quantity.zero
    , outputMass = Quantity.zero
    , waste = Quantity.zero
    , deadstock = Quantity.zero
    , transport = Transport.default defaultImpacts
    , impacts = defaultImpacts
    , complementsImpacts = Impact.noComplementsImpacts
    , heat = Quantity.zero
    , kwh = Quantity.zero
    , processInfo = defaultProcessInfo
    , airTransportRatio = Split.zero -- Note: this depends on next step country, so we can't set an accurate default value initially
    , durability = Unit.standardDurability Unit.NonPhysicalDurability
    , makingComplexity = Nothing
    , makingWaste = Nothing
    , makingDeadStock = Nothing
    , picking = Nothing
    , threadDensity = Nothing
    , yarnSize = Nothing
    , surfaceMass = Nothing
    , dyeingMedium = Nothing
    , printing = Nothing
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { countryElec = Nothing
    , countryHeat = Nothing
    , airTransportRatio = Nothing
    , airTransport = Nothing
    , seaTransport = Nothing
    , roadTransport = Nothing
    , useIroning = Nothing
    , useNonIroning = Nothing
    , passengerCar = Nothing
    , endOfLife = Nothing
    , fabric = Nothing
    , dyeing = Nothing
    , making = Nothing
    , distribution = Nothing
    , fading = Nothing
    , printing = Nothing
    }


computeMaterialTransportAndImpact : Db -> Country -> Mass -> Inputs.MaterialInput -> Transport
computeMaterialTransportAndImpact { distances, textile } country outputMass materialInput =
    let
        materialMass =
            materialInput.share
                |> Split.applyToQuantity outputMass
    in
    materialInput
        |> Inputs.computeMaterialTransport distances country.code
        |> Formula.transportRatio Split.zero
        |> computeTransportImpacts Impact.empty textile.wellKnown textile.wellKnown.roadTransport materialMass


{-| Computes step transport distances and impact regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/ecobalyse/methodologie/transport>

-}
computeTransports : Db -> Inputs -> Step -> Step -> Step
computeTransports db inputs next ({ processInfo } as current) =
    let
        transport =
            if current.label == Label.Material then
                inputs.materials
                    |> List.map (computeMaterialTransportAndImpact db next.country current.outputMass)
                    |> Transport.sum

            else
                db.distances
                    |> Transport.getTransportBetween current.transport.impacts current.country.code next.country.code
                    |> computeTransportSummary current
                    |> computeTransportImpacts current.transport.impacts
                        db.textile.wellKnown
                        db.textile.wellKnown.roadTransport
                        (getTransportedMass inputs current)
    in
    { current
        | processInfo =
            { processInfo
                | roadTransport = Just db.textile.wellKnown.roadTransport.name
                , seaTransport = Just db.textile.wellKnown.seaTransport.name
                , airTransport = Just db.textile.wellKnown.airTransport.name
            }
        , transport = transport
    }


computeTransportImpacts : Impacts -> WellKnown -> Process -> Mass -> Transport -> Transport
computeTransportImpacts impacts { seaTransport, airTransport } roadProcess mass { road, sea, air } =
    { road = road
    , roadCooled = Quantity.zero
    , sea = sea
    , seaCooled = Quantity.zero
    , air = air
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    let
                        ( roadImpact, seaImpact, airImpact ) =
                            ( mass |> Unit.forKgAndDistance (Process.getImpact trigram roadProcess) road
                            , mass |> Unit.forKgAndDistance (Process.getImpact trigram seaTransport) sea
                            , mass |> Unit.forKgAndDistance (Process.getImpact trigram airTransport) air
                            )
                    in
                    Quantity.sum [ roadImpact, seaImpact, airImpact ]
                )
    }


computeTransportSummary : Step -> Transport -> Transport
computeTransportSummary step transport =
    let
        ( noTransports, defaultInland ) =
            ( Transport.default step.transport.impacts
            , Transport.default step.transport.impacts
            )
    in
    case step.label of
        Label.Making ->
            -- Air transport only applies between the Making and the Distribution steps
            transport
                |> Formula.transportRatio step.airTransportRatio
                -- Added intermediary inland transport distances to materialize
                -- transport to the "distribution" step
                -- Also ensure we don't add unnecessary air transport
                |> Transport.add { defaultInland | air = Quantity.zero }

        Label.Distribution ->
            -- Product Distribution leverages no transports
            noTransports

        Label.Use ->
            -- Product Use leverages no transports
            noTransports

        Label.EndOfLife ->
            -- End of life leverages no transports
            noTransports

        _ ->
            -- All other steps don't use air transport, force a 0 split
            transport
                |> Formula.transportRatio Split.zero


getInputSurface : Inputs -> Step -> Area
getInputSurface { product, surfaceMass } { inputMass } =
    let
        surfaceMassWithDefault =
            Maybe.withDefault product.surfaceMass surfaceMass
    in
    Unit.surfaceMassToSurface surfaceMassWithDefault inputMass


getOutputSurface : Inputs -> Step -> Area
getOutputSurface { product, surfaceMass } { outputMass } =
    Unit.surfaceMassToSurface (Maybe.withDefault product.surfaceMass surfaceMass) outputMass


getTransportedMass : Inputs -> Step -> Mass
getTransportedMass inputs { label, outputMass } =
    -- Transports from the Making step shouldn't include waste, only the final product.
    if label == Label.Making then
        inputs.mass

    else
        outputMass


updateFromInputs : Textile.Db -> Inputs -> Step -> Step
updateFromInputs { wellKnown } inputs ({ label, country, complementsImpacts } as step) =
    let
        { airTransportRatio, makingComplexity, makingWaste, makingDeadStock, yarnSize, surfaceMass, dyeingMedium, printing } =
            inputs
    in
    case label of
        Label.Material ->
            { step
                | complementsImpacts =
                    { complementsImpacts
                      -- Note: no other steps than the Material one generate microfibers pollution
                        | microfibers = Inputs.getTotalMicrofibersComplement inputs
                    }
            }

        Label.Spinning ->
            { step
                | yarnSize = yarnSize
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                    }
            }

        Label.Fabric ->
            { step
                | yarnSize = yarnSize
                , surfaceMass = surfaceMass
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , fabric =
                            inputs.product.fabric
                                |> Fabric.getProcess wellKnown
                                |> .name
                                |> Just
                    }
            }

        Label.Ennobling ->
            { step
                | dyeingMedium = dyeingMedium
                , printing = printing
                , processInfo =
                    { defaultProcessInfo
                        | countryHeat = Just country.heatProcess.name
                        , countryElec = Just country.electricityProcess.name
                        , dyeing =
                            wellKnown
                                |> WellKnown.getDyeingProcess
                                    (dyeingMedium
                                        |> Maybe.withDefault inputs.product.dyeing.defaultMedium
                                    )
                                |> .name
                                |> Just
                        , printing =
                            printing
                                |> Maybe.map
                                    (\{ kind } ->
                                        WellKnown.getPrintingProcess kind wellKnown |> .printingProcess |> .name
                                    )
                    }
            }

        Label.Making ->
            { step
                | airTransportRatio =
                    airTransportRatio |> Maybe.withDefault country.airTransportRatio
                , makingWaste = makingWaste
                , makingDeadStock = makingDeadStock
                , makingComplexity = makingComplexity
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , fading = Just wellKnown.fading.name
                        , airTransportRatio =
                            country.airTransportRatio
                                |> airTransportRatioToString
                                |> Just
                    }
            }

        Label.Distribution ->
            { step
                | processInfo =
                    { defaultProcessInfo | distribution = Just wellKnown.distribution.name }
            }

        Label.Use ->
            { step
                | processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , useIroning =
                            -- Note: Much better expressing electricity consumption in kWh than in MJ
                            inputs.product.use.ironingElec
                                |> Energy.inKilowattHours
                                |> Format.formatFloat 4
                                |> (\x -> "Repassage\u{00A0}: " ++ x ++ "\u{00A0}kWh")
                                |> Just
                        , useNonIroning = Just inputs.product.use.nonIroningProcess.name
                    }
            }

        Label.EndOfLife ->
            { step
                | complementsImpacts =
                    { complementsImpacts
                        | outOfEuropeEOL = Inputs.getOutOfEuropeEOLComplement inputs
                    }
                , processInfo =
                    { defaultProcessInfo
                        | passengerCar = Just "Transport en voiture vers point de collecte (1km)"
                        , countryElec = Just country.electricityProcess.name
                        , countryHeat = Just country.heatProcess.name
                        , endOfLife = Just wellKnown.endOfLife.name
                    }
            }


initMass : Mass -> Step -> Step
initMass mass step =
    { step
        | inputMass = mass
        , outputMass = mass
    }


updateWasteAndMasses : Mass -> Mass -> Step -> Step
updateWasteAndMasses waste mass step =
    { step
        | waste = waste
        , inputMass = mass
        , outputMass = Quantity.difference mass waste
    }


updateDeadStock : Mass -> Mass -> Step -> Step
updateDeadStock deadstock mass step =
    { step
        | deadstock = deadstock
        , inputMass = mass
        , outputMass = Quantity.difference mass deadstock
    }


airTransportDisabled : Step -> Bool
airTransportDisabled { enabled, label, country } =
    not enabled
        || -- Note: disallow air transport from France to France at the Making step
           (label == Label.Making && country.code == Country.codeFromString "FR")


airTransportRatioToString : Split -> String
airTransportRatioToString percentage =
    case Split.toPercent percentage |> round of
        0 ->
            "Aucun transport aérien"

        _ ->
            Split.toPercentString 0 percentage ++ "% de transport aérien"


surfaceMassToString : Unit.SurfaceMass -> String
surfaceMassToString surfaceMass =
    "Grammage\u{00A0}: " ++ String.fromInt (Unit.surfaceMassInGramsPerSquareMeters surfaceMass) ++ "\u{202F}g/m²"


makingWasteToString : Split -> String
makingWasteToString makingWaste =
    if makingWaste == Split.zero then
        "Aucune perte en confection"

    else
        Split.toPercentString 0 makingWaste ++ "% de pertes"


makingDeadStockToString : Split -> String
makingDeadStockToString makingDeadStock =
    if makingDeadStock == Split.zero then
        "Aucun stock dormant"

    else
        Split.toPercentString 0 makingDeadStock ++ "% de stocks dormants"


yarnSizeToString : Unit.YarnSize -> String
yarnSizeToString yarnSize =
    "Titrage\u{00A0}: " ++ String.fromFloat (Unit.yarnSizeInKilometers yarnSize) ++ "\u{202F}Nm (" ++ yarnSizeToDtexString yarnSize ++ ")"


yarnSizeToDtexString : Unit.YarnSize -> String
yarnSizeToDtexString yarnSize =
    Format.formatFloat 2 (Unit.yarnSizeInGrams yarnSize) ++ "\u{202F}Dtex"


encode : Step -> Encode.Value
encode v =
    Encode.object
        [ ( "label", Encode.string (Label.toString v.label) )
        , ( "enabled", Encode.bool v.enabled )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "inputMass", Encode.float (Mass.inKilograms v.inputMass) )
        , ( "outputMass", Encode.float (Mass.inKilograms v.outputMass) )
        , ( "waste", Encode.float (Mass.inKilograms v.waste) )
        , ( "deadstock", Encode.float (Mass.inKilograms v.deadstock) )
        , ( "transport", Transport.encode v.transport )
        , ( "impacts"
          , v.impacts
                |> Impact.applyComplements (Impact.getTotalComplementsImpacts v.complementsImpacts)
                |> Impact.encode
          )
        , ( "complementsImpacts", Impact.encodeComplementsImpacts v.complementsImpacts )
        , ( "heat_MJ", Encode.float (Energy.inMegajoules v.heat) )
        , ( "elec_kWh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "airTransportRatio", Split.encodeFloat v.airTransportRatio )
        , ( "durability", Unit.encodeNonPhysicalDurability v.durability )
        , ( "makingWaste", v.makingWaste |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "makingDeadStock", v.makingDeadStock |> Maybe.map Split.encodeFloat |> Maybe.withDefault Encode.null )
        , ( "picking", v.picking |> Maybe.map Unit.encodePickPerMeter |> Maybe.withDefault Encode.null )
        , ( "threadDensity", v.threadDensity |> Maybe.map Unit.encodeThreadDensity |> Maybe.withDefault Encode.null )
        , ( "yarnSize", v.yarnSize |> Maybe.map Unit.encodeYarnSize |> Maybe.withDefault Encode.null )
        , ( "surfaceMass", v.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        ]


encodeProcessInfo : ProcessInfo -> Encode.Value
encodeProcessInfo v =
    let
        encodeMaybeString =
            Maybe.map Encode.string >> Maybe.withDefault Encode.null
    in
    Encode.object
        [ ( "countryElec", encodeMaybeString v.countryElec )
        , ( "countryHeat", encodeMaybeString v.countryHeat )
        , ( "airTransportRatio", encodeMaybeString v.airTransportRatio )
        , ( "airTransport", encodeMaybeString v.airTransport )
        , ( "seaTransport", encodeMaybeString v.seaTransport )
        , ( "roadTransport", encodeMaybeString v.roadTransport )
        , ( "useIroning", encodeMaybeString v.useIroning )
        , ( "useNonIroning", encodeMaybeString v.useNonIroning )
        , ( "passengerCar", encodeMaybeString v.passengerCar )
        , ( "endOfLife", encodeMaybeString v.endOfLife )
        , ( "fabric", encodeMaybeString v.fabric )
        , ( "making", encodeMaybeString v.making )
        , ( "distribution", encodeMaybeString v.distribution )
        , ( "fading", encodeMaybeString v.fading )
        ]


getTotalImpactsWithoutComplements : Step -> Impacts
getTotalImpactsWithoutComplements { impacts, transport } =
    Impact.sumImpacts [ impacts, transport.impacts ]
