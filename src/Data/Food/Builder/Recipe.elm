module Data.Food.Builder.Recipe exposing
    ( Recipe
    , RecipeIngredient
    , Results
    , Transform
    , availableIngredients
    , availablePackagings
    , compute
    , computeIngredientTransport
    , computeProcessImpacts
    , deletePackaging
    , encodeQuery
    , encodeResults
    , fromQuery
    , getMassAtPackaging
    , getTransformedIngredientsMass
    , ingredientQueryFromIngredient
    , processQueryFromProcess
    , resetTransform
    , serializeQuery
    , setCategory
    , toString
    )

import Data.Country as Country exposing (Country)
import Data.Food.Builder.Conservation as Conservation
import Data.Food.Builder.Db exposing (Db)
import Data.Food.Builder.Query as BuilderQuery exposing (Query)
import Data.Food.Category as Category exposing (Category)
import Data.Food.Ingredient as Ingredient exposing (Id, Ingredient)
import Data.Food.Origin as Origin
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact exposing (Impacts)
import Data.Scope as Scope
import Data.Textile.Formula as Formula
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Density exposing (Density)
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
    , byPlane : Maybe Bool
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Transform
    , packaging : List Packaging
    , conservation : Maybe Conservation.Conservation
    , category : Maybe Category
    }


type alias Results =
    { total : Impacts
    , perKg : Impacts
    , scoring : Scoring
    , totalMass : Mass
    , recipe :
        { total : Impacts
        , ingredientsTotal : Impacts
        , ingredients : List ( RecipeIngredient, Impacts )
        , transform : Impacts
        , transports : Transport
        , conservation : Impacts
        }
    , packaging : Impacts
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


availableIngredients : List Id -> List Ingredient -> List Ingredient
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
            (\({ ingredients, transform, packaging, conservation, category } as recipe) ->
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

                    conservationImpacts =
                        let
                            wellknown =
                                db.processes
                                    |> Process.loadWellKnown

                            mass =
                                ingredients
                                    |> List.map .mass
                                    |> Quantity.sum

                            volume =
                                ingredients
                                    |> List.foldl
                                        (\ingredient tvolume ->
                                            Quantity.plus tvolume (ingredient.mass |> Quantity.at_ (Density.gramsPerCubicCentimeter ingredient.ingredient.density))
                                        )
                                        (Volume.liters 0.0)
                        in
                        Result.map2 (Conservation.computeImpacts db mass volume)
                            wellknown
                            (conservation
                                |> Result.fromMaybe "No conservation defined"
                            )

                    recipeImpacts =
                        updateImpacts
                            [ ingredientsTotalImpacts
                            , transformImpacts
                            , ingredientsTransport.impacts
                            ]

                    totalImpacts =
                        [ Ok recipeImpacts, Ok packagingImpacts, conservationImpacts ]
                            |> RE.combine
                            |> Result.map (Impact.sumImpacts db.impacts)

                    impactsPerKg =
                        -- Note: Product impacts per kg is computed against transformed
                        --       ingredients mass, excluding packaging
                        totalImpacts
                            |> Result.map
                                (Impact.perKg (getTransformedIngredientsMass recipe))

                    packagingImpacts =
                        packaging
                            |> List.map (computeProcessImpacts db.impacts)
                            |> updateImpacts

                    scoring =
                        impactsPerKg
                            |> Result.map (computeScoring db.impacts category)
                in
                Result.map4
                    (\t i c s ->
                        ( recipe
                        , { total = t
                          , perKg = i
                          , scoring = s

                          -- XXX: For now, we stop at packaging step
                          , totalMass = getMassAtPackaging recipe
                          , recipe =
                                { total = recipeImpacts
                                , ingredientsTotal = ingredientsTotalImpacts
                                , ingredients = ingredientsImpacts
                                , transform = transformImpacts
                                , transports = ingredientsTransport
                                , conservation = c
                                }
                          , packaging = packagingImpacts
                          , transports = ingredientsTransport
                          }
                        )
                    )
                    totalImpacts
                    impactsPerKg
                    conservationImpacts
                    scoring
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
computeIngredientTransport db { ingredient, country, mass, byPlane } =
    let
        emptyImpacts =
            Impact.impactsFromDefinitons db.impacts

        planeRatio =
            -- Special case: if the default origin of an ingredient is "by plane"
            -- and we selected a transport by plane, then we take an air transport ratio of 1
            Unit.Ratio
                (if byPlane == Just True then
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
                        |> Ingredient.getDefaultOriginTransport db.impacts

        transport =
            baseTransport
                -- 160km of road transport are added for every ingredient, wherever they come
                -- from (including France)
                |> (\t -> { t | road = t.road |> Quantity.plus (Length.kilometers 160) })
    in
    { transport
        | impacts =
            db.processes
                |> Process.loadWellKnown
                |> Result.map
                    (\{ lorryTransport, boatTransport, planeTransport } ->
                        [ ( lorryTransport, transport.road )
                        , ( boatTransport, transport.sea )
                        , ( planeTransport, transport.air )
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


encodeQuery : Query -> Encode.Value
encodeQuery q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "transform", q.transform |> Maybe.map encodeProcess |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list encodeProcess q.packaging )
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
        , ( "recipe"
          , Encode.object
                [ ( "total", encodeImpacts results.recipe.total )
                , ( "ingredientsTotal", encodeImpacts results.recipe.ingredientsTotal )
                , ( "transform", encodeImpacts results.recipe.transform )
                , ( "transports", Transport.encode defs results.recipe.transports )
                ]
          )
        , ( "packaging", encodeImpacts results.packaging )
        , ( "transports", Transport.encode defs results.transports )
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
    Result.map5 Recipe
        (ingredientListFromQuery db query)
        (transformFromQuery db query)
        (packagingListFromQuery db query)
        (Ok query.conservation)
        (categoryFromQuery query.category)


getMassAtPackaging : Recipe -> Mass
getMassAtPackaging recipe =
    Quantity.sum
        [ getTransformedIngredientsMass recipe
        , recipe.packaging
            |> List.map .mass
            |> Quantity.sum
        ]


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


getRecipeIngredientProcess : RecipeIngredient -> Process
getRecipeIngredientProcess { ingredient, variant } =
    case variant of
        BuilderQuery.Default ->
            ingredient.default

        BuilderQuery.Organic ->
            ingredient.variants.organic
                |> Maybe.withDefault ingredient.default


ingredientListFromQuery : Db -> Query -> Result String (List RecipeIngredient)
ingredientListFromQuery db =
    .ingredients >> RE.combineMap (ingredientFromQuery db)


ingredientFromQuery : Db -> BuilderQuery.IngredientQuery -> Result String RecipeIngredient
ingredientFromQuery { countries, ingredients } { id, mass, variant, country, byPlane } =
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
            |> Result.andThen (Ingredient.byPlaneAllowed byPlane)
        )


ingredientQueryFromIngredient : Ingredient -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredient =
    { id = ingredient.id
    , name = ingredient.name
    , mass = Mass.grams 100
    , variant = BuilderQuery.Default
    , country = Nothing
    , byPlane = Ingredient.byPlaneByDefault ingredient
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


serializeQuery : Query -> String
serializeQuery =
    encodeQuery >> Encode.encode 2


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
        BuilderQuery.Default ->
            "default"

        BuilderQuery.Organic ->
            "organic"
