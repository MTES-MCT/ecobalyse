module Data.Food.Builder.Recipe exposing
    ( Recipe
    , RecipeIngredient
    , Results
    , Scoring
    , Transform
    , availableIngredients
    , availablePackagings
    , compute
    , computeIngredientTransport
    , computeProcessImpacts
    , deletePackaging
    , encode
    , encodeResults
    , fromQuery
    , getMassAtPackaging
    , getPackagingMass
    , getTransformedIngredientsMass
    , ingredientQueryFromIngredient
    , processQueryFromProcess
    , resetTransform
    , setCategory
    , toString
    )

import Data.Country as Country exposing (Country)
import Data.Food.Builder.Db exposing (Db)
import Data.Food.Builder.Query as BuilderQuery exposing (Query)
import Data.Food.Category as Category exposing (Category)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Origin as Origin
import Data.Food.Preparation as Preparation exposing (Preparation)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Retail as Retail
import Data.Impact as Impact exposing (Impacts)
import Data.Scope as Scope
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
    , variant : BuilderQuery.Variant
    , country : Maybe Country
    , planeTransport : Ingredient.PlaneTransport
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Transform
    , packaging : List Packaging
    , distribution : Retail.Distribution
    , preparation : List Preparation
    , category : Maybe Category
    }


type alias Results =
    { total : Impacts
    , perKg : Impacts
    , scoring : Scoring
    , totalMass : Mass
    , preparedMass : Mass
    , recipe :
        { total : Impacts
        , ingredientsTotal : Impacts
        , ingredients : List ( RecipeIngredient, Impacts )
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


type alias Score =
    { impact : Unit.Impact
    , letter : String
    , outOf100 : Int
    }


type alias Scoring =
    { category : String
    , all : Score
    , climate : Score
    , biodiversity : Score
    , health : Score
    , resources : Score
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


categoryFromQuery : Maybe Category.Id -> Result String (Maybe Category)
categoryFromQuery =
    Maybe.map (Category.get >> Result.map Just)
        >> Maybe.withDefault (Ok Nothing)


compute : Db -> Query -> Result String ( Recipe, Results )
compute db =
    -- FIXME get the wellknown early and propagate the error to the computation
    fromQuery db
        >> Result.map
            (\({ ingredients, transform, packaging, distribution, preparation, category } as recipe) ->
                let
                    updateImpacts impacts =
                        impacts
                            |> Impact.sumImpacts db.impacts
                            |> Impact.updateAggregatedScores db.impacts

                    ingredientsImpacts =
                        ingredients
                            |> List.map
                                (\recipeIngredient ->
                                    recipeIngredient
                                        |> computeIngredientImpacts
                                        |> Impact.updateAggregatedScores db.impacts
                                        |> Tuple.pair recipeIngredient
                                )

                    ingredientsTotalImpacts =
                        ingredientsImpacts
                            |> List.map Tuple.second
                            |> Impact.sumImpacts db.impacts

                    ingredientsTransport =
                        ingredients
                            -- FIXME pass the wellknown to computeIngredientTransport
                            |> List.map (computeIngredientTransport db)
                            |> Transport.sum db.impacts

                    transformImpacts =
                        transform
                            |> Maybe.map (computeProcessImpacts db.impacts >> List.singleton >> updateImpacts)
                            |> Maybe.withDefault Impact.noImpacts

                    distributionImpacts =
                        let
                            volume =
                                getTransformedIngredientsVolume recipe
                        in
                        Result.map (Retail.computeImpacts db volume distribution)
                            (Process.loadWellKnown db.processes)

                    distributionTransport =
                        let
                            mass =
                                getMassAtPackaging recipe
                        in
                        Result.map (Retail.distributionTransportImpact db mass distribution)
                            (Process.loadWellKnown db.processes)

                    recipeImpacts =
                        updateImpacts
                            [ ingredientsTotalImpacts
                            , transformImpacts
                            , ingredientsTransport.impacts
                            ]

                    transformedIngredientsMass =
                        getTransformedIngredientsMass recipe

                    packagingImpacts =
                        packaging
                            |> List.map (computeProcessImpacts db.impacts)
                            |> updateImpacts

                    preparationImpacts =
                        preparation
                            |> RE.combineMap (Preparation.apply db transformedIngredientsMass)
                            |> Result.map (Impact.sumImpacts db.impacts >> List.singleton >> updateImpacts)

                    preparedMass =
                        getEdiblePreparedMass recipe

                    totalImpacts =
                        [ Ok recipeImpacts
                        , Ok packagingImpacts
                        , distributionImpacts
                        , distributionTransport |> Result.map .impacts
                        , preparationImpacts
                        ]
                            |> RE.combine
                            |> Result.map (Impact.sumImpacts db.impacts)

                    impactsPerKg =
                        -- Note: Product impacts per kg is computed against edible
                        --       product mass as consumer, excluding packaging
                        totalImpacts
                            |> Result.map (Impact.perKg preparedMass)

                    scoring =
                        impactsPerKg
                            |> Result.map (computeScoring db.impacts category)
                in
                Ok
                    (\total perKg distrib distribTransport preparationImpacts_ score ->
                        ( recipe
                        , { total = total
                          , perKg = perKg
                          , scoring = score
                          , totalMass = getMassAtPackaging recipe
                          , preparedMass = preparedMass
                          , recipe =
                                { total = recipeImpacts
                                , ingredientsTotal = ingredientsTotalImpacts
                                , ingredients = ingredientsImpacts
                                , transform = transformImpacts
                                , transports = ingredientsTransport
                                , transformedMass = transformedIngredientsMass
                                }
                          , packaging = packagingImpacts
                          , distribution =
                                { total = distrib
                                , transports = distribTransport
                                }
                          , preparation = preparationImpacts_
                          , transports =
                                Transport.sum db.impacts
                                    [ ingredientsTransport
                                    , distribTransport
                                    ]
                          }
                        )
                    )
                    |> RE.andMap totalImpacts
                    |> RE.andMap impactsPerKg
                    |> RE.andMap distributionImpacts
                    |> RE.andMap distributionTransport
                    |> RE.andMap preparationImpacts
                    |> RE.andMap scoring
            )
        >> RE.join


computeScoring : List Impact.Definition -> Maybe Category -> Impacts -> Scoring
computeScoring defs maybeCategory perKg =
    let
        -- Note: Score out of 100 is only computed for ecoscore
        ecsPerKg =
            perKg
                |> Impact.getImpact (Impact.trg "ecs")

        subScores =
            perKg
                |> Impact.toProtectionAreas defs

        makeScore get scoreImpact =
            let
                outOf100 =
                    case maybeCategory of
                        Just { bounds } ->
                            scoreImpact
                                |> Impact.getBoundedScoreOutOf100 (get bounds)

                        Nothing ->
                            -- Note: if no category is specified, all subscores equal the main score
                            ecsPerKg
                                |> Impact.getAggregatedScoreOutOf100
            in
            { outOf100 = outOf100
            , letter = Impact.getAggregatedScoreLetter outOf100
            , impact = scoreImpact
            }
    in
    { category = maybeCategory |> Maybe.map .name |> Maybe.withDefault "Toutes les catégories"
    , all = makeScore .all ecsPerKg
    , climate = makeScore .climate subScores.climate
    , biodiversity = makeScore .biodiversity subScores.biodiversity
    , health = makeScore .health subScores.health
    , resources = makeScore .resources subScores.resources
    }


computeImpact : Mass -> Impact.Trigram -> Unit.Impact -> Unit.Impact
computeImpact mass _ =
    Unit.impactToFloat
        >> (*) (Mass.inKilograms mass)
        >> Unit.impact


computeProcessImpacts : List Impact.Definition -> { a | process : Process, mass : Mass } -> Impacts
computeProcessImpacts defs item =
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)
        |> Impact.updateAggregatedScores defs


computeIngredientImpacts : RecipeIngredient -> Impacts
computeIngredientImpacts ({ mass } as recipeIngredient) =
    recipeIngredient
        |> getRecipeIngredientProcess
        |> .impacts
        |> Impact.mapImpacts (computeImpact mass)


computeIngredientTransport : Db -> RecipeIngredient -> Transport
computeIngredientTransport db { ingredient, country, mass, planeTransport } =
    let
        emptyImpacts =
            Impact.impactsFromDefinitons db.impacts

        planeRatio =
            -- Special case: if the default origin of an ingredient is "by plane"
            -- and we selected a transport by plane, then we take an air transport ratio of 1
            Unit.Ratio
                (if planeTransport == Ingredient.ByPlane then
                    1

                 else
                    0
                )

        baseTransport =
            case country of
                -- In case a custom country is provided, compute the distances to it from France
                Just { code } ->
                    db.transports
                        |> Transport.getTransportBetween Scope.Food emptyImpacts code france
                        |> Formula.transportRatio planeRatio

                -- Otherwise retrieve ingredient's default origin transport data
                Nothing ->
                    ingredient.defaultOrigin
                        |> Ingredient.getDefaultOriginTransport db.impacts planeTransport

        toTransformation t =
            -- 160km of road transport are added for every ingredient, wherever they come
            -- from (including France). This corresponds to the step "1. RECETTE" in the
            -- [transport documentation](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/transport#circuits-consideres)
            { t | road = t.road |> Quantity.plus (Length.kilometers 160) }

        toLogistics t =
            -- 500km of road transport are added for every ingredient that are not coming from France.
            -- This corresponds to the step "2. RECETTE" in the
            -- [transport documentation](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/transport#circuits-consideres)
            case country of
                Just { code } ->
                    if code /= Country.codeFromString "FR" then
                        { t | road = t.road |> Quantity.plus (Length.kilometers 500) }

                    else
                        t

                Nothing ->
                    if ingredient.defaultOrigin /= Origin.France then
                        { t | road = t.road |> Quantity.plus (Length.kilometers 500) }

                    else
                        t

        transport =
            baseTransport
                |> toTransformation
                |> toLogistics
    in
    { transport
        | impacts =
            db.processes
                |> Process.loadWellKnown
                |> Result.map
                    (\wellKnown ->
                        [ ( wellKnown.lorryTransport, transport.road )
                        , ( wellKnown.boatTransport, transport.sea )
                        , ( wellKnown.planeTransport, transport.air )
                        ]
                            |> List.map
                                (\( transportProcess, distance ) ->
                                    transportProcess.impacts
                                        |> Impact.mapImpacts
                                            (\_ impact ->
                                                impact
                                                    |> Unit.impactToFloat
                                                    |> (*) (Mass.inMetricTons mass * Length.inKilometers distance)
                                                    |> Unit.impact
                                            )
                                )
                    )
                |> Result.withDefault []
                |> Impact.sumImpacts db.impacts
                |> Impact.updateAggregatedScores db.impacts
    }


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


encodeIngredient : BuilderQuery.IngredientQuery -> Encode.Value
encodeIngredient i =
    Encode.object
        [ ( "id", Ingredient.encodeId i.id )
        , ( "name", Encode.string i.name )
        , ( "mass", Encode.float (Mass.inKilograms i.mass) )
        , ( "variant", variantToString i.variant |> Encode.string )
        , ( "country", i.country |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        ]


encodeProcess : BuilderQuery.ProcessQuery -> Encode.Value
encodeProcess p =
    Encode.object
        [ ( "code", p.code |> Process.codeToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms p.mass) )
        ]


encode : Query -> Encode.Value
encode q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "transform", q.transform |> Maybe.map encodeProcess |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list encodeProcess q.packaging )
        , ( "preparation", Encode.list Preparation.encodeId q.preparation )
        , ( "distribution", Retail.encode q.distribution )
        ]


encodeResults : List Impact.Definition -> Results -> Encode.Value
encodeResults defs results =
    let
        encodeImpacts =
            Impact.encodeImpacts defs Scope.Food
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
                , ( "transform", encodeImpacts results.recipe.transform )
                , ( "transports", Transport.encode defs results.recipe.transports )
                ]
          )
        , ( "packaging", encodeImpacts results.packaging )
        , ( "preparation", encodeImpacts results.preparation )
        , ( "transports", Transport.encode defs results.transports )
        , ( "distribution"
          , Encode.object
                [ ( "total", encodeImpacts results.distribution.total )
                , ( "transports", Transport.encode defs results.distribution.transports )
                ]
          )
        ]


