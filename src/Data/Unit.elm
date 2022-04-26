module Data.Unit exposing
    ( Functional(..)
    , Impact
    , ImpactUnit(..)
    , PickPerMeter(..)
    , Quality(..)
    , Ratio(..)
    , Reparability(..)
    , SurfaceDensity(..)
    , decodeImpact
    , decodePickPerMeter
    , decodeQuality
    , decodeRatio
    , decodeReparability
    , decodeSurfaceDensity
    , encodeImpact
    , encodePickPerMeter
    , encodeQuality
    , encodeRatio
    , encodeReparability
    , encodeSurfaceDensity
    , forKWh
    , forKg
    , forKgAndDistance
    , forMJ
    , functionalToSlug
    , functionalToString
    , impact
    , impactPefScore
    , impactToFloat
    , inFunctionalUnit
    , maxPickPerMeter
    , maxQuality
    , maxReparability
    , maxSurfaceDensity
    , minPickPerMeter
    , minQuality
    , minReparability
    , minSurfaceDensity
    , parseFunctional
    , pickPerMeter
    , pickPerMeterToFloat
    , pickPerMeterToInt
    , quality
    , qualityToFloat
    , ratio
    , ratioToFloat
    , ratioedForKWh
    , ratioedForKg
    , ratioedForMJ
    , reparability
    , reparabilityToFloat
    , standardQuality
    , standardReparability
    , surfaceDensity
    , surfaceDensityToFloat
    , surfaceDensityToInt
    )

import Duration exposing (Duration)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..))
import Url.Parser as Parser exposing (Parser)



-- Functional unit


type Functional
    = PerDayOfWear
    | PerItem


functionalToString : Functional -> String
functionalToString funit =
    case funit of
        PerDayOfWear ->
            "par jour d'utilisation"

        PerItem ->
            "par vêtement"


functionalToSlug : Functional -> String
functionalToSlug funit =
    case funit of
        PerDayOfWear ->
            "per-day"

        PerItem ->
            "per-item"


parseFunctional : Parser (Functional -> a) a
parseFunctional =
    Parser.custom "FUNCTIONAL_UNIT" <|
        \string ->
            case string of
                "per-day" ->
                    Just PerDayOfWear

                _ ->
                    Just PerItem



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
    Decode.map ratio Decode.float


encodeRatio : Ratio -> Encode.Value
encodeRatio (Ratio float) =
    Encode.float float



-- Quality


type Quality
    = Quality Float


minQuality : Quality
minQuality =
    Quality 0.67


standardQuality : Quality
standardQuality =
    Quality 1


maxQuality : Quality
maxQuality =
    Quality 1.45


quality : Float -> Quality
quality =
    Quality


qualityToFloat : Quality -> Float
qualityToFloat (Quality float) =
    float


decodeQuality : Decoder Quality
decodeQuality =
    Decode.map quality Decode.float


encodeQuality : Quality -> Encode.Value
encodeQuality (Quality float) =
    Encode.float float



-- Reparability


type Reparability
    = Reparability Float


minReparability : Reparability
minReparability =
    Reparability 1


standardReparability : Reparability
standardReparability =
    minReparability


maxReparability : Reparability
maxReparability =
    Reparability 1.15


reparability : Float -> Reparability
reparability =
    Reparability


reparabilityToFloat : Reparability -> Float
reparabilityToFloat (Reparability float) =
    float


decodeReparability : Decoder Reparability
decodeReparability =
    Decode.map reparability Decode.float


encodeReparability : Reparability -> Encode.Value
encodeReparability (Reparability float) =
    Encode.float float



-- Picking


type PickPerMeter
    = PickPerMeter Int


minPickPerMeter : PickPerMeter
minPickPerMeter =
    PickPerMeter 1000


maxPickPerMeter : PickPerMeter
maxPickPerMeter =
    PickPerMeter 5000


pickPerMeter : Int -> PickPerMeter
pickPerMeter =
    PickPerMeter


pickPerMeterToFloat : PickPerMeter -> Float
pickPerMeterToFloat (PickPerMeter int) =
    toFloat int


pickPerMeterToInt : PickPerMeter -> Int
pickPerMeterToInt (PickPerMeter int) =
    int


decodePickPerMeter : Decoder PickPerMeter
decodePickPerMeter =
    Decode.map pickPerMeter Decode.int


encodePickPerMeter : PickPerMeter -> Encode.Value
encodePickPerMeter (PickPerMeter int) =
    Encode.int int



-- SurfaceDensity


type SurfaceDensity
    = SurfaceDensity Int


minSurfaceDensity : SurfaceDensity
minSurfaceDensity =
    SurfaceDensity 1000


maxSurfaceDensity : SurfaceDensity
maxSurfaceDensity =
    SurfaceDensity 5000


surfaceDensity : Int -> SurfaceDensity
surfaceDensity =
    SurfaceDensity


surfaceDensityToFloat : SurfaceDensity -> Float
surfaceDensityToFloat (SurfaceDensity int) =
    toFloat int


surfaceDensityToInt : SurfaceDensity -> Int
surfaceDensityToInt (SurfaceDensity int) =
    int


decodeSurfaceDensity : Decoder SurfaceDensity
decodeSurfaceDensity =
    Decode.map surfaceDensity Decode.int


encodeSurfaceDensity : SurfaceDensity -> Encode.Value
encodeSurfaceDensity (SurfaceDensity int) =
    Encode.int int



-- Abstract Impact


type ImpactUnit
    = ImpactUnit Never


type alias Impact =
    Quantity Float ImpactUnit


impact : Float -> Impact
impact value =
    Quantity value


impactToFloat : Impact -> Float
impactToFloat (Quantity value) =
    value


impactPefScore : Impact -> Ratio -> Impact -> Impact
impactPefScore normalization weighting =
    Quantity.divideBy (impactToFloat normalization)
        >> Quantity.multiplyBy (ratioToFloat weighting)
        -- Raw PEF scores are expressed in Pt (points), we want mPt (millipoints)
        >> Quantity.multiplyBy 1000


decodeImpact : Decoder Impact
decodeImpact =
    Decode.float
        |> Decode.andThen (impact >> Decode.succeed)


encodeImpact : Impact -> Encode.Value
encodeImpact =
    impactToFloat >> Encode.float


inFunctionalUnit : Functional -> Duration -> Impact -> Impact
inFunctionalUnit funit daysOfWear =
    case funit of
        PerItem ->
            identity

        PerDayOfWear ->
            Quantity.divideBy (Duration.inDays daysOfWear)



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
