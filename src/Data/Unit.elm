module Data.Unit exposing
    ( HolisticDurability
    , Impact
    , ImpactUnit(..)
    , NonPhysicalDurability(..)
    , PhysicalDurability(..)
    , PickPerMeter(..)
    , Ratio(..)
    , SurfaceMass
    , ThreadDensity(..)
    , YarnSize
    , decodeImpact
    , decodePhysicalDurability
    , decodeRatio
    , decodeSurfaceMass
    , decodeYarnSize
    , encodeImpact
    , encodeNonPhysicalDurability
    , encodePhysicalDurability
    , encodePickPerMeter
    , encodeSurfaceMass
    , encodeThreadDensity
    , encodeYarnSize
    , floatDurabilityFromHolistic
    , forKWh
    , forKg
    , forKgAndDistance
    , forMJ
    , gramsPerSquareMeter
    , impact
    , impactAggregateScore
    , impactToFloat
    , maxDurability
    , maxSurfaceMass
    , maxYarnSize
    , minDurability
    , minSurfaceMass
    , minYarnSize
    , noImpacts
    , nonPhysicalDurability
    , nonPhysicalDurabilityToFloat
    , physicalDurability
    , physicalDurabilityToFloat
    , pickPerMeter
    , pickPerMeterToFloat
    , ratio
    , ratioToFloat
    , ratioedForKWh
    , ratioedForKg
    , ratioedForMJ
    , standardDurability
    , surfaceMassInGramsPerSquareMeters
    , surfaceMassToSurface
    , threadDensity
    , threadDensityHigh
    , threadDensityLow
    , threadDensityToFloat
    , threadDensityToInt
    , yarnSizeInGrams
    , yarnSizeInKilometers
    , yarnSizeKilometersPerKg
    )

import Area exposing (Area)
import Data.Split as Split exposing (Split)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..))



-- Ratio


type Ratio
    = Ratio Float


ratio : Float -> Ratio
ratio float =
    Ratio float


ratioToFloat : Ratio -> Float
ratioToFloat (Ratio float) =
    float


decodeRatio : Decoder Ratio
decodeRatio =
    Decode.float
        |> Decode.map ratio



-- Durability


type PhysicalDurability
    = PhysicalDurability Float


type NonPhysicalDurability
    = NonPhysicalDurability Float


type alias HolisticDurability =
    { nonPhysical : NonPhysicalDurability
    , physical : PhysicalDurability
    }


minDurability : (Float -> a) -> a
minDurability dur =
    dur 0.67


standardDurability : (Float -> a) -> a
standardDurability dur =
    dur 1


maxDurability : (Float -> a) -> a
maxDurability dur =
    dur 1.45


physicalDurability : Float -> PhysicalDurability
physicalDurability value =
    PhysicalDurability value


nonPhysicalDurability : Float -> NonPhysicalDurability
nonPhysicalDurability value =
    NonPhysicalDurability value


floatDurabilityFromHolistic : HolisticDurability -> Float
floatDurabilityFromHolistic { nonPhysical, physical } =
    min (physicalDurabilityToFloat physical) (nonPhysicalDurabilityToFloat nonPhysical)


physicalDurabilityToFloat : PhysicalDurability -> Float
physicalDurabilityToFloat (PhysicalDurability float) =
    float


nonPhysicalDurabilityToFloat : NonPhysicalDurability -> Float
nonPhysicalDurabilityToFloat (NonPhysicalDurability float) =
    float


decodePhysicalDurability : Decoder PhysicalDurability
decodePhysicalDurability =
    Decode.float
        |> Decode.map physicalDurability


encodePhysicalDurability : PhysicalDurability -> Encode.Value
encodePhysicalDurability (PhysicalDurability float) =
    Encode.float float


encodeNonPhysicalDurability : NonPhysicalDurability -> Encode.Value
encodeNonPhysicalDurability (NonPhysicalDurability float) =
    Encode.float float



-- Yarn size (Titrage): combien de kilomètres de fil dans 1kg de matière. 50Nm : 50km de fil pèsent 1kg.


type alias YarnSize =
    Quantity Float (Quantity.Rate Length.Meters Mass.Kilograms)


yarnSizeKilometersPerKg : Float -> YarnSize
yarnSizeKilometersPerKg kilometers =
    -- The Nm unit is the length in kilometers of a yarn that weighs 1kg
    Quantity.rate (Length.kilometers kilometers) Mass.kilogram


minYarnSize : YarnSize
minYarnSize =
    yarnSizeKilometersPerKg 9


maxYarnSize : YarnSize
maxYarnSize =
    yarnSizeKilometersPerKg 200


yarnSizeInKilometers : YarnSize -> Float
yarnSizeInKilometers yarnSize =
    -- Used to display the value using the Nm unit
    Quantity.at yarnSize Mass.kilogram
        |> Length.inKilometers


yarnSizeInGrams : YarnSize -> Float
yarnSizeInGrams yarnSize =
    -- Used to display the value using the Dtex unit
    Quantity.at_ yarnSize (Length.meters 10000)
        |> Mass.inGrams


encodeYarnSize : YarnSize -> Encode.Value
encodeYarnSize =
    yarnSizeInKilometers >> Encode.float


decodeYarnSize : Decoder YarnSize
decodeYarnSize =
    Decode.float
        |> Decode.andThen
            (\float ->
                let
                    yarnSize =
                        yarnSizeKilometersPerKg float
                in
                if (yarnSize |> Quantity.lessThan minYarnSize) || (yarnSize |> Quantity.greaterThan maxYarnSize) then
                    Decode.fail
                        ("Le titrage spécifié ("
                            ++ String.fromFloat float
                            ++ ") doit être compris entre "
                            ++ String.fromFloat (yarnSizeInKilometers minYarnSize)
                            ++ " et "
                            ++ String.fromFloat (yarnSizeInKilometers maxYarnSize)
                            ++ "."
                        )

                else
                    Decode.succeed float
            )
        |> Decode.map yarnSizeKilometersPerKg



