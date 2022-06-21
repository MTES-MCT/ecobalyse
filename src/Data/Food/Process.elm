module Data.Food.Process exposing
    ( Amount
    , ImpactsForProcesses
    , Process
    , ProcessName
    , computePefImpact
    , decode
    , empty
    , findByName
    , isIngredient
    , isProcess
    , processNameToString
    , stringToProcessName
    )

import Data.Impact as Impact exposing (Definition, Impacts)
import Data.Unit as Unit
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode exposing (Decoder)


type alias Amount =
    Unit.Ratio


type ProcessName
    = ProcessName String


stringToProcessName : String -> ProcessName
stringToProcessName str =
    ProcessName str


processNameToString : ProcessName -> String
processNameToString (ProcessName name) =
    name


isProcess : ProcessName -> Bool
isProcess (ProcessName processName) =
    String.endsWith "/ FR U" processName
        || String.startsWith "Transport, " processName
        || String.startsWith "Biowaste " processName
        || String.startsWith "Mixing, " processName


isIngredient : ProcessName -> Bool
isIngredient =
    isProcess >> not


type alias Process =
    { amount : Amount
    , impacts : Impacts
    }


type alias ImpactsForProcesses =
    AnyDict String ProcessName Impacts


empty : ImpactsForProcesses
empty =
    AnyDict.empty processNameToString


computePefImpact : List Definition -> Process -> Process
computePefImpact definitions process =
    { process
        | impacts =
            Impact.updatePefImpact definitions process.impacts
    }


findByName : ProcessName -> ImpactsForProcesses -> Result String Impacts
findByName ((ProcessName name) as procName) =
    AnyDict.get procName
        >> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


decode : List Definition -> Decoder ImpactsForProcesses
decode definitions =
    AnyDict.decode (\str _ -> ProcessName str) processNameToString (Impact.decodeImpacts definitions)
