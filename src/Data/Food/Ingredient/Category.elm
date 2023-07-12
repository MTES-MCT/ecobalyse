module Data.Food.Ingredient.Category exposing
    ( Category(..)
    , decode
    , fromAnimalOrigin
    , toLabel
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Category
    = AnimalProduct
    | Conventional
    | DairyProduct
    | GrainRaw
    | GrainProcessed
    | Misc
    | NutOilseedRaw
    | NutOilseedProcessed
    | SpiceCondimentOrAdditive
    | VegetableFresh
    | VegetableProcessed
    | Organic
    | BleuBlancCoeur


fromAnimalOrigin : List Category -> Bool
fromAnimalOrigin categories =
    [ AnimalProduct, DairyProduct ]
        |> List.any (\c -> List.member c categories)


fromString : String -> Result String Category
fromString str =
    case str of
        "animal_product" ->
            Ok AnimalProduct

        "conventional" ->
            Ok Conventional

        "dairy_product" ->
            Ok DairyProduct

        "grain_raw" ->
            Ok GrainRaw

        "grain_processed" ->
            Ok GrainProcessed

        "misc" ->
            Ok Misc

        "nut_oilseed_raw" ->
            Ok NutOilseedRaw

        "nut_oilseed_processed" ->
            Ok NutOilseedProcessed

        "spice_condiment_additive" ->
            Ok SpiceCondimentOrAdditive

        "vegetable_fresh" ->
            Ok VegetableFresh

        "vegetable_processed" ->
            Ok VegetableProcessed

        "organic" ->
            Ok Organic

        "bleublanccoeur" ->
            Ok BleuBlancCoeur

        _ ->
            Err <| "Categorie d'ingrédient invalide : " ++ str


toLabel : Category -> String
toLabel category =
    case category of
        AnimalProduct ->
            "Viandes, œufs, poissons, et dérivés"

        Conventional ->
            "Conventionnel"

        DairyProduct ->
            "Lait et ingrédients laitiers"

        GrainRaw ->
            "Céréales brutes"

        GrainProcessed ->
            "Céréales transformées"

        Misc ->
            "Divers"

        NutOilseedRaw ->
            "Fruits à coque et oléoprotéagineux bruts"

        NutOilseedProcessed ->
            "Graisses végétales et oléoprotéagineux transformés"

        SpiceCondimentOrAdditive ->
            "Condiments, épices, additifs"

        VegetableFresh ->
            "Fruits et légumes frais"

        VegetableProcessed ->
            "Fruits et légumes transformés"

        Organic ->
            "Bio"

        BleuBlancCoeur ->
            "Bleu-Blanc-Cœur"


decode : Decoder Category
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)
