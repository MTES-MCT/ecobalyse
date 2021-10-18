module Data.Process exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Process =
    { cat1 : Cat1
    , cat2 : Cat2
    , cat3 : Cat3
    , name : String
    , uuid : Uuid
    , climateChange : Float -- kgCO2e per kg of material to process
    , heat : Energy -- MJ per kg of material to process
    , elec_pppm : Float -- kWh/(pick,m) per kg of material to process
    , elec : Energy -- MJ per kg of material to process
    , waste : Mass -- kg of textile wasted per kg of material to process
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


noOp : Process
noOp =
    { cat1 = Textile
    , cat2 = Material
    , cat3 = NaturalMaterials
    , name = "void"
    , uuid = Uuid ""
    , climateChange = 0
    , heat = Energy.megajoules 0
    , elec_pppm = 0
    , elec = Energy.megajoules 0
    , waste = Mass.kilograms 0
    }


findByUuid : Uuid -> Process
findByUuid uuid =
    processes |> List.filter (.uuid >> (==) uuid) |> List.head |> Maybe.withDefault noOp


findByName : String -> Process
findByName name =
    processes |> List.filter (.name >> (==) name) |> List.head |> Maybe.withDefault noOp


airTransport : Process
airTransport =
    findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"


seaTransport : Process
seaTransport =
    findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"


roadTransportPreMaking : Process
roadTransportPreMaking =
    findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"


roadTransportPostMaking : Process
roadTransportPostMaking =
    findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"


distribution : Process
distribution =
    findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"


dyeingHigh : Process
dyeingHigh =
    findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"


dyeingLow : Process
dyeingLow =
    findByName "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées"


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


processes : List Process
processes =
    -- In a first iteration, processes data will statically live in memory; later on, we'll load them over HTTP.
    case Decode.decodeString (Decode.list decode) jsonProcesses of
        Ok decoded ->
            decoded

        Err _ ->
            []


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string


fromResult : Result String a -> Decoder a
fromResult result =
    case result of
        Ok great ->
            Decode.succeed great

        Err problem ->
            Decode.fail problem


decode : Decoder Process
decode =
    Decode.succeed Process
        |> Pipe.required "cat1" (Decode.string |> Decode.andThen (cat1FromString >> fromResult))
        |> Pipe.required "cat2" (Decode.string |> Decode.andThen (cat2FromString >> fromResult))
        |> Pipe.required "cat3" (Decode.string |> Decode.andThen (cat3FromString >> fromResult))
        |> Pipe.required "name" Decode.string
        |> Pipe.required "uuid" (Decode.map Uuid Decode.string)
        |> Pipe.required "climateChange" Decode.float
        |> Pipe.required "heat" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "elec_pppm" Decode.float
        |> Pipe.required "elec" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "waste" (Decode.map Mass.kilograms Decode.float)


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "cat1", v.cat1 |> cat1ToString |> Encode.string )
        , ( "cat2", v.cat2 |> cat2ToString |> Encode.string )
        , ( "cat3", v.cat3 |> cat3ToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "uuid", v.uuid |> uuidToString |> Encode.string )
        , ( "climateChange", Encode.float v.climateChange )
        , ( "heat", v.heat |> Energy.inMegajoules |> Encode.float )
        , ( "elec_pppm", Encode.float v.elec_pppm )
        , ( "elec", v.elec |> Energy.inMegajoules |> Encode.float )
        , ( "waste", v.waste |> Mass.inKilograms |> Encode.float )
        ]


encodeAll : String
encodeAll =
    processes |> Encode.list encode |> Encode.encode 0