-- Thread density (Densité de fils)


type ThreadDensity
    = ThreadDensity Float


encodeThreadDensity : ThreadDensity -> Encode.Value
encodeThreadDensity (ThreadDensity float) =
    Encode.float float


threadDensity : Float -> ThreadDensity
threadDensity =
    ThreadDensity


threadDensityLow : ThreadDensity
threadDensityLow =
    threadDensity 10


threadDensityHigh : ThreadDensity
threadDensityHigh =
    threadDensity 80


threadDensityToInt : ThreadDensity -> Int
threadDensityToInt (ThreadDensity float) =
    round float


threadDensityToFloat : ThreadDensity -> Float
threadDensityToFloat (ThreadDensity float) =
    float



-- Picking (Duitage)


type PickPerMeter
    = PickPerMeter Int


pickPerMeter : Int -> PickPerMeter
pickPerMeter =
    PickPerMeter


pickPerMeterToFloat : PickPerMeter -> Float
pickPerMeterToFloat (PickPerMeter int) =
    toFloat int


encodePickPerMeter : PickPerMeter -> Encode.Value
encodePickPerMeter (PickPerMeter int) =
    Encode.int int



-- SurfaceMass (Grammage, ou masse surfacique)


type alias SurfaceMass =
    Quantity Float (Quantity.Rate Mass.Kilograms Area.SquareMeters)


gramsPerSquareMeter : Int -> SurfaceMass
gramsPerSquareMeter int =
    Quantity.rate (Mass.grams (toFloat int)) Area.squareMeter


surfaceMassInGramsPerSquareMeters : SurfaceMass -> Int
surfaceMassInGramsPerSquareMeters surfaceMass =
    Quantity.at surfaceMass Area.squareMeter
        |> Mass.inGrams
        |> round


surfaceMassToSurface : SurfaceMass -> Mass -> Area
surfaceMassToSurface surfaceMass mass =
    -- Given a g/m2 and an input mass, return the area in m2
    Quantity.at_ surfaceMass mass


minSurfaceMass : SurfaceMass
minSurfaceMass =
    gramsPerSquareMeter 80


maxSurfaceMass : SurfaceMass
maxSurfaceMass =
    gramsPerSquareMeter 500


decodeSurfaceMass : Decoder SurfaceMass
decodeSurfaceMass =
    Decode.int
        |> Decode.map gramsPerSquareMeter


encodeSurfaceMass : SurfaceMass -> Encode.Value
encodeSurfaceMass surfaceMass =
    Encode.int (surfaceMassInGramsPerSquareMeters surfaceMass)



-- Abstract Impact


type ImpactUnit
    = ImpactUnit Never


type alias Impact =
    Quantity Float ImpactUnit


impact : Float -> Impact
impact value =
    Quantity value


noImpacts : Impact
noImpacts =
    impact 0


impactToFloat : Impact -> Float
impactToFloat (Quantity value) =
    value


impactAggregateScore : Impact -> Split -> Impact -> Impact
impactAggregateScore normalization weighting =
    Quantity.divideBy (impactToFloat normalization)
        >> Quantity.multiplyBy (Split.toFloat weighting)
        -- Raw aggregate scores like PEF are expressed in Pt (points); we want Pts (micropoints)
        >> Quantity.multiplyBy 1000000


decodeImpact : Decoder Impact
decodeImpact =
    Decode.map impact Decode.float


encodeImpact : Impact -> Encode.Value
encodeImpact =
    impactToFloat >> Encode.float



-- Generic helpers


forKg : Quantity Float unit -> Mass -> Quantity Float unit
forKg forOneKg =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    forOneKg
        |> Quantity.per Mass.kilogram
        |> Quantity.at


forKgAndDistance : Quantity Float unit -> Length -> Mass -> Quantity Float unit
forKgAndDistance cc distance mass =
    -- Note: unit rate is for transported tons per km.
    mass
        |> Quantity.divideBy 1000
        |> forKg cc
        |> Quantity.multiplyBy (Length.inKilometers distance)


forKWh : Quantity Float unit -> Energy -> Quantity Float unit
forKWh forOneKWh =
    forOneKWh
        |> Quantity.per (Energy.kilowattHours 1)
        |> Quantity.at


forMJ : Quantity Float unit -> Energy -> Quantity Float unit
forMJ forOneMJ =
    forOneMJ
        |> Quantity.per (Energy.megajoules 1)
        |> Quantity.at


ratioed :
    (Quantity Float unit -> a -> Quantity Float unit)
    -> ( Quantity Float unit, Quantity Float unit )
    -> Ratio
    -> a
    -> Quantity Float unit
ratioed for ( a, b ) (Ratio ratio_) input =
    Quantity.sum
        [ input |> for a |> Quantity.multiplyBy ratio_
        , input |> for b |> Quantity.multiplyBy (1 - ratio_)
        ]


ratioedForKg : ( Quantity Float unit, Quantity Float unit ) -> Ratio -> Mass -> Quantity Float unit
ratioedForKg =
    ratioed forKg


ratioedForKWh : ( Quantity Float unit, Quantity Float unit ) -> Ratio -> Energy -> Quantity Float unit
ratioedForKWh =
    ratioed forKWh


ratioedForMJ : ( Quantity Float unit, Quantity Float unit ) -> Ratio -> Energy -> Quantity Float unit
ratioedForMJ =
    ratioed forMJ
