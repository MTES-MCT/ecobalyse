module Data.Food.Recipe exposing
    ( Recipe
    , RecipeIngredient
    , Results
    , Transform
    , availableIngredients
    , availablePackagings
    , compute
    , computeIngredientComplementsImpacts
    , computeIngredientTransport
    , computeProcessImpacts
    , deletePackaging
    , encodeResults
    , fromQuery
    , getMassAtPackaging
    , getPackagingMass
    , getTransformedIngredientsMass
    , ingredientQueryFromIngredient
    , processQueryFromProcess
    , resetDistribution
    , resetTransform
    , toStepsImpacts
    , toString
    )

import Data.Country as Country exposing (Country)
import Data.Food.EcosystemicServices as EcosystemicServices exposing (EcosystemicServices)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Origin as Origin
import Data.Food.Preparation as Preparation exposing (Preparation)
import Data.Food.Query as BuilderQuery exposing (Query)
import Data.Food.Retail as Retail
import Data.Food.WellKnown exposing (WellKnown)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Process.Category as ProcessCategory
import Data.Scoring as Scoring exposing (Scoring)
import Data.Split as Split
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Density exposing (Density, gramsPerCubicCentimeter)
import Json.Encode as Encode
import Length
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Static.Db exposing (Db)
import String.Extra as SE
import Volume exposing (Volume)


france : Country.Code
france =
    Country.codeFromString "FR"


type alias Packaging =
    { mass : Mass
    , process : Process.Process
    }


type alias RecipeIngredient =
    { country : Maybe Country
    , ingredient : Ingredient
    , mass : Mass
    , planeTransport : Ingredient.PlaneTransport
    }


type alias Recipe =
    { distribution : Maybe Retail.Distribution
    , ingredients : List RecipeIngredient
    , packaging : List Packaging
    , preparation : List Preparation
    , transform : Maybe Transform
    }


type alias Results =
    { distribution : { total : Impacts, transports : Transport }
    , packaging : Impacts
    , perKg : Impacts
    , preparation : Impacts
    , preparedMass : Mass
    , recipe :
        { total : Impacts
        , initialMass : Mass
        , edibleMass : Mass
        , ingredientsTotal : Impacts
        , ingredients : List ( RecipeIngredient, Impacts )
        , totalComplementsImpact : Impact.ComplementsImpacts
        , totalComplementsImpactPerKg : Impact.ComplementsImpacts
        , transform : Impacts
        , transports : Transport
        , transformedMass : Mass
        }
    , scoring : Scoring
    , total : Impacts
    , totalMass : Mass
    , transports : Transport
    }


type alias Transform =
    { mass : Mass
    , process : Process.Process
    }


availableIngredients : List Ingredient.Id -> List Ingredient -> List Ingredient
availableIngredients usedIngredientIds =
    List.filter (\{ id } -> not (List.member id usedIngredientIds))


availablePackagings : List Process.Id -> List Process -> List Process
availablePackagings usedProcesses =
    Process.listByCategory ProcessCategory.Packaging
        >> List.filter (\process -> not (List.member process.id usedProcesses))


