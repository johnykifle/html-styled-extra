module Html.Styled.Extra exposing (static, nothing, viewIf, viewIfLazy, viewMaybe)

{-| Convenience functionality on
[`Html.Styled`](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/Html-Styled#Html)

@docs static, nothing, viewIf, viewIfLazy, viewMaybe

-}

import Html.Styled exposing (Html)


{-| Embedding static html.

The type argument
[`Never`](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#Never)
in `Html Never` tells us that the html has no event handlers attached,
it will not generate any messages. We may want to embed such static
html into arbitrary views, while using types to enforce the
staticness. That is what this function provides.

_Note:_ To call this function, the argument need not be literally of type
`Html Never`. It suffices if it is a fully polymorphic (in the message type)
`Html` value. For example, this works: `static (Html.Styled.text "abcdef")`.

-}
static : Html Never -> Html msg
static =
    Html.Styled.map never


{-| Render nothing.

A more idiomatic way of rendering nothing compared to using
`Html.Styled.text ""` directly.

-}
nothing : Html msg
nothing =
    Html.Styled.text ""


{-| A function to only render html under a certain condition

    fieldView : Model -> Html Msg
    fieldView model =
        div
            []
            [ fieldInput model
            , viewIf
                (not <| List.isEmpty model.errors)
                errorsView
            ]

-}
viewIf : Bool -> Html msg -> Html msg
viewIf condition html =
    if condition then
        html

    else
        nothing


{-| Just like `viewIf` except its more performant. In viewIf, the html is always evaluated, even if its not rendered. `viewIfLazy` only evaluates your view function if it needs to. The trade off is your view function needs to accept a unit type (`()`) as its final parameter

    fieldView : Model -> Html Msg
    fieldView model =
        div
            []
            [ fieldInput model
            , viewIfLazy
                (not <| List.isEmpty model.errors)
                (\() -> errorsView)
            ]

-}
viewIfLazy : Bool -> (() -> Html msg) -> Html msg
viewIfLazy condition htmlF =
    if condition then
        htmlF ()

    else
        nothing


{-| Renders `Html.Styled.nothing` in case of Nothing, uses the provided function in case of Just.

    viewMaybePost : Maybe Post -> Html Msg
    viewMaybePost maybePost =
        viewMaybe viewPost maybePost

    viewPost : Post -> Html Msg

-}
viewMaybe : (a -> Html msg) -> Maybe a -> Html msg
viewMaybe fn maybeThing =
    maybeThing
        |> Maybe.map fn
        |> Maybe.withDefault nothing
