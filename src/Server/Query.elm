module Server.Query exposing
    ( Errors
    , encodeErrors
    , parse
    )

import Data.Country as Country exposing (Country)
import Data.Env as Env
import Data.Textile.Db exposing (Db)
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Unit as Unit
import Dict exposing (Dict)
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE
import Url.Parser.Query as Query



-- Query String


type alias FieldName =
    String


type alias ErrorMessage =
    String


type alias Errors =
    Dict FieldName ErrorMessage


type alias ParseResult a =
    Result ( FieldName, String ) a


succeed : a -> Query.Parser a
succeed =
    -- Kind of a hack: we don't have access to the Query.Parser constructor, so
    -- we use Query.custom to wrap our thing in a Query.Parser
    always >> Query.custom ""


parse : Db -> Query.Parser (Result Errors Inputs.Query)
parse db =
    succeed (Ok Inputs.Query)
        |> apply (massParser "mass")
        |> apply (materialListParser "materials" db.materials)
        |> apply (productParser "product" db.products)
        |> apply (maybeCountryParser "countrySpinning" db.countries)
        |> apply (countryParser "countryFabric" db.countries)
        |> apply (countryParser "countryDyeing" db.countries)
        |> apply (countryParser "countryMaking" db.countries)
        |> apply (maybeRatioParser "dyeingWeighting")
        |> apply (maybeRatioParser "airTransportRatio")
        |> apply (maybeQuality "quality")
        |> apply (maybeReparability "reparability")
        |> apply (maybeMakingWaste "makingWaste")
        |> apply (maybePicking "picking")
        |> apply (maybeSurfaceMass "surfaceMass")
        |> apply (maybeDisabledSteps "disabledSteps")
        |> apply (maybeBool "disabledFading")


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


apply :
    Query.Parser (ParseResult a)
    -> Query.Parser (Result Errors (a -> b))
    -> Query.Parser (Result Errors b)
apply argParser funcParser =
    -- Adapted from https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    -- with the full list of errors returned, instead of just the first one encountered.
    Query.map2
        builder
        (Query.map toErrors argParser)
        funcParser


floatParser : String -> Query.Parser (Maybe Float)
floatParser key =
    Query.custom key <|
        \stringList ->
            case stringList of
                [ str ] ->
                    String.toFloat str

                _ ->
                    Nothing


massParser : String -> Query.Parser (ParseResult Mass)
massParser key =
    floatParser key
        |> Query.map (Result.fromMaybe ( key, "La masse est manquante." ))
        |> Query.map
            (Result.andThen
                (\mass ->
                    if mass < 0 then
                        Err ( key, "La masse doit ??tre sup??rieure ou ??gale ?? z??ro." )

                    else
                        Ok <| Mass.kilograms mass
                )
            )


productParser : String -> List Product -> Query.Parser (ParseResult Product.Id)
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


materialListParser : String -> List Material -> Query.Parser (ParseResult (List Inputs.MaterialQuery))
materialListParser key materials =
    Query.custom (key ++ "[]")
        (List.map (parseMaterial_ materials)
            >> RE.combine
            >> Result.andThen validateMaterialList
            >> Result.mapError (\err -> ( key, err ))
        )


parseMaterial_ : List Material -> String -> Result String Inputs.MaterialQuery
parseMaterial_ materials string =
    case String.split ";" string of
        [ id, share ] ->
            Ok Inputs.MaterialQuery
                |> RE.andMap (parseMaterialId_ materials id)
                |> RE.andMap (parseRatio_ share)

        [ "" ] ->
            Err <| "Format de mati??re vide."

        _ ->
            Err <| "Format de mati??re invalide : " ++ string ++ "."


parseMaterialId_ : List Material -> String -> Result String Material.Id
parseMaterialId_ materials string =
    materials
        |> Material.findById (Material.Id string)
        |> Result.map .id


parseRatio_ : String -> Result String Unit.Ratio
parseRatio_ string =
    string
        |> String.toFloat
        |> Result.fromMaybe ("Ratio invalide : " ++ string)
        |> Result.andThen
            (\ratio ->
                if ratio < 0 || ratio > 1 then
                    Err <|
                        "Un ratio doit ??tre compris entre 0 et 1 inclus (ici : "
                            ++ String.fromFloat ratio
                            ++ ")."

                else
                    Ok ratio
            )
        |> Result.map Unit.ratio


validateMaterialList : List Inputs.MaterialQuery -> Result String (List Inputs.MaterialQuery)
validateMaterialList list =
    if list == [] then
        Err "La liste des mati??res est vide."

    else
        let
            total =
                list |> List.map (.share >> Unit.ratioToFloat) |> List.sum
        in
        if total /= 1 then
            Err <|
                "La somme des parts de mati??res doit ??tre ??gale ?? 1 (ici : "
                    ++ String.fromFloat total
                    ++ ")"

        else
            Ok list


