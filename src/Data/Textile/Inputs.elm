module Data.Textile.Inputs exposing
    ( Inputs
    , MaterialInput
    , MaterialQuery
    , Query
    , addMaterial
    , b64decode
    , b64encode
    , countryList
    , decodeQuery
    , defaultQuery
    , encode
    , encodeQuery
    , fromQuery
    , getMainMaterial
    , jupeCircuitAsie
    , parseBase64Query
    , presets
    , removeMaterial
    , tShirtCotonAsie
    , tShirtCotonFrance
    , toQuery
    , toString
    , toggleStep
    , updateMaterial
    , updateMaterialShare
    , updateProduct
    , updateStepCountry
    )

import Base64
import Data.Country as Country exposing (Country)
import Data.Textile.Db exposing (Db)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)
import Views.Format as Format


type alias MaterialInput =
    { material : Material
    , share : Unit.Ratio
    }


type alias Inputs =
    { mass : Mass
    , materials : List MaterialInput
    , product : Product
    , countryMaterial : Country
    , countrySpinning : Country
    , countryFabric : Country
    , countryDyeing : Country
    , countryMaking : Country
    , countryDistribution : Country
    , countryUse : Country
    , countryEndOfLife : Country
    , dyeingWeighting : Maybe Unit.Ratio
    , airTransportRatio : Maybe Unit.Ratio
    , quality : Maybe Unit.Quality
    , reparability : Maybe Unit.Reparability
    , makingWaste : Maybe Unit.Ratio
    , picking : Maybe Unit.PickPerMeter
    , surfaceMass : Maybe Unit.SurfaceMass
    , disabledSteps : List Label
    , disabledFading : Maybe Bool
    }


type alias MaterialQuery =
    { id : Material.Id
    , share : Unit.Ratio
    }


type alias Query =
    { mass : Mass
    , materials : List MaterialQuery
    , product : Product.Id
    , countrySpinning : Maybe Country.Code
    , countryFabric : Country.Code
    , countryDyeing : Country.Code
    , countryMaking : Country.Code
    , dyeingWeighting : Maybe Unit.Ratio
    , airTransportRatio : Maybe Unit.Ratio
    , quality : Maybe Unit.Quality
    , reparability : Maybe Unit.Reparability
    , makingWaste : Maybe Unit.Ratio
    , picking : Maybe Unit.PickPerMeter
    , surfaceMass : Maybe Unit.SurfaceMass
    , disabledSteps : List Label
    , disabledFading : Maybe Bool
    }


toMaterialInputs : List Material -> List MaterialQuery -> Result String (List MaterialInput)
toMaterialInputs materials =
    List.map
        (\{ id, share } ->
            Material.findById id materials
                |> Result.map
                    (\material_ ->
                        { material = material_
                        , share = share
                        }
                    )
        )
        >> RE.combine


toMaterialQuery : List MaterialInput -> List MaterialQuery
toMaterialQuery =
    List.map (\{ material, share } -> { id = material.id, share = share })


getMainMaterial : List MaterialInput -> Result String Material
getMainMaterial =
    List.sortBy (.share >> Unit.ratioToFloat)
        >> List.reverse
        >> List.head
        >> Maybe.map .material
        >> Result.fromMaybe "La liste de matières est vide."


getMainMaterialCountry : List Country -> List MaterialInput -> Result String Country
getMainMaterialCountry countries =
    getMainMaterial
        >> Result.andThen
            (\{ defaultCountry } ->
                Country.findByCode defaultCountry countries
            )


