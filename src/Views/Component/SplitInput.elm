module Views.Component.SplitInput exposing (view)

import Data.Split as Split exposing (Split)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { disabled : Bool
    , share : Split
    , onChange : Maybe Split -> msg
    }


view : Config msg -> Html msg
view { disabled, share, onChange } =
    div [ class "input-group input-group" ]
        [ input
            [ class "form-control text-end incdec-arrows-left"
            , type_ "number"
            , step "1"
            , share
                |> Split.toPercent
                |> String.fromInt
                |> value
            , title "Quantité en pourcents"
            , onInput <|
                \str ->
                    onChange
                        (if str == "" then
                            Nothing

                         else
                            str
                                |> String.toInt
                                |> Maybe.andThen (Split.fromPercent >> Result.toMaybe)
                        )
            , Attr.min "0"
            , Attr.disabled disabled
            ]
            []
        , span [ class "input-group-text", title "pourcents" ]
            [ text "%"
            ]
        ]
