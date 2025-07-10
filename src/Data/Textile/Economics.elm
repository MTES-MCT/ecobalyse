module Data.Textile.Economics exposing
    ( Business(..)
    , Economics
    , Price
    , businessFromString
    , businessToLabel
    , businessToString
    , computeNonPhysicalDurabilityIndex
    , computeNumberOfReferencesIndex
    , computeRepairCostIndex
    , decode
    , decodeBusiness
    , decodePrice
    , encodeBusiness
    , encodePrice
    , maxNumberOfReferences
    , maxPrice
    , minNumberOfReferences
    , minPrice
    , priceFromFloat
    , priceToFloat
    )

import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type alias Economics =
    { business : Business
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
    = -- Grande entreprise avec service de réparation
      LargeBusinessWithServices
      -- Grande entreprise sans service de réparation
    | LargeBusinessWithoutServices
      -- PME/TPE
    | SmallBusiness


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
            Err <| "Type d'entreprise inconnu : " ++ string


businessToLabel : Business -> String
businessToLabel business =
    case business of
        LargeBusinessWithServices ->
            "Grande entreprise avec service de réparation"

        LargeBusinessWithoutServices ->
            "Grande entreprise sans service de réparation"

        SmallBusiness ->
            "PME/TPE"


businessToString : Business -> String
businessToString business =
    case business of
        LargeBusinessWithServices ->
            "large-business-with-services"

        LargeBusinessWithoutServices ->
            "large-business-without-services"

        SmallBusiness ->
            "small-business"


computeNonPhysicalDurabilityIndex : Economics -> Unit.NonPhysicalDurability
computeNonPhysicalDurabilityIndex economics =
    let
        ( minDurability, maxDurability ) =
            ( Unit.nonPhysicalDurabilityToFloat (Unit.minDurability Unit.NonPhysicalDurability)
            , Unit.nonPhysicalDurabilityToFloat (Unit.maxDurability Unit.NonPhysicalDurability)
            )

        finalIndex =
            [ ( 0.5, computeNumberOfReferencesIndex economics.numberOfReferences )
            , ( 0.5, computeRepairCostIndex economics.business economics.price economics.repairCost )
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
        |> Unit.nonPhysicalDurability


computeRepairCostIndex : Business -> Price -> Price -> Unit.Ratio
computeRepairCostIndex business price repairCost =
    let
        ( highThreshold, lowThreshold ) =
            ( 0.33, 1 )

        repairCostRatio =
            priceToFloat repairCost / priceToFloat price

        repairabilityIndice =
            if repairCostRatio < highThreshold then
                1

            else if repairCostRatio > lowThreshold then
                0

            else
                (priceToFloat price - priceToFloat repairCost / lowThreshold)
                    / (priceToFloat repairCost / highThreshold - priceToFloat repairCost / lowThreshold)
    in
    Unit.ratio <|
        case business of
            LargeBusinessWithServices ->
                repairabilityIndice * 0.67 + 0.33

            LargeBusinessWithoutServices ->
                repairabilityIndice * 0.67

            SmallBusiness ->
                repairabilityIndice


computeNumberOfReferencesIndex : Int -> Unit.Ratio
computeNumberOfReferencesIndex n =
    let
        fromThreshold high low =
            (low - toFloat n) / (low - high)
    in
    Unit.ratio <|
        if n <= 1000 then
            -- From 0 to 1000: 100%
            1

        else if n <= 7000 then
            -- From 1000 to 7000: decreasing from 100% to 50%
            0.5 + (fromThreshold 1000 7000 * (1 - 0.5))

        else if n <= 16000 then
            -- From 7000 to 16000: decreasing from 50% to 0%
            fromThreshold 7000 16000 * 0.5

        else
            -- Over 16000: 0%
            0


decode : Decoder Economics
decode =
    Decode.succeed Economics
        |> Pipe.required "business" decodeBusiness
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


minNumberOfReferences : Int
minNumberOfReferences =
    1


minPrice : Price
minPrice =
    Price 1


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