fromQuery : Db -> Query -> Result String Inputs
fromQuery db query =
    let
        materials =
            query.materials
                |> toMaterialInputs db.materials

        franceResult =
            Country.findByCode (Country.Code "FR") db.countries

        mainMaterialCountry =
            materials |> Result.andThen (getMainMaterialCountry db.countries)
    in
    Ok Inputs
        |> RE.andMap (Ok query.mass)
        |> RE.andMap materials
        |> RE.andMap (db.products |> Product.findById query.product)
        -- Material country is constrained to be the first material's default country
        |> RE.andMap mainMaterialCountry
        -- Spinning country is either provided by query or fallbacks to material's default
        -- country, making the parameter optional
        |> RE.andMap
            (case query.countrySpinning of
                Just spinningCountryCode ->
                    Country.findByCode spinningCountryCode db.countries

                Nothing ->
                    mainMaterialCountry
            )
        |> RE.andMap (db.countries |> Country.findByCode query.countryFabric)
        |> RE.andMap (db.countries |> Country.findByCode query.countryDyeing)
        |> RE.andMap (db.countries |> Country.findByCode query.countryMaking)
        -- The distribution country is always France
        |> RE.andMap franceResult
        -- The use country is always France
        |> RE.andMap franceResult
        -- The end of life country is always France
        |> RE.andMap franceResult
        |> RE.andMap (Ok query.dyeingWeighting)
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.quality)
        |> RE.andMap (Ok query.reparability)
        |> RE.andMap (Ok query.makingWaste)
        |> RE.andMap (Ok query.picking)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.disabledFading)


toQuery : Inputs -> Query
toQuery inputs =
    { mass = inputs.mass
    , materials = toMaterialQuery inputs.materials
    , product = inputs.product.id
    , countrySpinning =
        if
            -- Discard custom spinning country if same as material default country
            (getMainMaterial inputs.materials |> Result.map .defaultCountry)
                == Ok inputs.countrySpinning.code
        then
            Nothing

        else
            Just inputs.countrySpinning.code
    , countryFabric = inputs.countryFabric.code
    , countryDyeing = inputs.countryDyeing.code
    , countryMaking = inputs.countryMaking.code
    , dyeingWeighting = inputs.dyeingWeighting
    , airTransportRatio = inputs.airTransportRatio
    , quality = inputs.quality
    , reparability = inputs.reparability
    , makingWaste = inputs.makingWaste
    , picking = inputs.picking
    , surfaceMass = inputs.surfaceMass
    , disabledSteps = inputs.disabledSteps
    , disabledFading = inputs.disabledFading
    }


toString : Inputs -> String
toString inputs =
    [ [ inputs.product.name ++ " de " ++ Format.kgToString inputs.mass ]
    , [ materialsToString inputs.materials ]
    , [ "matière", inputs.countryMaterial.name ]
    , [ "filature", inputs.countrySpinning.name ]
    , case inputs.product.fabric of
        Product.Knitted _ ->
            [ "tricotage", inputs.countryFabric.name ]

        Product.Weaved _ _ _ ->
            [ "tissage", inputs.countryFabric.name ++ weavingOptionsToString inputs.picking inputs.surfaceMass ]
    , [ "teinture", inputs.countryDyeing.name ++ dyeingOptionsToString inputs.dyeingWeighting ]
    , [ "confection", inputs.countryMaking.name ++ makingOptionsToString inputs ]
    , [ "distribution", inputs.countryDistribution.name ]
    , [ "utilisation", inputs.countryUse.name ++ useOptionsToString inputs.quality inputs.reparability ]
    , [ "fin de vie", inputs.countryEndOfLife.name ]
    ]
        |> List.map (String.join "\u{00A0}: ")
        |> String.join ", "


materialsToString : List MaterialInput -> String
materialsToString materials =
    materials
        |> List.filter (\{ share } -> Unit.ratioToFloat share > 0)
        |> List.map
            (\{ material, share } ->
                Format.formatFloat 0 (Unit.ratioToFloat share * 100)
                    ++ "% "
                    ++ material.shortName
            )
        |> String.join ", "


weavingOptionsToString : Maybe Unit.PickPerMeter -> Maybe Unit.SurfaceMass -> String
weavingOptionsToString _ _ =
    -- FIXME: migrate Step.*ToString fns to avoid circular import so we can reuse them here?
    ""


dyeingOptionsToString : Maybe Unit.Ratio -> String
dyeingOptionsToString maybeRatio =
    case maybeRatio of
        Nothing ->
            " (procédé représentatif)"

        Just ratio ->
            if Unit.ratioToFloat ratio == 0 then
                " (procédé représentatif)"

            else
                ratio
                    |> Format.ratioToPercentString
                    |> (\percent -> " (procédé " ++ percent ++ " majorant)")


