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
    , decodeResults
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
import Data.Food.Db as Food
import Data.Food.EcosystemicServices as EcosystemicServices exposing (EcosystemicServices)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Origin as Origin
import Data.Food.Preparation as Preparation exposing (Preparation)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Query as BuilderQuery exposing (Query)
import Data.Food.Retail as Retail
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Scope as Scope
import Data.Scoring as Scoring exposing (Scoring)
import Data.Split as Split
import Data.Textile.Formula as Formula
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Density exposing (Density, gramsPerCubicCentimeter)
import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
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
    { process : Process.Process
    , mass : Mass
    }


type alias RecipeIngredient =
    { ingredient : Ingredient
    , mass : Mass
    , country : Maybe Country
    , planeTransport : Ingredient.PlaneTransport
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Transform
    , packaging : List Packaging
    , distribution : Maybe Retail.Distribution
    , preparation : List Preparation
    }


type alias RecipeImpacts =
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


type alias Results =
    { inputs : Recipe
    , total : Impacts
    , perKg : Impacts
    , scoring : Scoring
    , totalMass : Mass
    , preparedMass : Mass
    , recipe : RecipeImpacts
    , packaging : Impacts
    , distribution : ResultsDistribution
    , preparation : Impacts
    , transports : Transport
    }


type alias ResultsDistribution =
    { total : Impacts
    , transports : Transport
    }


type alias Transform =
    { process : Process.Process
    , mass : Mass
    }


availableIngredients : List Ingredient.Id -> List Ingredient -> List Ingredient
availableIngredients usedIngredientIds =
    List.filter (\{ id } -> not (List.member id usedIngredientIds))


