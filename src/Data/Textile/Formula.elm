module Data.Textile.Formula exposing
    ( bleachingImpacts
    , computePicking
    , computeThreadDensity
    , dyeingImpacts
    , endOfLifeImpacts
    , finishingImpacts
    , genericWaste
    , knittingImpacts
    , makingDeadStock
    , makingImpacts
    , makingWaste
    , materialDyeingToxicityImpacts
    , materialPrintingToxicityImpacts
    , printingImpacts
    , pureMaterialImpacts
    , recycledMaterialImpacts
    , spinningImpacts
    , transportRatio
    , useImpacts
    , weavingImpacts
    )

import Area exposing (Area)
import Data.Country as Country
import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material exposing (CFFData)
import Data.Textile.Process as Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Duration
import Energy exposing (Energy)
import Mass exposing (Mass)
import Quantity
import Volume exposing (Volume)



-- Waste


{-| Compute source mass needed and waste generated by the operation.
-}
genericWaste : Unit.Ratio -> Mass -> { waste : Mass, mass : Mass }
genericWaste processWaste baseMass =
    let
        waste =
            baseMass
                |> Quantity.multiplyBy (Unit.ratioToFloat processWaste)
    in
    { waste = waste, mass = baseMass |> Quantity.plus waste }


{-| Compute source material mass needed and waste generated by the operation, according to
material & product waste data.
-}
makingWaste : Split -> Mass -> { waste : Mass, mass : Mass }
makingWaste pcrWaste baseMass =
    let
        mass =
            -- (product weight + textile waste for confection) / (1 - PCR product waste rate)
            baseMass
                |> Quantity.divideBy (Split.toFloat (Split.complement pcrWaste))
    in
    { waste = Quantity.minus baseMass mass, mass = mass }


{-| Compute source material mass needed and deadstock generated by the operation, according to
making deadstock data.
-}
makingDeadStock : Split -> Mass -> { deadstock : Mass, mass : Mass }
makingDeadStock deadstock baseMass =
    let
        mass =
            -- (product weight + textile deadstock during confection) / (1 - deadstock rate)
            baseMass
                |> Quantity.divideBy (Split.toFloat (Split.complement deadstock))
    in
    { deadstock = Quantity.minus baseMass mass, mass = mass }



-- Impacts
--


pureMaterialImpacts : Impacts -> Process -> Mass -> Impacts
pureMaterialImpacts impacts process mass =
    impacts
        |> Impact.mapImpacts
            (\trigram _ ->
                mass
                    |> Unit.forKg (Process.getImpact trigram process)
            )


recycledMaterialImpacts :
    Impacts
    -> { recycledProcess : Process, nonRecycledProcess : Process, cffData : CFFData }
    -> Mass
    -> Impacts
recycledMaterialImpacts impacts { recycledProcess, nonRecycledProcess, cffData } outputMass =
    let
        { manufacturerAllocation, recycledQualityRatio } =
            cffData
    in
    impacts
        |> Impact.mapImpacts
            (\trigram _ ->
                let
                    ( recycledImpactPerKg, nonRecycledImpactPerKg ) =
                        ( Process.getImpact trigram recycledProcess |> Unit.impactToFloat
                        , Process.getImpact trigram nonRecycledProcess |> Unit.impactToFloat
                        )
                in
                Mass.inKilograms outputMass
                    * (Split.apply recycledImpactPerKg manufacturerAllocation
                        + Split.apply (Split.toFloat recycledQualityRatio) (Split.complement manufacturerAllocation)
                        * nonRecycledImpactPerKg
                      )
                    |> Unit.impact
            )


spinningImpacts :
    Impacts
    -> { spinningKwh : Energy, countryElecProcess : Process }
    -> { kwh : Energy, impacts : Impacts }
spinningImpacts impacts { spinningKwh, countryElecProcess } =
    { kwh = spinningKwh
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    spinningKwh |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                )
    }


