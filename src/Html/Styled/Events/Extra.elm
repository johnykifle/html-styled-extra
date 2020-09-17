module Html.Styled.Events.Extra exposing
    ( charCode
    , targetValueFloat, targetValueInt, targetValueMaybe, targetValueMaybeFloat, targetValueMaybeInt
    , targetValueFloatParse, targetValueIntParse, targetValueMaybeFloatParse, targetValueMaybeIntParse
    , targetSelectedIndex, targetSelectedOptions
    , onClickPreventDefault, onClickStopPropagation, onClickPreventDefaultAndStopPropagation, onEnter, onChange, onMultiSelect
    )

{-| Additional decoders for use with event handlers in html.


# Event decoders

  - TODO: `key`

  - TODO: `code`

  - TODO: `KeyEvent`, `keyEvent`

@docs charCode


# Typed event decoders

@docs targetValueFloat, targetValueInt, targetValueMaybe, targetValueMaybeFloat, targetValueMaybeInt
@docs targetValueFloatParse, targetValueIntParse, targetValueMaybeFloatParse, targetValueMaybeIntParse
@docs targetSelectedIndex, targetSelectedOptions


# Event Handlers

@docs onClickPreventDefault, onClickStopPropagation, onClickPreventDefaultAndStopPropagation, onEnter, onChange, onMultiSelect

-}

import Html.Styled exposing (Attribute)
import Html.Styled.Events exposing (..)
import Json.Decode as Json



