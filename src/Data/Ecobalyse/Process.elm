module Data.Ecobalyse.Process exposing
    ( Amount
    , Impacts
    , ImpactsForProcesses
    , Process
    , ProcessName
    , decode
    , empty
    , findByName
    )

import Data.Unit as Unit
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias Impacts =
    { acd : Float
    , ozd : Float
    , cch : Float
    , ccb : Float
    , ccf : Float
    , ccl : Float
    , fwe : Float
    , swe : Float
    , tre : Float
    , pco : Float
    , pma : Float
    , ior : Float
    , fru : Float
    , mru : Float
    , ldu : Float
    , wtu : Float
    , etf : Float
    , htc : Float
    , htn : Float
    }


type alias Amount =
    Unit.Ratio


type alias ProcessName =
    String


type alias Process =
    { amount : Amount
    , impacts : Impacts
    }


type alias ImpactsForProcesses =
    Dict String Impacts


empty : ImpactsForProcesses
empty =
    Dict.empty


findByName : String -> ImpactsForProcesses -> Result String Impacts
findByName name =
    Dict.get name
        >> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


decodeImpacts : Decoder Impacts
decodeImpacts =
    Decode.succeed Impacts
        |> Pipe.required "acd" Decode.float
        |> Pipe.required "ozd" Decode.float
        |> Pipe.required "cch" Decode.float
        |> Pipe.required "ccb" Decode.float
        |> Pipe.required "ccf" Decode.float
        |> Pipe.required "ccl" Decode.float
        |> Pipe.required "fwe" Decode.float
        |> Pipe.required "swe" Decode.float
        |> Pipe.required "tre" Decode.float
        |> Pipe.required "pco" Decode.float
        |> Pipe.required "pma" Decode.float
        |> Pipe.required "ior" Decode.float
        |> Pipe.required "fru" Decode.float
        |> Pipe.required "mru" Decode.float
        |> Pipe.required "ldu" Decode.float
        |> Pipe.required "wtu" Decode.float
        |> Pipe.required "etf" Decode.float
        |> Pipe.required "htc" Decode.float
        |> Pipe.required "htn" Decode.float


decode : Decoder ImpactsForProcesses
decode =
    Decode.dict decodeImpacts