compute : Db -> Query -> Result String ( Recipe, Results )
compute ({ food } as db) =
    -- FIXME get the wellknown early and propagate the error to the computation
    fromQuery db
        >> Result.map
            (\({ ingredients, transform, packaging, distribution, preparation } as recipe) ->
                let
                    ingredientsImpacts =
                        ingredients
                            |> List.map
                                (\recipeIngredient ->
                                    recipeIngredient
                                        |> computeIngredientImpacts
                                        |> Tuple.pair recipeIngredient
                                )

                    ingredientsTotalImpacts =
                        ingredientsImpacts
                            |> List.map Tuple.second
                            |> Impact.sumImpacts

                    ingredientsTransport =
                        ingredients
                            -- FIXME pass the wellknown to computeIngredientTransport
                            |> List.map (computeIngredientTransport db)
                            |> Transport.sum

                    transformImpacts =
                        transform
                            |> Maybe.map computeProcessImpacts
                            |> Maybe.withDefault Impact.empty

                    distributionImpacts =
                        distribution
                            |> Maybe.map
                                (\distrib ->
                                    let
                                        volume =
                                            getTransformedIngredientsVolume food.wellKnown recipe
                                    in
                                    Retail.computeImpacts volume distrib food.wellKnown
                                )
                            |> Maybe.withDefault Impact.empty

                    distributionTransportNeedsCooling =
                        ingredients
                            |> List.any (.ingredient >> .transportCooling >> (/=) Ingredient.NoCooling)

                    distributionTransport =
                        let
                            mass =
                                getMassAtPackaging food.wellKnown recipe

                            transport =
                                distribution
                                    |> Maybe.map
                                        (\distrib ->
                                            Retail.distributionTransport distrib distributionTransportNeedsCooling
                                        )
                                    |> Maybe.withDefault (Transport.default Impact.empty)

                            modes =
                                convertWellKnownToTransportModes db.food.wellKnown
                        in
                        Transport.computeImpacts modes mass transport

                    recipeImpacts =
                        Impact.sumImpacts
                            [ ingredientsTotalImpacts
                            , transformImpacts
                            , ingredientsTransport.impacts
                            ]

                    transformedIngredientsMass =
                        getTransformedIngredientsMass food.wellKnown recipe

                    packagingImpacts =
                        packaging
                            |> List.map computeProcessImpacts
                            |> Impact.sumImpacts

                    preparationImpacts =
                        preparation
                            |> List.map (Preparation.apply food.wellKnown transformedIngredientsMass)
                            |> Impact.sumImpacts

                    preparedMass =
                        getPreparedMassAtConsumer food.wellKnown recipe

                    totalComplementsImpact =
                        computeIngredientsTotalComplements ingredients

                    addIngredientsComplements impacts =
                        impacts
                            |> Impact.applyComplements (Impact.getTotalComplementsImpacts totalComplementsImpact)

                    totalComplementsImpactPerKg =
                        totalComplementsImpact
                            |> Impact.mapComplementsImpacts (Quantity.divideBy (Mass.inKilograms preparedMass))

                    totalImpactsWithoutComplements =
                        Impact.sumImpacts
                            [ recipeImpacts
                            , packagingImpacts
                            , distributionImpacts
                            , distributionTransport.impacts
                            , preparationImpacts
                            ]

                    totalImpacts =
                        addIngredientsComplements totalImpactsWithoutComplements

                    -- Note: Product impacts per kg is computed against prepared
                    --       product mass at consumer, excluding packaging
                    impactsPerKg =
                        totalImpacts
                            |> Impact.perKg preparedMass

                    impactsPerKgWithoutComplements =
                        totalImpactsWithoutComplements
                            |> Impact.perKg preparedMass

                    scoring =
                        impactsPerKgWithoutComplements
                            |> Scoring.compute db.definitions
                                (Impact.getTotalComplementsImpacts totalComplementsImpactPerKg)
                in
                ( recipe
                , { distribution = { total = distributionImpacts, transports = distributionTransport }
                  , packaging = packagingImpacts
                  , perKg = impactsPerKg
                  , preparation = preparationImpacts
                  , preparedMass = preparedMass
                  , recipe =
                        { edibleMass = removeIngredientsInedibleMass recipe.ingredients |> List.map .mass |> Quantity.sum
                        , ingredients = ingredientsImpacts
                        , ingredientsTotal = addIngredientsComplements ingredientsTotalImpacts
                        , initialMass = recipe.ingredients |> List.map .mass |> Quantity.sum
                        , total = addIngredientsComplements recipeImpacts
                        , totalComplementsImpact = totalComplementsImpact
                        , totalComplementsImpactPerKg = totalComplementsImpactPerKg
                        , transform = transformImpacts
                        , transformedMass = transformedIngredientsMass
                        , transports = ingredientsTransport
                        }
                  , scoring = scoring
                  , total = totalImpacts
                  , totalMass = getMassAtPackaging food.wellKnown recipe
                  , transports = Transport.sum [ ingredientsTransport, distributionTransport ]
                  }
                )
            )


{-| Converts food well-known transport processes to generic transport configuration format.

TODO: migrate food to use the new format entirely, so we have a single place to configure them for all scopes

-}
convertWellKnownToTransportModes : WellKnown -> Transport.ModeProcesses
convertWellKnownToTransportModes wellKnown =
    { boat = wellKnown.boatTransport
    , boatCooling = wellKnown.boatCoolingTransport
    , lorry = wellKnown.lorryTransport
    , lorryCooling = wellKnown.lorryCoolingTransport
    , plane = wellKnown.planeTransport
    }


