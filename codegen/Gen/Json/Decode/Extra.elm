module Gen.Json.Decode.Extra exposing (andMap, call_, collection, combine, datetime, dict2, doubleEncoded, fromMaybe, fromResult, indexedList, keys, moduleName_, optionalField, optionalNullableField, parseFloat, parseInt, sequence, set, url, values_, when, withDefault)

{-| 
@docs moduleName_, datetime, url, andMap, when, collection, sequence, combine, indexedList, keys, set, dict2, withDefault, optionalField, optionalNullableField, fromMaybe, fromResult, parseInt, parseFloat, doubleEncoded, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Json", "Decode", "Extra" ]


{-| Decode an ISO-8601 formatted date-time string.

This always returns a `Time.Posix` value, which is naturally always expressed in
UTC.

    import Json.Decode exposing (..)
    import Json.Encode
    import Time

    """ "2018-08-26T09:46:00+02:00" """
        |> decodeString datetime
    --> Ok (Time.millisToPosix 1535269560000)

    """ "" """
      |> decodeString datetime
    --> Err
    -->    (Failure
    -->        "Expecting an ISO-8601 formatted date+time string"
    -->        (Json.Encode.string "")
    -->    )

datetime: Json.Decode.Decoder Time.Posix
-}
datetime : Elm.Expression
datetime =
    Elm.value
        { importFrom = [ "Json", "Decode", "Extra" ]
        , name = "datetime"
        , annotation =
            Just
                (Type.namedWith
                    [ "Json", "Decode" ]
                    "Decoder"
                    [ Type.namedWith [ "Time" ] "Posix" [] ]
                )
        }


{-| Decode a URL

This always returns a `Url.Url` value.

    import Json.Decode exposing (..)
    import Url

    """ "http://foo.bar/quux" """
        |> decodeString url
    --> Ok <| Url.Url Url.Http "foo.bar" Nothing "/quux" Nothing Nothing

url: Json.Decode.Decoder Url.Url
-}
url : Elm.Expression
url =
    Elm.value
        { importFrom = [ "Json", "Decode", "Extra" ]
        , name = "url"
        , annotation =
            Just
                (Type.namedWith
                    [ "Json", "Decode" ]
                    "Decoder"
                    [ Type.namedWith [ "Url" ] "Url" [] ]
                )
        }


{-| Can be helpful when decoding large objects incrementally.

See [the `andMap` docs](https://github.com/elm-community/json-extra/blob/2.0.0/docs/andMap.md)
for an explanation of how `andMap` works and how to use it.

andMap: Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b
-}
andMap : Elm.Expression -> Elm.Expression -> Elm.Expression
andMap andMapArg andMapArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "andMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.function [ Type.var "a" ] (Type.var "b") ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "b" ]
                        )
                    )
            }
        )
        [ andMapArg, andMapArg0 ]


{-| Helper for conditionally decoding values based on some discriminator
that needs to pass a certain check.

    import Json.Decode exposing (..)
    import Json.Encode


    is : a -> a -> Bool
    is a b =
        a == b


    enabledValue : Decoder Int
    enabledValue =
      (field "value" int)
        |> when (field "enabled" bool) (is True)


    """ { "enabled": true, "value": 123 } """
        |> decodeString enabledValue
    --> Ok 123


    input : Json.Decode.Value
    input =
        Json.Encode.object
            [ ( "enabled", Json.Encode.bool False )
            , ( "value", Json.Encode.int 321 )
            ]

    expectedError : Error
    expectedError =
       Failure "Check failed with input" input

    """ { "enabled": false, "value": 321 } """
        |> decodeString enabledValue
    --> Err expectedError

This can also be used to decode union types that are encoded with a discriminator field:

    type Animal = Cat String | Dog String


    dog : Decoder Animal
    dog =
        map Dog (field "name" string)


    cat : Decoder Animal
    cat =
        map Cat (field "name" string)


    animalType : Decoder String
    animalType =
        field "type" string


    animal : Decoder Animal
    animal =
        oneOf
            [ when animalType (is "dog") dog
            , when animalType (is "cat") cat
            ]


    """
    [
      { "type": "dog", "name": "Dawg" },
      { "type": "cat", "name": "Roxy" }
    ]
    """
        |> decodeString (list animal)
    --> Ok [ Dog "Dawg", Cat "Roxy" ]

when: 
    Json.Decode.Decoder a
    -> (a -> Bool)
    -> Json.Decode.Decoder b
    -> Json.Decode.Decoder b
-}
when :
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
when whenArg whenArg0 whenArg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "when"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        , Type.function [ Type.var "a" ] Type.bool
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "b" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "b" ]
                        )
                    )
            }
        )
        [ whenArg, Elm.functionReduced "whenUnpack" whenArg0, whenArg1 ]


