module Data.Food.Process exposing
    ( Process
    , ProcessName
    , Processes
    , boatTransportName
    , decodeProcesses
    , emptyProcess
    , emptyProcesses
    , findByName
    , lorryTransportName
    , nameFromString
    , nameToString
    , planeTransportName
    )

import Data.Impact as Impact
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias Processes =
    AnyDict String ProcessName Process


{-| Process
A process is an entry from public/data/food/processes.json. It has impacts and
various other data like categories, code, unit...
-}
type ProcessName
    = ProcessName String


lorryTransportName : ProcessName
lorryTransportName =
    ProcessName "Transport, freight, lorry 16-32 metric ton, EURO5 {RER}| transport, freight, lorry 16-32 metric ton, EURO5 | Cut-off, S - Copied from Ecoinvent"


boatTransportName : ProcessName
boatTransportName =
    ProcessName "Transport, freight, sea, transoceanic ship {GLO}| processing | Cut-off, S - Copied from Ecoinvent"


planeTransportName : ProcessName
planeTransportName =
    ProcessName "Transport, freight, aircraft {RER}| intercontinental | Cut-off, S - Copied from Ecoinvent"


nameFromString : String -> ProcessName
nameFromString =
    ProcessName


nameToString : ProcessName -> String
nameToString (ProcessName name) =
    name


type alias Process =
    { name : ProcessName
    , impacts : Impact.Impacts
    , ciqualCode : Maybe Int
    , step : Maybe String
    , dqr : Maybe Float
    , emptyProcess : Bool
    , unit : String
    , code : String
    , simaproCategory : String
    , systemDescription : String
    , categoryTags : List String
    }


emptyProcess : Process
emptyProcess =
    { name = nameFromString "empty process"
    , impacts = Impact.noImpacts
    , ciqualCode = Nothing
    , step = Nothing
    , dqr = Nothing
    , emptyProcess = True
    , unit = ""
    , code = ""
    , simaproCategory = ""
    , systemDescription = ""
    , categoryTags = []
    }


decodeProcess : List Impact.Definition -> Decoder Process
decodeProcess definitions =
    Decode.succeed Process
        |> Pipe.hardcoded (nameFromString "to be defined")
        |> Pipe.required "impacts" (Impact.decodeImpacts definitions)
        |> Pipe.required "ciqual_code" (Decode.nullable Decode.int)
        |> Pipe.required "step" (Decode.nullable Decode.string)
        |> Pipe.required "dqr" (Decode.nullable Decode.float)
        |> Pipe.required "empty_process" Decode.bool
        |> Pipe.required "unit" (Decode.map formatStringUnit Decode.string)
        |> Pipe.required "code" Decode.string
        |> Pipe.required "simapro_category" Decode.string
        |> Pipe.required "system_description" Decode.string
        |> Pipe.required "category_tags" (Decode.list Decode.string)


decodeProcesses : List Impact.Definition -> Decoder Processes
decodeProcesses definitions =
    AnyDict.decode (\str _ -> ProcessName str) nameToString (decodeProcess definitions)
        |> Decode.map
            (AnyDict.map
                (\processName process ->
                    { process | name = processName }
                )
            )


emptyProcesses : Processes
emptyProcesses =
    AnyDict.empty nameToString


findByName : Processes -> ProcessName -> Result String Process
findByName processes ((ProcessName name) as procName) =
    processes
        |> AnyDict.get procName
        |> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


formatStringUnit : String -> String
formatStringUnit str =
    case str of
        "cubic meter" ->
            "m³"

        "kilogram" ->
            "kg"

        "kilometer" ->
            "km"

        "kilowatt hour" ->
            "kWh"

        "litre" ->
            "l"

        "megajoule" ->
            "MJ"

        "ton kilometer" ->
            "t/km"

        _ ->
            str
