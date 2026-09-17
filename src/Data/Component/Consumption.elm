module Data.Component.Consumption exposing
    ( Consumption
    , decode
    , decodeAndValidate
    , encode
    , fromProcess
    , validate
    )

import Data.Common.DecodeUtils as DU
import Data.Component.Amount as Amount exposing (Amount)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


{-| A use-stage consumption: a process id and, when the process is not product-mass-dependent,
an amount (validation ensures integrity).
-}
type alias Consumption =
    { amount : Maybe Amount
    , processId : Process.Id
    }


decode : Decoder Consumption
decode =
    Decode.oneOf
        [ -- id only; this must be a product-mass-dependent process
          Process.decodeId |> Decode.map (Consumption Nothing)

        -- the process may be product-mass-dependent, runtime validation will ensure integrity
        , Decode.succeed Consumption
            |> DU.strictOptional "amount" Amount.decode
            |> Pipe.required "processId" Process.decodeId
        ]


{-| Decodes and validates a consumption against a list of processes.
-}
decodeAndValidate : List Process -> Decoder Consumption
decodeAndValidate processes =
    decode |> Decode.andThen (validate processes >> DE.fromResult)


encode : Consumption -> Encode.Value
encode consumption =
    case consumption.amount of
        Just amount ->
            Encode.object
                [ ( "amount", Amount.encode amount )
                , ( "processId", Process.encodeId consumption.processId )
                ]

        Nothing ->
            Process.encodeId consumption.processId


fromProcess : Process -> Consumption
fromProcess process =
    { amount =
        if Process.hasCategory Category.ProductMassDependent process then
            Nothing

        else
            -- By default, always set the amount to 1 unit (eg. 1kg, 1m3, 1L etc)
            Just (Amount.fromFloat 1)
    , processId = process.id
    }


validate : List Process -> Consumption -> Result String Consumption
validate processes consumption =
    case Process.findById consumption.processId processes of
        Err error ->
            Err error

        Ok process ->
            let
                isMassDependent =
                    -- FIXME: move to Process module
                    Process.hasCategory Category.ProductMassDependent process
            in
            case ( consumption.amount, isMassDependent ) of
                ( Just _, True ) ->
                    Err <|
                        "Le procédé "
                            ++ Process.getDisplayName process
                            ++ " est productmassdependent, le champ amount ne doit pas être renseigné"

                ( Just amount, False ) ->
                    Amount.validate amount
                        |> Result.map (\validAmount -> { consumption | amount = Just validAmount })

                ( Nothing, True ) ->
                    Ok consumption

                ( Nothing, False ) ->
                    Err <|
                        "Le procédé "
                            ++ Process.getDisplayName process
                            ++ " n’est pas productmassdependent, le champ amount est obligatoire"