jsonProcesses : String
jsonProcesses =
    """
[
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, TR",
    "uuid": "6fad8643-de3e-49dd-a48b-8e17b4175c23",
    "climateChange": 0.706988,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, TN",
    "uuid": "f0eb64cd-468d-4f3c-a9a3-3b3661625955",
    "climateChange": 0.80722,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, IN",
    "uuid": "1b470f5c-6ae6-404d-bd71-8546d33dbc17",
    "climateChange": 1.58299,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, FR",
    "uuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
    "climateChange": 0.0813225,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, CN",
    "uuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
    "climateChange": 1.05738,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, ES",
    "uuid": "37301c44-c4cf-4214-a4ac-eee5785ccdc5",
    "climateChange": 0.467803,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, PT",
    "uuid": "a1d83202-0052-4d10-b9d2-938564be6a0b",
    "climateChange": 0.571172,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Electricité",
    "cat3": "Mix moyen",
    "name": "Mix électrique réseau, BD",
    "uuid": "1ee6061e-8e15-4558-9338-94ad87abf932",
    "climateChange": 0.795168,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Chaleur",
    "cat3": "Mix moyen",
    "name": "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA",
    "uuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
    "climateChange": 0.106827,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Chaleur",
    "cat3": "Mix moyen",
    "name": "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), RER",
    "uuid": "59c4c64c-0916-868a-5dd6-a42c4c42222f",
    "climateChange": 0.0744719,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Chaleur",
    "cat3": "Mix moyen",
    "name": "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR",
    "uuid": "12fc43f2-a007-423b-a619-619d725793ea",
    "climateChange": 0.0854514,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Energie",
    "cat2": "Chaleur",
    "cat3": "Valeur par énergie primaire",
    "name": "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), ES",
    "uuid": "618440a9-f4aa-65bc-21cb-ea40eee53f3d",
    "climateChange": 0.0830517,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Plume de canard, inventaire agrégé",
    "uuid": "d1f06ea5-d63f-453a-8f98-55ce78ae7579",
    "climateChange": 16.238,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de soie",
    "uuid": "94b4b0e1-61e4-4f4d-b9b2-efe7623b0e68",
    "climateChange": 18.5727,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 7.79322
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de lin (filasse)",
    "uuid": "e5a6d538-f932-4242-98b4-3a0c6439629c",
    "climateChange": 16.7281,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.170215
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de lin (étoupe)",
    "uuid": "fcef1a31-bb18-49e4-bdb6-e53dfe015ba0",
    "climateChange": 15.1829,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.288932
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de laine de mouton Mérinos, inventaire partiellement agrégé",
    "uuid": "4e035dbf-f48b-4b5a-94ea-0006c713958b",
    "climateChange": 73.8467,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.08696
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de laine de mouton",
    "uuid": "376bd165-d354-41aa-a6e3-fd3228413bb2",
    "climateChange": 80.2769,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.672241
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de laine de chameau",
    "uuid": "c191a4dd-5080-4eb6-9c59-b13c943327bc",
    "climateChange": 175.102,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 3.17851
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de jute",
    "uuid": "72010874-4d26-4c7a-95de-c6987dfdedeb",
    "climateChange": 12.9611,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.270519
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de coton conventionnel, inventaire partiellement agrégé",
    "uuid": "f211bbdb-415c-46fd-be4d-ddf199575b44",
    "climateChange": 16.3699,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.201201
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de chanvre",
    "uuid": "08601439-f338-4f94-ac8c-538061b65d16",
    "climateChange": 19.5483,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.221094
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil de cachemire",
    "uuid": "380c0d9c-2840-4390-bd3f-5c960f26f5ed",
    "climateChange": 385.476,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 3.17851
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fil d'angora",
    "uuid": "29bddef1-d753-45af-9ca6-aec05e2d02b9",
    "climateChange": 45.1782,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.672241
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières naturelles",
    "name": "Fibres de kapok, inventaire agrégé",
    "uuid": "36cdbfc4-3f48-47b0-8ae0-294bb6017df1",
    "climateChange": -0.0280245,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de viscose",
    "uuid": "81a67d97-3cd9-44ef-9ee2-159364364c0f",
    "climateChange": 7.99002,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0582011
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polyuréthane",
    "uuid": "c3738500-0a62-4b95-b4a2-b7beb12a9e1a",
    "climateChange": 20.6809,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.00796392
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polytriméthylène téréphtalate (PTT), inventaire partiellement agrégé",
    "uuid": "eca33573-0d09-4d79-9b28-da42bfcc7a4b",
    "climateChange": 12.0842,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polytéréphtalate de butylène (PBT), inventaire agrégé",
    "uuid": "7f8bbfdc-fb65-4e3a-ac81-eda197ef17fc",
    "climateChange": 10.1195,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polypropylène",
    "uuid": "a30cfbde-393a-40db-9263-ea00bfced0b7",
    "climateChange": 6.91894,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polylactide",
    "uuid": "f2dd799d-1b69-4e7a-99bd-696bbbd5a978",
    "climateChange": 9.35683,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polyéthylène",
    "uuid": "088ed617-67fa-4d42-b3af-ee6cf39cf36f",
    "climateChange": 6.91078,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polyester, inventaire partiellement agrégé",
    "uuid": "4d57c51d-7d56-46e1-acde-02fbcdc943e4",
    "climateChange": 10.2505,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament de polyamide 66",
    "uuid": "182fa424-1f49-4728-b0f1-cb4e4ab36392",
    "climateChange": 13.6468,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament d'aramide",
    "uuid": "7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5",
    "climateChange": 22.3103,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament d'acrylique",
    "uuid": "aee6709f-0864-4fc5-8760-68cb644a0021",
    "climateChange": 18.4288,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.00796392
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Filament bi-composant polypropylène/polyamide",
    "uuid": "37396ac4-13a2-484c-9cc6-5b5a93ff6e6e",
    "climateChange": 8.26356,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319569
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières synthétiques",
    "name": "Feuille de néoprène, inventaire agrégé",
    "uuid": "76fefff3-3781-49a2-8deb-c12945a6b71f",
    "climateChange": 9.87734,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de filament de polyester recyclé (recyclage mécanique), traitement de bouteilles post-consommation, inventaire partiellement agrégé",
    "uuid": "4072bfa2-1948-4d12-8de9-bbeb6cc628e1",
    "climateChange": 6.58922,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.031957
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de filament de polyester recyclé (recyclage chimique partiel), traitement de bouteilles post-consommation, inventaire partiellement agrégé",
    "uuid": "e65e8157-9bd1-4711-9571-8e4a22c2d2b5",
    "climateChange": 22.3377,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.032
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de filament de polyester recyclé (recyclage chimique complet), traitement de bouteilles post-consommation, inventaire partiellement agrégé",
    "uuid": "221067ba-5c2f-4dad-b09a-dd5af0a9ae31",
    "climateChange": 6.99213,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.032
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de filament de polyamide recyclé (recyclage chimique), traitement de déchets issus de filets de pêche, de tapis et de déchets de production, inventaire partiellement agrégé",
    "uuid": "41ee61c2-9a98-4eec-8949-9d9b54289bd0",
    "climateChange": 8.55458,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.0319681
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fil de viscose recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé",
    "uuid": "9671ae26-d772-4bb1-aad5-6b826555d0cd",
    "climateChange": 6.46416,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.137851
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fil de polyamide recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé",
    "uuid": "af5d130d-f18b-438c-9f19-d1ee49756960",
    "climateChange": 5.22649,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.137851
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fil de laine recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé",
    "uuid": "92dfabc7-9441-463e-bda8-7bc5943c0e9d",
    "climateChange": 0.495013,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.1688
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fil de coton recyclé (recyclage mécanique), traitement de déchets textiles post-consommation, inventaire partiellement agrégé",
    "uuid": "4d23093d-1346-4018-8c0f-7aae33c67bcd",
    "climateChange": 1.02499,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.77305
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fil de coton recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé",
    "uuid": "2b24abb0-c1ec-4298-9b58-350904a26104",
    "climateChange": 1.42207,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.323
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fil d'acrylique recyclé (recyclage mécanique), traitement de déchets de production textiles, inventaire partiellement agrégé",
    "uuid": "7603beaa-c555-4283-b9f8-4d5d231b8490",
    "climateChange": 6.56515,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.137851
  },
  {
    "cat1": "Textile",
    "cat2": "Matières",
    "cat3": "Matières recyclées",
    "name": "Production de fibres recyclées, traitement de déchets textiles post-consommation (recyclage mécanique), inventaire partiellement agrégé",
    "uuid": "ca5dc5b3-7fa2-4779-af0b-aa6f31cd457f",
    "climateChange": 0.250572,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0.21
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Tricotage",
    "name": "Tricotage",
    "uuid": "9c478d79-ff6b-45e1-9396-c3bd897faa1d",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 8.64,
    "waste": 0.0576
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Tissage",
    "name": "Tissage (habillement)",
    "uuid": "f9686809-f55e-4b96-b1f0-3298959de7d0",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0.0003145,
    "elec": 0,
    "waste": 0.0667
  },
  {
    "cat1": "Textile",
    "cat2": "Ennoblissement",
    "cat3": "Teinture",
    "name": "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées",
    "uuid": "cf001531-5f2d-48b1-b30a-4a17466a8b30",
    "climateChange": 0.420837,
    "heat": 71.71,
    "elec_pppm": 0,
    "elec": 38.1,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Ennoblissement",
    "cat3": "Teinture",
    "name": "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées",
    "uuid": "fb4bea16-7ce1-43e2-9e03-462250214988",
    "climateChange": 0.397712,
    "heat": 25.87,
    "elec_pppm": 0,
    "elec": 7.17,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Confection",
    "name": "Confection (jeans)",
    "uuid": "1f428a50-73c0-4fc1-ab39-00fd312458ee",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 9.612,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Confection",
    "name": "Confection (gilet, jupe, pantalon, pull)",
    "uuid": "387059fc-72cb-4a92-b1e7-2ef9242f8380",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 2.232,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Confection",
    "name": "Confection (débardeur, tee-shirt, combinaison)",
    "uuid": "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 1.8,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Confection",
    "name": "Confection (chemisier, manteau, veste, cape, robe)",
    "uuid": "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 3.204,
    "waste": 0
  },
  {
    "cat1": "Textile",
    "cat2": "Mise en forme",
    "cat3": "Confection",
    "name": "Confection (ceinture, châle, chapeau, sac, écharpe)",
    "uuid": "0a260a3f-260e-4b43-a0df-0cf673fda960",
    "climateChange": 0,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 1.512,
    "waste": 0
  },
  {
    "cat1": "Transport",
    "cat2": "Maritime",
    "cat3": "Flotte moyenne",
    "name": "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO",
    "uuid": "8dc4ce62-ff0f-4680-897f-867c3b31a923",
    "climateChange": 0.0483042,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Transport",
    "cat2": "Aérien",
    "cat3": "Flotte moyenne",
    "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
    "uuid": "839b263d-5111-4318-9275-7026937e88b2",
    "climateChange": 1.20941,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Transport",
    "cat2": "Routier",
    "cat3": "Flotte moyenne continentale",
    "name": "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO",
    "uuid": "cf6e9d81-358c-4f44-5ab7-0e7a89440576",
    "climateChange": 0.204544,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Transport",
    "cat2": "Routier",
    "cat3": "Flotte moyenne continentale",
    "name": "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER",
    "uuid": "c0397088-6a57-eea7-8950-1d6db2e6bfdb",
    "climateChange": 0.156105,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  },
  {
    "cat1": "Transport",
    "cat2": "Routier",
    "cat3": "Flotte moyenne française",
    "name": "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR",
    "uuid": "f49b27fa-f22e-c6e1-ab4b-e9f873e2e648",
    "climateChange": 0.269575,
    "heat": 0,
    "elec_pppm": 0,
    "elec": 0,
    "waste": 0
  }
]
"""
