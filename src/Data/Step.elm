module Data.Step exposing
    ( Label(..)
    , Step
    , airTransportRatioToString
    , computeTransports
    , create
    , displayLabel
    , dyeingWeightingToString
    , encode
    , getStepGitbookPath
    , initMass
    , labelToString
    , makingWasteToString
    , qualityToString
    , reparabilityToString
    , updateFromInputs
    , updateWaste
    )

import Data.Country as Country exposing (Country)
import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Gitbook as Gitbook
import Data.Impact as Impact exposing (Impacts)
import Data.Inputs exposing (Inputs)
import Data.Process as Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity


type alias Step =
    { label : Label
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
    , dyeingWeighting : Unit.Ratio -- FIXME: why not Maybe?
    , airTransportRatio : Unit.Ratio -- FIXME: why not Maybe?
    , quality : Unit.Quality
    , reparability : Unit.Reparability
    , makingWaste : Maybe Unit.Ratio
    }


type alias ProcessInfo =
    { countryElec : Maybe String
    , countryHeat : Maybe String
    , dyeingWeighting : Maybe String
    , airTransportRatio : Maybe String
    , airTransport : Maybe String
    , seaTransport : Maybe String
    , roadTransport : Maybe String
    , useIroning : Maybe String
    , useNonIroning : Maybe String
    , passengerCar : Maybe String
    , endOfLife : Maybe String
    , knittingWeaving : Maybe String
    , making : Maybe String
    , distribution : Maybe String
    , fading : Maybe String
    }


type Label
    = MaterialAndSpinning -- Matière & Filature
    | WeavingKnitting -- Tissage & Tricotage
    | Ennoblement -- Ennoblement
    | Making -- Confection
    | Distribution -- Distribution
    | Use -- Utilisation
    | EndOfLife -- Fin de vie


create : { db : Db, label : Label, editable : Bool, country : Country } -> Step
create { db, label, editable, country } =
    let
        defaultImpacts =
            Impact.impactsFromDefinitons db.impacts
    in
    { label = label
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
    , dyeingWeighting = country.dyeingWeighting
    , airTransportRatio = Unit.ratio 0 -- Note: this depends on next step country, so we can't set an accurate default value initially
    , quality = Unit.standardQuality
    , reparability = Unit.standardReparability
    , makingWaste = Nothing
    }


defaultProcessInfo : ProcessInfo
defaultProcessInfo =
    { countryElec = Nothing
    , countryHeat = Nothing
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , airTransport = Nothing
    , seaTransport = Nothing
    , roadTransport = Nothing
    , useIroning = Nothing
    , useNonIroning = Nothing
    , passengerCar = Nothing
    , endOfLife = Nothing
    , knittingWeaving = Nothing
    , making = Nothing
    , distribution = Nothing
    , fading = Nothing
    }


displayLabel : { knitted : Bool, faded : Bool } -> Label -> String
displayLabel { knitted, faded } label =
    case ( label, knitted, faded ) of
        ( Making, _, True ) ->
            "Confection & Délavage"

        ( Making, _, False ) ->
            "Confection"

        ( WeavingKnitting, True, _ ) ->
            "Tricotage"

        ( WeavingKnitting, False, _ ) ->
            "Tissage"

        _ ->
            labelToString label


