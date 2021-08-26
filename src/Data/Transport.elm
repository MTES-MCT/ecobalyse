module Data.Transport exposing (..)

import Data.Country as Country exposing (..)
import Dict exposing (Dict)


type alias Info =
    ( Int, Int )


type alias Km =
    Int


type alias Ratio =
    Int


type alias Transport =
    { road : ( Km, Ratio ) --terre
    , air : ( Km, Ratio ) --air
    , sea : ( Km, Ratio ) --mer
    }


default : Transport
default =
    Transport ( 0, 0 ) ( 0, 0 ) ( 0, 0 )


toDict : List ( Country, a ) -> Dict String a
toDict =
    List.map (Tuple.mapFirst Country.toString) >> Dict.fromList


defaultInlandRoad : Int
defaultInlandRoad =
    500


distances : Dict String (Dict String Transport)
distances =
    toDict
        [ ( Turkey
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 16243, 100 ), air = ( 7100, 33 ) } )
                , ( France, { road = ( 2798, 90 ), sea = ( 6226, 10 ), air = ( 2200, 33 ) } )
                , ( Germany, { road = ( 3052, 90 ), sea = ( 6826, 10 ), air = ( 1800, 33 ) } )
                , ( Greece, { road = ( 1158, 90 ), sea = ( 1297, 10 ), air = ( 600, 33 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 6655, 100 ), air = ( 4600, 33 ) } )
                , ( Italy, { road = ( 1940, 90 ), sea = ( 2387, 10 ), air = ( 1400, 33 ) } )
                , ( Morocco, { road = ( 0, 0 ), sea = ( 4156, 100 ), air = ( 3300, 33 ) } )
                , ( Spain, { road = ( 3312, 90 ), sea = ( 5576, 10 ), air = ( 2700, 33 ) } )
                , ( Tunisia, { road = ( 0, 0 ), sea = ( 2348, 100 ), air = ( 1700, 33 ) } )
                , ( Turkey, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                ]
          )
        , ( Tunisia
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 17637, 100 ), air = ( 8600, 33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 4343, 100 ), air = ( 1500, 0 ) } )
                , ( Germany, { road = ( 0, 0 ), sea = ( 4489, 100 ), air = ( 1500, 0 ) } )
                , ( Greece, { road = ( 0, 0 ), sea = ( 1591, 100 ), air = ( 1200, 0 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 8048, 100 ), air = ( 6200, 33 ) } )
                , ( Italy, { road = ( 0, 0 ), sea = ( 908, 100 ), air = ( 600, 0 ) } )
                , ( Morocco, { road = ( 1569, 90 ), sea = ( 2274, 10 ), air = ( 1700, 0 ) } )
                , ( Spain, { road = ( 0, 0 ), sea = ( 3693, 100 ), air = ( 1300, 0 ) } )
                , ( Tunisia, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                ]
          )
        , ( Morocco
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 19479, 100 ), air = ( 10000, 33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 2566, 100 ), air = ( 1900, 0 ) } )
                , ( Germany, { road = ( 0, 0 ), sea = ( 3167, 100 ), air = ( 2300, 0 ) } )
                , ( Greece, { road = ( 0, 0 ), sea = ( 3343, 100 ), air = ( 2900, 0 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 9891, 100 ), air = ( 7900, 33 ) } )
                , ( Italy, { road = ( 0, 0 ), sea = ( 2078, 100 ), air = ( 2000, 0 ) } )
                , ( Morocco, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                , ( Spain, { road = ( 0, 0 ), sea = ( 1916, 100 ), air = ( 900, 0 ) } )
                ]
          )
        , ( Italy
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 17740, 100 ), air = ( 8200, 33 ) } )
                , ( France, { road = ( 957, 50 ), sea = ( 4146, 50 ), air = ( 1100, 0 ) } )
                , ( Germany, { road = ( 1045, 90 ), sea = ( 4747, 10 ), air = ( 1000, 0 ) } )
                , ( Greece, { road = ( 841, 25 ), sea = ( 1576, 75 ), air = ( 1100, 0 ) } )
                , ( India, { road = ( 0, 0 ), sea = ( 8152, 100 ), air = ( 5900, 33 ) } )
                , ( Italy, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                , ( Spain, { road = ( 1372, 90 ), sea = ( 3496, 10 ), air = ( 1300, 0 ) } )
                ]
          )
        , ( India
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 11274, 100 ), air = ( 3800, 33 ) } )
                , ( France, { road = ( 0, 0 ), sea = ( 11960, 100 ), air = ( 6600, 33 ) } )
                , ( Germany, { road = ( 0, 0 ), sea = ( 12560, 100 ), air = ( 6100, 0 ) } )
                , ( Greece, { road = ( 0, 0 ), sea = ( 7168, 100 ), air = ( 5000, 0 ) } )
                , ( India, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                , ( Spain, { road = ( 0, 0 ), sea = ( 11310, 100 ), air = ( 7300, 0 ) } )
                ]
          )
        , ( Greece
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 16756, 100 ), air = ( 7600, 33 ) } )
                , ( France, { road = ( 1783, 50 ), sea = ( 5413, 50 ), air = ( 2100, 0 ) } )
                , ( Germany, { road = ( 1609, 90 ), sea = ( 6013, 10 ), air = ( 1800, 0 ) } )
                , ( Greece, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                , ( Spain, { road = ( 2183, 90 ), sea = ( 4763, 10 ), air = ( 2400, 0 ) } )
                ]
          )
        , ( France
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 21548, 100 ), air = ( 8200, 33 ) } )
                , ( France, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                , ( Germany, { road = ( 815, 90 ), sea = ( 1300, 10 ), air = ( 400, 0 ) } )
                , ( Spain, { road = ( 801, 90 ), sea = ( 1672, 10 ), air = ( 1100, 0 ) } )
                ]
          )
        , ( Spain
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 20898, 100 ), air = ( 9200, 33 ) } )
                , ( Germany, { road = ( 1615, 90 ), sea = ( 2272, 10 ), air = ( 1400, 0 ) } )
                , ( Spain, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                ]
          )
        , ( Germany
          , toDict
                [ ( China, { road = ( 0, 0 ), sea = ( 22149, 100 ), air = ( 7800, 33 ) } )
                , ( Germany, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                ]
          )
        , ( China
          , toDict
                [ ( China, { road = ( defaultInlandRoad, 100 ), sea = ( 0, 0 ), air = ( 0, 0 ) } )
                ]
          )
        ]


getDistanceInfo : Country -> Country -> Transport
getDistanceInfo cA cB =
    distances
        |> Dict.get (Country.toString cA)
        |> Maybe.andThen (Dict.get (Country.toString cB))
        |> Maybe.withDefault default


getDistanceCo2 : Country -> Country -> Float
getDistanceCo2 cA cB =
    let
        { road, air, sea } =
            getDistanceInfo cA cB

        ( roadKm, _ ) =
            road

        ( airKm, _ ) =
            air

        ( seaKm, _ ) =
            sea
    in
    roadKm + airKm + seaKm |> toFloat
