module Data.Session exposing
    ( Notification(..)
    , Session
    , checkComparedSimulations
    , closeNotification
    , deleteBookmark
    , deserializeStore
    , maxComparedSimulations
    , notifyError
    , saveBookmark
    , serializeStore
    , toggleComparedSimulation
    , updateEcotoxWeighting
    , updateFoodQuery
    , updateTextileQuery
    )

import Browser.Navigation as Nav
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Db as FoodDb
import Data.Food.Query as FoodQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as TextileInputs
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Request.Version exposing (Version)
import Set exposing (Set)


type alias Session =
    { navKey : Nav.Key
    , clientUrl : String
    , store : Store
    , currentVersion : Version
    , matomo : { host : String, siteId : String }
    , textileDb : TextileDb.Db
    , foodDb : FoodDb.Db
    , notifications : List Notification
    , queries :
        { food : FoodQuery.Query
        , textile : TextileInputs.Query
        }
    }



-- Notifications


type Notification
    = GenericError String String


closeNotification : Notification -> Session -> Session
closeNotification notification ({ notifications } as session) =
    { session | notifications = notifications |> List.filter ((/=) notification) }


notifyError : String -> String -> Session -> Session
notifyError title error ({ notifications } as session) =
    { session | notifications = notifications ++ [ GenericError title error ] }



-- Boomarks


deleteBookmark : Bookmark -> Session -> Session
deleteBookmark bookmark =
    updateStore
        (\store ->
            { store
                | bookmarks =
                    List.filter ((/=) bookmark) store.bookmarks
            }
        )


saveBookmark : Bookmark -> Session -> Session
saveBookmark bookmark =
    updateStore
        (\store ->
            { store
                | bookmarks =
                    bookmark :: store.bookmarks
            }
        )



-- Queries


updateFoodQuery : FoodQuery.Query -> Session -> Session
updateFoodQuery foodQuery ({ queries } as session) =
    { session | queries = { queries | food = foodQuery } }


updateTextileQuery : TextileInputs.Query -> Session -> Session
updateTextileQuery textileQuery ({ queries } as session) =
    { session | queries = { queries | textile = textileQuery } }



-- Comparator


maxComparedSimulations : Int
maxComparedSimulations =
    12


checkComparedSimulations : Session -> Session
checkComparedSimulations =
    updateStore
        (\({ bookmarks, comparedSimulations } as store) ->
            { store
                | comparedSimulations =
                    if Set.size comparedSimulations == 0 then
                        -- Add max bookmarks to compared sims
                        bookmarks
                            |> Bookmark.sort
                            |> List.take maxComparedSimulations
                            |> List.map Bookmark.toId
                            |> Set.fromList

                    else
                        -- Purge deleted bookmarks from compared sims
                        comparedSimulations
                            |> Set.filter
                                (\id ->
                                    bookmarks
                                        |> List.map Bookmark.toId
                                        |> List.member id
                                )
            }
        )


toggleComparedSimulation : Bookmark -> Bool -> Session -> Session
toggleComparedSimulation bookmark checked =
    updateStore
        (\store ->
            { store
                | comparedSimulations =
                    if checked then
                        Set.insert (Bookmark.toId bookmark) store.comparedSimulations

                    else
                        Set.remove (Bookmark.toId bookmark) store.comparedSimulations
            }
        )



-- Store
--
-- A serializable data structure holding session information you want to share
-- across browser restarts, typically in localStorage.


type alias Store =
    { comparedSimulations : Set String
    , bookmarks : List Bookmark
    }


defaultStore : Store
defaultStore =
    { comparedSimulations = Set.empty
    , bookmarks = []
    }


decodeStore : Decoder Store
decodeStore =
    Decode.succeed Store
        |> JDP.optional "comparedSimulations" (Decode.map Set.fromList (Decode.list Decode.string)) Set.empty
        |> JDP.optional "bookmarks" (Decode.list Bookmark.decode) []


encodeStore : Store -> Encode.Value
encodeStore store =
    Encode.object
        [ ( "comparedSimulations", store.comparedSimulations |> Set.toList |> Encode.list Encode.string )
        , ( "bookmarks", Encode.list Bookmark.encode store.bookmarks )
        ]


deserializeStore : String -> Store
deserializeStore =
    Decode.decodeString decodeStore
        -- FIXME: this should return a `Result String Store` so we could inform
        -- users something went wrong while decoding their data (eg. so they can
        -- report the issue).
        -- Meanwhile, if you ever need to debug JSON decode errors from session
        -- store, uncomment these lines.
        -- >> (\res ->
        --         case res of
        --             Ok r ->
        --                 Ok r
        --             Err err ->
        --                 let
        --                     _ =
        --                         Debug.log "deserializeStore error" err
        --                 in
        --                 Err err
        --    )
        >> Result.withDefault defaultStore


serializeStore : Store -> String
serializeStore =
    encodeStore >> Encode.encode 0


updateStore : (Store -> Store) -> Session -> Session
updateStore update session =
    { session | store = update session.store }


{-| Updates food and textile databases with updated impact definitions and recomputes
resulting aggregated impacts.
-}
updateDbDefinitions : Definitions -> Session -> Session
updateDbDefinitions definitions ({ foodDb, textileDb } as session) =
    { session
        | foodDb =
            { foodDb
                | impactDefinitions = definitions
                , processes =
                    foodDb.processes
                        |> List.map
                            (\({ impacts } as process) ->
                                { process | impacts = Impact.updateAggregatedScores definitions impacts }
                            )
            }
        , textileDb =
            { textileDb
                | impactDefinitions = definitions
                , processes =
                    textileDb.processes
                        |> List.map
                            (\({ impacts } as process) ->
                                { process | impacts = Impact.updateAggregatedScores definitions impacts }
                            )
            }
    }


updateEcotoxWeighting : Unit.Ratio -> Session -> Session
updateEcotoxWeighting (Unit.Ratio ratio) session =
    let
        defsToUpdate =
            [ Definition.Acd
            , Definition.Fru
            , Definition.Fwe
            , Definition.Ior
            , Definition.Ldu
            , Definition.Mru
            , Definition.Ozd
            , Definition.Pco
            , Definition.Pma
            , Definition.Swe
            , Definition.Tre
            , Definition.Wtu
            ]

        cleanRatio =
            clamp 0 25 ratio

        newDefinitions =
            session.textileDb.impactDefinitions
                -- Start with updating EtfC with the provided ratio
                |> Definition.update Definition.EtfC
                    (\({ ecoscoreData } as definition) ->
                        { definition
                            | ecoscoreData =
                                ecoscoreData
                                    |> Maybe.map (\ecs -> { ecs | weighting = Unit.ratio cleanRatio })
                        }
                    )
                -- Apply Pascal's formula to the other definitions to adjust
                |> Definition.map
                    (\trg def ->
                        if List.member trg defsToUpdate then
                            let
                                pefWeighting =
                                    def.pefData
                                        |> Maybe.map .weighting
                                        |> Maybe.withDefault (Unit.ratio 0)
                                        |> Unit.ratioToFloat
                            in
                            { def
                                | ecoscoreData =
                                    def.ecoscoreData
                                        |> Maybe.map
                                            (\ecoscoreData ->
                                                { ecoscoreData
                                                  -- = (PEF weighting for this trigram) * (78.94% - custom ratio) / 73.05%
                                                    | weighting = Unit.ratio (pefWeighting * (0.7894 - cleanRatio) / 0.7305)
                                                }
                                            )
                            }

                        else
                            def
                    )
    in
    session
        |> updateDbDefinitions newDefinitions