{-| Computes step transport distances and impact regarding next step.

Docs: <https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/transport>

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
        Ennoblement ->
            transport
                -- Note: no air transport ratio at the Ennoblement step
                |> Formula.transportRatio (Unit.ratio 0)
                -- Added intermediary inland transport distances to materialize
                -- "processing" + "dyeing" steps (see Excel)
                -- Also ensure we don't add unnecessary air transport
                |> Transport.add { defaultInland | air = Quantity.zero }

        Making ->
            -- Air transport only applies between the Making and the Distribution steps
            transport
                |> Formula.transportRatio step.airTransportRatio

        Use ->
            -- Product Use leverages no transports
            noTransports

        EndOfLife ->
            -- End of life leverages no transports
            noTransports

        _ ->
            -- All other steps don't use air transport, force a 0 ratio
            transport
                |> Formula.transportRatio (Unit.ratio 0)


getRoadTransportProcess : Process.WellKnown -> Step -> Process
getRoadTransportProcess wellKnown { label } =
    case label of
        Making ->
            wellKnown.roadTransportPostMaking

        Distribution ->
            wellKnown.distribution

        _ ->
            wellKnown.roadTransportPreMaking


updateFromInputs : Db -> Inputs -> Step -> Step
updateFromInputs { processes } inputs ({ label, country } as step) =
    let
        { dyeingWeighting, airTransportRatio, quality, reparability, makingWaste } =
            inputs
    in
    -- Note: only WeavingKnitting, Ennoblement, Making and Use steps render detailed processes info.
    case label of
        WeavingKnitting ->
            { step
                | processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , knittingWeaving = Just inputs.product.fabricProcess.name
                    }
            }

        Ennoblement ->
            { step
                | dyeingWeighting =
                    dyeingWeighting |> Maybe.withDefault country.dyeingWeighting
                , processInfo =
                    { defaultProcessInfo
                        | countryHeat = Just country.heatProcess.name
                        , countryElec = Just country.electricityProcess.name
                        , dyeingWeighting = Just (dyeingWeightingToString country.dyeingWeighting)
                    }
            }

        Making ->
            { step
                | airTransportRatio =
                    airTransportRatio |> Maybe.withDefault country.airTransportRatio
                , makingWaste = makingWaste
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , making = Just inputs.product.makingProcess.name
                        , fading =
                            if inputs.product.faded then
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

        Distribution ->
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

        Use ->
            { step
                | quality =
                    quality |> Maybe.withDefault Unit.standardQuality
                , reparability =
                    reparability |> Maybe.withDefault Unit.standardReparability
                , processInfo =
                    { defaultProcessInfo
                        | countryElec = Just country.electricityProcess.name
                        , useIroning = Just inputs.product.useIroningProcess.name
                        , useNonIroning = Just inputs.product.useNonIroningProcess.name
                    }
            }

        EndOfLife ->
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


dyeingWeightingToString : Unit.Ratio -> String
dyeingWeightingToString (Unit.Ratio dyeingWeighting) =
    case round (dyeingWeighting * 100) of
        0 ->
            "Procédé représentatif"

        p ->
            "Procédé " ++ String.fromInt p ++ "% majorant"


qualityToString : Unit.Quality -> String
qualityToString (Unit.Quality float) =
    "Qualité intrinsèque\u{00A0}: " ++ String.fromFloat float


reparabilityToString : Unit.Reparability -> String
reparabilityToString (Unit.Reparability float) =
    "Réparabilité\u{00A0}: " ++ String.fromFloat float


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
        [ ( "label", Encode.string (labelToString v.label) )
        , ( "country", Country.encode v.country )
        , ( "editable", Encode.bool v.editable )
        , ( "inputMass", Encode.float (Mass.inKilograms v.inputMass) )
        , ( "outputMass", Encode.float (Mass.inKilograms v.outputMass) )
        , ( "waste", Encode.float (Mass.inKilograms v.waste) )
        , ( "transport", Transport.encode v.transport )
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "heat", Encode.float (Energy.inMegajoules v.heat) )
        , ( "kwh", Encode.float (Energy.inKilowattHours v.kwh) )
        , ( "processInfo", encodeProcessInfo v.processInfo )
        , ( "dyeingWeighting", Unit.encodeRatio v.dyeingWeighting )
        , ( "airTransportRatio", Unit.encodeRatio v.airTransportRatio )
        , ( "quality", Unit.encodeQuality v.quality )
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
        , ( "dyeingWeighting", encodeMaybeString v.dyeingWeighting )
        , ( "airTransportRatio", encodeMaybeString v.airTransportRatio )
        , ( "airTransport", encodeMaybeString v.airTransport )
        , ( "seaTransport", encodeMaybeString v.seaTransport )
        , ( "roadTransport", encodeMaybeString v.roadTransport )
        , ( "useIroning", encodeMaybeString v.useIroning )
        , ( "useNonIroning", encodeMaybeString v.useNonIroning )
        , ( "passengerCar", encodeMaybeString v.passengerCar )
        , ( "endOfLife", encodeMaybeString v.endOfLife )
        , ( "knittingWeaving", encodeMaybeString v.knittingWeaving )
        , ( "distribution", encodeMaybeString v.distribution )
        ]


labelToString : Label -> String
labelToString label =
    case label of
        MaterialAndSpinning ->
            "Matière & Filature"

        WeavingKnitting ->
            "Tissage & Tricotage"

        Making ->
            "Confection"

        Ennoblement ->
            "Teinture"

        Distribution ->
            "Distribution"

        Use ->
            "Utilisation"

        EndOfLife ->
            "Fin de vie"


getStepGitbookPath : Label -> Gitbook.Path
getStepGitbookPath label =
    case label of
        MaterialAndSpinning ->
            Gitbook.MaterialAndSpinning

        WeavingKnitting ->
            Gitbook.WeavingKnitting

        Ennoblement ->
            Gitbook.Dyeing

        Making ->
            Gitbook.Making

        Distribution ->
            Gitbook.Distribution

        Use ->
            Gitbook.Use

        EndOfLife ->
            Gitbook.EndOfLife
