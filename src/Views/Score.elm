module Views.Score exposing (view)

import Data.Impact as Impact
import Data.Impact.Definition exposing (Definition)
import Data.ImpactSet as ImpactSet exposing (Impacts)
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass exposing (Mass)
import Views.Format as Format


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
            |> ImpactSet.getImpact impactDefinition.trigram
            |> Impact.toFloat
            |> String.fromFloat
            |> attribute "data-score"
        ]
        [ div [ class "card-body text-center text-nowrap text-white" ]
            [ div [ class "display-3 lh-1" ] [ Format.formatImpact impactDefinition score ]
            , div []
                [ scoreWithoutDurability
                    |> Maybe.map (\s -> span [] [ Format.formatImpact impactDefinition s, text " hors durabilité" ])
                    |> Maybe.withDefault (text "")
                ]
            , small [] [ text "Pour ", Format.kg mass ]
            ]
        , case customInfo of
            Just html ->
                div [ class "card-footer text-white text-center" ]
                    [ html ]

            Nothing ->
                text ""
        ]
