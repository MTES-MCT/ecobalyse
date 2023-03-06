module Data.Food.Comsumption exposing
    ( Technique
    , applyTechnique
    , techniques
    )

import Data.Food.Builder.Db as BuilderDb
import Data.Food.Process as Process
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Energy exposing (Energy)
import Mass exposing (Mass)


type alias Technique =
    { name : String
    , elec : ( Energy, Unit.Ratio )
    , heat : ( Energy, Unit.Ratio )
    }


techniques : List Technique
techniques =
    -- see https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/etapes-du-cycles-de-vie/consommation#techniques-de-preparation
    [ { name = "Friture"
      , elec = ( Energy.kilowattHours 0.667, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { name = "Cuisson à la poêle"
      , elec = ( Energy.kilowattHours 0.44, Unit.ratio 0.4 )
      , heat = ( Energy.megajoules 1.584, Unit.ratio 0.6 )
      }
    , { name = "Réchauffage à la poêle"
      , elec = ( Energy.kilowattHours 0.08, Unit.ratio 0.4 )
      , heat = ( Energy.megajoules 0.288, Unit.ratio 0.6 )
      }
    , { name = "Four"
      , elec = ( Energy.kilowattHours 0.999, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { name = "Four micro-ondes"
      , elec = ( Energy.kilowattHours 0.128, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { name = "Réfrigération"
      , elec = ( Energy.kilowattHours 0.0777, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    , { name = "Congélation"
      , elec = ( Energy.kilowattHours 0.294, Unit.ratio 1 )
      , heat = ( Energy.megajoules 0, Unit.ratio 0 )
      }
    ]


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
