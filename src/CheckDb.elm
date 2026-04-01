port module CheckDb exposing (main)

import Data.Component as Component exposing (Component)
import Data.Component.Config as ComponentConfig
import Data.Example exposing (Example)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope
import Data.Uuid as Uuid
import Dict exposing (Dict)
import List.Extra as LE
import Set exposing (Set)
import Static.Db as StaticDb exposing (Db)


type alias Flags =
    { componentConfigJson : String
    , detailedProcessesJson : String
    , nonDetailedProcessesJson : String
    }


type alias Error =
    String


init : Flags -> ( (), Cmd () )
init flags =
    ( ()
    , case checkStaticDatabases flags of
        Err errors ->
            logAndExit { message = formatErrors errors, status = 1 }

        Ok _ ->
            logAndExit { message = "Dbs look fine", status = 0 }
    )


{-| Adds a titled error section only when the section has entries.
-}
addGroupedErrors : String -> List Error -> List Error -> List Error
addGroupedErrors label errors =
    (++) <|
        if List.isEmpty errors then
            []

        else
            (label ++ ":")
                :: (errors
                        |> LE.unique
                        |> List.map (\err -> "  - " ++ err)
                   )


backtick : String -> String
backtick string =
    "`" ++ string ++ "`"


{-| Validates component config JSON against a static database.
-}
checkComponentConfig : Db -> String -> List Error
checkComponentConfig db =
    ComponentConfig.parse db
        >> Result.mapError List.singleton
        >> Result.map (always [])
        >> Result.withDefault []


{-| Returns missing component ids referenced by a component item.
-}
checkComponentItemId : Set String -> Component.Item -> List String
checkComponentItemId knownComponentStringIds item =
    item.id
        |> Maybe.map
            (Component.idToString
                >> (\stringId ->
                        if Set.member stringId knownComponentStringIds then
                            []

                        else
                            [ stringId ]
                   )
            )
        |> Maybe.withDefault []


{-| Validates process references used by generic components.
-}
checkComponentsProcessIds : Set String -> Db -> List Error
checkComponentsProcessIds knownProcessStringIds db =
    db.components
        |> List.filter (.scope >> Scope.isGeneric)
        |> List.concatMap
            (\component ->
                component.elements
                    |> List.concatMap
                        (\{ material, transforms } ->
                            []
                                |> (++) (material |> checkProcessId knownProcessStringIds component "element.material")
                                |> (++) (transforms |> List.concatMap (checkProcessId knownProcessStringIds component "element.transforms"))
                        )
            )


{-| Ensures a component-referenced process is allowed for the component scope.
-}
checkComponentProcessScope :
    Dict String Process
    -> Component
    -> Example query
    -> String
    -> Process.Id
    -> List Error
checkComponentProcessScope processes component example fieldName processId =
    let
        processIdString =
            Process.idToString processId
    in
    case processes |> Dict.get processIdString of
        Just process ->
            if List.member component.scope process.scopes then
                []

            else
                formatError
                    [ "Process " ++ processLabel process
                    , "is not scoped for " ++ backtick (Scope.toString component.scope)
                    , "but is referenced in " ++ backtick fieldName
                    , "by component " ++ componentLabel component
                    , "used by example " ++ exampleLabel example
                    ]

        Nothing ->
            []


{-| Validates example/component scope compatibility and nested process scopes.
-}
checkComponentScopeMismatch : Dict String Process -> Example query -> Component -> List Error
checkComponentScopeMismatch processes example component =
    let
        scopeMismatchErrors =
            if component.scope == example.scope then
                []

            else
                formatError
                    [ "Example " ++ exampleLabel example
                    , "references component " ++ componentLabel component
                    , "but scopes are incompatible"
                    ]

        processScopeErrors =
            component.elements
                |> List.concatMap
                    (\{ material, transforms } ->
                        []
                            |> (++) (material |> checkComponentProcessScope processes component example "element.material")
                            |> (++) (transforms |> List.concatMap (checkComponentProcessScope processes component example "element.transforms"))
                    )
    in
    scopeMismatchErrors ++ processScopeErrors


{-| Checks that an Example consumptions are linked to existing scope-compatible processes.
-}
checkExampleConsumption : Dict String Process -> Example query -> Component.Consumption -> List Error
checkExampleConsumption processes example consumption =
    let
        processIdString =
            Process.idToString consumption.processId
    in
    case processes |> Dict.get processIdString of
        Just process ->
            if List.member example.scope process.scopes then
                []

            else
                formatError
                    [ "Example " ++ exampleLabel example
                    , "references process " ++ processLabel process
                    , "in consumptions but isn't scoped for " ++ backtick (Scope.toString example.scope)
                    ]

        Nothing ->
            formatError
                [ "Example " ++ exampleLabel example
                , "references missing process " ++ processIdString ++ " in consumptions"
                ]


{-| Resolves a component Item from within an Example query and validates its scope.
-}
checkExampleComponentItem : Dict String Process -> Dict String Component -> Example query -> Component.Item -> List Error
checkExampleComponentItem processes components example =
    .id
        >> Maybe.map Component.idToString
        >> Maybe.andThen (\id -> Dict.get id components)
        >> Maybe.map (checkComponentScopeMismatch processes example)
        >> Maybe.withDefault []