{-| Some JavaScript structures look like arrays, but aren't really. Examples
include `HTMLCollection`, `NodeList` and everything else that has a `length`
property, has values indexed by an integer key between 0 and `length`, but yet
_is not_ a JavaScript Array.

This decoder can come to the rescue.

    import Json.Decode exposing (..)


    """ { "length": 3, "0": "foo", "1": "bar", "2": "baz" } """
        |> decodeString (collection string)
    --> Ok [ "foo", "bar", "baz" ]

collection: Json.Decode.Decoder a -> Json.Decode.Decoder (List a)
-}
collection : Elm.Expression -> Elm.Expression
collection collectionArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "collection"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
        )
        [ collectionArg ]


{-| This function turns a list of decoders into a decoder that returns a list.

The returned decoder will zip the list of decoders with a list of values,
matching each decoder with exactly one value at the same position. This is most
often useful in cases when you find yourself needing to dynamically generate a
list of decoders based on some data, and decode some other data with this list
of decoders.

Note that this function, unlike `List.map2`'s behaviour, expects the list of
decoders to have the same length as the list of values in the JSON.

    import Json.Decode exposing (..)


    decoder : Decoder (List (Maybe String))
    decoder =
        sequence
            [ map Just string
            , succeed Nothing
            , map Just string
            ]


    decodeString decoder """ [ "pick me", "ignore me", "and pick me" ] """
    --> Ok [ Just "pick me", Nothing, Just "and pick me" ]

sequence: List (Json.Decode.Decoder a) -> Json.Decode.Decoder (List a)
-}
sequence : List Elm.Expression -> Elm.Expression
sequence sequenceArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "sequence"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Json", "Decode" ]
                                "Decoder"
                                [ Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
        )
        [ Elm.list sequenceArg ]


{-| Helps converting a list of decoders into a decoder for a list of that type.

    import Json.Decode exposing (..)


    decoders : List (Decoder String)
    decoders =
        [ field "foo" string
        , field "bar" string
        , field "another" string
        ]


    """ { "foo": "hello", "another": "!", "bar": "world" } """
        |> decodeString (combine decoders)
    --> Ok [ "hello", "world", "!" ]

combine: List (Json.Decode.Decoder a) -> Json.Decode.Decoder (List a)
-}
combine : List Elm.Expression -> Elm.Expression
combine combineArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "combine"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Json", "Decode" ]
                                "Decoder"
                                [ Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
        )
        [ Elm.list combineArg ]


{-| Get access to the current index while decoding a list element.

    import Json.Decode exposing (..)


    repeatedStringDecoder : Int -> Decoder String
    repeatedStringDecoder times =
        string |> map (String.repeat times)


    """ [ "a", "b", "c", "d" ] """
        |> decodeString (indexedList repeatedStringDecoder)
    --> Ok [ "", "b", "cc", "ddd" ]

indexedList: (Int -> Json.Decode.Decoder a) -> Json.Decode.Decoder (List a)
-}
indexedList : (Elm.Expression -> Elm.Expression) -> Elm.Expression
indexedList indexedListArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "indexedList"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.int ]
                            (Type.namedWith
                                [ "Json", "Decode" ]
                                "Decoder"
                                [ Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "indexedListUnpack" indexedListArg ]


{-| Get a list of the keys of a JSON object

    import Json.Decode exposing (..)


    """ { "alice": 42, "bob": 99 } """
        |> decodeString keys
    --> Ok [ "alice", "bob" ]

keys: Json.Decode.Decoder (List String)
-}
keys : Elm.Expression
keys =
    Elm.value
        { importFrom = [ "Json", "Decode", "Extra" ]
        , name = "keys"
        , annotation =
            Just
                (Type.namedWith
                    [ "Json", "Decode" ]
                    "Decoder"
                    [ Type.list Type.string ]
                )
        }


{-| Extract a set.

    import Json.Decode exposing (..)
    import Set


    "[ 1, 1, 5, 2 ]"
        |> decodeString (set int)
    --> Ok <| Set.fromList [ 1, 2, 5 ]

set: Json.Decode.Decoder comparable -> Json.Decode.Decoder (Set.Set comparable)
-}
set : Elm.Expression -> Elm.Expression
set setArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "set"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "comparable" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.namedWith
                                [ "Set" ]
                                "Set"
                                [ Type.var "comparable" ]
                            ]
                        )
                    )
            }
        )
        [ setArg ]


