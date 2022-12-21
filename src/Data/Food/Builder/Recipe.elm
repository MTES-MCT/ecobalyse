module Data.Food.Builder.Recipe exposing
    ( Recipe
    , RecipeIngredient
    , Results
    , addPackaging
    , availableIngredients
    , compute
    , computeProcessImpacts
    , deletePackaging
    , encodeQuery
    , encodeResults
    , fromQuery
    , ingredientQueryFromIngredient
    , recipeStepImpacts
    , resetTransform
    , serializeQuery
    , setTransform
    , sumMasses
    , toString
    , updatePackagingMass
    , updateTransformMass
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
    , country : Country
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Transform
    , packaging : List Packaging
    }


type alias Results =
    { impacts : Impacts
    , recipe :
        { ingredients : Impacts
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


addPackaging : Mass -> Process.Code -> Query -> Query
addPackaging mass code query =
    { query
        | packaging =
            query.packaging ++ [ { code = code, mass = mass } ]
    }


availableIngredients : List Id -> List Ingredient -> List Ingredient
availableIngredients usedIngredientIds =
    List.filter (\{ id } -> not (List.member id usedIngredientIds))


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
                            |> List.map computeIngredientImpacts

                    ingredientsTransport =
                        ingredients
                            |> List.map (computeIngredientTransport db)
                            |> Transport.sum db.impacts

                    transformImpacts =
                        transform
                            |> Maybe.map (computeProcessImpacts db.impacts >> List.singleton >> updateImpacts)
                            |> Maybe.withDefault Impact.noImpacts

                    packagingImpacts =
                        packaging
                            |> List.map (computeProcessImpacts db.impacts)
                in
                ( recipe
                , { impacts =
                        [ ingredientsImpacts
                        , List.singleton ingredientsTransport.impacts
                        , List.singleton transformImpacts
                        , packagingImpacts
                        ]
                            |> List.concat
                            |> updateImpacts
                  , recipe =
                        { ingredients = updateImpacts ingredientsImpacts
                        , transform = transformImpacts
                        , transports = ingredientsTransport
                        }
                  , packaging = updateImpacts packagingImpacts
                  , transports =
                        [ ingredientsTransport ]
                            |> Transport.sum db.impacts
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
computeIngredientTransport db { country, mass } =
    let
        baseImpacts =
            Impact.impactsFromDefinitons db.impacts

        transport =
            db.transports
                |> Transport.getTransportBetween baseImpacts country.code france
                -- Notes:
                -- - This reuses the road/sea transport distances ratio computation stuff
                -- - We want the transport ratio for the plane to be 0 for food (for now)
                |> Formula.transportRatio (Unit.Ratio 0)
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
        ]


encodePackaging : BuilderQuery.PackagingQuery -> Encode.Value
encodePackaging i =
    Encode.object
        [ ( "code", i.code |> Process.codeToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms i.mass) )
        ]


encodeQuery : Query -> Encode.Value
encodeQuery q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "transform", q.transform |> Maybe.map encodeTransform |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list encodePackaging q.packaging )
        ]


encodeResults : List Impact.Definition -> Results -> Encode.Value
encodeResults definitions results =
    let
        encodeImpacts =
            Impact.encodeImpacts definitions Scope.Food
    in
    Encode.object
        [ ( "impacts", encodeImpacts results.impacts )
        , ( "recipe"
          , Encode.object
                [ ( "ingredients", encodeImpacts results.recipe.ingredients )
                , ( "transform", encodeImpacts results.recipe.transform )
                ]
          )
        , ( "packaging", encodeImpacts results.packaging )
        ]


encodeTransform : BuilderQuery.TransformQuery -> Encode.Value
encodeTransform p =
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
ingredientFromQuery { countries, ingredients } ingredientQuery =
    Result.map4 RecipeIngredient
        (Ingredient.findByID ingredientQuery.id ingredients)
        (Ok ingredientQuery.mass)
        (Ok ingredientQuery.variant)
        (Country.findByCode ingredientQuery.country countries)


ingredientQueryFromIngredient : Ingredient -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredient =
    { id = ingredient.id
    , name = ingredient.name
    , mass = Mass.grams 100
    , variant = BuilderQuery.Default
    , country = BuilderQuery.defaultCountry
    }


packagingListFromQuery :
    Db
    -> { a | packaging : List BuilderQuery.PackagingQuery }
    -> Result String (List Packaging)
packagingListFromQuery db query =
    query.packaging
        |> RE.combineMap (packagingFromQuery db)


packagingFromQuery : Db -> BuilderQuery.PackagingQuery -> Result String Packaging
packagingFromQuery { processes } { code, mass } =
    Result.map2 Packaging
        (Process.findByCode processes code)
        (Ok mass)


recipeStepImpacts : Db -> Results -> Impacts
recipeStepImpacts db { recipe } =
    [ recipe.ingredients, recipe.transform ]
        |> Impact.sumImpacts db.impacts


resetTransform : Query -> Query
resetTransform query =
    { query | transform = Nothing }


setTransform : Mass -> Process.Code -> Query -> Query
setTransform mass code query =
    { query | transform = Just { code = code, mass = mass } }


serializeQuery : Query -> String
serializeQuery =
    encodeQuery >> Encode.encode 2


sumMasses : List { a | mass : Mass } -> Mass
sumMasses =
    List.map .mass >> Quantity.sum


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
    -> { a | transform : Maybe BuilderQuery.TransformQuery }
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


updateMass :
    Process.Code
    -> Mass
    -> List { a | code : Process.Code, mass : Mass }
    -> List { a | code : Process.Code, mass : Mass }
updateMass code mass =
    List.map
        (\item ->
            if item.code == code then
                { item | mass = mass }

            else
                item
        )


updatePackagingMass : Mass -> Process.Code -> Query -> Query
updatePackagingMass mass code query =
    { query
        | packaging =
            query.packaging
                |> updateMass code mass
    }


updateTransformMass : Mass -> Query -> Query
updateTransformMass mass query =
    { query
        | transform =
            query.transform
                |> Maybe.map (\transform -> { transform | mass = mass })
    }


variantToString : BuilderQuery.Variant -> String
variantToString variant =
    case variant of
        BuilderQuery.Default ->
            "default"

        BuilderQuery.Organic ->
            "organic"