encodeScore : Score -> Encode.Value
encodeScore score =
    Encode.object
        [ ( "impact", Unit.encodeImpact score.impact )
        , ( "letter", Encode.string score.letter )
        , ( "outOf100", Encode.int score.outOf100 )
        ]


encodeScoring : Scoring -> Encode.Value
encodeScoring scoring =
    Encode.object
        [ ( "category", Encode.string scoring.category )
        , ( "all", encodeScore scoring.all )
        , ( "climate", encodeScore scoring.climate )
        , ( "biodiversity", encodeScore scoring.biodiversity )
        , ( "health", encodeScore scoring.health )
        , ( "resources", encodeScore scoring.resources )
        ]


fromQuery : Db -> Query -> Result String Recipe
fromQuery db query =
    Ok Recipe
        |> RE.andMap (ingredientListFromQuery db query)
        |> RE.andMap (transformFromQuery db query)
        |> RE.andMap (packagingListFromQuery db query)
        |> RE.andMap (Ok query.distribution)
        |> RE.andMap (preparationListFromQuery query)
        |> RE.andMap (categoryFromQuery query.category)


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


getEdiblePreparedMass : Recipe -> Mass
getEdiblePreparedMass ({ ingredients, transform, preparation } as recipe) =
    let
        cookedAtPlant =
            case transform |> Maybe.andThen (.process >> .alias) of
                Just "cooking" ->
                    True

                _ ->
                    False

        cookedAtConsumer =
            (preparation |> List.filter .applyRawToCookedRatio |> List.length) > 0
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