{-| Reports missing component ids referenced by generic examples.
-}
checkExamplesComponentIds : Set String -> Db -> List Error
checkExamplesComponentIds knownComponentStringIds db =
    db.object.examples
        |> List.filter (.scope >> Scope.isGeneric)
        |> List.concatMap
            (\example ->
                example.query.items
                    |> List.concatMap (checkComponentItemId knownComponentStringIds)
                    |> List.concatMap
                        (\missingComponentId ->
                            formatError
                                [ "Missing component id " ++ missingComponentId
                                , "referenced by example " ++ exampleLabel example
                                ]
                        )
            )


{-| Runs scope checks between examples, their components, and referenced processes.
-}
checkExamplesScope : Db -> List Error
checkExamplesScope db =
    let
        ( processesMap, componentsMap ) =
            ( processById db.processes
            , componentById db.components
            )
    in
    db.object.examples
        |> List.filter (.scope >> Scope.isGeneric)
        |> List.concatMap
            (\example ->
                List.concat
                    [ example.query.items
                        |> List.concatMap (checkExampleComponentItem processesMap componentsMap example)
                    , example.query.consumptions
                        |> List.concatMap (checkExampleConsumption processesMap example)
                    ]
            )


{-| Reports a missing process id referenced from a component field.
-}
checkProcessId : Set String -> Component -> String -> Process.Id -> List Error
checkProcessId knownProcessStringIds component fieldName processId =
    let
        processStringId =
            Process.idToString processId
    in
    if Set.member processStringId knownProcessStringIds |> not then
        formatError
            [ "Missing process id " ++ processStringId
            , "referenced by component " ++ componentLabel component
            , "in " ++ backtick fieldName
            ]

    else
        []


{-| Checks a static database and config comformity, then returns a list of errors.
-}
checkStaticDatabase : String -> String -> Result String Db -> List Error
checkStaticDatabase config dbName dbResult =
    let
        section title =
            dbName ++ " - " ++ title
    in
    case dbResult of
        Err errorMessage ->
            [] |> addGroupedErrors (section "Database decoding checks") [ errorMessage ]

        Ok db ->
            let
                ( knownComponentStringIds, knownProcessStringIds ) =
                    ( knownComponentIds db
                    , knownProcessIds db
                    )
            in
            []
                |> addGroupedErrors (section "Examples components checks") (checkExamplesComponentIds knownComponentStringIds db)
                |> addGroupedErrors (section "Components processes checks") (checkComponentsProcessIds knownProcessStringIds db)
                |> addGroupedErrors (section "Scoping checks") (checkExamplesScope db)
                |> addGroupedErrors (section "Component config checks") (checkComponentConfig db config)


{-| Decodes both static databases, executes checks, and returns grouped errors.
-}
checkStaticDatabases : Flags -> Result (List Error) ()
checkStaticDatabases { componentConfigJson, detailedProcessesJson, nonDetailedProcessesJson } =
    case
        List.concatMap (\( dbName, dbResult ) -> checkStaticDatabase componentConfigJson dbName dbResult)
            [ ( "Detailed Db", StaticDb.db detailedProcessesJson )
            , ( "Non-detailed Db", StaticDb.db nonDetailedProcessesJson )
            ]
    of
        [] ->
            Ok ()

        errors ->
            Err errors


componentLabel : Component -> String
componentLabel component =
    quote component.name
        ++ " ("
        ++ backtick (Scope.toString component.scope)
        ++ ", "
        ++ (component.id
                |> Maybe.map Component.idToString
                |> Maybe.withDefault "N/A"
           )
        ++ ")"


{-| Builds a lookup map of components keyed by component id.
-}
componentById : List Component -> Dict String Component
componentById =
    List.filterMap
        (\component ->
            component.id
                |> Maybe.map (\componentId -> ( Component.idToString componentId, component ))
        )
        >> Dict.fromList


exampleLabel : Example query -> String
exampleLabel example =
    quote example.name
        ++ " ("
        ++ backtick (Scope.toString example.scope)
        ++ ", "
        ++ Uuid.toString example.id
        ++ ")"


formatError : List String -> List Error
formatError lines =
    case lines of
        [] ->
            []

        x :: xs ->
            (x :: List.map (\l -> "\n    " ++ l) xs)
                |> String.concat
                |> List.singleton


formatErrors : List Error -> Error
formatErrors errors =
    "Static DB checks failed:\n" ++ String.join "\n" errors


{-| Extracts all declared component ids from a database.
-}
knownComponentIds : Db -> Set String
knownComponentIds =
    .components
        >> List.filterMap .id
        >> List.map Component.idToString
        >> Set.fromList


{-| Extracts all declared process ids from a database.
-}
knownProcessIds : Db -> Set String
knownProcessIds =
    .processes
        >> List.map (.id >> Process.idToString)
        >> Set.fromList


{-| Builds a lookup map of processes keyed by process id.
-}
processById : List Process -> Dict String Process
processById =
    List.map (\process -> ( Process.idToString process.id, process ))
        >> Dict.fromList


processLabel : Process -> String
processLabel process =
    quote (Process.getDisplayName process)
        ++ " ("
        ++ Process.idToString process.id
        ++ ")"


quote : String -> String
quote string =
    "“" ++ string ++ "”"


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , subscriptions = always Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }


port logAndExit : { message : String, status : Int } -> Cmd msg
