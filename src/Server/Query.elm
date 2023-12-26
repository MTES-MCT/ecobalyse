module Server.Query exposing
    ( Errors
    , encodeErrors
    , parseFoodQuery
    , parseTextileQuery
    )

import Data.Country as Country exposing (Country)
import Data.Env as Env
import Data.Food.Db as FoodDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Ingredient.Category as IngredientCategory
import Data.Food.Preparation as Preparation
import Data.Food.Process as FoodProcess
import Data.Food.Query as BuilderQuery
import Data.Food.Retail as Retail exposing (Distribution)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Textile.Db as TextileDb
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.HeatSource as HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Unit as Unit
import Dict exposing (Dict)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Regex
import Result.Extra as RE
import Url.Parser.Query as Query exposing (Parser)



-- Query String


type alias FieldName =
    String


type alias ErrorMessage =
    String


type alias Errors =
    Dict FieldName ErrorMessage


type alias ParseResult a =
    Result ( FieldName, String ) a


succeed : a -> Parser a
succeed =
    -- Kind of a hack: we don't have access to the Parser constructor, so
    -- we use Query.custom to wrap our thing in a Parser
    always >> Query.custom ""


parseFoodQuery : FoodDb.Db -> Parser (Result Errors BuilderQuery.Query)
parseFoodQuery foodDb =
    succeed (Ok BuilderQuery.Query)
        |> apply (ingredientListParser "ingredients" foodDb)
        |> apply (maybeTransformParser "transform" foodDb.processes)
        |> apply (packagingListParser "packaging" foodDb.processes)
        |> apply (distributionParser "distribution")
        |> apply (preparationListParser "preparation")


ingredientListParser : String -> FoodDb.Db -> Parser (ParseResult (List BuilderQuery.IngredientQuery))
ingredientListParser key foodDb =
    Query.custom (key ++ "[]")
        (List.map (ingredientParser foodDb)
            >> RE.combine
            >> Result.mapError (\err -> ( key, err ))
        )


ingredientParser : FoodDb.Db -> String -> Result String BuilderQuery.IngredientQuery
ingredientParser { countries, ingredients } string =
    let
        byPlaneParser byPlane ingredient =
            ingredient
                |> validateByPlaneValue byPlane
                |> Result.andThen (\maybeByPlane -> Ingredient.byPlaneAllowed maybeByPlane ingredient)
    in
    case String.split ";" string of
        [ id, mass ] ->
            let
                ingredient =
                    ingredients
                        |> Ingredient.findByID (Ingredient.idFromString id)
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (Ok Nothing)
                |> RE.andMap (Result.map Ingredient.byPlaneByDefault ingredient)
                |> RE.andMap (Ok Nothing)

        [ id, mass, countryCode ] ->
            let
                ingredient =
                    ingredients
                        |> Ingredient.findByID (Ingredient.idFromString id)
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (countryParser countries Scope.Food countryCode)
                |> RE.andMap (Result.map Ingredient.byPlaneByDefault ingredient)
                |> RE.andMap (Ok Nothing)

        [ id, mass, countryCode, byPlane ] ->
            let
                ingredient =
                    ingredients
                        |> Ingredient.findByID (Ingredient.idFromString id)
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (countryParser countries Scope.Food countryCode)
                |> RE.andMap (ingredient |> Result.andThen (byPlaneParser byPlane))
                |> RE.andMap (Ok Nothing)

        [ id, mass, countryCode, byPlane, complements ] ->
            let
                ingredient =
                    ingredients
                        |> Ingredient.findByID (Ingredient.idFromString id)
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (countryParser countries Scope.Food countryCode)
                |> RE.andMap (ingredient |> Result.andThen (byPlaneParser byPlane))
                |> RE.andMap (ingredient |> Result.andThen (complementsParser complements))

        [ "" ] ->
            Err <| "Format d'ingrédient vide."

        _ ->
            Err <| "Format d'ingrédient invalide : " ++ string ++ "."


