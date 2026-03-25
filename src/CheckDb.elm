port module CheckDb exposing (main)

import Data.Component as Component exposing (Component)
import Data.Example exposing (Example)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope
import Data.Uuid as Uuid
import Dict exposing (Dict)
import List.Extra as LE
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
    -> { component : Component, example : Example query }
    -> String
    -> Process.Id
    -> List String
checkComponentProcessScope processes { component, example } fieldName processId =
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
                    ++ " is not scoped for “"
                    ++ Scope.toString component.scope
                    ++ "” but is referenced in "
                    ++ backtick fieldName
                    ++ " by component "
                    ++ componentLabel component
                    ++ " used by example "
                    ++ exampleLabel example
                ]

        Nothing ->
            []


checkExampleConsumption : Dict String Process -> Example query -> { b | processId : Process.Id } -> List String
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
                    ++ " references process “"
                    ++ processLabel process
                    ++ " in consumptions but it isn’t scoped for “"
                    ++ Scope.toString example.scope
                    ++ "”"
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
                    (\element ->
                        []
                            |> (++)
                                (checkComponentProcessScope processes
                                    { component = component, example = example }
                                    "element.material"
                                    element.material
                                )
                            |> (++)
                                (element.transforms
                                    |> List.concatMap
                                        (checkComponentProcessScope processes
                                            { component = component, example = example }
                                            "element.transforms"
                                        )
                                )
                    )
    in
    scopeMismatchErrors ++ processScopeErrors


checkExamplesComponentIds : Db -> List String
checkExamplesComponentIds db =
    let
        knownComponentIds : Set String
        knownComponentIds =
            db.components
                |> List.filterMap .id
                |> List.map Component.idToString
                |> Set.fromList

        checkItemId : { a | id : Maybe Component.Id } -> List String
        checkItemId item =
            case item.id of
                Just componentId ->
                    let
                        referencedComponentId =
                            Component.idToString componentId
                    in
                    if Set.member referencedComponentId knownComponentIds then
                        []

                    else
                        [ referencedComponentId ]

                Nothing ->
                    []
    in
    db.object.examples
        |> List.filter (.scope >> Scope.isGeneric)
        |> List.concatMap
            (\example ->
                example.query.items
                    |> List.concatMap checkItemId
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

        decodeFailureMessages =
            dbResults
                |> List.filterMap
                    (\result ->
                        case result of
                            Err err ->
                                Just err

                            Ok _ ->
                                Nothing
                    )

        decodedDbs =
            List.filterMap Result.toMaybe
                dbResults

        missingExampleComponentIds =
            decodedDbs
                |> List.concatMap checkExamplesComponentIds
                |> LE.unique

        examplesScopingIssues =
            decodedDbs
                |> List.concatMap checkExamplesScope
                |> LE.unique

        missingComponentProcessIds =
            decodedDbs
                |> List.concatMap checkComponentsProcessIds
                |> LE.unique

        integrityErrors =
            []
                |> addGroupedErrors "Examples components checks" missingExampleComponentIds
                |> addGroupedErrors "Examples scoping checks" examplesScopingIssues
                |> addGroupedErrors "Components processes checks" missingComponentProcessIds

        allErrors =
            []
                |> addGroupedErrors "DB decode" decodeFailureMessages
                |> (++)
                    (if List.isEmpty integrityErrors then
                        []

                     else
                        integrityErrors
                    )
    in
    if List.isEmpty allErrors then
        Ok ()

    else
        Err allErrors


componentLabel : Component -> String
componentLabel component =
    "“"
        ++ component.name
        ++ "” ("
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
    "“"
        ++ example.name
        ++ "” ("
        ++ Scope.toString example.scope
        ++ ", "
        ++ Uuid.toString example.id
        ++ ")"


formatErrors : List String -> String
formatErrors errors =
    "Static DB checks failed:\n" ++ String.join "\n" errors


processById : List Process -> Dict String Process
processById processes =
    processes
        |> List.map (\process -> ( Process.idToString process.id, process ))
        |> Dict.fromList


processLabel : Process -> String
processLabel process =
    "“"
        ++ Process.getDisplayName process
        ++ "” ("
        ++ Process.idToString process.id
        ++ ")"


knownProcessIds : Db -> Set String
knownProcessIds db =
    db.processes
        |> List.map (.id >> Process.idToString)
        |> Set.fromList


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , subscriptions = always Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }


port logAndExit : { message : String, status : Int } -> Cmd msg