dyeingImpacts :
    Impacts
    -> Process -- Inbound: Dyeing process
    -> Process -- Outbound: country heat impact
    -> Process -- Outbound: country electricity impact
    -> Mass
    -> { heat : Energy, kwh : Energy, impacts : Impacts }
dyeingImpacts impacts dyeingProcess heatProcess elecProcess baseMass =
    let
        heatMJ =
            Mass.inKilograms baseMass
                * Energy.inMegajoules dyeingProcess.heat
                |> Energy.megajoules

        kwh =
            Mass.inKilograms baseMass
                * Energy.inMegajoules dyeingProcess.elec
                |> Energy.megajoules
    in
    { heat = heatMJ
    , kwh = kwh
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    Quantity.sum
                        [ baseMass |> Unit.forKg (Process.getImpact trigram dyeingProcess)
                        , heatMJ |> Unit.forMJ (Process.getImpact trigram heatProcess)
                        , kwh |> Unit.forKWh (Process.getImpact trigram elecProcess)
                        ]
                )
    }


printingImpacts :
    Impacts
    ->
        { printingProcess : Process -- Inbound: Printing process
        , heatProcess : Process -- Outbound: country heat impact
        , elecProcess : Process -- Outbound: country electricity impact
        , surfaceMass : Unit.SurfaceMass
        , ratio : Split
        }
    -> Mass
    -> { heat : Energy, kwh : Energy, impacts : Impacts }
printingImpacts impacts { printingProcess, heatProcess, elecProcess, surfaceMass, ratio } baseMass =
    let
        surface =
            Unit.surfaceMassToSurface surfaceMass baseMass
                |> Area.inSquareMeters
                -- Apply ratio
                |> (\surfaceInSquareMeters -> Split.apply surfaceInSquareMeters ratio)

        ( heatMJ, kwh ) =
            -- Note: printing processes heat and elec values are expressed "per square meter"
            ( Quantity.multiplyBy surface printingProcess.heat
            , Quantity.multiplyBy surface printingProcess.elec
            )
    in
    { heat = heatMJ
    , kwh = kwh
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    Quantity.sum
                        [ baseMass |> Unit.forKg (Process.getImpact trigram printingProcess)
                        , heatMJ |> Unit.forMJ (Process.getImpact trigram heatProcess)
                        , kwh |> Unit.forKWh (Process.getImpact trigram elecProcess)
                        ]
                )
    }


finishingImpacts :
    Impacts
    ->
        { finishingProcess : Process -- Inbound: Printing process
        , heatProcess : Process -- Outbound: country heat impact
        , elecProcess : Process -- Outbound: country electricity impact
        }
    -> Mass
    -> { heat : Energy, kwh : Energy, impacts : Impacts }
finishingImpacts impacts { finishingProcess, heatProcess, elecProcess } baseMass =
    let
        ( heatMJ, kwh ) =
            ( Quantity.multiplyBy (Mass.inKilograms baseMass) finishingProcess.heat
            , Quantity.multiplyBy (Mass.inKilograms baseMass) finishingProcess.elec
            )
    in
    { heat = heatMJ
    , kwh = kwh
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    Quantity.sum
                        [ baseMass |> Unit.forKg (Process.getImpact trigram finishingProcess)
                        , heatMJ |> Unit.forMJ (Process.getImpact trigram heatProcess)
                        , kwh |> Unit.forKWh (Process.getImpact trigram elecProcess)
                        ]
                )
    }


getAquaticPollutionRealRatio : Country.AquaticPollutionScenario -> Float
getAquaticPollutionRealRatio scenario =
    -- The toxicity impacts in the "enriched" ennobling processes
    -- "bleaching", "printing-dyes" and "printing-paste",  are based
    -- on the "average" value.
    -- To have the real ratio, we need to do:
    -- ratio / average
    let
        countryRatio =
            Country.getAquaticPollutionRatio scenario |> Split.toFloat

        averageRatio =
            Country.getAquaticPollutionRatio Country.Average |> Split.toFloat
    in
    countryRatio / averageRatio


