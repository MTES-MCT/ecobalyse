
module Generate exposing (main)

{-| -}

import Elm
import Elm.Annotation as Type
import Gen.CodeGen.Generate as Generate
import Json.Decode


main : Program Json.Decode.Value () ()
main =
    Generate.run
        [ impactDefinitions
        ]



impactDefinitions : Elm.File
impactDefinitions =
    Elm.file [ "Data", "Impact", "Definition" ]
        [ Elm.declaration "hello"
            (Elm.string "World!")
        ]
