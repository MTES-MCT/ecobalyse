module Data.Textile.Economics exposing
    ( Economics
    , Price
    , computeDurabilityIndex
    , computeMarketingDurationIndex
    , computeNumberOfReferencesIndex
    , computeRepairCostIndex
    , decode
    , decodePrice
    , maxMarketingDuration
    , maxNumberOfReferences
    , maxPrice
    , minMarketingDuration
    , minNumberOfReferences
    , minPrice
    , priceFromFloat
    , priceToFloat
    )

import Data.Unit as Unit
import Duration exposing (Duration)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias Economics =
    { marketingDuration : Duration
    , numberOfReferences : Int
    , price : Price
    , repairCost : Price
    }


{-| Note: We don't want to specify a specific currency (eg. EUR, USD)
so we can keep prices abstract yet consistent.
TODO: move to Unit?
-}
type Price
    = Price Float


computeDurabilityIndex :
    { marketingDuration : Duration
    , numberOfReferences : Int
    , price : Price
    , repairCost : Price
    }
    -- FIXME: actually should be a Unit.Ratio?
    -> Unit.Durability
computeDurabilityIndex { marketingDuration, numberOfReferences, price, repairCost } =
    let
        ( minDurability, maxDurability ) =
            ( Unit.durabilityToFloat Unit.minDurability
            , Unit.durabilityToFloat Unit.maxDurability
            )

        finalIndex =
            [ computeMarketingDurationIndex marketingDuration
            , computeNumberOfReferencesIndex numberOfReferences
            , computeRepairCostIndex price repairCost
            ]
                |> List.map Unit.ratioToFloat
                |> List.sum
                -- FIXME: For now we don't deal with weighting
                |> (\x -> x / 3)
    in
    minDurability
        + finalIndex
        * (maxDurability - minDurability)
        |> clamp minDurability maxDurability
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


computeRepairCostIndex : Price -> Price -> Unit.Ratio
computeRepairCostIndex price repairCost =
    let
        ( highThreshold, lowThreshold ) =
            ( 0.33, 0.5 )

        repairCostRatio =
            priceToFloat repairCost / priceToFloat price
    in
    Unit.ratio <|
        if repairCostRatio < highThreshold then
            1

        else if repairCostRatio > lowThreshold then
            0

        else
            (lowThreshold - repairCostRatio) / (lowThreshold - highThreshold)


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


decode : Decoder Economics
decode =
    Decode.succeed Economics
        |> Pipe.required "marketingDuration" (Decode.map Duration.days Decode.float)
        |> Pipe.required "numberOfReferences" Decode.int
        |> Pipe.required "price" (Decode.map priceFromFloat Decode.float)
        |> Pipe.required "repairCost" (Decode.map priceFromFloat Decode.float)


decodePrice : Decoder Price
decodePrice =
    Decode.map priceFromFloat Decode.float


minMarketingDuration : Duration
minMarketingDuration =
    Duration.days 30


minNumberOfReferences : Int
minNumberOfReferences =
    1


minPrice : Price
minPrice =
    Price 1


maxMarketingDuration : Duration
maxMarketingDuration =
    Duration.days 730


maxNumberOfReferences : Int
maxNumberOfReferences =
    200000


maxPrice : Price
maxPrice =
    Price 1000


priceToFloat : Price -> Float
priceToFloat (Price float) =
    float


priceFromFloat : Float -> Price
priceFromFloat =
    Price
