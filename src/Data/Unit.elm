module Data.Unit exposing
    ( Functional(..)
    , Impact
    , ImpactUnit(..)
    , PickPerMeter(..)
    , Quality(..)
    , Ratio(..)
    , Reparability(..)
    , SurfaceMass(..)
    , decodeImpact
    , encodeImpact
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
    , maxSurfaceMass
    , minPickPerMeter
    , minQuality
    , minReparability
    , minSurfaceMass
    , parseFunctional
    , pickPerMeter
    , pickPerMeterCodec
    , pickPerMeterToFloat
    , pickPerMeterToInt
    , quality
    , qualityCodec
    , qualityToFloat
    , ratio
    , ratioCodec
    , ratioToFloat
    , ratioedForKWh
    , ratioedForKg
    , ratioedForMJ
    , reparability
    , reparabilityCodec
    , reparabilityToFloat
    , standardQuality
    , standardReparability
    , surfaceMass
    , surfaceMassCodec
    , surfaceMassToFloat
    , surfaceMassToInt
    )

import Codec exposing (Codec)
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


ratioCodec : Codec Ratio
ratioCodec =
    Codec.float
        |> Codec.andThen
            (\float ->
                if float < 0 || float > 1 then
                    Codec.fail
                        ("Le ratio spécifié ("
                            ++ String.fromFloat float
                            ++ ") doit être compris entre 0 et 1."
                        )

                else
                    Codec.succeed (ratio float)
            )
            ratioToFloat



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


qualityCodec : Codec Quality
qualityCodec =
    Codec.float
        |> Codec.andThen
            (\float ->
                if float < qualityToFloat minQuality || float > qualityToFloat maxQuality then
                    Codec.fail
                        ("La qualité spécifiée ("
                            ++ String.fromFloat float
                            ++ ") doit être comprise entre "
                            ++ String.fromFloat (qualityToFloat minQuality)
                            ++ " et "
                            ++ String.fromFloat (qualityToFloat maxQuality)
                            ++ "."
                        )

                else
                    Codec.succeed (quality float)
            )
            qualityToFloat



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


reparabilityCodec : Codec Reparability
reparabilityCodec =
    Codec.float
        |> Codec.andThen
            (\float ->
                if float < reparabilityToFloat minReparability || float > reparabilityToFloat maxReparability then
                    Codec.fail
                        ("L'indice de réparabilité spécifié ("
                            ++ String.fromFloat float
                            ++ ") doit être compris entre "
                            ++ String.fromFloat (reparabilityToFloat minReparability)
                            ++ " et "
                            ++ String.fromFloat (reparabilityToFloat maxReparability)
                            ++ "."
                        )

                else
                    Codec.succeed (reparability float)
            )
            reparabilityToFloat



-- Picking (Duitage)


type PickPerMeter
    = PickPerMeter Int


minPickPerMeter : PickPerMeter
minPickPerMeter =
    PickPerMeter 800


maxPickPerMeter : PickPerMeter
maxPickPerMeter =
    PickPerMeter 9000


pickPerMeter : Int -> PickPerMeter
pickPerMeter =
    PickPerMeter


pickPerMeterToFloat : PickPerMeter -> Float
pickPerMeterToFloat (PickPerMeter int) =
    toFloat int


pickPerMeterToInt : PickPerMeter -> Int
pickPerMeterToInt (PickPerMeter int) =
    int


pickPerMeterCodec : Codec PickPerMeter
pickPerMeterCodec =
    Codec.int
        |> Codec.andThen
            (\int ->
                if int < pickPerMeterToInt minPickPerMeter || int > pickPerMeterToInt maxPickPerMeter then
                    Codec.fail
                        ("Le duitage spécifié ("
                            ++ String.fromInt int
                            ++ ") doit être compris entre "
                            ++ String.fromInt (pickPerMeterToInt minPickPerMeter)
                            ++ " et "
                            ++ String.fromInt (pickPerMeterToInt maxPickPerMeter)
                            ++ "."
                        )

                else
                    Codec.succeed (pickPerMeter int)
            )
            pickPerMeterToInt



-- SurfaceMass (Grammage, ou masse surfacique)


type SurfaceMass
    = SurfaceMass Int


minSurfaceMass : SurfaceMass
minSurfaceMass =
    SurfaceMass 30


maxSurfaceMass : SurfaceMass
maxSurfaceMass =
    SurfaceMass 500


surfaceMass : Int -> SurfaceMass
surfaceMass =
    SurfaceMass


surfaceMassToFloat : SurfaceMass -> Float
surfaceMassToFloat (SurfaceMass int) =
    toFloat int


surfaceMassToInt : SurfaceMass -> Int
surfaceMassToInt (SurfaceMass int) =
    int


surfaceMassCodec : Codec SurfaceMass
surfaceMassCodec =
    Codec.int
        |> Codec.andThen
            (\int ->
                if int < surfaceMassToInt minSurfaceMass || int > surfaceMassToInt maxSurfaceMass then
                    Codec.fail
                        ("La masse surfacique spécifiée ("
                            ++ String.fromInt int
                            ++ ") doit être comprise entre "
                            ++ String.fromInt (surfaceMassToInt minSurfaceMass)
                            ++ " et "
                            ++ String.fromInt (surfaceMassToInt maxSurfaceMass)
                            ++ "."
                        )

                else
                    Codec.succeed (surfaceMass int)
            )
            surfaceMassToInt



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
