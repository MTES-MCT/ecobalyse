module Data.Textile.Economics exposing
    ( Business(..)
    , Economics
    , Price
    , businessFromString
    , businessToLabel
    , businessToString
    , computeDurabilityIndex
    , computeMarketingDurationIndex
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
            "Grande entreprise proposant un service de réparation et de prise en garantie"

        LargeBusinessWithoutServices ->
            "Grande entreprise ne proposant pas de service de réparation ou de prise en garantie"


businessToString : Business -> String
businessToString business =
    case business of
        SmallBusiness ->
            "small-business"

        LargeBusinessWithServices ->
            "large-business-with-services"

        LargeBusinessWithoutServices ->
            "large-business-without-services"


computeDurabilityIndex :
    { business : Business
    , marketingDuration : Duration
    , numberOfReferences : Int
    , price : Price
    , repairCost : Price
    }
    -> Unit.Durability
computeDurabilityIndex { business, marketingDuration, numberOfReferences, price, repairCost } =
    let
        ( minDurability, maxDurability ) =
            ( Unit.durabilityToFloat Unit.minDurability
            , Unit.durabilityToFloat Unit.maxDurability
            )

        finalIndex =
            [ computeMarketingDurationIndex marketingDuration
            , computeNumberOfReferencesIndex numberOfReferences
            , computeRepairCostIndex business price repairCost
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
                repairabilityIndice * 0.67

            _ ->
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


decode : Decoder Economics
decode =
    Decode.succeed Economics
        |> Pipe.required "business" decodeBusiness
        |> Pipe.required "marketingDuration" (Decode.map Duration.days Decode.float)
        |> Pipe.required "numberOfReferences" Decode.int
        |> Pipe.required "price" decodePrice
        |> Pipe.required "repairCost" decodePrice


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
