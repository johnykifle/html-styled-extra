module Html.Styled.Attributes.Extra exposing
    ( static
    , empty, attributeIf, attributeMaybe
    , valueAsFloat, valueAsInt, autocomplete
    , role
    , low, high, optimum
    , volume
    , stringProperty
    , boolProperty
    , floatProperty
    , intProperty
    )

{-| Additional attributes for html


# Embedding static attributes

@docs static


# Conditional attribute handling

@docs empty, attributeIf, attributeMaybe


# Inputs

@docs valueAsFloat, valueAsInt, autocomplete


# Semantic web

@docs role


# Meter element

@docs low, high, optimum


# Media element

@docs volume


# Custom Attributes

@docs stringProperty
@docs boolProperty
@docs floatProperty
@docs intProperty

-}

import Html.Styled exposing (Attribute)
import Html.Styled.Attributes exposing (attribute, property)
import Html.Styled.Attributes.Autocomplete as Autocomplete
import Json.Encode as Json


{-| Embedding static attributes.

Works alike to [`Html.Styled.Extra.static`](Html-Styled-Extra#static).

-}
static : Attribute Never -> Attribute msg
static =
    Html.Styled.Attributes.map never


{-| A no-op attribute.

Allows for patterns like:

    Html.Styled.div
        [ someAttr
        , if someCondition then
            empty

          else
            someAttr2
        ]
        [ someHtml ]

instead of

    Html.Styled.div
        (someAttr
            :: (if someCondition then
                    []

                else
                    [ someAttr2 ]
               )
        )
        [ someHtml ]

This is useful eg. for conditional event handlers.

---

The only effect it can have on the resulting DOM is adding a `class` attribute,
or adding an extra trailing space in the `class` attribute if added after
`Html.Styled.Attribute.class` or `Html.Styled.Attribute.classList`:

    -- side effect 1:
    -- <div class="" />
    Html.Styled.div [ empty ] []

    -- side effect 2:
    -- <div class="x " />
    Html.Styled.div [ class "x", empty ] []

    -- no side effect:
    -- <div class="x" />
    Html.Styled.div [ empty, class "x" ] []

    -- side effect 2:
    -- <div class="x " />
    Html.Styled.div [ classList [ ( "x", True ) ], empty ] []

    -- no side effect:
    -- <div class="x" />
    Html.Styled.div [ empty, classList [ ( "x", True ) ] ] []

-}
empty : Attribute msg
empty =
    Html.Styled.Attributes.classList []


{-| A function to only render a HTML attribute under a certain condition
-}
attributeIf : Bool -> Attribute msg -> Attribute msg
attributeIf condition attr =
    if condition then
        attr

    else
        empty


{-| Renders `empty` attribute in case of Nothing, uses the provided function in case of Just.
-}
attributeMaybe : (a -> Attribute msg) -> Maybe a -> Attribute msg
attributeMaybe fn =
    Maybe.map fn >> Maybe.withDefault empty


{-| Create arbitrary string _properties_.
-}
stringProperty : String -> String -> Attribute msg
stringProperty name string =
    property name (Json.string string)


{-| Create arbitrary bool _properties_.
-}
boolProperty : String -> Bool -> Attribute msg
boolProperty name bool =
    property name (Json.bool bool)


{-| Create arbitrary floating-point _properties_.
-}
floatProperty : String -> Float -> Attribute msg
floatProperty name float =
    property name (Json.float float)


{-| Create arbitrary integer _properties_.
-}
intProperty : String -> Int -> Attribute msg
intProperty name int =
    property name (Json.int int)


{-| Uses `valueAsNumber` to update an input with a floating-point value.
This should only be used on &lt;input&gt; of type `number`, `range`, or `date`.
It differs from `value` in that a floating point value will not necessarily overwrite the contents on an input element.

    valueAsFloat 2.5 -- e.g. will not change the displayed value for input showing "2.5000"

    valueAsFloat 0.4 -- e.g. will not change the displayed value for input showing ".4"

-}
valueAsFloat : Float -> Attribute msg
valueAsFloat value =
    floatProperty "valueAsNumber" value


{-| Uses `valueAsNumber` to update an input with an integer value.
This should only be used on &lt;input&gt; of type `number`, `range`, or `date`.
It differs from `value` in that an integer value will not necessarily overwrite the contents on an input element.

    valueAsInt 18 -- e.g. will not change the displayed value for input showing "00018"

-}
valueAsInt : Int -> Attribute msg
valueAsInt value =
    intProperty "valueAsNumber" value


{-| Render one of the possible `Completion` types into an `Attribute`.
-}
autocomplete : Autocomplete.Completion -> Attribute msg
autocomplete =
    Autocomplete.completionValue >> attribute "autocomplete"


{-| Used to annotate markup languages with machine-extractable semantic information about the purpose of an element.
See the [official specs](http://www.w3.org/TR/role-attribute/).
-}
role : String -> Attribute msg
role r =
    attribute "role" r


{-| The upper numeric bound of the low end of the measured range, used with the meter element.
-}
low : String -> Attribute msg
low =
    stringProperty "low"


{-| The lower numeric bound of the high end of the measured range, used with the meter element.
-}
high : String -> Attribute msg
high =
    stringProperty "high"


{-| This attribute indicates the optimal numeric value, used with the meter element.
-}
optimum : String -> Attribute msg
optimum =
    stringProperty "optimum"


{-| Audio volume, starting from 0.0 (silent) up to 1.0 (loudest).
-}
volume : Float -> Attribute msg
volume =
    floatProperty "volume"
