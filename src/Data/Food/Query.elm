module Data.Food.Query exposing
    ( IngredientQuery
    , ProcessQuery
    , Query
    , addIngredient
    , addPackaging
    , addPreparation
    , b64encode
    , buildApiQuery
    , decode
    , deleteIngredient
    , deletePreparation
    , emptyQuery
    , encode
    , parseBase64Query
    , recipes
    , royalPizza
    , serialize
    , setDistribution
    , setTransform
    , toCategory
    , toString
    , updateDistribution
    , updateIngredient
    , updatePackaging
    , updatePreparation
    , updateTransform
    )

import Base64
import Data.Country as Country
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Retail as Retail
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)


type alias IngredientQuery =
    { id : Ingredient.Id
    , mass : Mass
    , country : Maybe Country.Code
    , planeTransport : Ingredient.PlaneTransport
    }


type alias ProcessQuery =
    { code : Process.Identifier
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe ProcessQuery
    , packaging : List ProcessQuery
    , distribution : Maybe Retail.Distribution
    , preparation : List Preparation.Id
    }


addPreparation : Preparation.Id -> Query -> Query
addPreparation preparationId query =
    { query
        | preparation =
            query.preparation
                ++ [ preparationId ]
    }


addIngredient : IngredientQuery -> Query -> Query
addIngredient ingredient query =
    { query
        | ingredients =
            query.ingredients
                ++ [ ingredient ]
    }
        |> updateTransformMass


addPackaging : ProcessQuery -> Query -> Query
addPackaging packaging query =
    { query
        | packaging =
            query.packaging
                ++ [ packaging ]
    }


