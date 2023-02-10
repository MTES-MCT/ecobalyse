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
    , toString
    )

import Data.Country as Country exposing (Country)
import Data.Food.Builder.Db exposing (Db)
import Data.Food.Builder.Query as BuilderQuery exposing (Query)
import Data.Food.Ingredient as Ingredient exposing (Id, Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact exposing (Impacts)
import Data.Scope as Scope
import Data.Textile.Formula as Formula
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Json.Encode as Encode
import Length
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import String.Extra as SE


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
    }


type alias Results =
    { total : Impacts
    , perKg : Impacts
    , totalMass : Mass
    , recipe :
        { total : Impacts
        , ingredientsTotal : Impacts
        , ingredients : List ( RecipeIngredient, Impacts )
        , transform : Impacts
        , transports : Transport
        }
    , packaging : Impacts
    , transports : Transport
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


compute : Db -> Query -> Result String ( Recipe, Results )
compute db =
    fromQuery db
        >> Result.map
            (\({ ingredients, transform, packaging } as recipe) ->
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
                            |> List.map (computeIngredientTransport db)
                            |> Transport.sum db.impacts

                    transformImpacts =
                        transform
                            |> Maybe.map (computeProcessImpacts db.impacts >> List.singleton >> updateImpacts)
                            |> Maybe.withDefault Impact.noImpacts

                    recipeImpacts =
                        updateImpacts
                            [ ingredientsTotalImpacts
                            , transformImpacts
                            , ingredientsTransport.impacts
                            ]

                    totalImpacts =
                        Impact.sumImpacts db.impacts
                            [ recipeImpacts, packagingImpacts ]

                    impactsPerKg =
                        -- Note: Product impacts per kg is computed against transformed
                        --       ingredients mass, excluding packaging
                        totalImpacts
                            |> Impact.perKg (getTransformedIngredientsMass recipe)

                    packagingImpacts =
                        packaging
                            |> List.map (computeProcessImpacts db.impacts)
                            |> updateImpacts
                in
                ( recipe
                , { total = totalImpacts
                  , perKg = impactsPerKg

                  -- XXX: For now, we stop at packaging step
                  , totalMass = getMassAtPackaging recipe
                  , recipe =
                        { total = recipeImpacts
                        , ingredientsTotal = ingredientsTotalImpacts
                        , ingredients = ingredientsImpacts
                        , transform = transformImpacts
                        , transports = ingredientsTransport
                        }
                  , packaging = packagingImpacts
                  , transports = ingredientsTransport
                  }
                )
            )


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

        baseTransport =
            case country of
                -- In case a custom country is provided, compute the distances to it from France
                Just { code } ->
                    db.transports
                        |> Transport.getTransportBetween Scope.Food emptyImpacts code france
                        |> (\ingredientTransport ->
                                if byPlane == Just True then
                                    -- Special case: if the default origin of an ingredient is "by plane"
                                    -- and we selected a transport by plane, then we take an air transport ratio of 1
                                    Formula.transportRatio (Unit.Ratio 1) ingredientTransport

                                else
                                    Formula.transportRatio (Unit.Ratio 0) ingredientTransport
                           )

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


encodeProcess : BuilderQuery.ProcessQuery -> Encode.Value
encodeProcess p =
    Encode.object
        [ ( "code", p.code |> Process.codeToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms p.mass) )
        ]


fromQuery : Db -> Query -> Result String Recipe
fromQuery db query =
    Result.map3 Recipe
        (ingredientListFromQuery db query)
        (transformFromQuery db query)
        (packagingListFromQuery db query)


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
            |> Result.andThen
                (\ingredient ->
                    if Ingredient.byPlaneByDefault ingredient == Nothing && byPlane /= Nothing then
                        Err Ingredient.byPlaneErrorMessage

                    else
                        Ok byPlane
                )
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