computeIngredientComplementsImpacts : EcosystemicServices -> Mass -> Impact.ComplementsImpacts
computeIngredientComplementsImpacts { cropDiversity, hedges, livestockDensity, permanentPasture, plotSize } ingredientMass =
    let
        apply coeff =
            Quantity.multiplyBy (Mass.inKilograms ingredientMass)
                >> Quantity.multiplyBy (Unit.ratioToFloat coeff)
    in
    { cropDiversity = apply EcosystemicServices.coefficients.cropDiversity cropDiversity
    , hedges = apply EcosystemicServices.coefficients.hedges hedges
    , livestockDensity = apply EcosystemicServices.coefficients.livestockDensity livestockDensity
    , microfibers = Unit.noImpacts
    , outOfEuropeEOL = Unit.noImpacts
    , permanentPasture = apply EcosystemicServices.coefficients.permanentPasture permanentPasture
    , plotSize = apply EcosystemicServices.coefficients.plotSize plotSize
    }


computeImpact : Mass -> Definition.Trigram -> Unit.Impact -> Unit.Impact
computeImpact mass _ =
    Unit.impactToFloat
        >> (*) (Mass.inKilograms mass)
        >> Unit.impact


computeProcessImpacts : { a | mass : Mass, process : Process } -> Impacts
computeProcessImpacts item =
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)


computeIngredientImpacts : RecipeIngredient -> Impacts
computeIngredientImpacts { ingredient, mass } =
    ingredient.process.impacts
        |> Impact.mapImpacts (computeImpact mass)


computeIngredientsTotalComplements : List RecipeIngredient -> Impact.ComplementsImpacts
computeIngredientsTotalComplements =
    List.foldl
        (\{ ingredient, mass } acc ->
            mass
                |> computeIngredientComplementsImpacts ingredient.ecosystemicServices
                |> Impact.addComplementsImpacts acc
        )
        Impact.noComplementsImpacts