bleachingImpacts :
    Impacts
    ->
        { bleachingProcess : Process -- Inbound: Bleaching process
        , aquaticPollutionScenario : Country.AquaticPollutionScenario
        , countryElecProcess : Process
        , countryHeatProcess : Process
        }
    -> Mass
    -> Impacts
bleachingImpacts impacts { bleachingProcess, countryElecProcess, countryHeatProcess } baseMass =
    impacts
        |> Impact.mapImpacts
            (\trigram _ ->
                Quantity.sum
                    [ bleachingProcess.elec
                        |> Quantity.multiplyBy (Mass.inKilograms baseMass)
                        |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                    , bleachingProcess.heat
                        |> Quantity.multiplyBy (Mass.inKilograms baseMass)
                        |> Unit.forMJ (Process.getImpact trigram countryHeatProcess)

                    -- FIXME: What to do with this now we don't have bleaching impacts anymore?
                    --        How should we use aquaticPollutionScenario now?
                    --        Maybe we should still apply the ratio to the resulting impacts?
                    -- , baseMass
                    --     |> Unit.forKg (Process.getImpact trigram bleachingProcess)
                    --     |> Quantity.multiplyBy (getAquaticPollutionRealRatio aquaticPollutionScenario)
                    ]
            )


materialDyeingToxicityImpacts :
    Impacts
    ->
        { dyeingToxicityProcess : Process -- Inbound: dyeing process
        , aquaticPollutionScenario : Country.AquaticPollutionScenario
        }
    -> Mass
    -> Split
    -> Impacts
materialDyeingToxicityImpacts impacts { dyeingToxicityProcess, aquaticPollutionScenario } baseMass split =
    impacts
        |> Impact.mapImpacts
            (\trigram _ ->
                baseMass
                    |> Unit.forKg (Process.getImpact trigram dyeingToxicityProcess)
                    |> Quantity.multiplyBy (getAquaticPollutionRealRatio aquaticPollutionScenario)
                    |> (\impact -> Split.applyToQuantity impact split)
            )


materialPrintingToxicityImpacts :
    Impacts
    ->
        { printingToxicityProcess : Process -- Inbound: printing process
        , aquaticPollutionScenario : Country.AquaticPollutionScenario
        }
    -> Split
    -> Mass
    -> Impacts
materialPrintingToxicityImpacts impacts { printingToxicityProcess, aquaticPollutionScenario } split baseMass =
    impacts
        |> Impact.mapImpacts
            (\trigram _ ->
                baseMass
                    |> Unit.forKg (Process.getImpact trigram printingToxicityProcess)
                    |> Quantity.multiplyBy (getAquaticPollutionRealRatio aquaticPollutionScenario)
                    |> (\impact -> Split.applyToQuantity impact split)
            )


makingImpacts :
    Impacts
    ->
        { makingComplexity : MakingComplexity
        , fadingProcess : Maybe Process
        , countryElecProcess : Process
        , countryHeatProcess : Process
        }
    -> Mass
    -> { kwh : Energy, heat : Energy, impacts : Impacts }