complementsParser : String -> Ingredient -> Result String (Maybe Ingredient.Complements)
complementsParser string { name, categories } =
    let
        parseComplement : String -> Result String Split
        parseComplement str =
            case String.toInt str of
                Just int ->
                    Split.fromPercent int

                Nothing ->
                    Err <| "Valeur de bonus invalide : " ++ str ++ "."
    in
    -- Format is either x:y (vegetables) or x:y:z (from animal origin, z being the welfare bonus)
    case String.split ":" string of
        [ a, b ] ->
            Ok Ingredient.Complements
                |> RE.andMap (parseComplement a)
                |> RE.andMap (parseComplement b)
                |> RE.andMap (Ok Split.zero)
                |> Result.map Just

        [ a, b, c ] ->
            if not (List.member IngredientCategory.AnimalProduct categories) then
                Err <| "L'ingrédient " ++ name ++ " ne permet pas l'application d'un bonus sur les conditions d'élevage."

            else
                Ok Ingredient.Complements
                    |> RE.andMap (parseComplement a)
                    |> RE.andMap (parseComplement b)
                    |> RE.andMap (parseComplement c)
                    |> Result.map Just

        [ "" ] ->
            Ok Nothing

        _ ->
            Err <| "Format de bonus d'ingrédient invalide: " ++ string ++ "."


countryParser : List Country -> Scope -> String -> Result String (Maybe Country.Code)
countryParser countries scope countryStr =
    if countryStr == "" then
        Ok Nothing

    else
        countries
            |> validateCountry countryStr scope
            |> Result.map Just


foodProcessCodeParser : List FoodProcess.Process -> String -> Result String FoodProcess.Identifier
foodProcessCodeParser processes string =
    processes
        |> FoodProcess.findByIdentifier (FoodProcess.codeFromString string)
        |> Result.map .code


packagingListParser : String -> List FoodProcess.Process -> Parser (ParseResult (List BuilderQuery.ProcessQuery))
packagingListParser key packagings =
    Query.custom (key ++ "[]")
        (List.map (packagingParser packagings)
            >> RE.combine
            >> Result.mapError (\err -> ( key, err ))
        )


preparationListParser : String -> Parser (ParseResult (List Preparation.Id))
preparationListParser key =
    Query.custom (key ++ "[]")
        -- Note: leveraging Preparation.findById for validation
        (List.map (Preparation.Id >> Preparation.findById >> Result.map .id)
            >> RE.combine
            >> Result.andThen
                (\list ->
                    if List.length list > 2 then
                        Err "Deux techniques de préparation maximum."

                    else
                        Ok list
                )
            >> Result.mapError (\err -> ( key, err ))
        )


packagingParser : List FoodProcess.Process -> String -> Result String BuilderQuery.ProcessQuery
packagingParser packagings string =
    case String.split ";" string of
        [ code, mass ] ->
            Ok BuilderQuery.ProcessQuery
                |> RE.andMap (foodProcessCodeParser packagings code)
                |> RE.andMap (validateMassInGrams mass)

        [ "" ] ->
            Err <| "Format d'emballage vide."

        _ ->
            Err <| "Format d'emballage invalide : " ++ string ++ "."


validateBool : String -> Result String Bool
validateBool str =
    case str of
        "true" ->
            Ok True

        "false" ->
            Ok False

        _ ->
            Err "La valeur ne peut être que true ou false."


validateByPlaneValue : String -> Ingredient -> Result String Ingredient.PlaneTransport
validateByPlaneValue str ingredient =
    case str of
        "" ->
            Ok (Ingredient.byPlaneByDefault ingredient)

        "byPlane" ->
            Ok Ingredient.ByPlane

        "noPlane" ->
            Ok Ingredient.NoPlane

        _ ->
            Err "La valeur ne peut être que parmi les choix suivants: '', 'byPlane', 'noPlane'."


validateCountry : String -> Scope -> List Country -> Result String Country.Code
validateCountry countryCode scope =
    Country.findByCode (Country.codeFromString countryCode)
        >> Result.andThen
            (\{ code, scopes } ->
                if List.member scope scopes then
                    Ok code

                else
                    "Le code pays "
                        ++ countryCode
                        ++ " n'est pas utilisable dans un contexte "
                        ++ Scope.toLabel scope
                        ++ "."
                        |> Err
            )


validateMassInGrams : String -> Result String Mass
validateMassInGrams string =
    string
        |> String.toFloat
        |> Result.fromMaybe ("Masse invalide : " ++ string)
        |> Result.andThen
            (\mass ->
                if mass < 0 then
                    Err "La masse doit être supérieure ou égale à zéro."

                else
                    Ok mass
            )
        |> Result.map Mass.grams


