module Data.Food.Preparation exposing
    ( Id(..)
    , Preparation
    , all
    , apply
    , decodeId
    , encodeId
    , findById
    , idToString
    , unused
    )

import Data.Food.Db as BuilderDb
import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Preparation =
    { id : Id
    , name : String
    , elec : ( Energy, Split )
    , heat : ( Energy, Split )
    , applyRawToCookedRatio : Bool
    }


type Id
    = Id String


all : List Preparation
all =
    -- see https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/etapes-du-cycles-de-vie/consommation#preparations-de-preparation
    [ { id = Id "frying"
      , name = "Friture"
      , elec = ( Energy.kilowattHours 0.667, Split.full )
      , heat = ( Energy.megajoules 0, Split.zero )
      , applyRawToCookedRatio = True
      }
    , { id = Id "pan-cooking"
      , name = "Cuisson à la poêle"
      , elec = ( Energy.kilowattHours 0.44, Split.fourty )
      , heat = ( Energy.megajoules 1.584, Split.complement Split.fourty )
      , applyRawToCookedRatio = True
      }
    , { id = Id "pan-warming"
      , name = "Réchauffage à la poêle"
      , elec = ( Energy.kilowattHours 0.08, Split.fourty )
      , heat = ( Energy.megajoules 0.288, Split.complement Split.fourty )
      , applyRawToCookedRatio = False
      }
    , { id = Id "oven"
      , name = "Cuisson au four"
      , elec = ( Energy.kilowattHours 0.999, Split.full )
      , heat = ( Energy.megajoules 0, Split.zero )
      , applyRawToCookedRatio = True
      }
    , { id = Id "microwave"
      , name = "Cuisson au four micro-ondes"
      , elec = ( Energy.kilowattHours 0.128, Split.full )
      , heat = ( Energy.megajoules 0, Split.zero )
      , applyRawToCookedRatio = True
      }
    , { id = Id "refrigeration"
      , name = "Réfrigération"
      , elec = ( Energy.kilowattHours 0.0777, Split.full )
      , heat = ( Energy.megajoules 0, Split.zero )
      , applyRawToCookedRatio = False
      }
    , { id = Id "freezing"
      , name = "Congélation"
      , elec = ( Energy.kilowattHours 0.294, Split.full )
      , heat = ( Energy.megajoules 0, Split.zero )
      , applyRawToCookedRatio = False
      }
    ]


apply : BuilderDb.Db -> Mass -> Preparation -> Impacts
apply { wellKnown } mass preparation =
    Impact.sumImpacts
        [ wellKnown.lowVoltageElectricity.impacts
            |> Impact.mapImpacts
                (\_ ->
                    Unit.impactToFloat
                        >> (*) (Energy.inKilowattHours (Tuple.first preparation.elec))
                        >> (*) (Mass.inKilograms mass)
                        >> (*) (Split.toFloat (Tuple.second preparation.elec))
                        >> Unit.impact
                )
        , wellKnown.domesticGasHeat.impacts
            |> Impact.mapImpacts
                (\_ ->
                    Unit.impactToFloat
                        >> (*) (Energy.inMegajoules (Tuple.first preparation.heat))
                        >> (*) (Mass.inKilograms mass)
                        >> (*) (Split.toFloat (Tuple.second preparation.heat))
                        >> Unit.impact
                )
        ]


decodeId : Decoder Id
decodeId =
    Decode.string
        |> Decode.andThen (idFromString >> DE.fromResult)


encodeId : Id -> Encode.Value
encodeId (Id id) =
    Encode.string id


findById : Id -> Result String Preparation
findById id =
    all
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe (notFoundError (idToString id))


idFromString : String -> Result String Id
idFromString string =
    if all |> List.map .id |> List.map idToString |> List.member string then
        Ok (Id string)

    else
        Err <| notFoundError string


idToString : Id -> String
idToString (Id string) =
    string


notFoundError : String -> String
notFoundError str =
    "Préparation inconnue: " ++ str


unused : List Id -> List Preparation -> List Preparation
unused usedIds =
    List.filter (\{ id } -> usedIds |> List.member id |> not)
