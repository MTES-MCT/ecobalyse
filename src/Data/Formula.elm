module Data.Formula exposing (..)

import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Energy exposing (Energy)
import Mass exposing (Mass)
import Quantity



-- Waste


{-| Compute source material mass needed and waste generated by the operation.
-}
genericWaste : Mass -> Mass -> { waste : Mass, mass : Mass }
genericWaste processWaste baseMass =
    let
        waste =
            baseMass
                |> Quantity.multiplyBy (Mass.inKilograms processWaste)
    in
    { waste = waste, mass = baseMass |> Quantity.plus waste }


{-| Compute source material mass needed and waste generated by the operation from
ratioed pristine/recycled material processes data.
-}
materialRecycledWaste :
    { pristineWaste : Mass
    , recycledWaste : Mass
    , recycledRatio : Float
    }
    -> Mass
    -> { waste : Mass, mass : Mass }
materialRecycledWaste { pristineWaste, recycledWaste, recycledRatio } baseMass =
    let
        ( recycledMass, pristineMass ) =
            ( baseMass |> Quantity.multiplyBy recycledRatio
            , baseMass |> Quantity.multiplyBy (1 - recycledRatio)
            )

        ( ratioedRecycledWaste, ratioedPristineWaste ) =
            ( recycledMass |> Quantity.multiplyBy (Mass.inKilograms recycledWaste)
            , pristineMass |> Quantity.multiplyBy (Mass.inKilograms pristineWaste)
            )

        waste =
            Quantity.plus ratioedRecycledWaste ratioedPristineWaste
    in
    { waste = waste
    , mass = Quantity.sum [ pristineMass, recycledMass, waste ]
    }


{-| Compute source material mass needed and waste generated by the operation, according to
material & product waste data.
-}
makingWaste :
    { processWaste : Mass
    , pcrWaste : Float
    }
    -> Mass
    -> { waste : Mass, mass : Mass }
makingWaste { processWaste, pcrWaste } baseMass =
    let
        mass =
            -- (product weight + textile waste for confection) / (1 - PCR product waste rate)
            Mass.kilograms <|
                (Mass.inKilograms baseMass + (Mass.inKilograms baseMass * Mass.inKilograms processWaste))
                    / (1 - pcrWaste)
    in
    { waste = Quantity.minus baseMass mass, mass = mass }



-- Impacts


materialAndSpinningImpacts :
    ( Process, Process ) -- Inbound: Material processes (recycled, non-recycled)
    -> Float -- Ratio of recycled material (bewteen 0 and 1)
    -> Mass
    -> { co2 : Unit.Co2e, fwe : Unit.Pe }
materialAndSpinningImpacts ( recycledProcess, nonRecycledProcess ) ratio baseMass =
    { co2 =
        baseMass
            |> Unit.ratioedForKg
                ( recycledProcess.climateChange
                , nonRecycledProcess.climateChange
                )
                ratio
    , fwe =
        baseMass
            |> Unit.ratioedForKg
                ( recycledProcess.freshwaterEutrophication
                , nonRecycledProcess.freshwaterEutrophication
                )
                ratio
    }


pureMaterialAndSpinningImpacts : Process -> Mass -> { co2 : Unit.Co2e, fwe : Unit.Pe }
pureMaterialAndSpinningImpacts process baseMass =
    { co2 = baseMass |> Unit.forKg process.climateChange
    , fwe = baseMass |> Unit.forKg process.freshwaterEutrophication
    }


dyeingImpacts :
    ( Process, Process ) -- Inbound: Dyeing processes (low, high)
    -> Float -- Low/high dyeing process ratio
    -> Process -- Outbound: country heat impact
    -> Process -- Outbound: country electricity impact
    -> Mass
    -> { co2 : Unit.Co2e, fwe : Unit.Pe, heat : Energy, kwh : Energy }
