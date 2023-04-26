module Data.Unit exposing
    ( Functional(..)
    , Impact
    , ImpactUnit(..)
    , PickPerMeter(..)
    , Quality(..)
    , Ratio(..)
    , Reparability(..)
    , SurfaceMass
    , ThreadDensity(..)
    , YarnSize
    , decodeImpact
    , decodeQuality
    , decodeRatio
    , decodeReparability
    , decodeSurfaceMass
    , decodeYarnSize
    , encodeImpact
    , encodePickPerMeter
    , encodeQuality
    , encodeReparability
    , encodeSurfaceMass
    , encodeThreadDensity
    , encodeYarnSize
    , forKWh
    , forKg
    , forKgAndDistance
    , forMJ
    , functionalToSlug
    , functionalToString
    , gramsPerSquareMeter
    , impact
    , impactAggregateScore
    , impactToFloat
    , inFunctionalUnit
    , maxQuality
    , maxReparability
    , maxSurfaceMass
    , maxYarnSize
    , minQuality
    , minReparability
    , minSurfaceMass
    , minYarnSize
    , parseFunctional
    , pickPerMeter
    , pickPerMeterToFloat
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
    , surfaceMassInGramsPerSquareMeters
    , surfaceMassToSurface
    , threadDensity
    , threadDensityHigh
    , threadDensityLow
    , threadDensityToFloat
    , threadDensityToInt
    , yarnSizeInKilometers
    , yarnSizeKilometersPerKg
    )

import Area exposing (Area)
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


decodeRatio : { percentage : Bool } -> Decoder Ratio
decodeRatio { percentage } =
    Decode.float
        |> Decode.andThen
            (\float ->
                if percentage && (float < 0 || float > 1) then
                    Decode.fail
                        ("Le ratio spécifié ("
                            ++ String.fromFloat float
                            ++ ") doit être compris entre 0 et 1."
                        )

                else
                    Decode.succeed float
            )
        |> Decode.map ratio



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
    Decode.float
        |> Decode.andThen
            (\float ->
                if float < qualityToFloat minQuality || float > qualityToFloat maxQuality then
                    Decode.fail
                        ("La qualité spécifiée ("
                            ++ String.fromFloat float
                            ++ ") doit être comprise entre "
                            ++ String.fromFloat (qualityToFloat minQuality)
                            ++ " et "
                            ++ String.fromFloat (qualityToFloat maxQuality)
                            ++ "."
                        )

                else
                    Decode.succeed float
            )
        |> Decode.map quality


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
    Decode.float
        |> Decode.andThen
            (\float ->
                if float < reparabilityToFloat minReparability || float > reparabilityToFloat maxReparability then
                    Decode.fail
                        ("L'indice de réparabilité spécifié ("
                            ++ String.fromFloat float
                            ++ ") doit être compris entre "
                            ++ String.fromFloat (reparabilityToFloat minReparability)
                            ++ " et "
                            ++ String.fromFloat (reparabilityToFloat maxReparability)
                            ++ "."
                        )

                else
                    Decode.succeed float
            )
        |> Decode.map reparability


encodeReparability : Reparability -> Encode.Value
encodeReparability (Reparability float) =
    Encode.float float



-- Yarn size (Titrage): combien de kilomètres de fil dans 1kg de matière. 50Nm : 50km de fil pèsent 1kg.


type alias YarnSize =
    Quantity Float (Quantity.Rate Length.Meters Mass.Kilograms)


yarnSizeKilometersPerKg : Int -> YarnSize
yarnSizeKilometersPerKg kilometers =
    Quantity.rate (Length.kilometers (toFloat kilometers)) Mass.kilogram


minYarnSize : YarnSize
minYarnSize =
    yarnSizeKilometersPerKg 9


maxYarnSize : YarnSize
maxYarnSize =
    yarnSizeKilometersPerKg 200


yarnSizeInKilometers : YarnSize -> Int
yarnSizeInKilometers yarnSize =
    Quantity.at yarnSize Mass.kilogram
        |> Length.inKilometers
        |> round


encodeYarnSize : YarnSize -> Encode.Value
encodeYarnSize yarnSize =
    yarnSize
        |> yarnSizeInKilometers
        |> Encode.int


decodeYarnSize : Decoder YarnSize
decodeYarnSize =
    Decode.int
        |> Decode.andThen
            (\int ->
                let
                    yarnSize =
                        yarnSizeKilometersPerKg int
                in
                if (yarnSize |> Quantity.lessThan minYarnSize) || (yarnSize |> Quantity.greaterThan maxYarnSize) then
                    Decode.fail
                        ("Le titrage spécifié ("
                            ++ String.fromInt int
                            ++ ") doit être compris entre "
                            ++ String.fromInt (yarnSizeInKilometers minYarnSize)
                            ++ " et "
                            ++ String.fromInt (yarnSizeInKilometers maxYarnSize)
                            ++ "."
                        )

                else
                    Decode.succeed int
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
        |> Decode.andThen
            (\int ->
                let
                    surfaceMass =
                        gramsPerSquareMeter int
                in
                if (surfaceMass |> Quantity.lessThan minSurfaceMass) || (surfaceMass |> Quantity.greaterThan maxSurfaceMass) then
                    Decode.fail
                        ("La masse surfacique spécifiée ("
                            ++ String.fromInt int
                            ++ ") doit être comprise entre "
                            ++ String.fromInt (surfaceMassInGramsPerSquareMeters minSurfaceMass)
                            ++ " et "
                            ++ String.fromInt (surfaceMassInGramsPerSquareMeters maxSurfaceMass)
                            ++ "."
                        )

                else
                    Decode.succeed int
            )
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


impactToFloat : Impact -> Float
impactToFloat (Quantity value) =
    value


impactAggregateScore : Impact -> Ratio -> Impact -> Impact
impactAggregateScore normalization weighting =
    Quantity.divideBy (impactToFloat normalization)
        >> Quantity.multiplyBy (ratioToFloat weighting)
        -- Raw aggregate scores like PEF are expressed in Pt (points); we want µPt (micropoints)
        >> Quantity.multiplyBy 1000000


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
