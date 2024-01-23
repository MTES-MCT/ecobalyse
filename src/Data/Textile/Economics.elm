module Data.Textile.Economics exposing
    ( Economics
    , Price
    , decode
    , decodePrice
    , priceFromFloat
    , priceToFloat
    )

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
-}
type Price
    = Price Float


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


priceToFloat : Price -> Float
priceToFloat (Price float) =
    float


priceFromFloat : Float -> Price
priceFromFloat =
    Price