maybeTransformParser : String -> List FoodProcess.Process -> Parser (ParseResult (Maybe BuilderQuery.ProcessQuery))
maybeTransformParser key transforms =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    parseTransform_ transforms str
                        |> Result.map Just
                        |> Result.mapError (\err -> ( key, err ))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


distributionParser : String -> Parser (ParseResult (Maybe Distribution))
distributionParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (Retail.fromString
                    >> Result.map Just
                    >> Result.mapError (\err -> ( key, err ))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


parseTransform_ : List FoodProcess.Process -> String -> Result String BuilderQuery.ProcessQuery
parseTransform_ transforms string =
    case String.split ";" string of
        [ code, mass ] ->
            Ok BuilderQuery.ProcessQuery
                |> RE.andMap (foodProcessCodeParser transforms code)
                |> RE.andMap (validateMassInGrams mass)

        [ "" ] ->
            Err <| "Code de procédé de transformation manquant."

        _ ->
            Err <| "Format de procédé de transformation invalide : " ++ string ++ "."


parseTextileQuery : TextileDb.Db -> Parser (Result Errors Inputs.Query)
parseTextileQuery textileDb =
    succeed (Ok Inputs.Query)
        |> apply (massParserInKilograms "mass")
        |> apply (materialListParser "materials" textileDb.materials textileDb.countries)
        |> apply (productParser "product" textileDb.products)
        |> apply (maybeTextileCountryParser "countrySpinning" textileDb.countries)
        |> apply (textileCountryParser "countryFabric" textileDb.countries)
        |> apply (textileCountryParser "countryDyeing" textileDb.countries)
        |> apply (textileCountryParser "countryMaking" textileDb.countries)
        |> apply (maybeSplitParser "airTransportRatio")
        |> apply (maybeQualityParser "quality")
        |> apply (maybeReparabilityParser "reparability")
        |> apply (maybeMakingWasteParser "makingWaste")
        |> apply (maybeMakingDeadStockParser "makingDeadStock")
        |> apply (maybeMakingComplexityParser "makingComplexity")
        |> apply (maybeYarnSizeParser "yarnSize")
        |> apply (maybeSurfaceMassParser "surfaceMass")
        |> apply (fabricParser "fabricProcess")
        |> apply (maybeDisabledStepsParser "disabledSteps")
        |> apply (maybeBoolParser "fading")
        |> apply (maybeDyeingMedium "dyeingMedium")
        |> apply (maybePrinting "printing")
        |> apply (maybeEnnoblingHeatSource "ennoblingHeatSource")


toErrors : ParseResult a -> Result Errors a
toErrors =
    Result.mapError
        (\( key, errorMessage ) ->
            Dict.singleton key errorMessage
        )


builder :
    Result (Dict comparable v) a
    -> Result (Dict comparable v) (a -> b)
    -> Result (Dict comparable v) b
builder result accumulator =
    case ( result, accumulator ) of
        ( Err a, Err b ) ->
            -- Merge the error dicts
            Err <| Dict.union a b

        ( Ok _, Err b ) ->
            -- No error in "result", but the accumulator is errored: return the errored accumulator
            Err b

        ( valueOrError, Ok fn ) ->
            Result.map fn valueOrError


apply : Parser (ParseResult a) -> Parser (Result Errors (a -> b)) -> Parser (Result Errors b)
apply argParser funcParser =
    -- Adapted from https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    -- with the full list of errors returned, instead of just the first one encountered.
    Query.map2
        builder
        (Query.map toErrors argParser)
        funcParser


floatParser : String -> Parser (Maybe Float)
floatParser key =
    Query.custom key <|
        \stringList ->
            case stringList of
                [ str ] ->
                    String.toFloat str

                _ ->
                    Nothing


massParserInKilograms : String -> Parser (ParseResult Mass)
massParserInKilograms key =
    floatParser key
        |> Query.map (Result.fromMaybe ( key, "La masse est manquante." ))
        |> Query.map
            (Result.andThen
                (\mass ->
                    if mass < 0 then
                        Err ( key, "La masse doit être supérieure ou égale à zéro." )

                    else
                        Ok <| Mass.kilograms mass
                )
            )


productParser : String -> List Product -> Parser (ParseResult Product.Id)
productParser key products =
    Query.string key
        |> Query.map (Result.fromMaybe ( key, "Identifiant du type de produit manquant." ))
        |> Query.map
            (Result.andThen
                (\id ->
                    products
                        |> Product.findById (Product.Id id)
                        |> Result.map .id
                        |> Result.mapError (\err -> ( key, err ))
                )
            )


materialListParser : String -> List Material -> List Country -> Parser (ParseResult (List Inputs.MaterialQuery))
materialListParser key materials countries =
    Query.custom (key ++ "[]")
        (List.map (parseMaterial_ materials countries)
            >> RE.combine
            >> Result.andThen validateMaterialList
            >> Result.mapError (\err -> ( key, err ))
        )


parseMaterial_ : List Material -> List Country -> String -> Result String Inputs.MaterialQuery
parseMaterial_ materials countries string =
    case String.split ";" string of
        [ id, share, spinningString, countryCode ] ->
            materials
                |> Material.findById (Material.Id id)
                |> Result.andThen
                    (\material ->
                        Ok Inputs.MaterialQuery
                            |> RE.andMap (Ok material.id)
                            |> RE.andMap (parseSplit share)
                            |> RE.andMap (parseSpinning material spinningString)
                            |> RE.andMap (countryParser countries Scope.Textile countryCode)
                    )

        [ id, share, spinningString ] ->
            materials
                |> Material.findById (Material.Id id)
                |> Result.andThen
                    (\material ->
                        Ok Inputs.MaterialQuery
                            |> RE.andMap (Ok material.id)
                            |> RE.andMap (parseSplit share)
                            |> RE.andMap (parseSpinning material spinningString)
                            |> RE.andMap (Ok Nothing)
                    )

        [ id, share ] ->
            Ok Inputs.MaterialQuery
                |> RE.andMap (parseMaterialId_ materials id)
                |> RE.andMap (parseSplit share)
                |> Result.map (\partiallyApplied -> partiallyApplied Nothing Nothing)

        [ "" ] ->
            Err <| "Format de matière vide."

        _ ->
            Err <| "Format de matière invalide : " ++ string ++ "."


parseMaterialId_ : List Material -> String -> Result String Material.Id
parseMaterialId_ materials string =
    materials
        |> Material.findById (Material.Id string)
        |> Result.map .id


parseSplit : String -> Result String Split
parseSplit string =
    string
        |> String.toFloat
        |> Result.fromMaybe ("Ratio invalide : " ++ string)
        |> Result.andThen Split.fromFloat


parseSpinning : Material -> String -> Result String (Maybe Spinning)
parseSpinning material spinningString =
    if spinningString == "" then
        Ok Nothing

    else
        let
            availableSpinningProcesses =
                Spinning.getAvailableProcesses material.origin
        in
        Spinning.fromString spinningString
            |> Result.andThen
                (\spinning ->
                    if List.member spinning availableSpinningProcesses then
                        Ok (Just spinning)

                    else
                        Err <| "Un procédé de filature/filage doit être choisi parmi (" ++ (availableSpinningProcesses |> List.map Spinning.toString |> String.join "|") ++ ") (ici: " ++ spinningString ++ ")"
                )
            |> Result.mapError
                (always <|
                    "Un procédé de filature/filage doit être choisi parmi ("
                        ++ (availableSpinningProcesses |> List.map Spinning.toString |> String.join "|")
                        ++ ") (ici: "
                        ++ spinningString
                        ++ ")"
                )


validateMaterialList : List Inputs.MaterialQuery -> Result String (List Inputs.MaterialQuery)
validateMaterialList list =
    if list == [] then
        Ok []

    else
        let
            total =
                list |> List.map (.share >> Split.toFloat) |> List.sum
        in
        if total /= 1 then
            Err <|
                "La somme des parts de matières doit être égale à 1 (ici : "
                    ++ String.fromFloat total
                    ++ ")"

        else
            Ok list


textileCountryParser : String -> List Country -> Parser (ParseResult Country.Code)
textileCountryParser key countries =
    Query.string key
        |> Query.map (Result.fromMaybe ( key, "Code pays manquant." ))
        |> Query.map
            (Result.andThen
                (\code ->
                    validateCountry code Scope.Textile countries
                        |> Result.mapError (\err -> ( key, err ))
                )
            )


maybeTextileCountryParser : String -> List Country -> Parser (ParseResult (Maybe Country.Code))
maybeTextileCountryParser key countries =
    Query.string key
        |> Query.map
            (Maybe.map
                (\code ->
                    validateCountry code Scope.Textile countries
                        |> Result.map Just
                        |> Result.mapError (\err -> ( key, err ))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeDyeingMedium : String -> Parser (ParseResult (Maybe DyeingMedium))
maybeDyeingMedium key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    case DyeingMedium.fromString str of
                        Ok dyeingMedium ->
                            Ok (Just dyeingMedium)

                        Err err ->
                            Err ( key, err )
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeEnnoblingHeatSource : String -> Parser (ParseResult (Maybe HeatSource))
maybeEnnoblingHeatSource key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    case HeatSource.fromString str of
                        Ok heatSource ->
                            Ok (Just heatSource)

                        Err err ->
                            Err ( key, err )
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybePrinting : String -> Parser (ParseResult (Maybe Printing))
maybePrinting key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    case Printing.fromStringParam str of
                        Ok printing ->
                            Ok (Just printing)

                        Err err ->
                            Err ( key, err )
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeSplitParser : String -> Parser (ParseResult (Maybe Split))
maybeSplitParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    if float < 0 || float > 1 then
                        Err ( key, "Un ratio doit être compris entre 0 et 1 inclus." )

                    else
                        Ok (Result.toMaybe (Split.fromFloat float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeQualityParser : String -> Parser (ParseResult (Maybe Unit.Quality))
maybeQualityParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    let
                        ( min, max ) =
                            ( Unit.qualityToFloat Unit.minQuality
                            , Unit.qualityToFloat Unit.maxQuality
                            )
                    in
                    if float < min || float > max then
                        Err
                            ( key
                            , "Le coefficient de qualité intrinsèque doit être compris entre "
                                ++ String.fromFloat min
                                ++ " et "
                                ++ String.fromFloat max
                                ++ "."
                            )

                    else
                        Ok (Just (Unit.quality float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeReparabilityParser : String -> Parser (ParseResult (Maybe Unit.Reparability))
maybeReparabilityParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    let
                        ( min, max ) =
                            ( Unit.reparabilityToFloat Unit.minReparability
                            , Unit.reparabilityToFloat Unit.maxReparability
                            )
                    in
                    if float < min || float > max then
                        Err
                            ( key
                            , "Le coefficient de réparabilité doit être compris entre "
                                ++ String.fromFloat min
                                ++ " et "
                                ++ String.fromFloat max
                                ++ "."
                            )

                    else
                        Ok (Just (Unit.reparability float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeMakingComplexityParser : String -> Parser (ParseResult (Maybe MakingComplexity))
maybeMakingComplexityParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    case MakingComplexity.fromString str of
                        Ok printing ->
                            Ok (Just printing)

                        Err err ->
                            Err ( key, err )
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeMakingWasteParser : String -> Parser (ParseResult (Maybe Split))
maybeMakingWasteParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    if float < Split.toFloat Env.minMakingWasteRatio || float > Split.toFloat Env.maxMakingWasteRatio then
                        Err
                            ( key
                            , "Le taux de perte en confection doit être compris entre "
                                ++ Split.toFloatString Env.minMakingWasteRatio
                                ++ " et "
                                ++ Split.toFloatString Env.maxMakingWasteRatio
                                ++ "."
                            )

                    else
                        Ok (Split.fromFloat float |> Result.toMaybe)
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeMakingDeadStockParser : String -> Parser (ParseResult (Maybe Split))
maybeMakingDeadStockParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    if float < Split.toFloat Env.minMakingDeadStockRatio || float > Split.toFloat Env.maxMakingDeadStockRatio then
                        Err
                            ( key
                            , "Le taux de stocks dormants en confection doit être compris entre "
                                ++ Split.toFloatString Env.minMakingDeadStockRatio
                                ++ " et "
                                ++ Split.toFloatString Env.maxMakingDeadStockRatio
                                ++ "."
                            )

                    else
                        Ok (Split.fromFloat float |> Result.toMaybe)
                )
                >> Maybe.withDefault (Ok Nothing)
            )


parseYarnSize : String -> Maybe Unit.YarnSize
parseYarnSize str =
    let
        withUnitRegex =
            -- Match either an int or a int and a unit `Nm` or `Dtex`
            Regex.fromString "(\\d+)(Nm|Dtex)"
                |> Maybe.withDefault Regex.never

        subMatches =
            -- If it matches, returns [ <the value>, <the unit> ]
            str
                |> Regex.find withUnitRegex
                |> List.map .submatches
    in
    case String.toInt str of
        Just int ->
            Just <| Unit.yarnSizeKilometersPerKg int

        Nothing ->
            case subMatches of
                [ [ Just intStr, Just "Nm" ] ] ->
                    String.toInt intStr
                        |> Maybe.map Unit.yarnSizeKilometersPerKg

                [ [ Just intStr, Just "Dtex" ] ] ->
                    String.toInt intStr
                        |> Maybe.map Unit.yarnSizeGramsPer10km

                _ ->
                    Nothing


maybeYarnSizeParser : String -> Parser (ParseResult (Maybe Unit.YarnSize))
maybeYarnSizeParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    case parseYarnSize str of
                        Just yarnSize ->
                            if (yarnSize |> Quantity.lessThan Unit.minYarnSize) || (yarnSize |> Quantity.greaterThan Unit.maxYarnSize) then
                                Err
                                    ( key
                                    , "Le titrage (yarnSize) doit être compris entre "
                                        ++ String.fromInt (Unit.yarnSizeInKilometers Unit.minYarnSize)
                                        ++ " et "
                                        ++ String.fromInt (Unit.yarnSizeInKilometers Unit.maxYarnSize)
                                        ++ " Nm (entre "
                                        -- The following two are reversed in Dtex because the unit is "reversed"
                                        ++ String.fromInt (Unit.yarnSizeInGrams Unit.maxYarnSize)
                                        ++ " et "
                                        ++ String.fromInt (Unit.yarnSizeInGrams Unit.minYarnSize)
                                        ++ " Dtex)"
                                    )

                            else
                                Ok (Just yarnSize)

                        Nothing ->
                            Err
                                ( key
                                , "Le format ne correspond pas au titrage (yarnSize) attendu : soit un entier simple (ie : `40`), ou avec l'unité `Nm` (ie : `40Nm`) ou `Dtex` (ie : `250Dtex`)"
                                )
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeSurfaceMassParser : String -> Parser (ParseResult (Maybe Unit.SurfaceMass))
maybeSurfaceMassParser key =
    Query.int key
        |> Query.map
            (Maybe.map
                (\int ->
                    let
                        surfaceMass =
                            Unit.gramsPerSquareMeter int
                    in
                    if
                        (surfaceMass |> Quantity.lessThan Unit.minSurfaceMass)
                            || (surfaceMass |> Quantity.greaterThan Unit.maxSurfaceMass)
                    then
                        Err
                            ( key
                            , "Le grammage (surfaceMass) doit être compris entre "
                                ++ String.fromInt (Unit.surfaceMassInGramsPerSquareMeters Unit.minSurfaceMass)
                                ++ " et "
                                ++ String.fromInt (Unit.surfaceMassInGramsPerSquareMeters Unit.maxSurfaceMass)
                                ++ " g/m²."
                            )

                    else
                        Ok (Just surfaceMass)
                )
                >> Maybe.withDefault (Ok Nothing)
            )


fabricParser : String -> Parser (ParseResult Fabric)
fabricParser key =
    Query.string key
        |> Query.map (Result.fromMaybe ( key, "Identifiant du type de tissu manquant." ))
        |> Query.map
            (Result.andThen
                (\str ->
                    case Fabric.fromString str of
                        Ok fabricProcess ->
                            Ok fabricProcess

                        Err err ->
                            Err ( key, err )
                )
            )


maybeDisabledStepsParser : String -> Parser (ParseResult (List Label))
maybeDisabledStepsParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    str
                        |> String.split ","
                        |> List.map Label.fromCodeString
                        |> RE.combine
                        |> Result.mapError
                            (\err ->
                                ( key
                                , "Impossible d'interpréter la liste des étapes désactivées; " ++ err
                                )
                            )
                )
                >> Maybe.withDefault (Ok [])
            )


maybeBoolParser : String -> Parser (ParseResult (Maybe Bool))
maybeBoolParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (validateBool
                    >> Result.map Just
                    >> Result.mapError (Tuple.pair key)
                )
                >> Maybe.withDefault (Ok Nothing)
            )



-- Encoders


encodeErrors : Errors -> Encode.Value
encodeErrors errors =
    Encode.object
        [ ( "errors"
          , errors
                |> Encode.dict identity Encode.string
          )
        ]
