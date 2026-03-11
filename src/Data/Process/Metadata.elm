module Data.Process.Metadata exposing (Metadata, decode, encode)

import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type alias Metadata =
    { complements : Maybe ComplementData
    , forestManagement : Maybe ForestManagement
    }


type alias ComplementData =
    { forest : Maybe Unit.Impact
    }


type ForestManagement
    = CertifiedDiversifiedForest
    | CertifiedSustainableManagement
    | DiversifiedForest
    | IntensivePlantation
    | SustainableManagement


forestManagementFromString : String -> Result String ForestManagement
forestManagementFromString string =
    case string of
        "certifiedDiversifiedForest" ->
            Ok CertifiedDiversifiedForest

        "certifiedSustainableManagement" ->
            Ok CertifiedSustainableManagement

        "diversifiedForest" ->
            Ok DiversifiedForest

        "intensivePlantation" ->
            Ok IntensivePlantation

        "sustainableManagement" ->
            Ok SustainableManagement

        _ ->
            Err ("Invalid or non-supported forest management value: " ++ string)


forestManagementToString : ForestManagement -> String
forestManagementToString forestManagement =
    case forestManagement of
        CertifiedDiversifiedForest ->
            "certifiedDiversifiedForest"

        CertifiedSustainableManagement ->
            "certifiedSustainableManagement"

        DiversifiedForest ->
            "diversifiedForest"

        IntensivePlantation ->
            "intensivePlantation"

        SustainableManagement ->
            "sustainableManagement"


decodeComplementData : Decoder ComplementData
decodeComplementData =
    Decode.succeed ComplementData
        |> DU.strictOptional "forest" Unit.decodeImpact


decodeForestManagement : Decoder ForestManagement
decodeForestManagement =
    Decode.string |> Decode.andThen (DE.fromResult << forestManagementFromString)


decode : Decoder Metadata
decode =
    Decode.succeed Metadata
        |> DU.strictOptional "complements" decodeComplementData
        |> DU.strictOptional "forestManagement" decodeForestManagement


encodeComplementData : ComplementData -> Encode.Value
encodeComplementData complementData =
    EU.optionalPropertiesObject
        [ ( "forest"
          , complementData.forest
                |> Maybe.map Unit.encodeImpact
          )
        ]


encode : Metadata -> Encode.Value
encode metadata =
    EU.optionalPropertiesObject
        [ ( "complements", metadata.complements |> Maybe.map encodeComplementData )
        , ( "forestManagement"
          , metadata.forestManagement
                |> Maybe.map forestManagementToString
                |> Maybe.map Encode.string
          )
        ]
