module Data.Db exposing
    ( Db
    , Properties
    , RawJsonString
    , RawJsonStrings
    , build
    , buildFromStrings
    , propGetters
    , rawJsonString
    )

import Data.Component as Component exposing (Component)
import Data.Component.ProductCategory as ProductCategory exposing (ProductCategory)
import Data.Country as Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Generic.Db as GenericDb
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Db as TextileDb
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { components : List Component
    , countries : List Country
    , definitions : Definitions
    , distances : Distances
    , food : FoodDb.Db
    , generic : GenericDb.Db
    , processes : List Process
    , products : List ProductCategory
    , textile : TextileDb.Db
    }


type alias Properties a =
    { apparelComponents : a
    , apparelExamples : a
    , apparelProductCategories : a
    , countries : a
    , definitions : a
    , food2Components : a
    , food2Examples : a
    , food2ProductCategories : a
    , foodIngredients : a
    , foodProductExamples : a
    , objectComponents : a
    , objectExamples : a
    , objectProductCategories : a
    , processes : a
    , textileComponents : a
    , textileMaterials : a
    , textileProductExamples : a
    , textileProducts : a
    , transports : a
    , veliComponents : a
    , veliExamples : a
    , veliProductCategories : a
    }


type RawJsonString
    = RawJsonString String


type alias RawJsonStrings =
    Properties RawJsonString


build : RawJsonStrings -> Result String Db
build json =
    extractJsonString json.processes
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap
                        (Scope.all
                            |> List.filterMap (scopeComponents json)
                            |> List.map (extractJsonString >> Component.decodeListFromJsonString)
                            |> RE.combine
                            -- A missing country inherits the process default origin. Resolve it once here at build
                            -- time so component elements always carries an explicit country. A later "unknown" choice
                            -- stays Nothing on the query item and is not filled again. Also a one-time processing
                            -- is more efficient than a per-query one.
                            |> Result.map (List.concat >> List.map (Component.applyDefaultOrigins processes))
                        )
                    |> RE.andMap
                        (extractJsonString json.countries
                            |> Decode.decodeString (Country.decodeList processes)
                            |> Result.mapError Decode.errorToString
                        )
                    |> RE.andMap
                        (extractJsonString json.definitions
                            |> Decode.decodeString Definition.decode
                            |> Result.mapError Decode.errorToString
                        )
                    |> RE.andMap
                        (extractJsonString json.transports
                            |> Decode.decodeString Transport.decodeDistances
                            |> Result.mapError Decode.errorToString
                        )
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                (extractJsonString json.foodProductExamples)
                                (extractJsonString json.foodIngredients)
                        )
                    |> RE.andMap
                        (GenericDb.buildFromJson
                            (List.map (\scope -> extractJsonString (scopeGenericExamples json scope)) Scope.allGeneric)
                            processes
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        ([ json.food2ProductCategories
                         , json.objectProductCategories
                         , json.veliProductCategories
                         ]
                            |> List.map (extractJsonString >> ProductCategory.decodeListFromJsonString)
                            |> RE.combine
                            |> Result.map List.concat
                        )
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                (extractJsonString json.textileProductExamples)
                                (extractJsonString json.textileMaterials)
                                (extractJsonString json.textileProducts)
                        )
            )


scopeComponents : RawJsonStrings -> Scope -> Maybe RawJsonString
scopeComponents json scope =
    case scope of
        Scope.Food ->
            Nothing

        Scope.Generic genericScope ->
            case genericScope of
                Scope.Apparel ->
                    Just json.apparelComponents

                Scope.Food2 ->
                    Just json.food2Components

                Scope.Object ->
                    Just json.objectComponents

                Scope.Veli ->
                    Just json.veliComponents

        Scope.Textile ->
            Just json.textileComponents


scopeGenericExamples : RawJsonStrings -> Scope.GenericScope -> RawJsonString
scopeGenericExamples json scope =
    case scope of
        Scope.Apparel ->
            json.apparelExamples

        Scope.Food2 ->
            json.food2Examples

        Scope.Object ->
            json.objectExamples

        Scope.Veli ->
            json.veliExamples


buildFromStrings : Properties String -> Result String Db
buildFromStrings strings =
    build
        { apparelComponents = rawJsonString strings.apparelComponents
        , apparelExamples = rawJsonString strings.apparelExamples
        , apparelProductCategories = rawJsonString strings.apparelProductCategories
        , countries = rawJsonString strings.countries
        , definitions = rawJsonString strings.definitions
        , food2Components = rawJsonString strings.food2Components
        , food2Examples = rawJsonString strings.food2Examples
        , food2ProductCategories = rawJsonString strings.food2ProductCategories
        , foodIngredients = rawJsonString strings.foodIngredients
        , foodProductExamples = rawJsonString strings.foodProductExamples
        , objectComponents = rawJsonString strings.objectComponents
        , objectExamples = rawJsonString strings.objectExamples
        , objectProductCategories = rawJsonString strings.objectProductCategories
        , processes = rawJsonString strings.processes
        , textileComponents = rawJsonString strings.textileComponents
        , textileMaterials = rawJsonString strings.textileMaterials
        , textileProductExamples = rawJsonString strings.textileProductExamples
        , textileProducts = rawJsonString strings.textileProducts
        , transports = rawJsonString strings.transports
        , veliComponents = rawJsonString strings.veliComponents
        , veliExamples = rawJsonString strings.veliExamples
        , veliProductCategories = rawJsonString strings.veliProductCategories
        }


extractJsonString : RawJsonString -> String
extractJsonString (RawJsonString string) =
    string


propGetters : List (Properties a -> a)
propGetters =
    .countries
        :: .definitions
        :: .transports
        :: .processes
        :: List.concatMap scopePropGetters Scope.all


scopePropGetters : Scope -> List (Properties a -> a)
scopePropGetters scope =
    case scope of
        Scope.Food ->
            [ .foodIngredients
            , .foodProductExamples
            ]

        Scope.Generic Scope.Apparel ->
            [ .apparelProductCategories
            , .apparelComponents
            , .apparelExamples
            ]

        Scope.Generic Scope.Food2 ->
            [ .food2ProductCategories
            , .food2Examples
            ]

        Scope.Generic Scope.Object ->
            [ .objectProductCategories
            , .objectComponents
            , .objectExamples
            ]

        Scope.Generic Scope.Veli ->
            [ .veliProductCategories
            , .veliComponents
            , .veliExamples
            ]

        Scope.Textile ->
            [ .textileComponents
            , .textileMaterials
            , .textileProductExamples
            , .textileProducts
            ]


rawJsonString : String -> RawJsonString
rawJsonString =
    RawJsonString