dyeingImpacts ( dyeingLowProcess, dyeingHighProcess ) highDyeingWeighting heatProcess elecProcess baseMass =
    let
        lowDyeingWeighting =
            1 - highDyeingWeighting

        ( lowDyeingMass, highDyeingMass ) =
            ( baseMass |> Quantity.multiplyBy lowDyeingWeighting
            , baseMass |> Quantity.multiplyBy highDyeingWeighting
            )

        dyeingCo2_ =
            Quantity.sum
                [ Unit.forKg dyeingLowProcess.climateChange lowDyeingMass
                , Unit.forKg dyeingHighProcess.climateChange highDyeingMass
                ]

        dyeingFwe =
            Quantity.sum
                [ Unit.forKg dyeingLowProcess.freshwaterEutrophication lowDyeingMass
                , Unit.forKg dyeingHighProcess.freshwaterEutrophication highDyeingMass
                ]

        heatMJ =
            Mass.inKilograms baseMass
                * ((highDyeingWeighting * Energy.inMegajoules dyeingHighProcess.heat)
                    + (lowDyeingWeighting * Energy.inMegajoules dyeingLowProcess.heat)
                  )
                |> Energy.megajoules

        heatCo2 =
            heatMJ |> Unit.forMJ heatProcess.climateChange

        heatFwe =
            heatMJ |> Unit.forMJ heatProcess.freshwaterEutrophication

        electricity =
            Mass.inKilograms baseMass
                * ((highDyeingWeighting * Energy.inMegajoules dyeingHighProcess.elec)
                    + (lowDyeingWeighting * Energy.inMegajoules dyeingLowProcess.elec)
                  )
                |> Energy.megajoules

        elecCo2 =
            electricity |> Unit.forKWh elecProcess.climateChange

        elecFwe =
            electricity |> Unit.forKWh elecProcess.freshwaterEutrophication
    in
    { co2 = Quantity.sum [ dyeingCo2_, heatCo2, elecCo2 ]
    , fwe = Quantity.sum [ dyeingFwe, heatFwe, elecFwe ]
    , heat = heatMJ
    , kwh = electricity
    }


makingImpacts :
    { makingProcess : Process, countryElecProcess : Process }
    -> Mass
    -> { kwh : Energy, co2 : Unit.Co2e, fwe : Unit.Pe }
makingImpacts { makingProcess, countryElecProcess } _ =
    -- Note: In Base Impacts, impacts are precomputed per "item", and are
    --       therefore not mass-dependent.
    let
        co2 =
            makingProcess.elec
                |> Unit.forKWh countryElecProcess.climateChange

        fwe =
            makingProcess.elec
                |> Unit.forKWh countryElecProcess.freshwaterEutrophication
    in
    { co2 = co2, fwe = fwe, kwh = makingProcess.elec }


knittingImpacts :
    { elec : Energy, countryElecProcess : Process }
    -> Mass
    -> { kwh : Energy, co2 : Unit.Co2e, fwe : Unit.Pe }
knittingImpacts { elec, countryElecProcess } baseMass =
    let
        electricityKWh =
            Energy.kilowattHours
                (Mass.inKilograms baseMass * Energy.inKilowattHours elec)
    in
    { kwh = electricityKWh
    , co2 = electricityKWh |> Unit.forKWh countryElecProcess.climateChange
    , fwe = electricityKWh |> Unit.forKWh countryElecProcess.freshwaterEutrophication
    }


weavingImpacts :
    { elecPppm : Float
    , countryElecProcess : Process
    , ppm : Int
    , grammage : Int
    }
    -> Mass
    -> { kwh : Energy, co2 : Unit.Co2e, fwe : Unit.Pe }
weavingImpacts { elecPppm, countryElecProcess, ppm, grammage } baseMass =
    let
        electricityKWh =
            (Mass.inKilograms baseMass * 1000 * toFloat ppm / toFloat grammage)
                * elecPppm
                |> Energy.kilowattHours
    in
    { kwh = electricityKWh
    , co2 = electricityKWh |> Unit.forKWh countryElecProcess.climateChange
    , fwe = electricityKWh |> Unit.forKWh countryElecProcess.freshwaterEutrophication
    }



-- Transports


transportRatio : Float -> Transport -> Transport
transportRatio airTransportRatio ({ road, sea, air } as transport) =
    let
        roadSeaRatio =
            Transport.roadSeaTransportRatio transport
    in
    { transport
        | road = road |> Quantity.multiplyBy (roadSeaRatio * (1 - airTransportRatio))
        , sea = sea |> Quantity.multiplyBy ((1 - roadSeaRatio) * (1 - airTransportRatio))
        , air = air |> Quantity.multiplyBy airTransportRatio
    }