computeIngredientTransport : Db -> RecipeIngredient -> Transport
computeIngredientTransport db { country, ingredient, mass, planeTransport } =
    let
        emptyImpacts =
            Impact.empty

        planeRatio =
            -- Special case: if the default origin of an ingredient is "by plane"
            -- and we selected a transport by plane, then we take an air transport ratio of 1
            if planeTransport == Ingredient.ByPlane then
                Split.full

            else
                Split.zero

        baseTransport =
            let
                base =
                    case country of
                        -- In case a custom country is provided, compute the distances to it from France
                        Just { code } ->
                            db.distances
                                |> Transport.getTransportBetween emptyImpacts code france
                                |> Transport.applyTransportRatios planeRatio

                        -- Otherwise retrieve ingredient's default origin transport data
                        Nothing ->
                            ingredient.defaultOrigin
                                |> Ingredient.getDefaultOriginTransport planeTransport
            in
            if ingredient.transportCooling /= Ingredient.NoCooling then
                -- Switch the distances to use the "cooled" version of the transport medium
                { base
                    | road = Quantity.zero
                    , roadCooled = base.road
                    , sea = Quantity.zero
                    , seaCooled = base.sea
                }

            else
                base

        toTransformation t =
            -- 160km of road transport are added for every ingredient, wherever they come
            -- from (including France). This corresponds to the step "1. RECETTE" in the
            -- [transport documentation](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/transport#circuits-consideres)
            Transport.addRoadWithCooling (Length.kilometers 160) (ingredient.transportCooling == Ingredient.AlwaysCool) t

        toLogistics t =
            -- 500km of road transport are added for every ingredient that are not coming from France.
            -- This corresponds to the step "2. RECETTE" in the
            -- [transport documentation](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/transport#circuits-consideres)
            case country of
                Just { code } ->
                    if code /= Country.codeFromString "FR" then
                        Transport.addRoadWithCooling (Length.kilometers 500) (ingredient.transportCooling == Ingredient.AlwaysCool) t

                    else
                        t

                Nothing ->
                    if ingredient.defaultOrigin /= Origin.France then
                        Transport.addRoadWithCooling (Length.kilometers 500) (ingredient.transportCooling == Ingredient.AlwaysCool) t

                    else
                        t

        transport =
            baseTransport
                |> toTransformation
                |> toLogistics

        modes =
            convertWellKnownToTransportModes db.food.wellKnown
    in
    Transport.computeImpacts modes mass transport


preparationListFromQuery : Query -> Result String (List Preparation)
preparationListFromQuery =
    .preparation
        >> List.map Preparation.findById
        >> RE.combine


deletePackaging : Process.Id -> Query -> Query
deletePackaging id query =
    { query
        | packaging =
            query.packaging
                |> List.filter (.id >> (/=) id)
    }


encodeResults : Results -> Encode.Value
encodeResults results =
    Encode.object
        [ ( "total", Impact.encode results.total )
        , ( "perKg", Impact.encode results.perKg )
        , ( "scoring", encodeScoring results.scoring )
        , ( "totalMass", results.totalMass |> Mass.inKilograms |> Encode.float )
        , ( "preparedMass", results.preparedMass |> Mass.inKilograms |> Encode.float )
        , ( "recipe"
          , Encode.object
                [ ( "total", Impact.encode results.recipe.total )
                , ( "ingredientsTotal", Impact.encode results.recipe.ingredientsTotal )
                , ( "totalBonusImpact", Impact.encodeComplementsImpacts results.recipe.totalComplementsImpact )
                , ( "transform", Impact.encode results.recipe.transform )
                , ( "transports", Transport.encode results.recipe.transports )
                ]
          )
        , ( "packaging", Impact.encode results.packaging )
        , ( "preparation", Impact.encode results.preparation )
        , ( "transports", Transport.encode results.transports )
        , ( "distribution"
          , Encode.object
                [ ( "total", Impact.encode results.distribution.total )
                , ( "transports", Transport.encode results.distribution.transports )
                ]
          )
        ]


encodeScoring : Scoring -> Encode.Value
encodeScoring scoring =
    Encode.object
        [ ( "all", Unit.encodeImpact scoring.all )
        , ( "climate", Unit.encodeImpact scoring.climate )
        , ( "biodiversity", Unit.encodeImpact scoring.biodiversity )
        , ( "health", Unit.encodeImpact scoring.health )
        , ( "resources", Unit.encodeImpact scoring.resources )
        ]


fromQuery : Db -> Query -> Result String Recipe
fromQuery db query =
    Ok Recipe
        |> RE.andMap (Ok query.distribution)
        |> RE.andMap (ingredientListFromQuery db query)
        |> RE.andMap (packagingListFromQuery db query)
        |> RE.andMap (preparationListFromQuery query)
        |> RE.andMap (transformFromQuery db query)


getMassAtPackaging : WellKnown -> Recipe -> Mass
getMassAtPackaging wellKnown recipe =
    Quantity.sum
        [ getTransformedIngredientsMass wellKnown recipe
        , getPackagingMass recipe
        ]


getPackagingMass : Recipe -> Mass
getPackagingMass recipe =
    recipe.packaging
        |> List.map .mass
        |> Quantity.sum


getPreparedMassAtConsumer : WellKnown -> Recipe -> Mass
getPreparedMassAtConsumer wellKnown ({ ingredients, transform, preparation } as recipe) =
    let
        cookedAtConsumer =
            preparation
                |> List.any .applyRawToCookedRatio
    in
    if not (isCookedAtPlant wellKnown transform) && cookedAtConsumer then
        ingredients
            |> List.map
                (\{ ingredient, mass } ->
                    -- apply raw to cooked ratio
                    mass |> Quantity.multiplyBy (Unit.ratioToFloat ingredient.rawToCookedRatio)
                )
            |> Quantity.sum

    else
        getTransformedIngredientsMass wellKnown recipe


isCookedAtPlant : WellKnown -> Maybe Transform -> Bool
isCookedAtPlant wellKnown transform =
    Maybe.map .process transform == Just wellKnown.cooking


removeIngredientsInedibleMass : List RecipeIngredient -> List RecipeIngredient
removeIngredientsInedibleMass =
    List.map
        (\({ mass, ingredient } as recipeIngredient) ->
            { recipeIngredient
                | mass =
                    mass
                        |> Quantity.multiplyBy (1 - Split.toFloat ingredient.inediblePart)
            }
        )


getTransformedIngredientsMass : WellKnown -> Recipe -> Mass
getTransformedIngredientsMass wellKnown { ingredients, transform } =
    ingredients
        -- Substract inedible mass from the ingredient total mass
        |> removeIngredientsInedibleMass
        |> List.map
            (\{ ingredient, mass } ->
                if isCookedAtPlant wellKnown transform then
                    -- If the product is cooked, apply raw to cook ratio to ingredient masses
                    mass |> Quantity.multiplyBy (Unit.ratioToFloat ingredient.rawToCookedRatio)

                else
                    mass
            )
        |> Quantity.sum


getTransformedIngredientsDensity : Recipe -> Density
getTransformedIngredientsDensity { ingredients, transform } =
    case ingredients of
        [ i ] ->
            -- density = 1 for a transformed ingredient
            if transform /= Nothing then
                gramsPerCubicCentimeter 1

            else
                i.ingredient.density

        _ ->
            -- density = 1 for recipes
            gramsPerCubicCentimeter 1


getTransformedIngredientsVolume : WellKnown -> Recipe -> Volume
getTransformedIngredientsVolume wellKnown recipe =
    getTransformedIngredientsMass wellKnown recipe |> Quantity.at_ (getTransformedIngredientsDensity recipe)


ingredientListFromQuery : Db -> Query -> Result String (List RecipeIngredient)
ingredientListFromQuery db =
    .ingredients >> RE.combineMap (ingredientFromQuery db)


ingredientFromQuery : Db -> BuilderQuery.IngredientQuery -> Result String RecipeIngredient
ingredientFromQuery db { country, id, mass, planeTransport } =
    let
        ingredientResult =
            Ingredient.findById id db.food.ingredients
    in
    Ok RecipeIngredient
        |> RE.andMap
            (case Maybe.map (\c -> Country.findByCode c db.countries) country of
                Just (Ok country_) ->
                    Ok (Just country_)

                Just (Err error) ->
                    Err error

                Nothing ->
                    Ok Nothing
            )
        |> RE.andMap ingredientResult
        |> RE.andMap (Ok mass)
        |> RE.andMap
            (ingredientResult
                |> Result.andThen (Ingredient.byPlaneAllowed planeTransport)
            )


ingredientQueryFromIngredient : Ingredient -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredient =
    { country = Nothing
    , id = ingredient.id
    , mass = Mass.grams 100
    , planeTransport = Ingredient.byPlaneByDefault ingredient
    }


packagingListFromQuery : Db -> { a | packaging : List BuilderQuery.ProcessQuery } -> Result String (List Packaging)
packagingListFromQuery db query =
    query.packaging
        |> RE.combineMap (packagingFromQuery db)


packagingFromQuery : Db -> BuilderQuery.ProcessQuery -> Result String Packaging
packagingFromQuery { processes } { id, mass } =
    processes
        |> Process.findById id
        |> Result.map (Packaging mass)


processQueryFromProcess : Process -> BuilderQuery.ProcessQuery
processQueryFromProcess process =
    { id = process.id
    , mass = Mass.grams 100
    }


resetTransform : Query -> Query
resetTransform query =
    { query | transform = Nothing }


resetDistribution : Query -> Query
resetDistribution query =
    { query | distribution = Nothing }


toStepsImpacts : Definition.Trigram -> Results -> Impact.StepsImpacts
toStepsImpacts trigram results =
    let
        getImpact =
            Impact.getImpact trigram
                >> Just
    in
    { distribution = getImpact results.distribution.total
    , endOfLife = Nothing
    , materials = getImpact results.recipe.ingredientsTotal
    , packaging = getImpact results.packaging
    , transform = getImpact results.recipe.transform
    , transports = getImpact results.transports.impacts
    , trims = Nothing
    , usage = getImpact results.preparation
    }


toString : Recipe -> String
toString { ingredients, packaging, transform } =
    let
        formatMass =
            Mass.inGrams >> round >> String.fromInt
    in
    [ ingredients
        |> List.map
            (\{ ingredient, mass } ->
                ingredient.name ++ " (" ++ formatMass mass ++ "g.)"
            )
        |> String.join ", "
        |> SE.nonEmpty
    , transform
        |> Maybe.map
            (\{ mass, process } ->
                Process.getDisplayName process ++ "(" ++ formatMass mass ++ ")"
            )
    , packaging
        |> List.map (.process >> Process.getDisplayName)
        |> String.join ", "
        |> SE.nonEmpty
        |> Maybe.map ((++) "Emballage: ")
    ]
        |> List.filterMap identity
        |> String.join "; "


transformFromQuery :
    Db
    -> { a | transform : Maybe BuilderQuery.ProcessQuery }
    -> Result String (Maybe Transform)
transformFromQuery { processes } query =
    query.transform
        |> Maybe.map
            (\{ id, mass } ->
                processes
                    |> Process.findById id
                    |> Result.map (Transform mass >> Just)
            )
        |> Maybe.withDefault (Ok Nothing)
