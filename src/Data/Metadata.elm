module Data.Metadata exposing (Metadata, decode, encode)

import Data.Common.DecodeUtils as DU
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra


type alias Metadata =
    { complements : Maybe ComplementData
    , forestManagement : Maybe ForestManagement
    }


type alias ComplementData =
    { forest : Maybe Float
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
        |> DU.strictOptional "forest" Decode.float


decode : Decoder Metadata
decode =
    Decode.succeed Metadata
        |> DU.strictOptional "complements" decodeComplementData
        |> DU.strictOptional "forestManagement" (Decode.string |> Decode.andThen (DE.fromResult << forestManagementFromString))


encodeComplementData : ComplementData -> Encode.Value
encodeComplementData complementData =
    Encode.object
        [ ( "forest", EncodeExtra.maybe Encode.float complementData.forest )
        ]


encode : Metadata -> Encode.Value
encode metadata =
    Encode.object
        [ ( "complements", EncodeExtra.maybe encodeComplementData metadata.complements )
        , ( "forestManagement", EncodeExtra.maybe Encode.string (Maybe.map forestManagementToString metadata.forestManagement) )
        ]
