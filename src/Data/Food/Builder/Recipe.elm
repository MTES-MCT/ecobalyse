module Data.Food.Builder.Recipe exposing
    ( Recipe
    , RecipeIngredient
    , Results
    , Scoring
    , Transform
    , availableIngredients
    , availablePackagings
    , compute
    , computeIngredientBonusesImpacts
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
    , toString
    )

import Data.Country as Country exposing (Country)
import Data.Food.Builder.Db exposing (Db)
import Data.Food.Builder.Query as BuilderQuery exposing (Query)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Origin as Origin
import Data.Food.Preparation as Preparation exposing (Preparation)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Retail as Retail
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Scope as Scope
import Data.Split as Split
import Data.Textile.Formula as Formula
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Density exposing (Density, gramsPerCubicCentimeter)
import Json.Encode as Encode
import Length
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import String.Extra as SE
import Volume exposing (Volume)


france : Country.Code
france =
    Country.codeFromString "FR"


type alias Packaging =
    { process : Process.Process
    , mass : Mass
    }


type alias RecipeIngredient =
    { ingredient : Ingredient
    , mass : Mass
    , country : Maybe Country
    , planeTransport : Ingredient.PlaneTransport
    , complements : Ingredient.Bonuses
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Transform
    , packaging : List Packaging
    , distribution : Maybe Retail.Distribution
    , preparation : List Preparation
    }


type alias Results =
    { total : Impacts
    , perKg : Impacts
    , scoring : Scoring
    , totalMass : Mass
    , preparedMass : Mass
    , recipe :
        { total : Impacts
        , initialMass : Mass
        , edibleMass : Mass
        , ingredientsTotal : Impacts
        , ingredients : List ( RecipeIngredient, Impacts )
        , totalBonusesImpact : Impact.BonusImpacts
        , totalBonusesImpactPerKg : Impact.BonusImpacts
        , transform : Impacts
        , transports : Transport
        , transformedMass : Mass
        }
    , packaging : Impacts
    , distribution :
        { total : Impacts
        , transports : Transport
        }
    , preparation : Impacts
    , transports : Transport
    }


type alias Scoring =
    { all : Unit.Impact
    , allWithoutBonuses : Unit.Impact
    , bonuses : Unit.Impact
    , climate : Unit.Impact
    , biodiversity : Unit.Impact
    , health : Unit.Impact
    , resources : Unit.Impact
    }


type alias Transform =
    { process : Process.Process
    , mass : Mass
    }


availableIngredients : List Ingredient.Id -> List Ingredient -> List Ingredient
availableIngredients usedIngredientIds =
    List.filter (\{ id } -> not (List.member id usedIngredientIds))


availablePackagings : List Process.Code -> List Process -> List Process
availablePackagings usedProcesses processes =
    processes
        |> Process.listByCategory Process.Packaging
        |> List.filter (\process -> not (List.member process.code usedProcesses))


