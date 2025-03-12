module Views.Component.MassInput exposing
    ( grams
    , kilograms
    )

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass exposing (Mass)


type alias Config msg =
    { attrs : List (Attribute msg)
    , disabled : Bool
    , mass : Mass
    , onChange : Maybe Mass -> msg
    }


type Unit
    = Gram
    | Kilogram


view : Unit -> Config msg -> Html msg
view unit { attrs, disabled, mass, onChange } =
    let
        baseAttrs =
            [ class "form-control text-end incdec-arrows-left"
            , type_ "number"
            , step "1"
            , mass
                |> (case unit of
                        Gram ->
                            Mass.inGrams

                        Kilogram ->
                            Mass.inKilograms
                   )
                |> String.fromFloat
                |> value
            , title <|
                "Quantité en "
                    ++ (case unit of
                            Gram ->
                                "grammes"

                            Kilogram ->
                                "kilogrammes"
                       )
            , onInput <|
                \str ->
                    onChange
                        (if str == "" then
                            Nothing

                         else
                            str
                                |> String.toFloat
                                |> Maybe.map
                                    (case unit of
                                        Gram ->
                                            Mass.grams

                                        Kilogram ->
                                            Mass.kilograms
                                    )
                        )
            , Attr.min "0"
            , Attr.step
                (case unit of
                    Gram ->
                        "1"

                    Kilogram ->
                        "0.01"
                )
            , Attr.disabled disabled
            ]
    in
    div [ class "input-group" ]
        [ input (baseAttrs ++ attrs) []
        , small [ class "input-group-text fs-8", title "grammes" ]
            [ text <|
                case unit of
                    Gram ->
                        "g"

                    Kilogram ->
                        "kg"
            ]
        ]


grams : Config msg -> Html msg
grams =
    view Gram


kilograms : Config msg -> Html msg
kilograms =
    view Kilogram
