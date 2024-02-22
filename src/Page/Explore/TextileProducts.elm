module Page.Explore.TextileProducts exposing (table)

import Area
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Scope exposing (Scope)
import Data.Split as Split
import Data.Textile.DyeingMedium as DyeingMedium
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric
import Data.Textile.Formula as Formula
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.MakingComplexity as MakingComplexity
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Simulator exposing (Simulator)
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Duration
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass
import Page.Explore.Common as Common
import Page.Explore.Table exposing (Table)
import Quantity
import RemoteData exposing (WebData)
import Route
import Views.Format as Format
import Volume


withTitle : String -> Html msg
withTitle str =
    span [ title str ] [ text str ]


table : { detailed : Bool, scope : Scope } -> Table { product : Product, simulatorData : WebData Simulator } String msg
table { detailed, scope } =
    { toId = .product >> .id >> Product.idToString
    , toRoute = .product >> .id >> Just >> Dataset.TextileProducts >> Route.Explore scope
    , rows =
        [ { label = "Identifiant"
          , toValue = .product >> .id >> Product.idToString
          , toCell =
                \{ product } ->
                    if detailed then
                        code [] [ text (Product.idToString product.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.TextileProducts (Just product.id))) ]
                            [ code [] [ text (Product.idToString product.id) ] ]
          }
        , { label = "Produit(s) concerné(s)"
          , toValue = .product >> .name
          , toCell = .product >> .name >> text
          }
        , { label = "Poids"
          , toValue = .product >> .mass >> Mass.inGrams >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.kg product.mass ]
          }
        , { label = "Titrage"
          , toValue = .product >> .yarnSize >> Unit.yarnSizeInKilometers >> String.fromInt
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ product.yarnSize |> Format.yarnSize ]
          }
        , { label = "Grammage"
          , toValue = .product >> .surfaceMass >> Unit.surfaceMassInGramsPerSquareMeters >> String.fromInt
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.surfaceMass product.surfaceMass
                        ]
          }
        , let
            computeThreadDensity { surfaceMass, yarnSize } =
                yarnSize
                    |> Formula.computeThreadDensity surfaceMass
          in
          { label = "Densité de fils"
          , toValue = .product >> computeThreadDensity >> Unit.threadDensityToFloat >> String.fromFloat
          , toCell =
                .product >> computeThreadDensity >> Format.threadDensity
          }
        , let
            computeSurface { mass, surfaceMass } =
                Mass.inGrams mass
                    / toFloat (Unit.surfaceMassInGramsPerSquareMeters surfaceMass)
          in
          { label = "Surface"
          , toValue = .product >> computeSurface >> String.fromFloat
          , toCell = .product >> computeSurface >> Area.squareMeters >> Format.squareMeters
          }
        , { label = "Volume"
          , toValue = .product >> .endOfLife >> .volume >> Volume.inCubicMeters >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.m3 product.endOfLife.volume ]
          }
        , let
            fabricToString product =
                if Fabric.isKnitted product.fabric then
                    "Tricotée"

                else
                    "Tissée"
          in
          { label = "Etoffe"
          , toValue = .product >> fabricToString
          , toCell = .product >> fabricToString >> text
          }
        , let
            picking simulator surfaceMass ys =
                let
                    outputMass =
                        simulator
                            |> (.lifeCycle >> LifeCycle.getStepProp Label.Fabric .outputMass Quantity.zero)

                    outputSurface =
                        Unit.surfaceMassToSurface surfaceMass outputMass

                    threadDensity =
                        Formula.computeThreadDensity surfaceMass ys
                in
                outputSurface
                    |> Formula.computePicking threadDensity
          in
          { label = "Duites.m"
          , toValue =
                \{ product, simulatorData } ->
                    simulatorData
                        |> RemoteData.map
                            (\simulator ->
                                picking simulator product.surfaceMass product.yarnSize
                                    |> Unit.pickPerMeterToFloat
                                    |> String.fromFloat
                            )
                        |> RemoteData.withDefault "chargement"
          , toCell =
                \{ product, simulatorData } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ simulatorData
                            |> RemoteData.map
                                (\simulator ->
                                    picking simulator product.surfaceMass product.yarnSize
                                        |> Format.picking
                                )
                            |> RemoteData.withDefault (text "chargement")
                        ]
          }
        , let
            fadableToString product =
                Common.boolText (Product.isFadedByDefault product)
          in
          { label = "Délavage par défaut"
          , toValue = .product >> fadableToString
          , toCell = .product >> fadableToString >> text
          }
        , { label = "Stocks dormants"
          , toValue = Split.toPercentString Env.defaultDeadStock |> always
          , toCell =
                div [ classList [ ( "text-center", not detailed ) ] ]
                    [ Format.splitAsPercentage Env.defaultDeadStock ]
                    |> always
          }
        , { label = "Type de teinture"
          , toValue = .product >> .dyeing >> .defaultMedium >> DyeingMedium.toLabel
          , toCell = .product >> .dyeing >> .defaultMedium >> DyeingMedium.toLabel >> text
          }
        , { label = "Confection (complexité)"
          , toValue = .product >> .making >> .complexity >> MakingComplexity.toLabel
          , toCell = .product >> .making >> .complexity >> MakingComplexity.toLabel >> text
          }
        , { label = "Confection (# minutes)"
          , toValue = .product >> Product.getMakingDurationInMinutes >> Duration.inMinutes >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Product.getMakingDurationInMinutes product |> Format.minutes ]
          }
        , { label = "Confection (taux de perte)"
          , toValue = .product >> .making >> .pcrWaste >> Split.toPercentString
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.splitAsPercentage product.making.pcrWaste ]
          }
        , { label = "Nombre de jours porté"
          , toValue = .product >> .use >> .daysOfWear >> Duration.inDays >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.days product.use.daysOfWear ]
          }
        , { label = "Utilisations avant lavage"
          , toValue = .product >> .use >> .wearsPerCycle >> String.fromInt
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ text <| String.fromInt product.use.wearsPerCycle ]
          }
        , { label = "Cycles d'entretien (par défaut)"
          , toValue = .product >> .use >> .defaultNbCycles >> String.fromInt
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ text <| String.fromInt product.use.defaultNbCycles ]
          }
        , { label = "Procédé de repassage"
          , toValue = .product >> .use >> .ironingProcess >> .name
          , toCell = .product >> .use >> .ironingProcess >> .name >> withTitle
          }
        , { label = "Procédé d'utilisation hors-repassage"
          , toValue = .product >> .use >> .nonIroningProcess >> .name
          , toCell = .product >> .use >> .nonIroningProcess >> .name >> withTitle
          }
        , { label = "Séchage électrique"
          , toValue = .product >> .use >> .ratioDryer >> Split.toPercentString
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.splitAsPercentage product.use.ratioDryer ]
          }
        , { label = "Repassage (part)"
          , toValue = .product >> .use >> .ratioIroning >> Split.toPercentString
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.splitAsPercentage product.use.ratioIroning ]
          }
        , { label = "Repassage (temps)"
          , toValue = .product >> .use >> .timeIroning >> Duration.inHours >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.hours product.use.timeIroning ]
          }
        , { label = "Prix par défaut"
          , toValue = .product >> .economics >> .price >> Economics.priceToFloat >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.priceInEUR product.economics.price ]
          }
        , { label = "Coût de réparation par défaut"
          , toValue = .product >> .economics >> .repairCost >> Economics.priceToFloat >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.priceInEUR product.economics.repairCost ]
          }
        , { label = "Type d'entreprise"
          , toValue = .product >> .economics >> .business >> Economics.businessToLabel
          , toCell = .product >> .economics >> .business >> Economics.businessToLabel >> text
          }
        , { label = "Durée de commercialisation moyenne"
          , toValue = .product >> .economics >> .marketingDuration >> Duration.inDays >> String.fromFloat
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ Format.days product.economics.marketingDuration ]
          }
        , { label = "Nombre de références"
          , toValue = .product >> .economics >> .numberOfReferences >> String.fromInt
          , toCell =
                \{ product } ->
                    div [ classList [ ( "text-center", not detailed ) ] ]
                        [ product.economics.numberOfReferences |> String.fromInt |> text
                        , text " références"
                        ]
          }
        , { label = "Traçabilité renforcée\u{00A0}?"
          , toValue = .product >> .economics >> .traceability >> Common.boolText
          , toCell = .product >> .economics >> .traceability >> Common.boolText >> text
          }
        ]
    }
