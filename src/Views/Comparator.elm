module Views.Comparator exposing (..)

import Data.Co2 exposing (Co2e)
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Inputs as Inputs
import Data.Material as Material
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Alert as Alert
import Views.Button as Button
import Views.Comparator.Chart as Chart
import Views.Format as Format
import Views.Icon as Icon


type alias Config msg =
    { session : Session
    , simulator : Simulator
    , openDocModal : Gitbook.Path -> msg
    }


getScore : Db -> Inputs.Query -> Result String Co2e
getScore db =
    Simulator.compute db >> Result.map .co2


getComparatorData : Db -> Inputs.Query -> Result String ( Co2e, Co2e, Co2e )
getComparatorData db query =
    Result.map3 (\a b c -> ( a, b, c ))
        (getScore db
            { query
                | countries =
                    [ Country.Code "CN"
                    , Country.Code "FR"
                    , Country.Code "FR"
                    , Country.Code "FR"
                    , Country.Code "FR"
                    ]
                , dyeingWeighting = Just 0
                , airTransportRatio = Just 0
            }
        )
        (getScore db
            { query
                | countries =
                    [ Country.Code "CN"
                    , Country.Code "TR"
                    , Country.Code "TR"
                    , Country.Code "TR"
                    , Country.Code "FR"
                    ]
                , dyeingWeighting = Just 0.5
                , airTransportRatio = Just 0
            }
        )
        (getScore db
            { query
                | countries =
                    [ Country.Code "CN"
                    , Country.Code "IN"
                    , Country.Code "IN"
                    , Country.Code "IN"
                    , Country.Code "FR"
                    ]
                , dyeingWeighting = Just 1
                , airTransportRatio = Just 1
            }
        )


view : Config msg -> Html msg
view ({ session, simulator } as config) =
    case simulator.inputs |> Inputs.toQuery |> getComparatorData session.db of
        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = "Erreur"
                , content = [ text error ]
                }

        Ok result ->
            viewComparator config simulator result


viewComparator : Config msg -> Simulator -> ( Co2e, Co2e, Co2e ) -> Html msg
viewComparator config { inputs, co2 } ( good, middle, bad ) =
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ [ "Comparaison pour"
              , inputs.product.name
              , "en"
              , Material.fullName inputs.recycledRatio inputs.material
              , "de "
              ]
                |> String.join " "
                |> text
            , Format.kg inputs.mass
            , Button.smallPill
                [ onClick (config.openDocModal Gitbook.ComparativeScale) ]
                [ Icon.question ]
            ]
        , div [ class "card-body", style "padding" "20px 0 30px 40px" ]
            [ Chart.view co2 ( good, middle, bad )
            ]
        ]