getTransformedIngredientsMass : Recipe -> Mass
getTransformedIngredientsMass { ingredients, transform } =
    ingredients
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
getRecipeIngredientProcess { ingredient, variant } =
    case variant of
        BuilderQuery.DefaultVariant ->
            ingredient.default

        BuilderQuery.Organic ->
            ingredient.variants.organic
                |> Maybe.withDefault ingredient.default


ingredientListFromQuery : Db -> Query -> Result String (List RecipeIngredient)
ingredientListFromQuery db =
    .ingredients >> RE.combineMap (ingredientFromQuery db)


ingredientFromQuery : Db -> BuilderQuery.IngredientQuery -> Result String RecipeIngredient
ingredientFromQuery { countries, ingredients } { id, mass, variant, country, planeTransport } =
    Result.map5 RecipeIngredient
        (Ingredient.findByID id ingredients)
        (Ok mass)
        (Ok variant)
        (case Maybe.map (\c -> Country.findByCode c countries) country of
            Just (Ok country_) ->
                Ok (Just country_)

            Just (Err error) ->
                Err error

            Nothing ->
                Ok Nothing
        )
        (Ingredient.findByID id ingredients
            |> Result.andThen (Ingredient.byPlaneAllowed planeTransport)
        )


ingredientQueryFromIngredient : Ingredient -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredient =
    { id = ingredient.id
    , name = ingredient.name
    , mass = Mass.grams 100
    , variant = BuilderQuery.DefaultVariant
    , country = Nothing
    , planeTransport = Ingredient.byPlaneByDefault ingredient
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


setCategory : Maybe Category.Id -> Query -> Query
setCategory maybeId query =
    { query | category = maybeId }


toString : Recipe -> String
toString { ingredients, transform, packaging } =
    let
        formatMass =
            Mass.inGrams >> round >> String.fromInt
    in
    [ ingredients
        |> List.map
            (\{ ingredient, mass, variant } ->
                ingredient.name
                    ++ " ("
                    ++ (case variant of
                            BuilderQuery.Organic ->
                                "bio, "

                            _ ->
                                ""
                       )
                    ++ formatMass mass
                    ++ "g.)"
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


variantToString : BuilderQuery.Variant -> String
variantToString variant =
    case variant of
        BuilderQuery.DefaultVariant ->
            "default"

        BuilderQuery.Organic ->
            "organic"
