module Data.Textile.Step exposing
    ( Step
    , airTransportRatioToString
    , computeTransports
    , create
    , displayLabel
    , encode
    , getInputSurface
    , getOutputSurface
    , initMass
    , makingWasteToString
    , pickingToString
    , qualityToString
    , reparabilityToString
    , surfaceMassToString
    , updateFromInputs
    , updateWaste
    )

import Area exposing (Area)
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium exposing (DyeingMedium)
import Data.Textile.Formula as Formula
import Data.Textile.Inputs exposing (Inputs)
import Data.Textile.Printing exposing (Printing)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity


type alias Step =
    { label : Label
    , enabled : Bool
    , country : Country
    , editable : Bool
    , inputMass : Mass
    , outputMass : Mass
    , waste : Mass
    , transport : Transport
    , impacts : Impacts
    , heat : Energy
    , kwh : Energy
    , processInfo : ProcessInfo
    , airTransportRatio : Unit.Ratio -- FIXME: why not Maybe?
    , quality : Unit.Quality
    , reparability : Unit.Reparability
    , makingWaste : Maybe Unit.Ratio
    , picking : Maybe Unit.PickPerMeter
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


create : { db : Db, label : Label, editable : Bool, country : Country, enabled : Bool } -> Step
create { db, label, editable, country, enabled } =
    let
        defaultImpacts =
            Impact.impactsFromDefinitons db.impacts
    in
    { label = label
    , enabled = enabled
    , country = country
    , editable = editable
    , inputMass = Quantity.zero
    , outputMass = Quantity.zero
    , waste = Quantity.zero
    , transport = Transport.default defaultImpacts
    , impacts = defaultImpacts
    , heat = Quantity.zero
    , kwh = Quantity.zero
    , processInfo = defaultProcessInfo
    , airTransportRatio = Unit.ratio 0 -- Note: this depends on next step country, so we can't set an accurate default value initially
    , quality = Unit.standardQuality
    , reparability = Unit.standardReparability
    , makingWaste = Nothing
    , picking = Nothing
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


displayLabel : { knitted : Bool, fadable : Bool } -> Label -> String
displayLabel { knitted, fadable } label =
    case ( label, knitted, fadable ) of
        ( Label.Making, _, True ) ->
            "Confection & Délavage"

        ( Label.Making, _, False ) ->
            "Confection"

        ( Label.Fabric, True, _ ) ->
            "Tricotage"

        ( Label.Fabric, False, _ ) ->
            "Tissage"

        _ ->
            Label.toString label


{-| Computes step transport distances and impact regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/ecobalyse/methodologie/transport>

-}
computeTransports : Db -> Step -> Step -> Result String Step
computeTransports db next ({ processInfo } as current) =
    db.processes
        |> Process.loadWellKnown
        |> Result.map
            (\wellKnown ->
                let
                    transport =
                        db.transports
                            |> Transport.getTransportBetween
                                current.transport.impacts
                                current.country.code
                                next.country.code

                    stepSummary =
                        computeTransportSummary current transport

                    roadTransportProcess =
                        getRoadTransportProcess wellKnown current
                in
                { current
                    | processInfo =
                        { processInfo
                            | roadTransport = Just roadTransportProcess.name
                            , seaTransport = Just wellKnown.seaTransport.name
                            , airTransport = Just wellKnown.airTransport.name
                        }
                    , transport =
                        stepSummary
                            |> computeTransportImpacts db
                                current.transport.impacts
                                wellKnown
                                roadTransportProcess
                                next.inputMass
                }
            )


computeTransportImpacts : Db -> Impacts -> Process.WellKnown -> Process -> Mass -> Transport -> Transport
computeTransportImpacts db impacts { seaTransport, airTransport } roadProcess mass { road, sea, air } =
    { road = road
    , sea = sea
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
            |> Impact.updatePefImpact db.impacts
    }


computeTransportSummary : Step -> Transport -> Transport
computeTransportSummary step transport =
    let
        ( noTransports, defaultInland ) =
            ( Transport.default step.transport.impacts
            , Transport.defaultInland step.transport.impacts
            )
    in
    case step.label of
        Label.Ennobling ->
            transport
                -- Note: no air transport ratio at the Dyeing step
                |> Formula.transportRatio (Unit.ratio 0)
                -- Added intermediary inland transport distances to materialize
                -- "processing" + "dyeing" steps (see Excel)
                -- Also ensure we don't add unnecessary air transport
                |> Transport.add { defaultInland | air = Quantity.zero }

        Label.Making ->
            -- Air transport only applies between the Making and the Distribution steps
            transport
                |> Formula.transportRatio step.airTransportRatio

        Label.Use ->
            -- Product Use leverages no transports
            noTransports

        Label.EndOfLife ->
            -- End of life leverages no transports
            noTransports

        _ ->
            -- All other steps don't use air transport, force a 0 ratio
            transport
                |> Formula.transportRatio (Unit.ratio 0)


getRoadTransportProcess : Process.WellKnown -> Step -> Process
getRoadTransportProcess wellKnown { label } =
    case label of
        Label.Making ->
            wellKnown.roadTransportPostMaking

        Label.Distribution ->
            wellKnown.distribution

        _ ->
            wellKnown.roadTransportPreMaking


getInputSurface : Inputs -> Step -> Area
getInputSurface { product, surfaceMass } { inputMass } =
    Mass.inGrams inputMass
        / Unit.surfaceMassToFloat
            (Maybe.withDefault product.surfaceMass surfaceMass)
        |> Area.squareMeters


getOutputSurface : Inputs -> Step -> Area
getOutputSurface { product, surfaceMass } { outputMass } =
    Mass.inGrams outputMass
        / Unit.surfaceMassToFloat
            (Maybe.withDefault product.surfaceMass surfaceMass)
        |> Area.squareMeters


updateFromInputs : Db -> Inputs -> Step -> Step
updateFromInputs { processes } inputs ({ label, country } as step) =
    let
        { airTransportRatio, quality, reparability, makingWaste, picking, surfaceMass, dyeingMedium, printing } =
            inputs
    in
    case label of
        Label.Spinning ->
            { step
                | processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                    }
            }

        Label.Fabric ->
            { step
                | picking = picking
                , surfaceMass = surfaceMass
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , fabric = Just (Product.getFabricProcess inputs.product |> .name)
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
                            processes
                                |> Process.loadWellKnown
                                |> Result.map
                                    (Process.getDyeingProcess
                                        (dyeingMedium
                                            |> Maybe.withDefault inputs.product.dyeing.defaultMedium
                                        )
                                        >> .name
                                    )
                                |> Result.toMaybe
                        , printing =
                            printing
                                |> Maybe.andThen
                                    (\printingType ->
                                        processes
                                            |> Process.loadWellKnown
                                            |> Result.map (Process.getPrintingProcess printingType >> .name)
                                            |> Result.toMaybe
                                    )
                    }
            }

        Label.Making ->
            { step
                | airTransportRatio =
                    airTransportRatio |> Maybe.withDefault country.airTransportRatio
                , makingWaste = makingWaste
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , making = Just inputs.product.making.process.name
                        , fading =
                            if inputs.product.making.fadable then
                                processes
                                    |> Process.loadWellKnown
                                    |> Result.map (.fading >> .name)
                                    |> Result.toMaybe

                            else
                                Nothing
                        , airTransportRatio =
                            country.airTransportRatio
                                |> airTransportRatioToString
                                |> Just
                    }
            }

        Label.Distribution ->
            processes
                |> Process.loadWellKnown
                |> Result.map
                    (\{ distribution } ->
                        { step
                            | processInfo =
                                { defaultProcessInfo | distribution = Just distribution.name }
                        }
                    )
                |> Result.withDefault step

        Label.Use ->
            { step
                | quality =
                    quality |> Maybe.withDefault Unit.standardQuality
                , reparability =
                    reparability |> Maybe.withDefault Unit.standardReparability
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , useIroning = Just inputs.product.use.ironingProcess.name
                        , useNonIroning = Just inputs.product.use.nonIroningProcess.name
                    }
            }

        Label.EndOfLife ->
            let
                newProcessInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , countryHeat = Just country.heatProcess.name
                    }
            in
            processes
                |> Process.loadWellKnown
                |> Result.map
                    (\{ endOfLife } ->
                        { step
                            | processInfo =
                                { newProcessInfo
                                    | passengerCar = Just "Transport en voiture vers point de collecte (1km)"
                                    , endOfLife = Just endOfLife.name
                                }
                        }
                    )
                |> Result.withDefault { step | processInfo = newProcessInfo }

        _ ->
            step