{-| Extract a dict using separate decoders for keys and values.

    import Json.Decode exposing (..)
    import Dict


    """ { "1": "foo", "2": "bar" } """
        |> decodeString (dict2 int string)
    --> Ok <| Dict.fromList [ ( 1, "foo" ), ( 2, "bar" ) ]

dict2: 
    Json.Decode.Decoder comparable
    -> Json.Decode.Decoder v
    -> Json.Decode.Decoder (Dict.Dict comparable v)
-}
dict2 : Elm.Expression -> Elm.Expression -> Elm.Expression
dict2 dict2Arg dict2Arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "dict2"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "comparable" ]
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "v" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.namedWith
                                [ "Dict" ]
                                "Dict"
                                [ Type.var "comparable", Type.var "v" ]
                            ]
                        )
                    )
            }
        )
        [ dict2Arg, dict2Arg0 ]


{-| Try running the given decoder; if that fails, then succeed with the given
fallback value.

    import Json.Decode exposing (..)


    """ { "children": "oops" } """
        |> decodeString (field "children" (list string) |> withDefault [])
    --> Ok []


    """ null """
        |> decodeString (field "children" (list string) |> withDefault [])
    --> Ok []


    """ 30 """
        |> decodeString (int |> withDefault 42)
    --> Ok 30

withDefault: a -> Json.Decode.Decoder a -> Json.Decode.Decoder a
-}
withDefault : Elm.Expression -> Elm.Expression -> Elm.Expression
withDefault withDefaultArg withDefaultArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "withDefault"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a"
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
        )
        [ withDefaultArg, withDefaultArg0 ]


{-| If a field is missing, succeed with `Nothing`. If it is present, decode it
as normal and wrap successes in a `Just`.

When decoding with
[`maybe`](http://package.elm-lang.org/packages/elm-lang/core/latest/Json-Decode#maybe),
if a field is present but malformed, you get a success and Nothing.
`optionalField` gives you a failed decoding in that case, so you know
you received malformed data.

Examples:

    import Json.Decode exposing (..)
    import Json.Encode

Let's define a `stuffDecoder` that extracts the `"stuff"` field, if it exists.

    stuffDecoder : Decoder (Maybe String)
    stuffDecoder =
        optionalField "stuff" string

If the "stuff" field is missing, decode to Nothing.

    """ { } """
        |> decodeString stuffDecoder
    --> Ok Nothing

If the "stuff" field is present but not a String, fail decoding.

    expectedError : Error
    expectedError =
        Failure "Expecting a STRING" (Json.Encode.list identity [])
          |> Field "stuff"

    """ { "stuff": [] } """
        |> decodeString stuffDecoder
    --> Err expectedError

If the "stuff" field is present and valid, decode to Just String.

    """ { "stuff": "yay!" } """
        |> decodeString stuffDecoder
    --> Ok <| Just "yay!"

optionalField: String -> Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a)
-}
optionalField : String -> Elm.Expression -> Elm.Expression
optionalField optionalFieldArg optionalFieldArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "optionalField"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.maybe (Type.var "a") ]
                        )
                    )
            }
        )
        [ Elm.string optionalFieldArg, optionalFieldArg0 ]


