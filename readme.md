# Indexer Extension for Quarto

This extension adds term indexing functionality to quarto.

## Installing

```bash
quarto add simply-logical/quarto_indexer
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check-in this directory.

## Usage

See [example.qmd](example.qmd) for a minimal example.

LaTeX conversion can be done with:
```bash
quarto render example.qmd --to latex
```

## Syntax

### `indexer`

```qmd
{{< indexer add
    'term to be indexed'

    <!-- indexer optional parameters -->
    idxdisplay='$\delta$ text to be displayed'
    idxsortkey='delta text to be displayed'
    idxsee='alternative term to be indexed'
    idxnesting='top-level term ! mid-level term ! bottom-level term'
    idxsuffix='custom suffix'
    idxstyle=mystyle
>}}
```

### `definer`

```qmd
{{< definer
    'term to be defined'

    <!-- definer optional parameters -->
    defref='def:my-def-label'
    defstyle=mystyle
    defindex='term to be indexed'

    <!-- indexer optional parameters -->
    idxsortkey='delta text to be displayed'
    idxsee='alternative term to be indexed'
    idxnesting='top-level term ! mid-level term ! bottom-level term'
    idxsuffix='custom suffix'
    idxstyle=mystyle
>}}
```

## Reference

- See the AST [documentation][ast].

## TODO

- [ ] An extension for *assigning index terms to parent elements*
      (e.g., section, example box)
- [ ] An extension for *custom collection lists*
      (one command for collecting terms and another for displaying their list)
- [ ] An extension for custom boxes (e.g., background, exercise);
      maybe have paired boxes (e.g., linked exercise and solution boxes)
- [ ] An extension for custom (numbered) environments
      (e.g., definition, theorem, example)
- [ ] An extension for *assigning custom tags to parent elements*
      (e.g., `difficulty:easy`, `difficulty:medium`, `difficulty:hard`
      to [sub]sections, exercises, etc.);
      maybe have lists/hierarchy of tags

[ast]: https://hackage.haskell.org/package/pandoc-types-1.23.1/docs/Text-Pandoc-Definition.html
