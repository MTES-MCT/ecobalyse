module Views.ComplementsDetails exposing (view)

import Data.Impact as Impact
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


type alias Config =
    { complementsImpacts : Impact.ComplementsImpacts
    , label : String
    }


view : Config -> List (Html msg) -> Html msg
view { complementsImpacts, label } detailedImpacts =
    details [ class "ComplementsDetails fs-7" ]
        (summary []
            [ div [ class "ComplementsTable d-flex justify-content-between w-100" ]
                [ span [ title "Cliquez pour plier/déplier" ] [ text label ]
                , span [ class "text-muted text-end", title "Total des compléments" ]
                    [ complementsImpacts
                        |> Impact.getTotalComplementsImpacts
                        |> Format.complement
                    ]
                ]
            ]
            :: detailedImpacts
        )