{-| A neat combination of `optionalField` and `nullable`.

What this means is that a decoder like `optionalNullableField "foo" string` will
return `Just "hello"` for `{"foo": "hello"}`, `Nothing` for both `{"foo": null}`
and `{}`, and an error for malformed input like `{"foo": 123}`.

    import Json.Decode exposing (Decoder, Error(..), decodeString, field, string)
    import Json.Decode.Extra exposing (optionalNullableField)
    import Json.Encode

    myDecoder : Decoder (Maybe String)
    myDecoder =
        optionalNullableField "foo" string


    """ {"foo": "hello"} """
        |> decodeString myDecoder
    --> Ok (Just "hello")


    """ {"foo": null} """
        |> decodeString myDecoder
    --> Ok Nothing


    """ {} """
        |> decodeString myDecoder
    --> Ok Nothing


    """ {"foo": 123} """
        |> decodeString myDecoder
        |> Result.mapError (\_ -> "expected error")
    --> Err "expected error"

optionalNullableField: String -> Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a)
-}
optionalNullableField : String -> Elm.Expression -> Elm.Expression
optionalNullableField optionalNullableFieldArg optionalNullableFieldArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "optionalNullableField"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.maybe (Type.var "a") ]
                        )
                    )
            }
        )
        [ Elm.string optionalNullableFieldArg, optionalNullableFieldArg0 ]


{-| Transform a `Maybe a` into a `Decoder a`

Sometimes, you'll have a function that produces a `Maybe a` value, that you may
want to use in a decoder.

Let's say, for example, that we have a function to extract the first letter of a
string, and we want to use that in a decoder so we can extract only the first
letter of that string.

    import Json.Decode exposing (..)
    import Json.Encode


    firstLetter : String -> Maybe Char
    firstLetter input =
        Maybe.map Tuple.first (String.uncons input)


    firstLetterDecoder : Decoder Char
    firstLetterDecoder =
        andThen
            (fromMaybe "Empty string not allowed" << firstLetter)
            string

    """ "something" """
        |> decodeString firstLetterDecoder
    --> Ok 's'


    """ "" """
        |> decodeString firstLetterDecoder
    --> Err (Failure "Empty string not allowed" (Json.Encode.string ""))

fromMaybe: String -> Maybe a -> Json.Decode.Decoder a
-}
fromMaybe : String -> Elm.Expression -> Elm.Expression
fromMaybe fromMaybeArg fromMaybeArg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "fromMaybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.maybe (Type.var "a") ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
        )
        [ Elm.string fromMaybeArg, fromMaybeArg0 ]


{-| Transform a result into a decoder

Sometimes it can be useful to use functions that primarily operate on
`Result` in decoders.

    import Json.Decode exposing (..)
    import Json.Encode


    validateString : String -> Result String String
    validateString input =
        case input of
            "" ->
                Err "Empty string is not allowed"
            _ ->
                Ok input


    """ "something" """
        |> decodeString (string |> andThen (fromResult << validateString))
    --> Ok "something"


    """ "" """
        |> decodeString (string |> andThen (fromResult << validateString))
    --> Err (Failure "Empty string is not allowed" (Json.Encode.string ""))

fromResult: Result.Result String a -> Json.Decode.Decoder a
-}
fromResult : Elm.Expression -> Elm.Expression
fromResult fromResultArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "fromResult"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.string, Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
        )
        [ fromResultArg ]


