module Data.Formula exposing (..)

import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Energy exposing (Energy)
import Mass exposing (Mass)
import Quantity



-- Waste


materialWaste : Process -> Mass -> { mass : Mass, waste : Mass }
materialWaste process baseMass =
    let
        waste =
            Quantity.multiplyBy (Mass.inKilograms baseMass) process.waste

        mass =
            Quantity.plus baseMass waste
    in
    { mass = mass, waste = waste }


materialRecycledWaste : Process -> Process -> Float -> Mass -> { mass : Mass, waste : Mass }
materialRecycledWaste pristine recycled recycledRatio baseMass =
    let
        ( recycledMass, pristineMass ) =
            ( baseMass |> Quantity.multiplyBy recycledRatio
            , baseMass |> Quantity.multiplyBy (1 - recycledRatio)
            )

        ( recycledWaste, pristineWaste ) =
            ( recycledMass |> Quantity.multiplyBy (Mass.inKilograms recycled.waste)
            , pristineMass |> Quantity.multiplyBy (Mass.inKilograms pristine.waste)
            )

        waste =
            Quantity.plus recycledWaste pristineWaste

        mass =
            recycledMass
                |> Quantity.plus pristineMass
                |> Quantity.plus waste
    in
    { mass = mass, waste = waste }


weavingKnittingWaste : Process -> Mass -> { mass : Mass, waste : Mass }
weavingKnittingWaste process baseMass =
    let
        waste =
            Quantity.multiplyBy (Mass.inKilograms baseMass) process.waste

        mass =
            Quantity.plus baseMass waste
    in
    { mass = mass, waste = waste }


makingWaste : Process -> Float -> Mass -> { mass : Mass, waste : Mass }
makingWaste process pcrWaste baseMass =
    let
        mass =
            -- (product weight + textile waste for confection) / (1 - PCR waste rate)
            Mass.kilograms <|
                (Mass.inKilograms baseMass + (Mass.inKilograms baseMass * Mass.inKilograms process.waste))
                    / (1 - pcrWaste)

        waste =
            Quantity.minus baseMass mass
    in
    { mass = mass, waste = waste }



-- Co2 score


dyeingCo2 :
    ( Process, Process )
    -> Float
    -> Float
    -> Float
    -> Mass
    -> { co2 : Float, heat : Energy, kwh : Energy }
dyeingCo2 ( dyeingLowProcess, dyeingHighProcess ) highDyeingWeighting heatCC elecCC baseMass =
    let
        lowDyeingWeighting =
            1 - highDyeingWeighting

        dyeingCo2_ =
            Mass.inKilograms baseMass
                * ((highDyeingWeighting * dyeingHighProcess.climateChange)
                    + (lowDyeingWeighting * dyeingLowProcess.climateChange)
                  )

        heatMJ =
            Mass.inKilograms baseMass
                * ((highDyeingWeighting * Energy.inMegajoules dyeingHighProcess.heat)
                    + (lowDyeingWeighting * Energy.inMegajoules dyeingLowProcess.heat)
                  )
                |> Energy.megajoules

        heatCo2 =
            heatCC
                |> (*) (Energy.inMegajoules heatMJ)

        electricity =
            Mass.inKilograms baseMass
                * ((highDyeingWeighting * Energy.inMegajoules dyeingHighProcess.elec)
                    + (lowDyeingWeighting * Energy.inMegajoules dyeingLowProcess.elec)
                  )
                |> Energy.megajoules

        elecCo2 =
            elecCC
                |> (*) (Energy.inKilowattHours electricity)
    in
    { co2 = dyeingCo2_ + heatCo2 + elecCo2
    , heat = heatMJ
    , kwh = electricity
    }


materialCo2 : Process -> Mass -> Float
materialCo2 process mass =
    process.climateChange * Mass.inKilograms mass


materialRecycledCo2 : Process -> Process -> Float -> Mass -> Float
materialRecycledCo2 pristineProcess recycledProcess recycledRatio baseMass =
    let
        ( recycledCo2, pristineCo2 ) =
            ( baseMass
                |> Quantity.multiplyBy recycledRatio
                |> Quantity.multiplyBy recycledProcess.climateChange
            , baseMass
                |> Quantity.multiplyBy (1 - recycledRatio)
                |> Quantity.multiplyBy pristineProcess.climateChange
            )
    in
    Quantity.plus recycledCo2 pristineCo2 |> Mass.inKilograms


makingCo2 : Process -> Float -> Mass -> { kwh : Energy, co2 : Float }
makingCo2 makingProcess elecCC baseMass =
    let
        makingCo2_ =
            makingProcess.climateChange
                |> (*) (Mass.inKilograms baseMass)

        kwh =
            makingProcess.elec
                |> Quantity.multiplyBy (Mass.inKilograms baseMass)

        elecCo2 =
            elecCC
                |> (*) (Energy.inKilowattHours kwh)
    in
    { co2 = makingCo2_ + elecCo2, kwh = kwh }


knittingCo2 : Process -> Float -> Mass -> { kwh : Energy, co2 : Float }
knittingCo2 fabricProcess elecCC baseMass =
    let
        electricityKWh =
            Mass.inKilograms baseMass * Energy.inKilowattHours fabricProcess.elec
    in
    { kwh = Energy.kilowattHours electricityKWh
    , co2 = electricityKWh * elecCC
    }


weavingCo2 : Process -> Float -> Int -> Int -> Mass -> { kwh : Energy, co2 : Float }
weavingCo2 fabricProcess elecCC ppm grammage baseMass =
    let
        electricityKWh =
            (Mass.inKilograms baseMass * 1000 * toFloat ppm / toFloat grammage)
                * fabricProcess.elec_pppm
    in
    { kwh = Energy.kilowattHours electricityKWh
    , co2 = electricityKWh * elecCC
    }



-- Transports


transportRatio : Float -> Transport.Summary -> Transport
transportRatio airTransportRatio ({ road, sea, air } as summary) =
    let
        roadSeaRatio =
            Transport.roadSeaTransportRatio summary
    in
    { road = (road * roadSeaRatio) * (1 - airTransportRatio)
    , sea = (sea * (1 - roadSeaRatio)) * (1 - airTransportRatio)
    , air = air * airTransportRatio
    }