makingOptionsToString : Inputs -> String
makingOptionsToString { product, makingWaste, airTransportRatio, disabledFading } =
    [ makingWaste
        |> Maybe.map (Format.ratioToPercentString >> (\s -> s ++ " de perte"))
    , airTransportRatio
        |> Maybe.andThen
            (\ratio ->
                if Unit.ratioToFloat ratio == 0 then
                    Nothing

                else
                    Just (Format.ratioToPercentString ratio ++ " de transport aérien")
            )
    , case ( product.making.fadable, disabledFading ) of
        ( True, Just True ) ->
            Just "non-délavé"

        _ ->
            Nothing
    ]
        |> List.filterMap identity
        |> String.join ", "
        |> (\s ->
                if s /= "" then
                    " (" ++ s ++ ")"

                else
                    ""
           )


useOptionsToString : Maybe Unit.Quality -> Maybe Unit.Reparability -> String
useOptionsToString maybeQuality maybeReparability =
    let
        ( quality, reparability ) =
            ( maybeQuality
                |> Maybe.map (Unit.qualityToFloat >> String.fromFloat)
                |> Maybe.withDefault "standard"
            , maybeReparability
                |> Maybe.map (Unit.reparabilityToFloat >> String.fromFloat)
                |> Maybe.withDefault "standard"
            )
    in
    if quality /= "standard" || reparability /= "standard" then
        " (qualité " ++ quality ++ ", réparabilité " ++ reparability ++ ")"

    else
        ""


countryList : Inputs -> List Country
countryList inputs =
    [ inputs.countryMaterial
    , inputs.countrySpinning
    , inputs.countryFabric
    , inputs.countryDyeing
    , inputs.countryMaking
    , inputs.countryDistribution
    , inputs.countryUse
    , inputs.countryEndOfLife
    ]


updateStepCountry : Label -> Country.Code -> Query -> Query
updateStepCountry label code query =
    case label of
        Label.Spinning ->
            { query | countrySpinning = Just code }

        Label.Fabric ->
            { query | countryFabric = code }

        Label.Dyeing ->
            { query
                | countryDyeing = code
                , dyeingWeighting =
                    if query.countryDyeing /= code then
                        -- reset custom value as we just switched country, which dyeing weighting is totally different
                        Nothing

                    else
                        query.dyeingWeighting
            }

        Label.Making ->
            { query
                | countryMaking = code
                , airTransportRatio =
                    if query.countryMaking /= code then
                        -- reset custom value as we just switched country
                        Nothing

                    else
                        query.airTransportRatio
            }

        _ ->
            query


toggleStep : Label -> Query -> Query
toggleStep label query =
    { query
        | disabledSteps =
            if List.member label query.disabledSteps then
                List.filter ((/=) label) query.disabledSteps

            else
                label :: query.disabledSteps
    }


addMaterial : Db -> Query -> Query
addMaterial db query =
    let
        ( length, polyester, elasthanne ) =
            ( List.length query.materials
            , Material.Id "pet"
            , Material.Id "pu"
            )

        notUsed id =
            query.materials
                |> List.map .id
                |> List.member id
                |> not

        newMaterialId =
            if length == 1 && notUsed polyester then
                Just polyester

            else if length == 2 && notUsed elasthanne then
                Just elasthanne

            else
                db.materials
                    |> List.filter (.id >> notUsed)
                    |> List.sortBy .priority
                    |> List.map .id
                    |> LE.last
    in
    case newMaterialId of
        Just id ->
            { query
                | materials =
                    query.materials ++ [ { id = id, share = Unit.ratio 0 } ]
            }

        Nothing ->
            query


updateMaterialAt : Int -> (MaterialQuery -> MaterialQuery) -> Query -> Query
updateMaterialAt index update query =
    { query | materials = query.materials |> LE.updateAt index update }


updateMaterial : Int -> Material -> Query -> Query
updateMaterial index { id } =
    -- Note: The first material country is always extracted and applied in `fromQuery`.
    updateMaterialAt index (\({ share } as m) -> { m | id = id, share = share })


updateMaterialShare : Int -> Unit.Ratio -> Query -> Query
updateMaterialShare index share =
    updateMaterialAt index (\m -> { m | share = share })


