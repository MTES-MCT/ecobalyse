module TestUtils exposing
    ( asTest
    , expectImpactsEqual
    , suiteWithDb
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (DefinitionsBase)
import Data.Unit as Unit
import Expect exposing (Expectation)
import Static.Db as StaticDb
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


suiteWithDb : String -> (StaticDb.Db -> List Test) -> Test
suiteWithDb name suite =
    case StaticDb.db of
        Ok db ->
            describe name (suite db)

        Err error ->
            describe name
                [ test "should load static database" <|
                    \_ -> Expect.fail <| "Couldn't parse static database: " ++ error
                ]


expectImpactsEqual : DefinitionsBase (Float -> Expectation) -> Impacts -> Expectation
expectImpactsEqual impacts subject =
    Expect.all
        [ Impact.getImpact Definition.Acd >> Unit.impactToFloat >> impacts.acd
        , Impact.getImpact Definition.Bvi >> Unit.impactToFloat >> impacts.bvi
        , Impact.getImpact Definition.Cch >> Unit.impactToFloat >> impacts.cch
        , Impact.getImpact Definition.Ecs >> Unit.impactToFloat >> impacts.ecs
        , Impact.getImpact Definition.Etf >> Unit.impactToFloat >> impacts.etf
        , Impact.getImpact Definition.EtfC >> Unit.impactToFloat >> impacts.etfc
        , Impact.getImpact Definition.Fru >> Unit.impactToFloat >> impacts.fru
        , Impact.getImpact Definition.Fwe >> Unit.impactToFloat >> impacts.fwe
        , Impact.getImpact Definition.Htc >> Unit.impactToFloat >> impacts.htc
        , Impact.getImpact Definition.HtcC >> Unit.impactToFloat >> impacts.htcc
        , Impact.getImpact Definition.Htn >> Unit.impactToFloat >> impacts.htn
        , Impact.getImpact Definition.HtnC >> Unit.impactToFloat >> impacts.htnc
        , Impact.getImpact Definition.Ior >> Unit.impactToFloat >> impacts.ior
        , Impact.getImpact Definition.Ldu >> Unit.impactToFloat >> impacts.ldu
        , Impact.getImpact Definition.Mru >> Unit.impactToFloat >> impacts.mru
        , Impact.getImpact Definition.Ozd >> Unit.impactToFloat >> impacts.ozd
        , Impact.getImpact Definition.Pco >> Unit.impactToFloat >> impacts.pco
        , Impact.getImpact Definition.Pef >> Unit.impactToFloat >> impacts.pef
        , Impact.getImpact Definition.Pma >> Unit.impactToFloat >> impacts.pma
        , Impact.getImpact Definition.Swe >> Unit.impactToFloat >> impacts.swe
        , Impact.getImpact Definition.Tre >> Unit.impactToFloat >> impacts.tre
        , Impact.getImpact Definition.Wtu >> Unit.impactToFloat >> impacts.wtu
        ]
        subject