compute : Db -> Query -> Result String ( Recipe, Results )
compute db =
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
                                            getTransformedIngredientsVolume recipe
                                    in
                                    Retail.computeImpacts volume distrib db.wellKnown
                                )
                            |> Maybe.withDefault Impact.empty

                    distributionTransportNeedsCooling =
                        ingredients
                            |> List.any (.ingredient >> .transportCooling >> (/=) Ingredient.NoCooling)

                    distributionTransport =
                        let
                            mass =
                                getMassAtPackaging recipe

                            transport =
                                distribution
                                    |> Maybe.map
                                        (\distrib ->
                                            Retail.distributionTransport distrib distributionTransportNeedsCooling
                                        )
                                    |> Maybe.withDefault (Transport.default Impact.empty)
                        in
                        Transport.computeImpacts db mass transport

                    recipeImpacts =
                        Impact.sumImpacts
                            [ ingredientsTotalImpacts
                            , transformImpacts
                            , ingredientsTransport.impacts
                            ]

                    transformedIngredientsMass =
                        getTransformedIngredientsMass recipe

                    packagingImpacts =
                        packaging
                            |> List.map computeProcessImpacts
                            |> Impact.sumImpacts

                    preparationImpacts =
                        preparation
                            |> List.map (Preparation.apply db transformedIngredientsMass)
                            |> (Impact.sumImpacts >> List.singleton >> Impact.sumImpacts)

                    preparedMass =
                        getPreparedMassAtConsumer recipe

                    addIngredientsBonuses impacts =
                        Impact.applyBonus totalBonusesImpact.total impacts

                    totalBonusesImpact =
                        ingredients
                            |> computeIngredientsTotalBonus db.impactDefinitions

                    totalBonusesImpactPerKg =
                        { totalBonusesImpact
                            | agroDiversity = Quantity.divideBy (Mass.inKilograms preparedMass) totalBonusesImpact.agroDiversity
                            , agroEcology = Quantity.divideBy (Mass.inKilograms preparedMass) totalBonusesImpact.agroEcology
                            , animalWelfare = Quantity.divideBy (Mass.inKilograms preparedMass) totalBonusesImpact.animalWelfare
                            , total = Quantity.divideBy (Mass.inKilograms preparedMass) totalBonusesImpact.total
                        }

                    totalImpactsWithoutBonuses =
                        Impact.sumImpacts
                            [ recipeImpacts
                            , packagingImpacts
                            , distributionImpacts
                            , distributionTransport.impacts
                            , preparationImpacts
                            ]

                    totalImpacts =
                        addIngredientsBonuses totalImpactsWithoutBonuses

                    -- Note: Product impacts per kg is computed against prepared
                    --       product mass at consumer, excluding packaging
                    impactsPerKg =
                        totalImpacts
                            |> Impact.perKg preparedMass

                    impactsPerKgWithoutBonuses =
                        totalImpactsWithoutBonuses
                            |> Impact.perKg preparedMass

                    scoring =
                        impactsPerKgWithoutBonuses
                            |> computeScoring db.impactDefinitions totalBonusesImpactPerKg.total
                in
                ( recipe
                , { total = totalImpacts
                  , perKg = impactsPerKg
                  , scoring = scoring
                  , totalMass = getMassAtPackaging recipe
                  , preparedMass = preparedMass
                  , recipe =
                        { total = addIngredientsBonuses recipeImpacts
                        , initialMass = recipe.ingredients |> List.map .mass |> Quantity.sum
                        , edibleMass = removeIngredientsInedibleMass recipe.ingredients |> List.map .mass |> Quantity.sum
                        , ingredientsTotal = addIngredientsBonuses ingredientsTotalImpacts
                        , ingredients = ingredientsImpacts
                        , totalBonusesImpact = totalBonusesImpact
                        , totalBonusesImpactPerKg = totalBonusesImpactPerKg
                        , transform = transformImpacts
                        , transports = ingredientsTransport
                        , transformedMass = transformedIngredientsMass
                        }
                  , packaging = packagingImpacts
                  , distribution =
                        { total = distributionImpacts
                        , transports = distributionTransport
                        }
                  , preparation = preparationImpacts
                  , transports =
                        Transport.sum
                            [ ingredientsTransport
                            , distributionTransport
                            ]
                  }
                )
            )


computeIngredientBonusesImpacts : Definitions -> Ingredient.Bonuses -> Impacts -> Impact.BonusImpacts
computeIngredientBonusesImpacts definitions { agroDiversity, agroEcology, animalWelfare } ingredientImpacts =
    let
        -- docs: https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/complements-hors-acv-en-construction
        ( lduNormalization, lduWeighting ) =
            definitions.ldu.ecoscoreData
                |> Maybe.map (\{ normalization, weighting } -> ( normalization, weighting ))
                |> Maybe.withDefault ( Unit.impact 0, Unit.ratio 0 )

        normalizedLandUse =
            ingredientImpacts
                |> Impact.getImpact Definition.Ldu
                |> Unit.impactAggregateScore lduNormalization lduWeighting
                |> Unit.impactToFloat

        ensurePositive x =
            clamp 0 x x

        ( agroDiversityBonus, agroEcologyBonus, animalWelfareBonus ) =
            ( ensurePositive (2.3 * Split.toFloat agroDiversity * normalizedLandUse)
            , ensurePositive (2.3 * Split.toFloat agroEcology * normalizedLandUse)
            , ensurePositive (1.5 * Split.toFloat animalWelfare * normalizedLandUse)
            )
    in
    { agroDiversity = Unit.impact agroDiversityBonus
    , agroEcology = Unit.impact agroEcologyBonus
    , animalWelfare = Unit.impact animalWelfareBonus
    , total = Unit.impact (agroDiversityBonus + agroEcologyBonus + animalWelfareBonus)
    }


