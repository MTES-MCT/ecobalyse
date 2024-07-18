module Data.Textile.Economics exposing
    ( Business(..)
    , Economics
    , Price
    , businessFromString
    , businessToLabel
    , businessToString
    , computeDurabilityIndex
    , computeMaterialsOriginIndex
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

import Data.Split as Split
import Data.Textile.Material.Origin as Origin
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
      -- Grande entreprise proposant un service de réparation et de garantie
    | LargeBusinessWithServices
      -- Grande entreprise ne proposant pas de service de réparation ou de garantie
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


computeMaterialsOriginIndex : Origin.Shares -> ( Unit.Ratio, String )
computeMaterialsOriginIndex { naturalFromAnimal, naturalFromVegetal } =
    if Split.toPercent naturalFromAnimal + Split.toPercent naturalFromVegetal > 90 then
        if Split.toPercent naturalFromAnimal > 90 then
            ( Unit.ratio 1, "Matières naturelles d'origine animale" )

        else
            ( Unit.ratio 0.5, "Matières naturelles" )

    else
        ( Unit.ratio 0, "Autres matières" )


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

            LargeBusinessWithServices ->
                repairabilityIndice * 0.67 + 0.33

            SmallBusiness ->
                repairabilityIndice


computeNumberOfReferencesIndex : Int -> Unit.Ratio
computeNumberOfReferencesIndex n =
    let
        fromThreshold high low =
            (low - toFloat n) / (low - high)
    in
    Unit.ratio <|
        if n > 12000 then
            -- Over 12000: 0%
            0

        else if n > 9000 then
            -- From 9000 to 12000: decreasing from 25% to 0%
            fromThreshold 9000 12000 * 0.25

        else if n > 6000 then
            -- From 6000 to 9000: decreasing from 80% to 25%
            0.25 + (fromThreshold 6000 9000 * (0.8 - 0.25))

        else if n > 3000 then
            -- From 3000 to 6000: decreasing from 100% to 80%
            0.8 + (fromThreshold 3000 6000 * 0.2)

        else
            -- From 0 to 3000: 100%
            1


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
