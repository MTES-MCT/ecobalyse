module Data.Process exposing (..)

import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE


type alias Process =
    { cat1 : Cat1
    , cat2 : Cat2
    , cat3 : Cat3
    , name : String
    , uuid : Uuid
    , impacts : Impacts
    , heat : Energy --  MJ per kg of material to process
    , elec_pppm : Float -- kWh/(pick,m) per kg of material to process
    , elec : Energy -- MJ per kg of material to process
    , waste : Mass -- kg of textile wasted per kg of material to process
    , alias : Maybe String
    }


type Uuid
    = Uuid String


type Cat1
    = --Energie
      Energy
      --Textile
    | Textile
      --Transport
    | Transport


type Cat2
    = -- "Aérien"
      AirTransport
      -- "Chaleur"
    | Heat
      -- "Electricité"
    | Electricity
      -- "Ennoblissement"
    | Ennoblement
      -- "Maritime"
    | SeaTransport
      -- "Matières"
    | Material
      -- "Mise en forme"
    | Processing
      -- "Routier"
    | RoadTransport


type Cat3
    = -- Mix moyen
      AverageMix
      -- Valeur par énergie primaire
    | PrimaryEnergyValue
      -- Matières naturelles
    | NaturalMaterials
      -- Matières synthétiques
    | SyntheticMaterials
      -- Matières recyclées
    | RecycledMaterials
      -- Tricotage
    | Knitting
      -- Tissage
    | Weaving
      -- Teinture
    | Dyeing
      -- Confection
    | Making
      -- Flotte moyenne
    | AverageFleet
      -- Flotte moyenne continentale
    | AverageContinentalFleet
      -- Flotte moyenne française
    | AverageFrenchFleet


type alias WellKnown =
    { airTransport : Process
    , seaTransport : Process
    , roadTransportPreMaking : Process
    , roadTransportPostMaking : Process
    , distribution : Process
    , dyeingHigh : Process
    , dyeingLow : Process
    }


noOpProcess : Process
noOpProcess =
    { cat1 = Textile
    , cat2 = Material
    , cat3 = NaturalMaterials
    , name = "void"
    , uuid = Uuid ""
    , impacts = Impact.noImpacts
    , heat = Energy.megajoules 0
    , elec_pppm = 0
    , elec = Energy.megajoules 0
    , waste = Mass.kilograms 0
    , alias = Nothing
    }


findByUuid : Uuid -> List Process -> Result String Process
findByUuid uuid =
    List.filter (.uuid >> (==) uuid)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par UUID: " ++ uuidToString uuid)


findByName : String -> List Process -> Result String Process
findByName name =
    List.filter (.name >> (==) name)
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par nom: " ++ name)


findByAlias : String -> List Process -> Result String Process
findByAlias alias =
    List.filter (.alias >> (==) (Just alias))
        >> List.head
        >> Result.fromMaybe ("Procédé introuvable par alias: " ++ alias)


getImpact : Impact.Trigram -> Process -> Unit.Impact
getImpact trigram =
    .impacts >> Impact.getImpact trigram


updateImpact : Impact.Trigram -> Unit.Impact -> Process -> Process
updateImpact trigram value process =
    { process
        | impacts =
            process.impacts
                |> Impact.updateImpact trigram value
    }


loadWellKnown : List Process -> Result String WellKnown
loadWellKnown p =
    Ok WellKnown
        |> RE.andMap (findByAlias "airTransport" p)
        |> RE.andMap (findByAlias "seaTransport" p)
        |> RE.andMap (findByAlias "roadTransportPreMaking" p)
        |> RE.andMap (findByAlias "roadTransportPostMaking" p)
        |> RE.andMap (findByAlias "distribution" p)
        |> RE.andMap (findByAlias "dyeingHigh" p)
        |> RE.andMap (findByAlias "dyeingLow" p)


cat1 : Cat1 -> List Process -> List Process
cat1 c1 =
    List.filter (.cat1 >> (==) c1)


cat2 : Cat2 -> List Process -> List Process
cat2 c2 =
    List.filter (.cat2 >> (==) c2)


cat3 : Cat3 -> List Process -> List Process
cat3 c3 =
    List.filter (.cat3 >> (==) c3)


cat1FromString : String -> Result String Cat1
cat1FromString c1 =
    case c1 of
        "Energie" ->
            Ok Energy

        "Textile" ->
            Ok Textile

        "Transport" ->
            Ok Transport

        _ ->
            Err <| "Catégorie 1 invalide: " ++ c1


cat1ToString : Cat1 -> String
cat1ToString c1 =
    case c1 of
        Energy ->
            "Energie"

        Textile ->
            "Textile"

        Transport ->
            "Transport"


