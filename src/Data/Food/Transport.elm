module Data.Food.Transport exposing
    ( Transport
    , getLength
    , inKgKilometers
    , inTonKilometers
    , kilometerToTonKilometer
    , tonKilometers
    )

import Length exposing (Length)
import Mass exposing (Mass)
import Quantity


type alias Transport =
    Quantity.Quantity Float (Quantity.Product Mass.Kilograms Length.Meters)


getLength : Mass -> Transport -> Length
getLength mass transport =
    Quantity.over mass transport


inKgKilometers : Transport -> Float
inKgKilometers transport =
    -- Transport is stored in kg.m, we want it in kg.km
    inTonKilometers transport
        -- 1 km == 1000m
        * 1000


inTonKilometers : Transport -> Float
inTonKilometers (Quantity.Quantity transport) =
    -- Transport is stored in kg.m, we want it in ton.km
    transport
        -- 1 ton == 1000kg
        / 1000
        -- 1km = 1000m
        / 1000


kilometerToTonKilometer : Length -> Mass -> Mass
kilometerToTonKilometer length amount =
    if length == Length.kilometers 0 || amount == Mass.metricTons 0 then
        Mass.metricTons 0

    else
        (Mass.inMetricTons amount / Length.inKilometers length)
            |> Mass.metricTons


tonKilometers : Float -> Transport
tonKilometers amount =
    -- Could equally be written `Quantity.product  (Mass.metricTons 1) (Length.kilometers amount)
    Quantity.product (Mass.metricTons amount) (Length.kilometers 1)
