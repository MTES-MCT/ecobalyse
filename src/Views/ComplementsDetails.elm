module Views.ComplementsDetails exposing (view)

import Data.Impact as Impact
import Data.Impact.Definition exposing (Definition)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Quantity
import Views.Format as Format


type alias Config =
    { complementsImpacts : Impact.ComplementsImpacts
    , selectedImpact : Definition
    }


view : Config -> List (Html msg) -> Html msg
view { complementsImpacts, selectedImpact } html =
    details [ class "ComplementsDetails fs-7" ]
        (summary []
            [ div [ class "ComplementsTable d-flex justify-content-between w-100" ]
                [ span [ title "Cliquez pour plier/déplier" ] [ text "Compléments" ]
                , span [ class "text-success text-end", title "Total des compléments" ]
                    [ Impact.getTotalComplementsImpacts complementsImpacts
                        |> Quantity.negate
                        |> Unit.impactToFloat
                        |> Format.formatImpactFloat selectedImpact
                    ]
                ]
            ]
            :: html
        )