cat2FromString : String -> Result String Cat2
cat2FromString c2 =
    case c2 of
        "Aérien" ->
            Ok AirTransport

        "Chaleur" ->
            Ok Heat

        "Electricité" ->
            Ok Electricity

        "Ennoblissement" ->
            Ok Ennoblement

        "Maritime" ->
            Ok SeaTransport

        "Matières" ->
            Ok Material

        "Mise en forme" ->
            Ok Processing

        "Routier" ->
            Ok RoadTransport

        _ ->
            Err <| "Catégorie 2 invalide: " ++ c2


cat2ToString : Cat2 -> String
cat2ToString c2 =
    case c2 of
        AirTransport ->
            "Aérien"

        Heat ->
            "Chaleur"

        Electricity ->
            "Electricité"

        Ennoblement ->
            "Ennoblissement"

        SeaTransport ->
            "Maritime"

        Material ->
            "Matières"

        Processing ->
            "Mise en forme"

        RoadTransport ->
            "Routier"


cat3FromString : String -> Result String Cat3
cat3FromString c3 =
    case c3 of
        "Mix moyen" ->
            Ok AverageMix

        "Valeur par énergie primaire" ->
            Ok PrimaryEnergyValue

        "Matières naturelles" ->
            Ok NaturalMaterials

        "Matières synthétiques" ->
            Ok SyntheticMaterials

        "Matières recyclées" ->
            Ok RecycledMaterials

        "Tricotage" ->
            Ok Knitting

        "Tissage" ->
            Ok Weaving

        "Teinture" ->
            Ok Dyeing

        "Confection" ->
            Ok Making

        "Flotte moyenne" ->
            Ok AverageFleet

        "Flotte moyenne continentale" ->
            Ok AverageContinentalFleet

        "Flotte moyenne française" ->
            Ok AverageFrenchFleet

        _ ->
            Err <| "Catégorie 3 invalide: " ++ c3


cat3ToString : Cat3 -> String
cat3ToString c3 =
    case c3 of
        AverageMix ->
            "Mix moyen"

        PrimaryEnergyValue ->
            "Valeur par énergie primaire"

        NaturalMaterials ->
            "Matières naturelles"

        SyntheticMaterials ->
            "Matières synthétiques"

        RecycledMaterials ->
            "Matières recyclées"

        Knitting ->
            "Tricotage"

        Weaving ->
            "Tissage"

        Dyeing ->
            "Teinture"

        Making ->
            "Confection"

        AverageFleet ->
            "Flotte moyenne"

        AverageContinentalFleet ->
            "Flotte moyenne continentale"

        AverageFrenchFleet ->
            "Flotte moyenne française"


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string


decodeFromUuid : List Process -> Decoder Process
decodeFromUuid processes =
    Decode.string
        |> Decode.andThen
            (\uuid ->
                processes
                    |> findByUuid (Uuid uuid)
                    |> DecodeExtra.fromResult
            )


decode : List Impact.Definition -> Decoder Process
decode impacts =
    Decode.succeed Process
        |> Pipe.required "cat1" (Decode.string |> Decode.andThen (cat1FromString >> DecodeExtra.fromResult))
        |> Pipe.required "cat2" (Decode.string |> Decode.andThen (cat2FromString >> DecodeExtra.fromResult))
        |> Pipe.required "cat3" (Decode.string |> Decode.andThen (cat3FromString >> DecodeExtra.fromResult))
        |> Pipe.required "name" Decode.string
        |> Pipe.required "uuid" (Decode.map Uuid Decode.string)
        |> Pipe.required "impacts" (Impact.decodeImpacts impacts)
        |> Pipe.required "heat" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "elec_pppm" Decode.float
        |> Pipe.required "elec" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "waste" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "alias" (Decode.maybe Decode.string)


decodeList : List Impact.Definition -> Decoder (List Process)
decodeList impacts =
    Decode.list (decode impacts)


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "cat1", v.cat1 |> cat1ToString |> Encode.string )
        , ( "cat2", v.cat2 |> cat2ToString |> Encode.string )
        , ( "cat3", v.cat3 |> cat3ToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "uuid", v.uuid |> uuidToString |> Encode.string )
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "heat", v.heat |> Energy.inMegajoules |> Encode.float )
        , ( "elec_pppm", Encode.float v.elec_pppm )
        , ( "elec", v.elec |> Energy.inMegajoules |> Encode.float )
        , ( "waste", v.waste |> Mass.inKilograms |> Encode.float )
        , ( "alias", v.alias |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        ]


encodeAll : List Process -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