removeMaterial : Int -> Query -> Query
removeMaterial index query =
    { query | materials = query.materials |> LE.removeAt index }
        |> (\({ materials } as q) ->
                -- set share to 100% when a single material remains
                if List.length materials == 1 then
                    updateMaterialShare 0 (Unit.ratio 1) q

                else
                    q
           )


updateProduct : Product -> Query -> Query
updateProduct product query =
    { query
        | product = product.id
        , mass = product.mass
        , quality =
            -- ensure resetting quality when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.quality
        , reparability =
            -- ensure resetting reparability when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.reparability
        , makingWaste =
            -- ensure resetting custom making waste when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.makingWaste
        , picking =
            -- ensure resetting custom picking when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.picking
        , surfaceMass =
            -- ensure resetting custom surface density when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.surfaceMass
    }


defaultQuery : Query
defaultQuery =
    tShirtCotonIndia


tShirtCotonFrance : Query
tShirtCotonFrance =
    -- T-shirt circuit France
    { mass = Mass.kilograms 0.17
    , materials = [ { id = Material.Id "coton", share = Unit.ratio 1 } ]
    , product = Product.Id "tshirt"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "FR"
    , countryDyeing = Country.Code "FR"
    , countryMaking = Country.Code "FR"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , picking = Nothing
    , surfaceMass = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    }


tShirtCotonEurope : Query
tShirtCotonEurope =
    -- T-shirt circuit Europe
    { tShirtCotonFrance
        | countryFabric = Country.Code "TR"
        , countryDyeing = Country.Code "TN"
        , countryMaking = Country.Code "ES"
    }


tShirtCotonIndia : Query
tShirtCotonIndia =
    -- T-shirt circuit Inde
    { tShirtCotonFrance
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "IN"
        , countryMaking = Country.Code "IN"
    }


tShirtCotonAsie : Query
tShirtCotonAsie =
    -- T-shirt circuit Asie
    { tShirtCotonFrance
        | countryFabric = Country.Code "CN"
        , countryDyeing = Country.Code "CN"
        , countryMaking = Country.Code "CN"
    }


jupeCircuitAsie : Query
jupeCircuitAsie =
    -- Jupe circuit Asie
    { mass = Mass.kilograms 0.3
    , materials = [ { id = Material.Id "acrylique", share = Unit.ratio 1 } ]
    , product = Product.Id "jupe"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "CN"
    , countryDyeing = Country.Code "CN"
    , countryMaking = Country.Code "CN"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , picking = Nothing
    , surfaceMass = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    }


manteauCircuitEurope : Query
manteauCircuitEurope =
    -- Manteau circuit Europe
    { mass = Mass.kilograms 0.95
    , materials = [ { id = Material.Id "cachemire", share = Unit.ratio 1 } ]
    , product = Product.Id "manteau"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "TR"
    , countryDyeing = Country.Code "TN"
    , countryMaking = Country.Code "ES"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , picking = Nothing
    , surfaceMass = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    }


pantalonCircuitEurope : Query
pantalonCircuitEurope =
    -- Pantalon circuit Europe
    { mass = Mass.kilograms 0.45
    , materials = [ { id = Material.Id "lin-filasse", share = Unit.ratio 1 } ]
    , product = Product.Id "pantalon"
    , countrySpinning = Nothing
    , countryFabric = Country.Code "TR"
    , countryDyeing = Country.Code "TR"
    , countryMaking = Country.Code "TR"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , quality = Nothing
    , reparability = Nothing
    , makingWaste = Nothing
    , picking = Nothing
    , surfaceMass = Nothing
    , disabledSteps = []
    , disabledFading = Nothing
    }