{-| Extract an int using [`String.toInt`](http://package.elm-lang.org/packages/elm-lang/core/latest/String#toInt)

    import Json.Decode exposing (..)


    """ { "field": "123" } """
        |> decodeString (field "field" parseInt)
    --> Ok 123

parseInt: Json.Decode.Decoder Int
-}
parseInt : Elm.Expression
parseInt =
    Elm.value
        { importFrom = [ "Json", "Decode", "Extra" ]
        , name = "parseInt"
        , annotation =
            Just (Type.namedWith [ "Json", "Decode" ] "Decoder" [ Type.int ])
        }


{-| Extract a float using [`String.toFloat`](http://package.elm-lang.org/packages/elm-lang/core/latest/String#toFloat)

    import Json.Decode exposing (..)


    """ { "field": "50.5" } """
        |> decodeString (field "field" parseFloat)
    --> Ok 50.5

parseFloat: Json.Decode.Decoder Float
-}
parseFloat : Elm.Expression
parseFloat =
    Elm.value
        { importFrom = [ "Json", "Decode", "Extra" ]
        , name = "parseFloat"
        , annotation =
            Just (Type.namedWith [ "Json", "Decode" ] "Decoder" [ Type.float ])
        }


{-| Extract a JSON-encoded string field

"Yo dawg, I heard you like JSON..."

If someone has put JSON in your JSON (perhaps a JSON log entry, encoded
as a string) this is the function you're looking for. Give it a decoder
and it will return a new decoder that applies your decoder to a string
field and yields the result (or fails if your decoder fails).

    import Json.Decode exposing (..)


    logEntriesDecoder : Decoder (List String)
    logEntriesDecoder =
        doubleEncoded (list string)


    logsDecoder : Decoder (List String)
    logsDecoder =
        field "logs" logEntriesDecoder


    """ { "logs": "[\\"log1\\", \\"log2\\"]"} """
        |> decodeString logsDecoder
    --> Ok [ "log1", "log2" ]

doubleEncoded: Json.Decode.Decoder a -> Json.Decode.Decoder a
-}
doubleEncoded : Elm.Expression -> Elm.Expression
doubleEncoded doubleEncodedArg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "doubleEncoded"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
        )
        [ doubleEncodedArg ]


call_ :
    { andMap : Elm.Expression -> Elm.Expression -> Elm.Expression
    , when :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , collection : Elm.Expression -> Elm.Expression
    , sequence : Elm.Expression -> Elm.Expression
    , combine : Elm.Expression -> Elm.Expression
    , indexedList : Elm.Expression -> Elm.Expression
    , set : Elm.Expression -> Elm.Expression
    , dict2 : Elm.Expression -> Elm.Expression -> Elm.Expression
    , withDefault : Elm.Expression -> Elm.Expression -> Elm.Expression
    , optionalField : Elm.Expression -> Elm.Expression -> Elm.Expression
    , optionalNullableField : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromMaybe : Elm.Expression -> Elm.Expression -> Elm.Expression
    , fromResult : Elm.Expression -> Elm.Expression
    , doubleEncoded : Elm.Expression -> Elm.Expression
    }
call_ =
    { andMap =
        \andMapArg andMapArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "andMap"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                , Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.function
                                        [ Type.var "a" ]
                                        (Type.var "b")
                                    ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "b" ]
                                )
                            )
                    }
                )
                [ andMapArg, andMapArg0 ]
    , when =
        \whenArg whenArg0 whenArg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "when"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                , Type.function [ Type.var "a" ] Type.bool
                                , Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "b" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "b" ]
                                )
                            )
                    }
                )
                [ whenArg, whenArg0, whenArg1 ]
    , collection =
        \collectionArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "collection"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.list (Type.var "a") ]
                                )
                            )
                    }
                )
                [ collectionArg ]
    , sequence =
        \sequenceArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "sequence"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith
                                        [ "Json", "Decode" ]
                                        "Decoder"
                                        [ Type.var "a" ]
                                    )
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.list (Type.var "a") ]
                                )
                            )
                    }
                )
                [ sequenceArg ]
    , combine =
        \combineArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "combine"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith
                                        [ "Json", "Decode" ]
                                        "Decoder"
                                        [ Type.var "a" ]
                                    )
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.list (Type.var "a") ]
                                )
                            )
                    }
                )
                [ combineArg ]
    , indexedList =
        \indexedListArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "indexedList"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.int ]
                                    (Type.namedWith
                                        [ "Json", "Decode" ]
                                        "Decoder"
                                        [ Type.var "a" ]
                                    )
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.list (Type.var "a") ]
                                )
                            )
                    }
                )
                [ indexedListArg ]
    , set =
        \setArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "set"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "comparable" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.namedWith
                                        [ "Set" ]
                                        "Set"
                                        [ Type.var "comparable" ]
                                    ]
                                )
                            )
                    }
                )
                [ setArg ]
    , dict2 =
        \dict2Arg dict2Arg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "dict2"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "comparable" ]
                                , Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "v" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.namedWith
                                        [ "Dict" ]
                                        "Dict"
                                        [ Type.var "comparable", Type.var "v" ]
                                    ]
                                )
                            )
                    }
                )
                [ dict2Arg, dict2Arg0 ]
    , withDefault =
        \withDefaultArg withDefaultArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "withDefault"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a"
                                , Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ withDefaultArg, withDefaultArg0 ]
    , optionalField =
        \optionalFieldArg optionalFieldArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "optionalField"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string
                                , Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.maybe (Type.var "a") ]
                                )
                            )
                    }
                )
                [ optionalFieldArg, optionalFieldArg0 ]
    , optionalNullableField =
        \optionalNullableFieldArg optionalNullableFieldArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "optionalNullableField"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string
                                , Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.maybe (Type.var "a") ]
                                )
                            )
                    }
                )
                [ optionalNullableFieldArg, optionalNullableFieldArg0 ]
    , fromMaybe =
        \fromMaybeArg fromMaybeArg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "fromMaybe"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string, Type.maybe (Type.var "a") ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ fromMaybeArg, fromMaybeArg0 ]
    , fromResult =
        \fromResultArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "fromResult"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.string, Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ fromResultArg ]
    , doubleEncoded =
        \doubleEncodedArg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Json", "Decode", "Extra" ]
                    , name = "doubleEncoded"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Json", "Decode" ]
                                    "Decoder"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ doubleEncodedArg ]
    }


