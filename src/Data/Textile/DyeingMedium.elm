module Data.Textile.DyeingMedium exposing
    ( DyeingMedium(..)
    , decode
    , encode
    , fromString
    , toLabel
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type DyeingMedium
    = Article
    | Fabric
    | Yarn


decode : Decoder DyeingMedium
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : DyeingMedium -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String DyeingMedium
fromString string =
    case string of
        "article" ->
            Ok Article

        "fabric" ->
            Ok Fabric

        "yarn" ->
            Ok Yarn

        _ ->
            Err <| "Type de support de teinture inconnu: " ++ string


toLabel : DyeingMedium -> String
toLabel medium =
    case medium of
        Article ->
            "Article"

        Fabric ->
            "Tissu"

        Yarn ->
            "Fil"


toString : DyeingMedium -> String
toString medium =
    case medium of
        Article ->
            "article"

        Fabric ->
            "fabric"

        Yarn ->
            "yarn"