makingImpacts impacts { makingComplexity, fadingProcess, countryElecProcess, countryHeatProcess } outputMass =
    -- Note: Fading, when enabled, is applied at the Making step because
    -- it can only be applied on finished products (using step output mass).
    -- Also:
    -- - Making impacts are precomputed per "item" (not mass-dependent)
    -- - Fading process, when defined, is mass-dependent
    let
        ( fadingElec, fadingHeat ) =
            ( fadingProcess
                |> Maybe.map .elec
                |> Maybe.withDefault Quantity.zero
                |> Quantity.multiplyBy (Mass.inKilograms outputMass)
            , fadingProcess
                |> Maybe.map .heat
                |> Maybe.withDefault Quantity.zero
                |> Quantity.multiplyBy (Mass.inKilograms outputMass)
            )

        -- Pre-computed constant: energy needed per minute of confection
        kWhPerMinute =
            Energy.kilowattHours 0.029

        elec =
            Quantity.multiplyBy (MakingComplexity.toDuration makingComplexity |> Duration.inMinutes) kWhPerMinute
    in
    { kwh = Quantity.sum [ elec, fadingElec ]
    , heat = fadingHeat
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    Quantity.sum
                        [ -- Making process (per-item)
                          elec
                            |> Unit.forKWh (Process.getImpact trigram countryElecProcess)

                        -- Fading process (mass-dependent)
                        , outputMass
                            |> Unit.forKg
                                (fadingProcess
                                    |> Maybe.map (Process.getImpact trigram)
                                    |> Maybe.withDefault Quantity.zero
                                )
                        , fadingElec
                            |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                        , fadingHeat
                            |> Unit.forMJ (Process.getImpact trigram countryHeatProcess)
                        ]
                )
    }


knittingImpacts :
    Impacts
    -> { elec : Energy, countryElecProcess : Process }
    -> Mass
    ->
        { kwh : Energy
        , threadDensity : Maybe Unit.ThreadDensity
        , picking : Maybe Unit.PickPerMeter
        , impacts : Impacts
        }
knittingImpacts impacts { elec, countryElecProcess } baseMass =
    let
        electricityKWh =
            Energy.kilowattHours
                (Mass.inKilograms baseMass * Energy.inKilowattHours elec)
    in
    { kwh = electricityKWh
    , threadDensity = Nothing
    , picking = Nothing
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    electricityKWh
                        |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                )
    }


weavingImpacts :
    Impacts
    ->
        { countryElecProcess : Process
        , outputMass : Mass
        , pickingElec : Float
        , surfaceMass : Unit.SurfaceMass
        , yarnSize : Unit.YarnSize
        }
    ->
        { kwh : Energy
        , threadDensity : Maybe Unit.ThreadDensity
        , picking : Maybe Unit.PickPerMeter
        , impacts : Impacts
        }
weavingImpacts impacts { countryElecProcess, outputMass, pickingElec, surfaceMass, yarnSize } =
    -- Methodology: https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/tricotage-tissage
    let
        outputSurface =
            Unit.surfaceMassToSurface surfaceMass outputMass

        threadDensity =
            computeThreadDensity surfaceMass yarnSize

        picking =
            computePicking threadDensity outputSurface

        -- Note: pickingElec is expressed in kWh/(pick,m) per kg of material to process (see Base Impacts)
        electricityKWh =
            pickingElec
                * Unit.pickPerMeterToFloat picking
                |> Energy.kilowattHours
    in
    { kwh = electricityKWh
    , threadDensity = Just threadDensity
    , picking = Just picking
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    electricityKWh
                        |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                )
    }


