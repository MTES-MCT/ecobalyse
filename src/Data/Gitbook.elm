module Data.Gitbook exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias Page =
    { title : String
    , description : String
    , markdown : String
    }


cleanMarkdown : String -> String
cleanMarkdown =
    String.replace "$$" "```"
        >> String.replace "{% hint style=\"danger\" %}" "> "
        >> String.replace "{% hint style=\"warning\" %}" "> "
        >> String.replace "{% hint style=\"info\" %}" "> "
        >> String.replace "{% endhint %}" ""


decodePage : Decoder Page
decodePage =
    Decode.map3 Page
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "document" Decode.string)