buildApiQuery : String -> Query -> String
buildApiQuery clientUrl query =
    """curl -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "api/food/recipe")
        |> String.replace "%json%" (encode query |> Encode.encode 0)


decode : Decoder Query
decode =
    Decode.succeed Query
        |> Pipe.required "ingredients" (Decode.list decodeIngredient)
        |> Pipe.optional "transform" (Decode.maybe decodeProcess) Nothing
        |> Pipe.optional "packaging" (Decode.list decodeProcess) []
        |> Pipe.optional "distribution" (Decode.maybe Retail.decode) Nothing
        |> Pipe.optional "preparation" (Decode.list Preparation.decodeId) []


decodePlaneTransport : Decoder Ingredient.PlaneTransport
decodePlaneTransport =
    Decode.maybe
        (Decode.string
            |> Decode.map
                (\str ->
                    case str of
                        "byPlane" ->
                            Ingredient.ByPlane

                        "noPlane" ->
                            Ingredient.NoPlane

                        _ ->
                            Ingredient.PlaneNotApplicable
                )
        )
        |> Decode.map
            (\maybe ->
                case maybe of
                    Just planeTransport ->
                        planeTransport

                    Nothing ->
                        Ingredient.PlaneNotApplicable
            )


decodeMassInGrams : Decoder Mass
decodeMassInGrams =
    Decode.float
        |> Decode.map Mass.grams


decodeProcess : Decoder ProcessQuery
decodeProcess =
    Decode.map2 ProcessQuery
        (Decode.field "code" Process.decodeIdentifier)
        (Decode.field "mass" decodeMassInGrams)


decodeIngredient : Decoder IngredientQuery
decodeIngredient =
    Decode.succeed IngredientQuery
        |> Pipe.required "id" Ingredient.decodeId
        |> Pipe.required "mass" decodeMassInGrams
        |> Pipe.optional "country" (Decode.maybe Country.decodeCode) Nothing
        |> Pipe.optional "byPlane" decodePlaneTransport Ingredient.PlaneNotApplicable


deletePreparation : Preparation.Id -> Query -> Query
deletePreparation preparationId query =
    { query
        | preparation =
            query.preparation
                |> List.filter ((/=) preparationId)
    }


deleteIngredient : Ingredient.Id -> Query -> Query
deleteIngredient id query =
    { query
        | ingredients =
            query.ingredients |> List.filter (.id >> (/=) id)
    }
        |> updateTransformMass


encode : Query -> Encode.Value
encode v =
    [ ( "ingredients", Encode.list encodeIngredient v.ingredients |> Just )
    , ( "transform", v.transform |> Maybe.map encodeProcess )
    , ( "packaging"
      , case v.packaging of
            [] ->
                Nothing

            list ->
                Encode.list encodeProcess list |> Just
      )
    , ( "distribution", v.distribution |> Maybe.map Retail.encode )
    , ( "preparation"
      , case v.preparation of
            [] ->
                Nothing

            list ->
                Encode.list Preparation.encodeId list |> Just
      )
    ]
        -- For concision, drop keys where no param is defined
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient v =
    [ ( "id", Ingredient.encodeId v.id |> Just )
    , ( "mass", encodeMassAsGrams v.mass |> Just )
    , ( "country", v.country |> Maybe.map Country.encodeCode )
    , ( "byPlane", v.planeTransport |> Ingredient.encodePlaneTransport )
    ]
        -- For concision, drop keys where no param is defined
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeMassAsGrams : Mass -> Encode.Value
encodeMassAsGrams =
    Mass.inGrams >> Encode.float


encodeProcess : ProcessQuery -> Encode.Value
encodeProcess v =
    Encode.object
        [ ( "code", Process.encodeIdentifier v.code )
        , ( "mass", encodeMassAsGrams v.mass )
        ]


getIngredientMass : List { a | mass : Mass } -> Mass
getIngredientMass ingredients =
    ingredients
        |> List.map .mass
        |> Quantity.sum


setTransform : ProcessQuery -> Query -> Query
setTransform transform query =
    { query | transform = Just transform }


setDistribution : Retail.Distribution -> Query -> Query
setDistribution distribution query =
    { query | distribution = Just distribution }


updatePreparation : Preparation.Id -> Preparation.Id -> Query -> Query
updatePreparation oldId newId query =
    { query
        | preparation =
            query.preparation
                |> List.map
                    (\id ->
                        if id == oldId then
                            newId

                        else
                            id
                    )
    }


updateIngredient : Ingredient.Id -> IngredientQuery -> Query -> Query
updateIngredient oldIngredientId newIngredient query =
    { query
        | ingredients =
            query.ingredients
                |> List.map
                    (\ingredient ->
                        if ingredient.id == oldIngredientId then
                            newIngredient

                        else
                            ingredient
                    )
    }
        |> updateTransformMass


updatePackaging : Process.Identifier -> ProcessQuery -> Query -> Query
updatePackaging oldPackagingCode newPackaging query =
    { query
        | packaging =
            query.packaging
                |> List.map
                    (\p ->
                        if p.code == oldPackagingCode then
                            newPackaging

                        else
                            p
                    )
    }


updateTransform : ProcessQuery -> Query -> Query
updateTransform newTransform query =
    { query
        | transform = Just newTransform
    }


updateTransformMass : Query -> Query
updateTransformMass query =
    { query
        | transform =
            query.transform
                |> Maybe.map
                    (\transform ->
                        { transform | mass = getIngredientMass query.ingredients }
                    )
    }


updateDistribution : String -> Query -> Query
updateDistribution distribution query =
    { query
        | distribution =
            Retail.fromString distribution
                |> Result.withDefault Retail.ambient
                |> Just
    }


serialize : Query -> String
serialize =
    encode >> Encode.encode 2


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decode
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encode >> Encode.encode 0 >> Base64.encode



-- Parser


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just



---- Example recipes


type alias Product =
    { name : String
    , query : Query
    , category : String
    }


recipesAndNames : List Product
recipesAndNames =
    [ { name = "Produit vide", query = emptyQuery, category = "" }
    , { name = "Farine de blé bio FR (1kg) - 20", query = wheatFROrganic, category = "Produits céréaliers" }
    , { name = "Farine de blé FR (1kg) - 22", query = wheatFR, category = "Produits céréaliers" }
    , { name = "Farine de blé origine Ukraine (1kg) - 22", query = wheatUKR, category = "Produits céréaliers" }
    , { name = "Filets de poulet bio FR (250g) - 95", query = chickenFROrganic, category = "Volaille" }
    , { name = "Filets de poulet FR (250g) - 96", query = chickenFR, category = "Volaille" }
    , { name = "Filets de poulet origine Brésil (250g) - 100", query = chickenBR, category = "Volaille" }
    , { name = "Pizza bolognese (375g) - 21", query = bolognesePizza, category = "Produit surgelé" }
    , { name = "Pizza bolognese FR (375g) - 21", query = bolognesePizzaFR, category = "Produit surgelé" }
    , { name = "Pizza bolognese FR bio (375g) - 21", query = bolognesePizzaFROrganic, category = "Produit surgelé" }
    , { name = "Pizza royale (350g) - 6", query = royalPizza, category = "Produit surgelé" }
    , { name = "Pizza royale FR (350g) - 6", query = royalPizzaFR, category = "Produit surgelé" }
    , { name = "Pizza végétale (385g) - 19", query = vegetablePizza, category = "Produit surgelé" }
    , { name = "Pizza végétale FR (385g) - 19", query = vegetablePizzaFR, category = "Produit surgelé" }
    , { name = "Steak haché surgelé origine Brésil (200g) - 82", query = groundSteakBR, category = "Viande bovine" }
    , { name = "Steak haché surgelé FR (250g) - 95", query = groundSteakFR, category = "Viande bovine" }
    , { name = "Steak haché surgelé bio FR (200g) - 78", query = groundSteakFROrganic, category = "Viande bovine" }
    ]


recipes : List Query
recipes =
    recipesAndNames
        |> List.map .query


toString : Query -> String
toString q =
    recipesAndNames
        |> List.filterMap
            (\{ name, query } ->
                if q == query then
                    Just name

                else
                    Nothing
            )
        |> List.head
        |> Maybe.withDefault "Produit personnalisé"


toCategory : Query -> String
toCategory q =
    recipesAndNames
        |> List.filterMap
            (\{ query, category } ->
                if q == query then
                    Just category

                else
                    Nothing
            )
        |> List.head
        |> Maybe.withDefault ""


emptyQuery : Query
emptyQuery =
    { ingredients = []
    , transform = Nothing
    , packaging = []
    , distribution = Nothing
    , preparation = []
    }


royalPizza : Query
royalPizza =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 97
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 89
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 70
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "cooked-ham"
          , mass = Mass.grams 16
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 5
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mushroom-eu"
          , mass = Mass.grams 31
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 16
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "black-pepper"
          , mass = Mass.grams 1
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 22
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 363
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


royalPizzaFR : Query
royalPizzaFR =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 97
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 89
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 70
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "cooked-ham"
          , mass = Mass.grams 16
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 5
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mushroom-eu"
          , mass = Mass.grams 31
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 16
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "black-pepper"
          , mass = Mass.grams 1
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 22
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 363
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


vegetablePizza : Query
vegetablePizza =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 113
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 76
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 36
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 4
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 21
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "black-pepper"
          , mass = Mass.grams 2
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "emmental"
          , mass = Mass.grams 12
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-greenhouse"
          , mass = Mass.grams 36
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "bellpepper-unheated-greenhouse"
          , mass = Mass.grams 36
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "onion"
          , mass = Mass.grams 12
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 22
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 396
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


vegetablePizzaFR : Query
vegetablePizzaFR =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 113
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 76
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 36
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 4
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 21
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "black-pepper"
          , mass = Mass.grams 2
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "emmental"
          , mass = Mass.grams 12
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-greenhouse"
          , mass = Mass.grams 36
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "bellpepper-unheated-greenhouse"
          , mass = Mass.grams 36
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "onion"
          , mass = Mass.grams 12
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 22
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 370
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


bolognesePizza : Query
bolognesePizza =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 148
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 100
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 19
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "ground-beef-feedlot"
          , mass = Mass.grams 43
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 3
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 5
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 33
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "emmental"
          , mass = Mass.grams 19
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sunflower-oil"
          , mass = Mass.grams 2
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "onion"
          , mass = Mass.grams 14
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "carrot"
          , mass = Mass.grams 6
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 398
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


bolognesePizzaFR : Query
bolognesePizzaFR =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 148
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 100
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 19
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "ground-beef"
          , mass = Mass.grams 43
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 3
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil"
          , mass = Mass.grams 5
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 33
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "emmental"
          , mass = Mass.grams 19
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sunflower-oil"
          , mass = Mass.grams 2
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "onion"
          , mass = Mass.grams 14
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "carrot"
          , mass = Mass.grams 6
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 392
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


bolognesePizzaFROrganic : Query
bolognesePizzaFROrganic =
    { ingredients =
        [ { id = Ingredient.idFromString "flour-organic"
          , mass = Mass.grams 148
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tomato-paste"
          , mass = Mass.grams 100
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "mozzarella"
          , mass = Mass.grams 19
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "ground-beef-organic"
          , mass = Mass.grams 43
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sugar"
          , mass = Mass.grams 3
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "rapeseed-oil-organic"
          , mass = Mass.grams 5
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "tap-water"
          , mass = Mass.grams 33
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "emmental"
          , mass = Mass.grams 19
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "sunflower-oil-organic"
          , mass = Mass.grams 2
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "onion"
          , mass = Mass.grams 14
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "carrot-organic"
          , mass = Mass.grams 6
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform =
        Just
            { code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 398
            }
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 100
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


groundSteakBR : Query
groundSteakBR =
    { ingredients =
        [ { id = Ingredient.idFromString "ground-beef-feedlot"
          , mass = Mass.grams 200
          , country = Just (Country.Code "BR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003111575"
          , mass = Mass.grams 50
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "pan-cooking"
        ]
    }


groundSteakFR : Query
groundSteakFR =
    { ingredients =
        [ { id = Ingredient.idFromString "ground-beef"
          , mass = Mass.grams 250
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003110698"
          , mass = Mass.grams 50
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "pan-cooking"
        ]
    }


groundSteakFROrganic : Query
groundSteakFROrganic =
    { ingredients =
        [ { id = Ingredient.idFromString "ground-beef-organic"
          , mass = Mass.grams 200
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003111575"
          , mass = Mass.grams 50
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "pan-cooking"
        ]
    }


chickenBR : Query
chickenBR =
    { ingredients =
        [ { id = Ingredient.idFromString "chicken-breast-br-max"
          , mass = Mass.grams 250
          , country = Just (Country.Code "BR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003111575"
          , mass = Mass.grams 50
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


chickenFROrganic : Query
chickenFROrganic =
    { ingredients =
        [ { id = Ingredient.idFromString "chicken-breast-organic"
          , mass = Mass.grams 250
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003111575"
          , mass = Mass.grams 50
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


chickenFR : Query
chickenFR =
    { ingredients =
        [ { id = Ingredient.idFromString "chicken-breast"
          , mass = Mass.grams 250
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003111575"
          , mass = Mass.grams 50
          }
        ]
    , distribution = Just Retail.frozen
    , preparation =
        [ Preparation.Id "freezing"
        , Preparation.Id "oven"
        ]
    }


wheatUKR : Query
wheatUKR =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 1000
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003108113"
          , mass = Mass.grams 20
          }
        ]
    , distribution = Just Retail.ambient
    , preparation = []
    }


wheatFR : Query
wheatFR =
    { ingredients =
        [ { id = Ingredient.idFromString "flour"
          , mass = Mass.grams 1000
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003108113"
          , mass = Mass.grams 20
          }
        ]
    , distribution = Just Retail.ambient
    , preparation = []
    }


wheatFROrganic : Query
wheatFROrganic =
    { ingredients =
        [ { id = Ingredient.idFromString "flour-organic"
          , mass = Mass.grams 1000
          , country = Just (Country.Code "FR")
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        ]
    , transform = Nothing
    , packaging =
        [ { code = Process.codeFromString "AGRIBALU000000003108113"
          , mass = Mass.grams 20
          }
        ]
    , distribution = Just Retail.ambient
    , preparation = []
    }
