port module CheckDb exposing (main)

import Data.Component as Component exposing (Component)
import Data.Example exposing (Example)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope
import Data.Uuid as Uuid
import Dict exposing (Dict)
import List.Extra as LE
import Result.Extra as RE
import Set exposing (Set)
import Static.Db as StaticDb exposing (Db)


type alias Flags =
    { detailedProcesses : String
    , nonDetailedProcesses : String
    }


init : Flags -> ( (), Cmd () )
init flags =
    ( ()
    , case checkStaticDatabases flags of
        Err errors ->
            logAndExit { message = formatErrors errors, status = 1 }

        Ok _ ->
            logAndExit { message = "Dbs look fine", status = 0 }
    )


addGroupedErrors : String -> List String -> List String -> List String
addGroupedErrors label errors =
    (++)
        (if List.isEmpty errors then
            []

         else
            (label ++ ":") :: (errors |> List.map (\err -> "  - " ++ err))
        )


backtick : String -> String
backtick string =
    "`" ++ string ++ "`"


checkComponentItemId : Db -> Component.Item -> List String
checkComponentItemId db item =
    case item.id of
        Just componentId ->
            let
                referencedComponentId =
                    Component.idToString componentId
            in
            if Set.member referencedComponentId (knownComponentIds db) then
                []

            else
                [ referencedComponentId ]

        Nothing ->
            []


checkComponentsProcessIds : Db -> List String
checkComponentsProcessIds db =
    db.components
        |> List.filter (.scope >> Scope.isGeneric)
        |> List.concatMap
            (\component ->
                component.elements
                    |> List.concatMap
                        (\{ material, transforms } ->
                            []
                                |> (++) (material |> checkProcessId db component "element.material")
                                |> (++) (transforms |> List.concatMap (checkProcessId db component "element.transforms"))
                        )
            )


checkComponentProcessScope :
    Dict String Process
    -> Component
    -> Example query
    -> String
    -> Process.Id
    -> List String
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
                [ "Process "
                    ++ processLabel process
                    ++ " is not scoped for "
                    ++ backtick (Scope.toString component.scope)
                    ++ " but is referenced in "
                    ++ backtick fieldName
                    ++ " by component "
                    ++ componentLabel component
                    ++ " used by example "
                    ++ exampleLabel example
                ]

        Nothing ->
            []


checkExampleConsumption : Dict String Process -> Example query -> Component.Consumption -> List String
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
                [ "Example "
                    ++ exampleLabel example
                    ++ " references process "
                    ++ processLabel process
                    ++ " in consumptions but it isn’t scoped for "
                    ++ backtick (Scope.toString example.scope)
                ]

        Nothing ->
            [ "Example "
                ++ exampleLabel example
                ++ " references missing process id "
                ++ processIdString
                ++ " in consumptions"
            ]


checkExampleItem : Dict String Process -> Dict String Component -> Example query -> Component.Item -> List String
checkExampleItem processes components example =
    .id
        >> Maybe.map Component.idToString
        >> Maybe.andThen (\id -> Dict.get id components)
        >> Maybe.map (checkComponentScopeMismatch processes example)
        >> Maybe.withDefault []


checkComponentScopeMismatch : Dict String Process -> Example query -> Component -> List String
checkComponentScopeMismatch processes example component =
    let
        scopeMismatchErrors =
            if component.scope == example.scope then
                []

            else
                [ "Example "
                    ++ exampleLabel example
                    ++ " references component "
                    ++ componentLabel component
                    ++ " but scopes are incompatible"
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


checkExamplesComponentIds : Db -> List String
checkExamplesComponentIds db =
    db.object.examples
        |> List.filter (.scope >> Scope.isGeneric)
        |> List.concatMap
            (\example ->
                example.query.items
                    |> List.concatMap (checkComponentItemId db)
                    |> List.map
                        (\missingComponentId ->
                            "Missing component id "
                                ++ missingComponentId
                                ++ " referenced by example "
                                ++ exampleLabel example
                        )
            )


checkExamplesScope : Db -> List String
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
                (example.query.items |> List.concatMap (checkExampleItem processesMap componentsMap example))
                    ++ (example.query.consumptions |> List.concatMap (checkExampleConsumption processesMap example))
            )


checkProcessId : Db -> Component -> String -> Process.Id -> List String
checkProcessId db component fieldName processId =
    let
        processStringId =
            Process.idToString processId
    in
    if knownProcessIds db |> Set.member processStringId |> not then
        [ "Missing process id "
            ++ processStringId
            ++ " referenced by component "
            ++ componentLabel component
            ++ " in "
            ++ backtick fieldName
        ]

    else
        []


checkStaticDatabases : Flags -> Result (List String) ()
checkStaticDatabases { detailedProcesses, nonDetailedProcesses } =
    let
        ( detailedDbResult, nonDetailedDbResult ) =
            ( StaticDb.db detailedProcesses
                |> Result.mapError (\err -> "Detailed Db is invalid: " ++ err)
            , StaticDb.db nonDetailedProcesses
                |> Result.mapError (\err -> "Non-detailed Db is invalid: " ++ err)
            )

        dbResults =
            [ nonDetailedDbResult, detailedDbResult ]

        dbs =
            dbResults |> List.filterMap Result.toMaybe
    in
    case
        []
            |> addGroupedErrors "DB decode"
                (dbResults
                    |> List.filterMap RE.error
                )
            |> addGroupedErrors "Examples components checks"
                (dbs
                    |> List.concatMap checkExamplesComponentIds
                    |> LE.unique
                )
            |> addGroupedErrors "Examples scoping checks"
                (dbs
                    |> List.concatMap checkExamplesScope
                    |> LE.unique
                )
            |> addGroupedErrors "Components processes checks"
                (dbs
                    |> List.concatMap checkComponentsProcessIds
                    |> LE.unique
                )
    of
        [] ->
            Ok ()

        errors ->
            Err errors


componentLabel : Component -> String
componentLabel component =
    quote component.name
        ++ " ("
        ++ Scope.toString component.scope
        ++ ", "
        ++ (component.id
                |> Maybe.map Component.idToString
                |> Maybe.withDefault "N/A"
           )
        ++ ")"


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


formatErrors : List String -> String
formatErrors errors =
    "Static DB checks failed:\n" ++ String.join "\n" errors


knownComponentIds : Db -> Set String
knownComponentIds =
    .components
        >> List.filterMap .id
        >> List.map Component.idToString
        >> Set.fromList


knownProcessIds : Db -> Set String
knownProcessIds =
    .processes
        >> List.map (.id >> Process.idToString)
        >> Set.fromList


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