availablePackagings : List Process.Identifier -> List Process -> List Process
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
                                    Retail.computeImpacts volume distrib db.food.wellKnown
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
                                    |> Maybe.withDefault (Transport.default Nothing)
                        in
                        Transport.computeImpacts db.food mass transport

                    recipeImpacts =
                        Impact.sumImpacts
                            [ ingredientsTotalImpacts
                            , transformImpacts
                            , ingredientsTransport.impacts
                                |> Maybe.withDefault Impact.empty
                            ]

                    transformedIngredientsMass =
                        getTransformedIngredientsMass recipe

                    packagingImpacts =
                        packaging
                            |> List.map computeProcessImpacts
                            |> Impact.sumImpacts

                    preparationImpacts =
                        preparation
                            |> List.map (Preparation.apply db.food transformedIngredientsMass)
                            |> (Impact.sumImpacts >> List.singleton >> Impact.sumImpacts)

                    preparedMass =
                        getPreparedMassAtConsumer recipe

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
                                |> Maybe.withDefault Impact.empty
                            , preparationImpacts
                            ]

                    totalImpacts =
                        totalImpactsWithoutComplements
                            |> Impact.updateAggregatedScores db.definitions
                            |> addIngredientsComplements

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
                , { inputs = recipe
                  , total = totalImpacts
                  , perKg = impactsPerKg
                  , scoring = scoring
                  , totalMass = getMassAtPackaging recipe
                  , preparedMass = preparedMass
                  , recipe =
                        { total = addIngredientsComplements recipeImpacts
                        , initialMass = recipe.ingredients |> List.map .mass |> Quantity.sum
                        , edibleMass = removeIngredientsInedibleMass recipe.ingredients |> List.map .mass |> Quantity.sum
                        , ingredientsTotal = addIngredientsComplements ingredientsTotalImpacts
                        , ingredients = ingredientsImpacts
                        , totalComplementsImpact = totalComplementsImpact
                        , totalComplementsImpactPerKg = totalComplementsImpactPerKg
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


computeIngredientComplementsImpacts : EcosystemicServices -> Mass -> Impact.ComplementsImpacts
computeIngredientComplementsImpacts { hedges, plotSize, cropDiversity, permanentPasture, livestockDensity } ingredientMass =
    let
        apply coeff =
            Quantity.multiplyBy (Mass.inKilograms ingredientMass)
                >> Quantity.multiplyBy (Unit.ratioToFloat coeff)
    in
    { hedges = apply EcosystemicServices.coefficients.hedges hedges
    , plotSize = apply EcosystemicServices.coefficients.plotSize plotSize
    , cropDiversity = apply EcosystemicServices.coefficients.cropDiversity cropDiversity
    , permanentPasture = apply EcosystemicServices.coefficients.permanentPasture permanentPasture
    , livestockDensity = apply EcosystemicServices.coefficients.livestockDensity livestockDensity

    -- Note: these complements don't apply to ingredients
    , microfibers = Unit.impact 0
    , outOfEuropeEOL = Unit.impact 0
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
computeIngredientTransport db { ingredient, country, mass, planeTransport } =
    let
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
                                |> Transport.getTransportBetween Scope.Food code france
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
    Transport.computeImpacts db.food mass transport


preparationListFromQuery : Query -> Result String (List Preparation)
preparationListFromQuery =
    .preparation
        >> List.map Preparation.findById
        >> RE.combine


deletePackaging : Process.Identifier -> Query -> Query
deletePackaging code query =
    { query
        | packaging =
            query.packaging
                |> List.filter (.code >> (/=) code)
    }


encodeResults : Results -> Encode.Value
encodeResults results =
    Encode.object
        [ ( "inputs", BuilderQuery.encode (toQuery results.inputs) )
        , ( "total", Impact.encode results.total )
        , ( "perKg", Impact.encode results.perKg )
        , ( "scoring", encodeScoring results.scoring )
        , ( "totalMass", results.totalMass |> Mass.inKilograms |> Encode.float )
        , ( "preparedMass", results.preparedMass |> Mass.inKilograms |> Encode.float )
        , ( "recipe", encodeRecipe results.recipe )
        , ( "packaging", Impact.encode results.packaging )
        , ( "distribution", encodeDistribution results.distribution )
        , ( "preparation", Impact.encode results.preparation )
        , ( "transports", Transport.encode results.transports )
        ]


decodeResults : Db -> Decoder Results
decodeResults db =
    Decode.succeed Results
        |> Pipe.required "inputs" (BuilderQuery.decode |> Decode.andThen (fromQuery db >> DE.fromResult))
        |> Pipe.required "total" (Impact.decodeImpacts db.definitions)
        |> Pipe.required "perKg" (Impact.decodeImpacts db.definitions)
        |> Pipe.required "scoring" decodeScoring
        |> Pipe.required "totalMass" (Decode.float |> Decode.map Mass.kilograms)
        |> Pipe.required "preparedMass" (Decode.float |> Decode.map Mass.kilograms)
        |> Pipe.required "recipe" (decodeRecipe db)
        |> Pipe.required "packaging" (Impact.decodeImpacts db.definitions)
        |> Pipe.required "distribution" (decodeDistribution db.definitions)
        |> Pipe.required "preparation" (Impact.decodeImpacts db.definitions)
        |> Pipe.required "transports" (Transport.decode db.definitions)



--    Encode.object
--       [ ( "total", Impact.encode results.distribution.total )
--       , ( "transports", Transport.encode results.distribution.transports )
--       ]
-- )


encodeScoring : Scoring -> Encode.Value
encodeScoring scoring =
    Encode.object
        [ ( "all", Unit.encodeImpact scoring.all )
        , ( "allWithoutComplements", Unit.encodeImpact scoring.allWithoutComplements )
        , ( "complements", Unit.encodeImpact scoring.complements )
        , ( "climate", Unit.encodeImpact scoring.climate )
        , ( "biodiversity", Unit.encodeImpact scoring.biodiversity )
        , ( "health", Unit.encodeImpact scoring.health )
        , ( "resources", Unit.encodeImpact scoring.resources )
        ]


decodeScoring : Decoder Scoring
decodeScoring =
    Decode.succeed Scoring
        |> Pipe.required "all" Unit.decodeImpact
        |> Pipe.required "allWithoutComplements" Unit.decodeImpact
        |> Pipe.required "complements" Unit.decodeImpact
        |> Pipe.required "climate" Unit.decodeImpact
        |> Pipe.required "biodiversity" Unit.decodeImpact
        |> Pipe.required "health" Unit.decodeImpact
        |> Pipe.required "resources" Unit.decodeImpact


encodeDistribution : ResultsDistribution -> Encode.Value
encodeDistribution distribution =
    Encode.object
        [ ( "total", Impact.encode distribution.total )
        , ( "transports", Transport.encode distribution.transports )
        ]


decodeDistribution : Definitions -> Decoder ResultsDistribution
decodeDistribution definitions =
    Decode.succeed ResultsDistribution
        |> Pipe.required "total" (Impact.decodeImpacts definitions)
        |> Pipe.required "transports" (Transport.decode definitions)


decodeRecipe : Db -> Decoder RecipeImpacts
decodeRecipe ({ definitions } as db) =
    Decode.succeed RecipeImpacts
        |> Pipe.required "total" (Impact.decodeImpacts definitions)
        |> Pipe.required "initialMass" (Decode.float |> Decode.map Mass.grams)
        |> Pipe.required "edibleMass" (Decode.float |> Decode.map Mass.grams)
        |> Pipe.required "ingredientsTotal" (Impact.decodeImpacts definitions)
        |> Pipe.required "ingredients" (Decode.list (decodeRecipeIngredient db))
        |> Pipe.required "totalComplementsImpact" Impact.decodeComplementsImpacts
        |> Pipe.required "totalComplementsImpactPerKg" Impact.decodeComplementsImpacts
        |> Pipe.required "transform" (Impact.decodeImpacts definitions)
        |> Pipe.required "transports" (Transport.decode definitions)
        |> Pipe.required "transformedMass" (Decode.float |> Decode.map Mass.grams)


encodeRecipe : RecipeImpacts -> Encode.Value
encodeRecipe recipe =
    Encode.object
        [ ( "total", Impact.encode recipe.total )
        , ( "initialMass", recipe.initialMass |> Mass.inKilograms |> Encode.float )
        , ( "edibleMass", recipe.edibleMass |> Mass.inKilograms |> Encode.float )
        , ( "ingredientsTotal", Impact.encode recipe.ingredientsTotal )
        , ( "ingredients", Encode.list encodeRecipeIngredient recipe.ingredients )
        , ( "totalComplementsImpact", Impact.encodeComplementsImpacts recipe.totalComplementsImpact )
        , ( "totalComplementsImpactPerKg", Impact.encodeComplementsImpacts recipe.totalComplementsImpactPerKg )
        , ( "transform", Impact.encode recipe.transform )
        , ( "transports", Transport.encode recipe.transports )
        , ( "transformedMass", recipe.transformedMass |> Mass.inKilograms |> Encode.float )
        ]


decodeRecipeIngredient : Db -> Decoder ( RecipeIngredient, Impacts )
decodeRecipeIngredient { definitions, food, textile } =
    Decode.succeed Tuple.pair
        |> Pipe.required "ingredient"
            (Decode.succeed RecipeIngredient
                |> Pipe.required "ingredient"
                    (food.processes
                        |> List.map (\process -> ( Process.codeToString process.code, process ))
                        |> Dict.fromList
                        |> Ingredient.decodeIngredient
                    )
                |> Pipe.required "mass" (Decode.float |> Decode.map Mass.grams)
                |> Pipe.required "country" (Decode.maybe (Country.decode textile.processes))
                |> Pipe.required "planeTransport" Ingredient.decodePlaneTransport
            )
        |> Pipe.required "impacts" (Impact.decodeImpacts definitions)


encodeRecipeIngredient : ( RecipeIngredient, Impacts ) -> Encode.Value
encodeRecipeIngredient ( recipeIngredient, impacts ) =
    Encode.object
        [ ( "ingredient"
          , Encode.object
                [ ( "ingredient", Ingredient.encodeIngredient recipeIngredient.ingredient )
                , ( "mass", Mass.inGrams recipeIngredient.mass |> Encode.float )
                , ( "country", recipeIngredient.country |> Maybe.map Country.encode |> Maybe.withDefault Encode.null )
                , ( "planeTransport", Ingredient.encodePlaneTransport recipeIngredient.planeTransport |> Maybe.withDefault Encode.null )
                ]
          )
        , ( "impacts", Impact.encode impacts )
        ]


fromQuery : Db -> Query -> Result String Recipe
fromQuery db query =
    Ok Recipe
        |> RE.andMap (ingredientListFromQuery db query)
        |> RE.andMap (transformFromQuery db.food query)
        |> RE.andMap (packagingListFromQuery db.food query)
        |> RE.andMap (Ok query.distribution)
        |> RE.andMap (preparationListFromQuery query)


toQuery : Recipe -> Query
toQuery recipe =
    { ingredients = List.map toIngredientQuery recipe.ingredients
    , transform = recipe.transform |> Maybe.map toProcessQuery
    , packaging = recipe.packaging |> List.map toProcessQuery
    , distribution = recipe.distribution
    , preparation = recipe.preparation |> List.map .id
    }


toIngredientQuery : RecipeIngredient -> BuilderQuery.IngredientQuery
toIngredientQuery ingredient =
    { id = ingredient.ingredient.id
    , mass = ingredient.mass
    , country = ingredient.country |> Maybe.map .code
    , planeTransport = ingredient.planeTransport
    }


toProcessQuery : { a | process : Process, mass : Mass } -> BuilderQuery.ProcessQuery
toProcessQuery process =
    { code = process.process.code
    , mass = process.mass
    }


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
            case transform |> Maybe.map (.process >> .id_) of
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
                case transform |> Maybe.map (.process >> .id_) of
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
ingredientFromQuery db { id, mass, country, planeTransport } =
    let
        ingredientResult =
            Ingredient.findByID id db.food.ingredients
    in
    Ok RecipeIngredient
        |> RE.andMap ingredientResult
        |> RE.andMap (Ok mass)
        |> RE.andMap
            (case Maybe.map (\c -> Country.findByCode c db.countries) country of
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


ingredientQueryFromIngredient : Ingredient -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredient =
    { id = ingredient.id
    , mass = Mass.grams 100
    , country = Nothing
    , planeTransport = Ingredient.byPlaneByDefault ingredient
    }


packagingListFromQuery :
    Food.Db
    -> { a | packaging : List BuilderQuery.ProcessQuery }
    -> Result String (List Packaging)
packagingListFromQuery db query =
    query.packaging
        |> RE.combineMap (packagingFromQuery db)


packagingFromQuery : Food.Db -> BuilderQuery.ProcessQuery -> Result String Packaging
packagingFromQuery { processes } { code, mass } =
    Result.map2 Packaging
        (Process.findByIdentifier code processes)
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


toStepsImpacts : Definition.Trigram -> Results -> Impact.StepsImpacts
toStepsImpacts trigram results =
    let
        getImpact =
            Impact.getImpact trigram
                >> Just
    in
    { materials = getImpact results.recipe.ingredientsTotal
    , transform = getImpact results.recipe.transform
    , packaging = getImpact results.packaging
    , transports =
        results.transports.impacts
            |> Maybe.withDefault Impact.empty
            |> getImpact
    , distribution = getImpact results.distribution.total
    , usage = getImpact results.preparation
    , endOfLife = Nothing
    }


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
    Food.Db
    -> { a | transform : Maybe BuilderQuery.ProcessQuery }
    -> Result String (Maybe Transform)
transformFromQuery { processes } query =
    query.transform
        |> Maybe.map
            (\transform ->
                Result.map2 Transform
                    (Process.findByIdentifier transform.code processes)
                    (Ok transform.mass)
                    |> Result.map Just
            )
        |> Maybe.withDefault (Ok Nothing)
