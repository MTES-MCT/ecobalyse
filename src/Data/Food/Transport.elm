module Data.Food.Transport exposing
    ( TransportationQuantity
    , getLength
    , inKgKilometers
    , inTonKilometers
    , kilometerToTonKilometer
    , tonKilometers
    )

import Length exposing (Length)
import Mass exposing (Mass)
import Quantity


type alias TransportationQuantity =
    Quantity.Quantity Float (Quantity.Product Mass.Kilograms Length.Meters)


getLength : Mass -> TransportationQuantity -> Length
getLength mass transport =
    Quantity.over mass transport


inKgKilometers : TransportationQuantity -> Float
inKgKilometers transport =
    -- Transport is stored in kg.m, we want it in kg.km
    inTonKilometers transport
        -- 1 km == 1000m
        / 1000


inTonKilometers : TransportationQuantity -> Float
inTonKilometers (Quantity.Quantity transport) =
    -- Transport is stored in kg.m, we want it in ton.km
    transport
        -- 1 ton == 1000kg
        / 1000
        -- 1km = 1000m
        / 1000


kilometerToTonKilometer : Length -> Mass -> Mass
kilometerToTonKilometer length amount =
    Mass.metricTons
        (if length == Length.kilometers 0 then
            0

         else
            Mass.inMetricTons amount * Length.inKilometers length
        )


tonKilometers : Float -> TransportationQuantity
tonKilometers amount =
    -- Could equally be written `Quantity.product  (Mass.metricTons 1) (Length.kilometers amount)
    Quantity.product (Mass.metricTons amount) (Length.kilometers 1)
