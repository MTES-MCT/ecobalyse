module Data.Formula exposing (..)

import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Transport)
import Energy exposing (Energy)
import Mass exposing (Mass)
import Quantity



-- Waste


{-| Compute source material mass needed and waste generated by the operation.
-}
genericWaste : Mass -> Mass -> { mass : Mass, waste : Mass }
genericWaste processWaste baseMass =
    let
        waste =
            Quantity.multiplyBy (Mass.inKilograms baseMass) processWaste

        mass =
            Quantity.plus baseMass waste
    in
    { mass = mass, waste = waste }


{-| Compute source material mass needed and waste generated by the operation from
ratioed pristine/recycled material processes data.
-}
materialRecycledWaste :
    { pristineWaste : Mass
    , recycledWaste : Mass
    , recycledRatio : Float
    }
    -> Mass
    -> { mass : Mass, waste : Mass }
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

        mass =
            recycledMass
                |> Quantity.plus pristineMass
                |> Quantity.plus waste
    in
    { mass = mass, waste = waste }


{-| Compute source material mass needed and waste generated by the operation, according to
material & product waste data.
-}
makingWaste : { processWaste : Mass, pcrWaste : Float } -> Mass -> { mass : Mass, waste : Mass }
makingWaste { processWaste, pcrWaste } baseMass =
    let
        mass =
            -- (product weight + textile waste for confection) / (1 - PCR product waste rate)
            Mass.kilograms <|
                (Mass.inKilograms baseMass + (Mass.inKilograms baseMass * Mass.inKilograms processWaste))
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


{-| Compute co2 from climate change impact and mass
-}
materialCo2 : Float -> Mass -> Float
materialCo2 climateChange mass =
    climateChange * Mass.inKilograms mass


{-| Compute co2 from ratioed material climate change impact and mass
-}
materialRecycledCo2 :
    { pristineClimateChange : Float
    , recycledClimateChange : Float
    , recycledRatio : Float
    }
    -> Mass
    -> Float
materialRecycledCo2 { pristineClimateChange, recycledClimateChange, recycledRatio } baseMass =
    let
        ( recycledCo2, pristineCo2 ) =
            ( baseMass
                |> Quantity.multiplyBy recycledRatio
                |> Quantity.multiplyBy recycledClimateChange
            , baseMass
                |> Quantity.multiplyBy (1 - recycledRatio)
                |> Quantity.multiplyBy pristineClimateChange
            )
    in
    Quantity.plus recycledCo2 pristineCo2 |> Mass.inKilograms


makingCo2 : Process -> Float -> Mass -> { kwh : Energy, co2 : Float }
makingCo2 makingProcess countryElecCC baseMass =
    let
        makingCo2_ =
            makingProcess.climateChange
                |> (*) (Mass.inKilograms baseMass)

        kwh =
            makingProcess.elec
                |> Quantity.multiplyBy (Mass.inKilograms baseMass)

        elecCo2 =
            countryElecCC
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
