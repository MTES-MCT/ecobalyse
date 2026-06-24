module Data.Db exposing
    ( Db
    , Properties
    , RawJsonString
    , RawJsonStrings
    , buildDb
    , propGetters
    , rawJsonString
    , updateDbProcesses
    )

import Data.Component as Component exposing (Component)
import Data.Country as Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Object.Db as ObjectDb
import Data.Process as Process exposing (Process)
import Data.Textile.Db as TextileDb
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { components : List Component
    , countries : List Country
    , definitions : Definitions
    , distances : Distances
    , food : FoodDb.Db
    , object : ObjectDb.Db
    , processes : List Process
    , textile : TextileDb.Db
    }


type alias Properties a =
    { countries : a
    , definitions : a
    , food2Examples : a
    , foodIngredients : a
    , foodProductExamples : a
    , objectComponents : a
    , objectExamples : a
    , processes : a
    , textileComponents : a
    , textileMaterials : a
    , textileProductExamples : a
    , textileProducts : a
    , transports : a
    , veliComponents : a
    , veliExamples : a
    }


type RawJsonString
    = RawJsonString String


type alias RawJsonStrings =
    Properties RawJsonString


buildDb : RawJsonStrings -> Result String Db
buildDb json =
    extractJsonString json.processes
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap
                        (decodeRawComponents
                            { food2Components = """[]"""
                            , objectComponents = extractJsonString json.objectComponents
                            , textileComponents = extractJsonString json.textileComponents
                            , veliComponents = extractJsonString json.veliComponents
                            }
                        )
                    |> RE.andMap
                        (extractJsonString json.countries
                            |> Decode.decodeString (Country.decodeList processes)
                            |> Result.mapError Decode.errorToString
                        )
                    |> RE.andMap
                        (extractJsonString json.definitions
                            |> Decode.decodeString Definition.decode
                            |> Result.mapError Decode.errorToString
                        )
                    |> RE.andMap
                        (extractJsonString json.transports
                            |> Decode.decodeString Transport.decodeDistances
                            |> Result.mapError Decode.errorToString
                        )
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                (extractJsonString json.foodProductExamples)
                                (extractJsonString json.foodIngredients)
                        )
                    |> RE.andMap
                        (ObjectDb.buildFromJson
                            (extractJsonString json.food2Examples)
                            (extractJsonString json.objectExamples)
                            (extractJsonString json.veliExamples)
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                (extractJsonString json.textileProductExamples)
                                (extractJsonString json.textileMaterials)
                                (extractJsonString json.textileProducts)
                        )
            )


decodeRawComponents :
    { food2Components : String
    , objectComponents : String
    , textileComponents : String
    , veliComponents : String
    }
    -> Result String (List Component)
decodeRawComponents { objectComponents, textileComponents, veliComponents } =
    [ objectComponents, textileComponents, veliComponents ]
        |> List.map Component.decodeListFromJsonString
        |> RE.combine
        |> Result.map List.concat


extractJsonString : RawJsonString -> String
extractJsonString (RawJsonString string) =
    string


propGetters : List (Properties a -> a)
propGetters =
    [ .countries
    , .definitions
    , .food2Examples
    , .foodIngredients
    , .foodProductExamples
    , .objectComponents
    , .objectExamples
    , .processes
    , .textileComponents
    , .textileMaterials
    , .textileProductExamples
    , .textileProducts
    , .transports
    , .veliComponents
    , .veliExamples
    ]


rawJsonString : String -> RawJsonString
rawJsonString =
    RawJsonString


updateDbProcesses : String -> Db -> Result String Db
updateDbProcesses processesJson db =
    processesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.map (\processes -> { db | processes = processes })