computeScoring : Definitions -> Unit.Impact -> Impacts -> Scoring
computeScoring definitions totalBonusImpactPerKg perKgWithoutBonuses =
    let
        ecsPerKgWithoutBonuses =
            perKgWithoutBonuses
                |> Impact.getImpact Definition.Ecs

        subScores =
            perKgWithoutBonuses
                |> Impact.toProtectionAreas definitions
    in
    { all = Quantity.difference ecsPerKgWithoutBonuses totalBonusImpactPerKg
    , allWithoutBonuses = ecsPerKgWithoutBonuses
    , bonuses = totalBonusImpactPerKg
    , climate = subScores.climate
    , biodiversity = subScores.biodiversity
    , health = subScores.health
    , resources = subScores.resources
    }


computeImpact : Mass -> Definition.Trigram -> Unit.Impact -> Unit.Impact
computeImpact mass _ =
    Unit.impactToFloat
        >> (*) (Mass.inKilograms mass)
        >> Unit.impact


computeProcessImpacts : { a | process : Process, mass : Mass } -> Impacts
computeProcessImpacts item =
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)


computeIngredientImpacts : RecipeIngredient -> Impacts
computeIngredientImpacts ({ mass } as recipeIngredient) =
    recipeIngredient
        |> getRecipeIngredientProcess
        |> .impacts
        |> Impact.mapImpacts (computeImpact mass)


computeIngredientsTotalBonus : Definitions -> List RecipeIngredient -> Impact.BonusImpacts
computeIngredientsTotalBonus definitions =
    List.foldl
        (\({ complements } as recipeIngredient) acc ->
            recipeIngredient
                |> computeIngredientImpacts
                |> computeIngredientBonusesImpacts definitions complements
                |> Impact.addBonusImpacts acc
        )
        Impact.noBonusImpacts


computeIngredientTransport : Db -> RecipeIngredient -> Transport
computeIngredientTransport db { ingredient, country, mass, planeTransport } =
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
                            db.transports
                                |> Transport.getTransportBetween Scope.Food emptyImpacts code france
                                |> Formula.transportRatio planeRatio

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
    in
    Transport.computeImpacts db mass transport


preparationListFromQuery : Query -> Result String (List Preparation)
preparationListFromQuery =
    .preparation
        >> List.map Preparation.findById
        >> RE.combine


deletePackaging : Process.Code -> Query -> Query
deletePackaging code query =
    { query
        | packaging =
            query.packaging
                |> List.filter (.code >> (/=) code)
    }


