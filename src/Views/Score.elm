module Views.Score exposing (view)

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass exposing (Mass)
import Views.Format as RichFormat


type alias Config msg =
    { customInfo : Maybe (Html msg)
    , impactDefinition : Definition
    , mass : Mass
    , score : Impacts
    , scoreWithoutDurability : Maybe Impacts
    }


view : Config msg -> Html msg
view { customInfo, impactDefinition, mass, score, scoreWithoutDurability } =
    div
        [ class "Score card bg-secondary shadow-sm"
        , attribute "data-testid" "score-card"
        , score
            |> Impact.getImpact impactDefinition.trigram
            |> Unit.impactToFloat
            |> String.fromFloat
            |> attribute "data-score"
        ]
        [ div [ class "card-body text-center text-nowrap text-white" ]
            [ div [ class "display-3 lh-1" ] [ RichFormat.impact impactDefinition score ]
            , div []
                [ scoreWithoutDurability
                    |> Maybe.map (\s -> span [] [ RichFormat.impact impactDefinition s, text " hors durabilité" ])
                    |> Maybe.withDefault (text "")
                ]
            , small [] [ text "Pour ", RichFormat.kilograms mass ]
            ]
        , case customInfo of
            Just html ->
                div [ class "card-footer text-white text-center" ]
                    [ html ]

            Nothing ->
                text ""
        ]
