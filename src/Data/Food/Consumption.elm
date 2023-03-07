module Data.Food.Consumption exposing
    ( Id(..)
    , Technique
    , applyTechnique
    , decodeId
    , encodeId
    , findById
    , idToString
    , techniques
    , unused
    )

import Data.Food.Builder.Db as BuilderDb
import Data.Food.Process as Process
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Technique =
    { id : Id
    , name : String
    , elec : ( Energy, Unit.Ratio )
    , heat : ( Energy, Unit.Ratio )
    }


type Id
    = Id String


applyTechnique : BuilderDb.Db -> Mass -> Technique -> Result String Impacts
applyTechnique db mass technique =
    db.processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ electricity, domesticGasHeat } ->
                Impact.sumImpacts db.impacts
                    [ electricity.impacts
                        |> Impact.mapImpacts
                            (\_ ->
                                Unit.impactToFloat
                                    >> (*) (Energy.inKilowattHours (Tuple.first technique.elec))
                                    >> (*) (Mass.inKilograms mass)
                                    >> (*) (Unit.ratioToFloat (Tuple.second technique.elec))
                                    >> Unit.impact
                            )
                    , domesticGasHeat.impacts
                        |> Impact.mapImpacts
                            (\_ ->
                                Unit.impactToFloat
                                    >> (*) (Energy.inMegajoules (Tuple.first technique.heat))
                                    >> (*) (Mass.inKilograms mass)
                                    >> (*) (Unit.ratioToFloat (Tuple.second technique.heat))
                                    >> Unit.impact
                            )
                    ]
            )


decodeId : Decoder Id
decodeId =
    Decode.string
        |> Decode.andThen (idFromString >> DE.fromResult)


encodeId : Id -> Encode.Value
encodeId (Id id) =
    Encode.string id


findById : Id -> Result String Technique
findById id =
    techniques
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Technique de préparation " ++ idToString id ++ " inconnue")


idFromString : String -> Result String Id
idFromString string =
    if techniques |> List.map .id |> List.map idToString |> List.member string then
        Ok (Id string)

    else
        Err <| "Technique de préparation inconnue: " ++ string


idToString : Id -> String
idToString (Id string) =
    string


techniques : List Technique
techniques =
    -- see https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/etapes-du-cycles-de-vie/consommation#techniques-de-preparation
    [ { id = Id "frying"
      , name = "Friture"
      , elec = ( Energy.kilowattHours 0.667, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { id = Id "pan-cooking"
      , name = "Cuisson à la poêle"
      , elec = ( Energy.kilowattHours 0.44, Unit.ratio 0.4 )
      , heat = ( Energy.megajoules 1.584, Unit.ratio 0.6 )
      }
    , { id = Id "pan-warming"
      , name = "Réchauffage à la poêle"
      , elec = ( Energy.kilowattHours 0.08, Unit.ratio 0.4 )
      , heat = ( Energy.megajoules 0.288, Unit.ratio 0.6 )
      }
    , { id = Id "oven"
      , name = "Four"
      , elec = ( Energy.kilowattHours 0.999, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { id = Id "microwaves"
      , name = "Four micro-ondes"
      , elec = ( Energy.kilowattHours 0.128, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { id = Id "refrigeration"
      , name = "Réfrigération"
      , elec = ( Energy.kilowattHours 0.0777, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { id = Id "freezing"
      , name = "Congélation"
      , elec = ( Energy.kilowattHours 0.294, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    ]


unused : List Id -> List Technique -> List Technique
unused usedIds =
    List.filter (\{ id } -> usedIds |> List.member id |> not)
