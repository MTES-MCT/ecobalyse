module Views.Impact exposing (..)

import Data.Impact as Impact exposing (Impact)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { impacts : List Impact
    , selected : Impact
    , switch : Result String Impact -> msg
    }


selector : Config msg -> Html msg
selector { impacts, selected, switch } =
    impacts
        |> List.map
            (\({ trigram, label } as impact) ->
                option
                    [ Attr.selected (selected == impact)
                    , value <| Impact.trigramToString trigram
                    ]
                    [ text label ]
            )
        |> select
            [ class "form-select"
            , onInput
                (Impact.trigramFromString
                    >> (\trigram -> Impact.get trigram impacts)
                    >> switch
                )
            ]
