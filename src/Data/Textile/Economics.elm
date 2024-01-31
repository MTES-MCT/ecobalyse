module Data.Textile.Economics exposing
    ( Business(..)
    , Economics
    , Price
    , businessFromString
    , businessToLabel
    , businessToString
    , computeDurabilityIndex
    , computeMarketingDurationIndex
    , computeMaterialsOriginIndex
    , computeNumberOfReferencesIndex
    , computeRepairCostIndex
    , decode
    , decodeBusiness
    , decodePrice
    , encodeBusiness
    , encodePrice
    , maxMarketingDuration
    , maxNumberOfReferences
    , maxPrice
    , minMarketingDuration
    , minNumberOfReferences
    , minPrice
    , priceFromFloat
    , priceToFloat
    )

import Data.Split as Split
import Data.Textile.Material.Origin as Origin
import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type alias Economics =
    { business : Business
    , marketingDuration : Duration
    , numberOfReferences : Int
    , price : Price
    , repairCost : Price
    , traceability : Bool
    }


{-| Note: We don't want to specify a specific currency (eg. EUR, USD)
so we can keep prices abstract yet consistent.
-}
type Price
    = Price Float


type Business
    = -- PME/TPE
      SmallBusiness
      -- Grande entreprise proposant un service de réparation et de prise en garantie
    | LargeBusinessWithServices
      -- Grande entreprise ne proposant pas de service de réparation ou de prise en garantie
    | LargeBusinessWithoutServices


businessFromString : String -> Result String Business
businessFromString string =
    case string of
        "small-business" ->
            Ok SmallBusiness

        "large-business-with-services" ->
            Ok LargeBusinessWithServices

        "large-business-without-services" ->
            Ok LargeBusinessWithoutServices

        _ ->
            Err <| "Type d'entreprise inconnu: " ++ string


businessToLabel : Business -> String
businessToLabel business =
    case business of
        SmallBusiness ->
            "PME/TPE"

        LargeBusinessWithServices ->
            "Grande entreprise proposant un service de réparation et de garantie"

        LargeBusinessWithoutServices ->
            "Grande entreprise ne proposant pas de service de réparation ou de garantie"


businessToString : Business -> String
businessToString business =
    case business of
        SmallBusiness ->
            "small-business"

        LargeBusinessWithServices ->
            "large-business-with-services"

        LargeBusinessWithoutServices ->
            "large-business-without-services"


computeDurabilityIndex : Origin.Shares -> Economics -> Unit.Durability
computeDurabilityIndex materialsOriginShares economics =
    let
        ( minDurability, maxDurability ) =
            ( Unit.durabilityToFloat Unit.minDurability
            , Unit.durabilityToFloat Unit.maxDurability
            )

        finalIndex =
            [ ( 0.15, computeMaterialsOriginIndex materialsOriginShares |> Tuple.first )
            , ( 0.2, computeMarketingDurationIndex economics.marketingDuration )
            , ( 0.2, computeNumberOfReferencesIndex economics.numberOfReferences )
            , ( 0.3, computeRepairCostIndex economics.business economics.price economics.repairCost )
            , ( 0.15, computeTraceabilityIndex economics.traceability )
            ]
                |> List.map (\( weighting, index ) -> weighting * Unit.ratioToFloat index)
                |> List.sum

        formatIndex =
            -- Rounds at 2 decimals
            (*) 100 >> round >> (\x -> toFloat x / 100)
    in
    minDurability
        + finalIndex
        * (maxDurability - minDurability)
        |> formatIndex
        |> Unit.durability


computeMarketingDurationIndex : Duration -> Unit.Ratio
computeMarketingDurationIndex marketingDuration =
    let
        ( highThreshold, lowThreshold ) =
            ( 180, 60 )

        marketingDurationDays =
            Duration.inDays marketingDuration
    in
    Unit.ratio <|
        if marketingDurationDays > highThreshold then
            1

        else if marketingDurationDays < lowThreshold then
            0

        else
            (marketingDurationDays - lowThreshold) / (highThreshold - lowThreshold)


computeMaterialsOriginIndex : Origin.Shares -> ( Unit.Ratio, String )
computeMaterialsOriginIndex { naturalFromAnimal, naturalFromVegetal } =
    if Split.toPercent naturalFromAnimal > 90 then
        ( Unit.ratio 1, "Matières naturelles d'origine animale" )

    else if Split.toPercent naturalFromVegetal > 90 then
        ( Unit.ratio 0.5, "Matières naturelles d'origine végétale" )

    else
        ( Unit.ratio 0, "" )


computeRepairCostIndex : Business -> Price -> Price -> Unit.Ratio
computeRepairCostIndex business price repairCost =
    let
        ( highThreshold, lowThreshold ) =
            ( 0.33, 0.5 )

        repairCostRatio =
            priceToFloat repairCost / priceToFloat price

        repairabilityIndice =
            if repairCostRatio < highThreshold then
                1

            else if repairCostRatio > lowThreshold then
                0

            else
                (lowThreshold - repairCostRatio) / (lowThreshold - highThreshold)
    in
    Unit.ratio <|
        case business of
            LargeBusinessWithoutServices ->
                (repairabilityIndice * 0.67) + 0.33

            LargeBusinessWithServices ->
                repairabilityIndice * 0.67

            SmallBusiness ->
                repairabilityIndice


computeNumberOfReferencesIndex : Int -> Unit.Ratio
computeNumberOfReferencesIndex numberOfReferences =
    let
        ( highThreshold, lowThreshold ) =
            ( 5000, 20000 )
    in
    Unit.ratio <|
        if numberOfReferences < highThreshold then
            1

        else if numberOfReferences > lowThreshold then
            0

        else
            (lowThreshold - toFloat numberOfReferences) / (lowThreshold - highThreshold)


computeTraceabilityIndex : Bool -> Unit.Ratio
computeTraceabilityIndex traceability =
    Unit.ratio
        (if traceability then
            1

         else
            0
        )


decode : Decoder Economics
decode =
    Decode.succeed Economics
        |> Pipe.required "business" decodeBusiness
        |> Pipe.required "marketingDuration" (Decode.map Duration.days Decode.float)
        |> Pipe.required "numberOfReferences" Decode.int
        |> Pipe.required "price" decodePrice
        |> Pipe.required "repairCost" decodePrice
        |> Pipe.required "traceability" Decode.bool


decodeBusiness : Decoder Business
decodeBusiness =
    Decode.string
        |> Decode.andThen (businessFromString >> DE.fromResult)


decodePrice : Decoder Price
decodePrice =
    Decode.map priceFromFloat Decode.float


encodeBusiness : Business -> Encode.Value
encodeBusiness =
    businessToString >> Encode.string


encodePrice : Price -> Encode.Value
encodePrice =
    priceToFloat >> Encode.float


minMarketingDuration : Duration
minMarketingDuration =
    Duration.day


minNumberOfReferences : Int
minNumberOfReferences =
    1


minPrice : Price
minPrice =
    Price 1


maxMarketingDuration : Duration
maxMarketingDuration =
    Duration.days 999


maxNumberOfReferences : Int
maxNumberOfReferences =
    999999


maxPrice : Price
maxPrice =
    Price 1000


priceToFloat : Price -> Float
priceToFloat (Price float) =
    float


priceFromFloat : Float -> Price
priceFromFloat =
    Price