initMass : Mass -> Step -> Step
initMass mass step =
    { step
        | inputMass = mass
        , outputMass = mass
    }


updateWaste : Mass -> Mass -> Step -> Step
updateWaste waste mass step =
    { step
        | waste = waste
        , inputMass = mass
        , outputMass = Quantity.difference mass waste
    }


airTransportRatioToString : Unit.Ratio -> String
airTransportRatioToString (Unit.Ratio airTransportRatio) =
    case round (airTransportRatio * 100) of
        0 ->
            "Aucun transport aérien"

        p ->
            String.fromInt p ++ "% de transport aérien"


qualityToString : Unit.Quality -> String
qualityToString (Unit.Quality float) =
    "Qualité intrinsèque\u{00A0}: " ++ String.fromFloat float


reparabilityToString : Unit.Reparability -> String
reparabilityToString (Unit.Reparability float) =
    "Réparabilité\u{00A0}: " ++ String.fromFloat float


pickingToString : Unit.PickPerMeter -> String
pickingToString (Unit.PickPerMeter int) =
    "Duitage\u{00A0}: " ++ String.fromInt int ++ "\u{202F}duites/m"


surfaceMassToString : Unit.SurfaceMass -> String
surfaceMassToString (Unit.SurfaceMass int) =
    "Grammage\u{00A0}: " ++ String.fromInt int ++ "\u{202F}gr/m²"


makingWasteToString : Unit.Ratio -> String
makingWasteToString (Unit.Ratio makingWaste) =
    case round (makingWaste * 100) of
        0 ->
            "Aucune perte en confection"

        p ->
            String.fromInt p ++ "% de pertes en confection"


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
        , ( "transport", Transport.encode v.transport )
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "heat_MJ", Encode.float (Energy.inMegajoules v.heat) )
        , ( "elec_kWh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "airTransportRatio", Unit.encodeRatio v.airTransportRatio )
        , ( "quality", Unit.encodeQuality v.quality )
        , ( "reparability", Unit.encodeReparability v.reparability )
        , ( "makingWaste", v.makingWaste |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "picking", v.picking |> Maybe.map Unit.encodePickPerMeter |> Maybe.withDefault Encode.null )
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