values_ :
    { datetime : Elm.Expression
    , url : Elm.Expression
    , andMap : Elm.Expression
    , when : Elm.Expression
    , collection : Elm.Expression
    , sequence : Elm.Expression
    , combine : Elm.Expression
    , indexedList : Elm.Expression
    , keys : Elm.Expression
    , set : Elm.Expression
    , dict2 : Elm.Expression
    , withDefault : Elm.Expression
    , optionalField : Elm.Expression
    , optionalNullableField : Elm.Expression
    , fromMaybe : Elm.Expression
    , fromResult : Elm.Expression
    , parseInt : Elm.Expression
    , parseFloat : Elm.Expression
    , doubleEncoded : Elm.Expression
    }
values_ =
    { datetime =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "datetime"
            , annotation =
                Just
                    (Type.namedWith
                        [ "Json", "Decode" ]
                        "Decoder"
                        [ Type.namedWith [ "Time" ] "Posix" [] ]
                    )
            }
    , url =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "url"
            , annotation =
                Just
                    (Type.namedWith
                        [ "Json", "Decode" ]
                        "Decoder"
                        [ Type.namedWith [ "Url" ] "Url" [] ]
                    )
            }
    , andMap =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "andMap"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.function [ Type.var "a" ] (Type.var "b") ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "b" ]
                        )
                    )
            }
    , when =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "when"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        , Type.function [ Type.var "a" ] Type.bool
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "b" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "b" ]
                        )
                    )
            }
    , collection =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "collection"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
    , sequence =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "sequence"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Json", "Decode" ]
                                "Decoder"
                                [ Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
    , combine =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "combine"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Json", "Decode" ]
                                "Decoder"
                                [ Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
    , indexedList =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "indexedList"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.int ]
                            (Type.namedWith
                                [ "Json", "Decode" ]
                                "Decoder"
                                [ Type.var "a" ]
                            )
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.list (Type.var "a") ]
                        )
                    )
            }
    , keys =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "keys"
            , annotation =
                Just
                    (Type.namedWith
                        [ "Json", "Decode" ]
                        "Decoder"
                        [ Type.list Type.string ]
                    )
            }
    , set =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "set"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "comparable" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.namedWith
                                [ "Set" ]
                                "Set"
                                [ Type.var "comparable" ]
                            ]
                        )
                    )
            }
    , dict2 =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "dict2"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "comparable" ]
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "v" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.namedWith
                                [ "Dict" ]
                                "Dict"
                                [ Type.var "comparable", Type.var "v" ]
                            ]
                        )
                    )
            }
    , withDefault =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "withDefault"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a"
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
    , optionalField =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "optionalField"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.maybe (Type.var "a") ]
                        )
                    )
            }
    , optionalNullableField =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "optionalNullableField"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.maybe (Type.var "a") ]
                        )
                    )
            }
    , fromMaybe =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "fromMaybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.string, Type.maybe (Type.var "a") ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
    , fromResult =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "fromResult"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.string, Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
    , parseInt =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "parseInt"
            , annotation =
                Just
                    (Type.namedWith [ "Json", "Decode" ] "Decoder" [ Type.int ])
            }
    , parseFloat =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "parseFloat"
            , annotation =
                Just
                    (Type.namedWith
                        [ "Json", "Decode" ]
                        "Decoder"
                        [ Type.float ]
                    )
            }
    , doubleEncoded =
        Elm.value
            { importFrom = [ "Json", "Decode", "Extra" ]
            , name = "doubleEncoded"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Json", "Decode" ]
                            "Decoder"
                            [ Type.var "a" ]
                        )
                    )
            }
    }