computeThreadDensity : Unit.SurfaceMass -> Unit.YarnSize -> Unit.ThreadDensity
computeThreadDensity surfaceMass yarnSize =
    -- Densité de fils (# fils/cm) = Grammage(g/m2) * Titrage (Nm) / 100 / 2 / wasteRatio
    let
        -- Taux d'embuvage/retrait = 8% (valeur constante)
        wasteRatio =
            1.08
    in
    toFloat (Unit.surfaceMassInGramsPerSquareMeters surfaceMass)
        * toFloat (Unit.yarnSizeInKilometers yarnSize)
        -- the output surface is in (m2) so we would have the threadDensity is in (# fils / m) but we need it in (# fils / cm)
        / 100
        -- the thread is weaved horizontally and vertically, so the number of threads along one axis is only half of the total thread length
        / 2
        / wasteRatio
        |> Unit.threadDensity


computePicking : Unit.ThreadDensity -> Area -> Unit.PickPerMeter
computePicking threadDensity outputSurface =
    -- Duites.m = Densité de fils (# fils / cm) * Surface sortante (m2) * 100
    Unit.threadDensityToFloat threadDensity
        * Area.inSquareMeters outputSurface
        -- threadDensity is in (# fils / cm) but we need it in (# fils / m) to be in par with the output surface in (m2)
        * 100
        |> round
        |> Unit.PickPerMeter


useImpacts :
    Impacts
    ->
        { useNbCycles : Int
        , ironingElec : Energy
        , nonIroningProcess : Process
        , countryElecProcess : Process
        }
    -> Mass
    -> { kwh : Energy, impacts : Impacts }
useImpacts impacts { useNbCycles, ironingElec, nonIroningProcess, countryElecProcess } baseMass =
    let
        totalEnergy =
            -- Note: Ironing is expressed per-item, non-ironing is mass-depdendent
            [ ironingElec
            , nonIroningProcess.elec
                |> Quantity.multiplyBy (Mass.inKilograms baseMass)
            ]
                |> Quantity.sum
                |> Quantity.multiplyBy (toFloat useNbCycles)
    in
    { kwh = totalEnergy
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    Quantity.sum
                        [ totalEnergy
                            |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                        , baseMass
                            |> Unit.forKg (Process.getImpact trigram nonIroningProcess)
                            |> Quantity.multiplyBy (toFloat useNbCycles)
                        ]
                )
    }


endOfLifeImpacts :
    Impacts
    ->
        { volume : Volume
        , passengerCar : Process
        , endOfLife : Process
        , countryElecProcess : Process
        , heatProcess : Process
        }
    -> Mass
    -> { kwh : Energy, heat : Energy, impacts : Impacts }
endOfLifeImpacts impacts { volume, passengerCar, endOfLife, countryElecProcess, heatProcess } baseMass =
    -- Notes:
    -- - passengerCar is expressed per-item
    -- - endOfLife is mass-dependent
    -- - a typical car trunk is 0.2m³ average
    let
        carTrunkAllocationRatio =
            volume
                |> Quantity.divideBy 0.2
                |> Volume.inCubicMeters

        ( elecEnergy, heatEnergy ) =
            ( Quantity.sum
                [ passengerCar.elec
                    |> Quantity.multiplyBy carTrunkAllocationRatio
                , endOfLife.elec
                    |> Quantity.multiplyBy (Mass.inKilograms baseMass)
                ]
            , Quantity.sum
                [ passengerCar.heat
                    |> Quantity.multiplyBy carTrunkAllocationRatio
                , endOfLife.heat
                    |> Quantity.multiplyBy (Mass.inKilograms baseMass)
                ]
            )
    in
    { kwh = elecEnergy
    , heat = heatEnergy
    , impacts =
        impacts
            |> Impact.mapImpacts
                (\trigram _ ->
                    Quantity.sum
                        [ Process.getImpact trigram passengerCar
                            |> Quantity.multiplyBy carTrunkAllocationRatio
                        , elecEnergy
                            |> Unit.forKWh (Process.getImpact trigram countryElecProcess)
                        , heatEnergy
                            |> Unit.forMJ (Process.getImpact trigram heatProcess)
                        , baseMass
                            |> Unit.forKg (Process.getImpact trigram endOfLife)
                        ]
                )
    }



-- Transports


transportRatio : Split -> Transport -> Transport
transportRatio airTransportRatio ({ road, sea, air } as transport) =
    let
        roadRatio =
            Transport.roadSeaTransportRatio transport

        seaRatio =
            Split.complement roadRatio
    in
    { transport
        | road = road |> Quantity.multiplyBy (Split.apply (Split.toFloat roadRatio) (Split.complement airTransportRatio))
        , sea = sea |> Quantity.multiplyBy (Split.apply (Split.toFloat seaRatio) (Split.complement airTransportRatio))
        , air = air |> Quantity.multiplyBy (Split.toFloat airTransportRatio)
    }
