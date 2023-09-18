module Views.Score exposing (view)

import Data.Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition)
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass exposing (Mass)
import Views.Format as Format


type alias Config =
    { impactDefinition : Definition
    , mass : Mass
    , score : Impacts
    }


view : Config -> Html msg
view { impactDefinition, mass, score } =
    div [ class "card bg-secondary shadow-sm" ]
        [ div [ class "card-body text-center text-nowrap text-white display-3 lh-1" ]
            [ Format.formatImpact impactDefinition score ]
        , div [ class "card-footer text-white text-center" ]
            [ text "Pour ", Format.kg mass ]
        ]
