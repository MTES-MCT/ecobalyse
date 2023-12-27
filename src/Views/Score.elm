module Views.Score exposing (view)

import Data.Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition)
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass exposing (Mass)
import Views.Format as Format


type alias Config msg =
    { impactDefinition : Definition
    , customInfo : Maybe (Html msg)
    , mass : Mass
    , score : Impacts
    }


view : Config msg -> Html msg
view { customInfo, impactDefinition, mass, score } =
    div [ class "card bg-secondary shadow-sm" ]
        [ div [ class "card-body text-center text-nowrap text-white" ]
            [ div [ class "display-3 lh-1" ] [ Format.formatImpact impactDefinition score ]
            , small [] [ text "Pour ", Format.kg mass ]
            ]
        , case customInfo of
            Just html ->
                div [ class "card-footer text-white text-center" ]
                    [ html ]

            Nothing ->
                text ""
        ]
