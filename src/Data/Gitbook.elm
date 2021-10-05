module Data.Gitbook exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias Page =
    { title : String
    , description : String
    , markdown : String
    , path : String
    }


cleanMarkdown : String -> String
cleanMarkdown =
    String.replace "$$" "```"
        >> String.replace "{% hint style=\"danger\" %}" "> "
        >> String.replace "{% hint style=\"warning\" %}" "> "
        >> String.replace "{% hint style=\"info\" %}" "> "
        >> String.replace "{% endhint %}" ""


publicUrl : String -> String
publicUrl path =
    "https://fabrique-numerique.gitbook.io/wikicarbone/" ++ path


decodePage : String -> Decoder Page
decodePage path =
    Decode.map4 Page
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "document" Decode.string)
        (Decode.succeed path)
