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