presets : List Query
presets =
    [ tShirtCotonFrance
    , tShirtCotonEurope
    , tShirtCotonAsie
    , jupeCircuitAsie
    , manteauCircuitEurope
    , pantalonCircuitEurope
    ]


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "materials", Encode.list encodeMaterialInput inputs.materials )
        , ( "product", Product.encode inputs.product )
        , ( "countryFabric", Country.encode inputs.countryFabric )
        , ( "countryDyeing", Country.encode inputs.countryDyeing )
        , ( "countryMaking", Country.encode inputs.countryMaking )
        , ( "dyeingWeighting", inputs.dyeingWeighting |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", inputs.airTransportRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "quality", inputs.quality |> Maybe.map Unit.encodeQuality |> Maybe.withDefault Encode.null )
        , ( "reparability", inputs.reparability |> Maybe.map Unit.encodeReparability |> Maybe.withDefault Encode.null )
        , ( "makingWaste", inputs.makingWaste |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "picking", inputs.picking |> Maybe.map Unit.encodePickPerMeter |> Maybe.withDefault Encode.null )
        , ( "surfaceMass", inputs.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        , ( "disabledSteps", Encode.list Label.encode inputs.disabledSteps )
        , ( "disabledFading", inputs.disabledFading |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        ]


encodeMaterialInput : MaterialInput -> Encode.Value
encodeMaterialInput v =
    Encode.object
        [ ( "material", Material.encode v.material )
        , ( "share", Unit.encodeRatio v.share )
        ]


decodeQuery : Decoder Query
decodeQuery =
    Decode.succeed Query
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "materials" (Decode.list decodeMaterialQuery)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.optional "countrySpinning" (Decode.maybe Country.decodeCode) Nothing
        |> Pipe.required "countryFabric" Country.decodeCode
        |> Pipe.required "countryDyeing" Country.decodeCode
        |> Pipe.required "countryMaking" Country.decodeCode
        |> Pipe.optional "dyeingWeighting" (Decode.maybe Unit.decodeRatio) Nothing
        |> Pipe.optional "airTransportRatio" (Decode.maybe Unit.decodeRatio) Nothing
        |> Pipe.optional "quality" (Decode.maybe Unit.decodeQuality) Nothing
        |> Pipe.optional "reparability" (Decode.maybe Unit.decodeReparability) Nothing
        |> Pipe.optional "makingWaste" (Decode.maybe Unit.decodeRatio) Nothing
        |> Pipe.optional "picking" (Decode.maybe Unit.decodePickPerMeter) Nothing
        |> Pipe.optional "surfaceMass" (Decode.maybe Unit.decodeSurfaceMass) Nothing
        |> Pipe.optional "disabledSteps" (Decode.list Label.decodeFromCode) []
        |> Pipe.optional "disabledFading" (Decode.maybe Decode.bool) Nothing


decodeMaterialQuery : Decoder MaterialQuery
decodeMaterialQuery =
    Decode.succeed MaterialQuery
        |> Pipe.required "id" (Decode.map Material.Id Decode.string)
        |> Pipe.required "share" Unit.decodeRatio


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "materials", Encode.list encodeMaterialQuery query.materials )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countrySpinning", query.countrySpinning |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        , ( "countryFabric", query.countryFabric |> Country.encodeCode )
        , ( "countryDyeing", query.countryDyeing |> Country.encodeCode )
        , ( "countryMaking", query.countryMaking |> Country.encodeCode )
        , ( "dyeingWeighting", query.dyeingWeighting |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", query.airTransportRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "quality", query.quality |> Maybe.map Unit.encodeQuality |> Maybe.withDefault Encode.null )
        , ( "reparability", query.reparability |> Maybe.map Unit.encodeReparability |> Maybe.withDefault Encode.null )
        , ( "makingWaste", query.makingWaste |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "picking", query.picking |> Maybe.map Unit.encodePickPerMeter |> Maybe.withDefault Encode.null )
        , ( "surfaceMass", query.surfaceMass |> Maybe.map Unit.encodeSurfaceMass |> Maybe.withDefault Encode.null )
        , ( "disabledSteps", Encode.list Label.encode query.disabledSteps )
        , ( "disabledFading", query.disabledFading |> Maybe.map Encode.bool |> Maybe.withDefault Encode.null )
        ]


encodeMaterialQuery : MaterialQuery -> Encode.Value
encodeMaterialQuery v =
    Encode.object
        [ ( "id", Material.encodeId v.id )
        , ( "share", Unit.encodeRatio v.share )
        ]


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decodeQuery
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encodeQuery >> Encode.encode 0 >> Base64.encode



-- Parser


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just