-- TODO
-- {-| Decode the key that was pressed.
-- The key attribute is intended for users who are interested in the meaning of the key being pressed, taking into account the current keyboard layout.
--
-- * If there exists an appropriate character in the [key values set](http://www.w3.org/TR/DOM-Level-3-Events-key/#key-value-tables), this will be the result. See also [MDN key values](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent.key#Key_values).
-- * If the value is has a printed representation, it will be a non-empty Unicode character string consisting of the char value.
-- * If more than one key is being pressed and the key combination includes modifier keys (e.g. `Control + a`), then the key value will still consist of the printable char value with no modifier keys except for 'Shift' and 'AltGr' applied.
-- * Otherwise the value will be `"Unidentified"`
--
-- Note that `keyCode`, `charCode` and `which` are all being deprecated. You should avoid using these in favour of `key` and `code`.
-- Google Chrome and Safari currently support this as `keyIdentifier` which is defined in the old draft of DOM Level 3 Events.
--
-- -}
-- key : Json.Decoder String
-- key = Json.oneOf [ Json.field "key" string, Json.field "keyIdentifier" string ]
-- TODO: Waiting for proper support in chrome & safari
-- {-| Return a string identifying the key that was pressed.
-- `keyCode`, `charCode` and `which` are all being deprecated. You should avoid using these in favour of `key` and `code`.
-- See [KeyboardEvent.keyCode](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent.keyCode).
-- -}
-- code : Json.Decoder String
-- code =
--     Json.field "code" string
-- TODO: Complete keyboard event
-- keyEvent : Json.Decoder KeyEvent
-- keyEvent =
--     Json.oneOf [ Json.field "keyCode" int ]


{-| Character code for key board events.
This is being deprecated, but support for DOM3 Keyboard events is not yet present in most browsers.
-}
charCode : Json.Decoder (Maybe Char)
charCode =
    Json.map (Maybe.map Tuple.first << String.uncons) (Json.field "charCode" Json.string)



-- implementation taken from: https://groups.google.com/d/msg/elm-dev/Ctl_kSKJuYc/rjkdBxx6AwAJ


customDecoder : Json.Decoder a -> (a -> Result String b) -> Json.Decoder b
customDecoder d f =
    let
        resultDecoder x =
            case x of
                Ok a ->
                    Json.succeed a

                Err e ->
                    Json.fail e
    in
    Json.map f d |> Json.andThen resultDecoder


maybeStringToResult : Maybe a -> Result String a
maybeStringToResult =
    Result.fromMaybe "could not convert string"


traverse : (String -> Maybe a) -> Maybe String -> Result String (Maybe a)
traverse f mx =
    case mx of
        Nothing ->
            Ok Nothing

        Just x ->
            x |> f |> maybeStringToResult |> Result.map Just


{-| Floating-point target value.
-}
targetValueFloat : Json.Decoder Float
targetValueFloat =
    customDecoder (Json.at [ "target", "valueAsNumber" ] Json.float) <|
        \v ->
            if isNaN v then
                Err "Not a number"

            else
                Ok v


{-| Integer target value.
-}
targetValueInt : Json.Decoder Int
targetValueInt =
    Json.at [ "target", "valueAsNumber" ] Json.int


{-| String or empty target value.
-}
targetValueMaybe : Json.Decoder (Maybe String)
targetValueMaybe =
    customDecoder targetValue
        (\s ->
            Ok <|
                if s == "" then
                    Nothing

                else
                    Just s
        )


{-| Floating-point or empty target value.
-}
targetValueMaybeFloat : Json.Decoder (Maybe Float)
targetValueMaybeFloat =
    targetValueMaybe
        |> Json.andThen
            (\mval ->
                case mval of
                    Nothing ->
                        Json.succeed Nothing

                    Just _ ->
                        Json.map Just targetValueFloat
            )


{-| Integer or empty target value.
-}
targetValueMaybeInt : Json.Decoder (Maybe Int)
targetValueMaybeInt =
    customDecoder targetValueMaybe (traverse String.toInt)


{-| Parse a floating-point value from the input instead of using `valueAsNumber`.
Use this with inputs that do not have a `number` type.
-}
targetValueFloatParse : Json.Decoder Float
targetValueFloatParse =
    customDecoder targetValue (String.toFloat >> maybeStringToResult)


{-| Parse an integer value from the input instead of using `valueAsNumber`.
Use this with inputs that do not have a `number` type.
-}
targetValueIntParse : Json.Decoder Int
targetValueIntParse =
    customDecoder targetValue (String.toInt >> maybeStringToResult)


{-| Parse an optional floating-point value from the input instead of using `valueAsNumber`.
Use this with inputs that do not have a `number` type.
-}
targetValueMaybeFloatParse : Json.Decoder (Maybe Float)
targetValueMaybeFloatParse =
    customDecoder targetValueMaybe (traverse String.toFloat)


{-| Parse an optional integer value from the input instead of using `valueAsNumber`.
Use this with inputs that do not have a `number` type.
-}
targetValueMaybeIntParse : Json.Decoder (Maybe Int)
targetValueMaybeIntParse =
    customDecoder targetValueMaybe (traverse String.toInt)


{-| Parse the index of the selected option of a select.
Returns Nothing in place of the spec's magic value -1.
-}
targetSelectedIndex : Json.Decoder (Maybe Int)
targetSelectedIndex =
    Json.at [ "target", "selectedIndex" ]
        (Json.map
            (\int ->
                if int == -1 then
                    Nothing

                else
                    Just int
            )
            Json.int
        )


{-| Parse `event.target.selectedOptions` and return option values.
-}
targetSelectedOptions : Json.Decoder (List String)
targetSelectedOptions =
    let
        options =
            Json.at [ "target", "selectedOptions" ] <|
                Json.keyValuePairs <|
                    Json.field "value" Json.string
    in
    Json.map (List.map Tuple.second) options



-- Event Handlers


{-| Always send `msg` upon click, preventing the browser's default behavior.
-}
onClickPreventDefault : msg -> Attribute msg
onClickPreventDefault msg =
    preventDefaultOn "click" <| Json.succeed ( msg, True )


{-| Always send `msg` upon click, preventing click propagation.
-}
onClickStopPropagation : msg -> Attribute msg
onClickStopPropagation msg =
    stopPropagationOn "click" <| Json.succeed ( msg, True )


{-| Always send `msg` upon click, preventing the browser's default behavior and propagation
-}
onClickPreventDefaultAndStopPropagation : msg -> Attribute msg
onClickPreventDefaultAndStopPropagation msg =
    custom "click" (Json.succeed { message = msg, stopPropagation = True, preventDefault = True })


{-| When the enter key is released, send the `msg`.
Otherwise, do nothing.
-}
onEnter : msg -> Attribute msg
onEnter onEnterAction =
    on "keyup" <|
        Json.andThen
            (\keyCode ->
                if keyCode == 13 then
                    Json.succeed onEnterAction

                else
                    Json.fail (String.fromInt keyCode)
            )
            keyCode


{-| An HTML Event attribute that passes the `event.target.value` to a `msg`
constructor when an `input`, `select`, or `textarea` element has changed.
-}
onChange : (String -> msg) -> Attribute msg
onChange onChangeAction =
    on "change" <| Json.map onChangeAction targetValue


{-| Detect change events on multi-choice select elements.

It will grab the string values of `event.target.selectedOptions` on any change
event.

Check out [`targetSelectedOptions`](#targetSelectedOptions) for more details on
how this works.

Note: [`onChange`](#onChange) parses `event.target.value` that doesn't work with
multi-choice select elements.

Note 2:
[`selectedOptions`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLSelectElement/selectedOptions)
is not supported by Internet Explorer.

-}
onMultiSelect : (List String -> msg) -> Attribute msg
onMultiSelect tagger =
    stopPropagationOn "change" <|
        Json.map (\x -> ( x, True )) <|
            Json.map tagger targetSelectedOptions