countryParser : String -> List Country -> Query.Parser (ParseResult Country.Code)
countryParser key countries =
    Query.string key
        |> Query.map (Result.fromMaybe ( key, "Code pays manquant." ))
        |> Query.map
            (Result.andThen
                (\code ->
                    countries
                        |> Country.findByCode (Country.Code code)
                        |> Result.map .code
                        |> Result.mapError (\err -> ( key, err ))
                )
            )


maybeCountryParser : String -> List Country -> Query.Parser (ParseResult (Maybe Country.Code))
maybeCountryParser key countries =
    Query.string key
        |> Query.map
            (Maybe.map
                (\code ->
                    countries
                        |> Country.findByCode (Country.Code code)
                        |> Result.map (.code >> Just)
                        |> Result.mapError (\err -> ( key, err ))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeRatioParser : String -> Query.Parser (ParseResult (Maybe Unit.Ratio))
maybeRatioParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    if float < 0 || float > 1 then
                        Err ( key, "Un ratio doit ??tre compris entre 0 et 1 inclus." )

                    else
                        Ok (Just (Unit.ratio float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeQuality : String -> Query.Parser (ParseResult (Maybe Unit.Quality))
maybeQuality key =
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
                            , "Le coefficient de qualit?? intrins??que doit ??tre compris entre "
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


maybeReparability : String -> Query.Parser (ParseResult (Maybe Unit.Reparability))
maybeReparability key =
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
                            , "Le coefficient de r??parabilit?? doit ??tre compris entre "
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


maybeMakingWaste : String -> Query.Parser (ParseResult (Maybe Unit.Ratio))
maybeMakingWaste key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    if float < Unit.ratioToFloat Env.minMakingWasteRatio || float > Unit.ratioToFloat Env.maxMakingWasteRatio then
                        Err
                            ( key
                            , "Le taux de perte en confection doit ??tre compris entre "
                                ++ String.fromFloat (Unit.ratioToFloat Env.minMakingWasteRatio)
                                ++ " et "
                                ++ String.fromFloat (Unit.ratioToFloat Env.maxMakingWasteRatio)
                                ++ "."
                            )

                    else
                        Ok (Just (Unit.ratio float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybePicking : String -> Query.Parser (ParseResult (Maybe Unit.PickPerMeter))
maybePicking key =
    Query.int key
        |> Query.map
            (Maybe.map
                (\int ->
                    if
                        (int < Unit.pickPerMeterToInt Unit.minPickPerMeter)
                            || (int > Unit.pickPerMeterToInt Unit.maxPickPerMeter)
                    then
                        Err
                            ( key
                            , "Le duitage (picking) doit ??tre compris entre "
                                ++ String.fromInt (Unit.pickPerMeterToInt Unit.minPickPerMeter)
                                ++ " et "
                                ++ String.fromInt (Unit.pickPerMeterToInt Unit.maxPickPerMeter)
                                ++ " duites/m."
                            )

                    else
                        Ok (Just (Unit.pickPerMeter int))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeSurfaceMass : String -> Query.Parser (ParseResult (Maybe Unit.SurfaceMass))
maybeSurfaceMass key =
    Query.int key
        |> Query.map
            (Maybe.map
                (\int ->
                    if
                        (int < Unit.surfaceMassToInt Unit.minSurfaceMass)
                            || (int > Unit.surfaceMassToInt Unit.maxSurfaceMass)
                    then
                        Err
                            ( key
                            , "Le grammage (surfaceMass) doit ??tre compris entre "
                                ++ String.fromInt (Unit.surfaceMassToInt Unit.minSurfaceMass)
                                ++ " et "
                                ++ String.fromInt (Unit.surfaceMassToInt Unit.maxSurfaceMass)
                                ++ " gr/m??."
                            )

                    else
                        Ok (Just (Unit.surfaceMass int))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeDisabledSteps : String -> Query.Parser (ParseResult (List Label))
maybeDisabledSteps key =
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
                                , "Impossible d'interpr??ter la liste des ??tapes d??sactiv??es; " ++ err
                                )
                            )
                )
                >> Maybe.withDefault (Ok [])
            )


maybeBool : String -> Query.Parser (ParseResult (Maybe Bool))
maybeBool key =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    case str of
                        "true" ->
                            Ok (Just True)

                        "false" ->
                            Ok (Just False)

                        _ ->
                            Err ( key, "La valeur ne peut ??tre que true ou false." )
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