encodeResults : Definitions -> Results -> Encode.Value
encodeResults definitions results =
    let
        encodeImpacts =
            Impact.encodeImpacts definitions Scope.Food
    in
    Encode.object
        [ ( "total", encodeImpacts results.total )
        , ( "perKg", encodeImpacts results.perKg )
        , ( "scoring", encodeScoring results.scoring )
        , ( "totalMass", results.totalMass |> Mass.inKilograms |> Encode.float )
        , ( "preparedMass", results.preparedMass |> Mass.inKilograms |> Encode.float )
        , ( "recipe"
          , Encode.object
                [ ( "total", encodeImpacts results.recipe.total )
                , ( "ingredientsTotal", encodeImpacts results.recipe.ingredientsTotal )
                , ( "totalBonusImpact", Impact.encodeBonusesImpacts results.recipe.totalBonusesImpact )
                , ( "transform", encodeImpacts results.recipe.transform )
                , ( "transports", Transport.encode definitions results.recipe.transports )
                ]
          )
        , ( "packaging", encodeImpacts results.packaging )
        , ( "preparation", encodeImpacts results.preparation )
        , ( "transports", Transport.encode definitions results.transports )
        , ( "distribution"
          , Encode.object
                [ ( "total", encodeImpacts results.distribution.total )
                , ( "transports", Transport.encode definitions results.distribution.transports )
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
        |> RE.andMap (ingredientListFromQuery db query)
        |> RE.andMap (transformFromQuery db query)
        |> RE.andMap (packagingListFromQuery db query)
        |> RE.andMap (Ok query.distribution)
        |> RE.andMap (preparationListFromQuery query)


getMassAtPackaging : Recipe -> Mass
getMassAtPackaging recipe =
    Quantity.sum
        [ getTransformedIngredientsMass recipe
        , getPackagingMass recipe
        ]


getPackagingMass : Recipe -> Mass
getPackagingMass recipe =
    recipe.packaging
        |> List.map .mass
        |> Quantity.sum


getPreparedMassAtConsumer : Recipe -> Mass
getPreparedMassAtConsumer ({ ingredients, transform, preparation } as recipe) =
    let
        cookedAtPlant =
            case transform |> Maybe.andThen (.process >> .alias) of
                Just "cooking" ->
                    True

                _ ->
                    False

        cookedAtConsumer =
            preparation
                |> List.any .applyRawToCookedRatio
    in
    if not cookedAtPlant && cookedAtConsumer then
        ingredients
            |> List.map
                (\{ ingredient, mass } ->
                    -- apply raw to cooked ratio
                    mass |> Quantity.multiplyBy (Unit.ratioToFloat ingredient.rawToCookedRatio)
                )
            |> Quantity.sum

    else
        getTransformedIngredientsMass recipe


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


getTransformedIngredientsMass : Recipe -> Mass
getTransformedIngredientsMass { ingredients, transform } =
    ingredients
        -- Substract inedible mass from the ingredient total mass
        |> removeIngredientsInedibleMass
        |> List.map
            (\{ ingredient, mass } ->
                case transform |> Maybe.andThen (.process >> .alias) of
                    Just "cooking" ->
                        -- If the product is cooked, apply raw to cook ratio to ingredient masses
                        mass |> Quantity.multiplyBy (Unit.ratioToFloat ingredient.rawToCookedRatio)

                    _ ->
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


getTransformedIngredientsVolume : Recipe -> Volume
getTransformedIngredientsVolume recipe =
    getTransformedIngredientsMass recipe |> Quantity.at_ (getTransformedIngredientsDensity recipe)


getRecipeIngredientProcess : RecipeIngredient -> Process
getRecipeIngredientProcess { ingredient } =
    -- XXX remove obsolete proxy
    ingredient.default


ingredientListFromQuery : Db -> Query -> Result String (List RecipeIngredient)
ingredientListFromQuery db =
    .ingredients >> RE.combineMap (ingredientFromQuery db)


ingredientFromQuery : Db -> BuilderQuery.IngredientQuery -> Result String RecipeIngredient
ingredientFromQuery { countries, ingredients } { id, mass, country, planeTransport, complements } =
    let
        ingredientResult =
            Ingredient.findByID id ingredients
    in
    Ok RecipeIngredient
        |> RE.andMap ingredientResult
        |> RE.andMap (Ok mass)
        |> RE.andMap
            (case Maybe.map (\c -> Country.findByCode c countries) country of
                Just (Ok country_) ->
                    Ok (Just country_)

                Just (Err error) ->
                    Err error

                Nothing ->
                    Ok Nothing
            )
        |> RE.andMap
            (ingredientResult
                |> Result.andThen (Ingredient.byPlaneAllowed planeTransport)
            )
        |> RE.andMap
            (ingredientResult
                |> Result.map
                    (\ing -> Maybe.withDefault ing.complements complements)
            )


ingredientQueryFromIngredient : Ingredient -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredient =
    { id = ingredient.id
    , mass = Mass.grams 100
    , country = Nothing
    , planeTransport = Ingredient.byPlaneByDefault ingredient
    , complements = Nothing
    }


packagingListFromQuery :
    Db
    -> { a | packaging : List BuilderQuery.ProcessQuery }
    -> Result String (List Packaging)
packagingListFromQuery db query =
    query.packaging
        |> RE.combineMap (packagingFromQuery db)


packagingFromQuery : Db -> BuilderQuery.ProcessQuery -> Result String Packaging
packagingFromQuery { processes } { code, mass } =
    Result.map2 Packaging
        (Process.findByCode processes code)
        (Ok mass)


processQueryFromProcess : Process -> BuilderQuery.ProcessQuery
processQueryFromProcess process =
    { code = process.code
    , mass = Mass.grams 100
    }


resetTransform : Query -> Query
resetTransform query =
    { query | transform = Nothing }


resetDistribution : Query -> Query
resetDistribution query =
    { query | distribution = Nothing }


toString : Recipe -> String
toString { ingredients, transform, packaging } =
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
            (\{ process, mass } ->
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
            (\transform ->
                Result.map2 Transform
                    (Process.findByCode processes transform.code)
                    (Ok transform.mass)
                    |> Result.map Just
            )
        |> Maybe.withDefault (Ok Nothing)
