# Additional HTML-related Functions for [`rtfeldman/elm-css`](https://github.com/rtfeldman/elm-css)

[![CI](https://github.com/ken-matsui/html-styled-extra/actions/workflows/elm.yml/badge.svg)](https://github.com/ken-matsui/html-styled-extra/actions/workflows/elm.yml)

This package contains convenience functions for working with Html, beyond that
which `rtfeldman/elm-css` provides.

You may want to import this into the `Html` namespace:

```elm
import Html.Styled.Extra as Html
```

Then you can do things like writing `Html.Styled.Extra.nothing` instead of `text ""`.

There are many event handlers & decoders in `Html.Styled.Events.Extra`, such as
`targetValueInt` or `onClickPreventDefault`.

## Installation

Run the following command in your directory that contains `elm.json`:

```bash
$ elm install ken-matsui/html-styled-extra
Here is my plan:

  Add:
    ken-matsui/html-styled-extra    1.0.0

Would you like me to update your elm.json accordingly? [Y/n]: y
Success!
```

## Contributing

Feedback and contributions are very welcome.

### Publishing a new version

```sh
$ elm bump
$ git tag 1.0.0
$ git push origin 1.0.0
$ elm publish
```

## License

MIT
