INDEXERSETUP = false

function ensureLatexDeps()
  quarto.doc.use_latex_package('makeidx')
  quarto.doc.include_text('in-header', '\\makeindex')
end

function ensureHtmlDeps()
end

function indexerSetup()
  if not INDEXERSETUP then
    if quarto.doc.is_format('pdf') then
      ensureLatexDeps()
    elseif quarto.doc.is_format('html') then
      ensureHtmlDeps()
    else
      error('Extension *indexer*: indexer is only implemented for LaTeX and HTML outputs.')
    end
    INDEXERSETUP = true
  end
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

function indexer_print()  -- args, kwargs, meta
  indexerSetup()

  if quarto.doc.is_format('pdf') then
    return pandoc.RawBlock('tex', '\\printindex')
  elseif quarto.doc.is_format('html') then
    return pandoc.Str('Extension *indexer*: TODO: implement \\printindex')
  end
end

function indexer_add_term(args, kwargs, meta) 
  indexerSetup()

  if #args ~= 1 then
    error('Extension *indexer*: *indexer_add_term* expects only 1 argument; '
          .. #args .. ' given.')
  end

  if #kwargs ~= 0 then
    error('Extension *indexer*: *indexer_add_term* expects 0 named argument; '
          .. #kwargs .. ' given.')
  end

  if #meta ~= 0 then
    error('Extension *indexer*: *indexer_add_term* expects 0 meta argument; '
          .. #meta .. ' given.')
  end

  if quarto.doc.is_format('pdf') then
    return pandoc.RawBlock('tex', '\\index{' .. args[1] .. '}')
  elseif quarto.doc.is_format('html') then
    return pandoc.RawInline(
      'html',
      '<i style="color: rgb(204, 51, 51)">' .. args[1] .. '</i>'
    )
  end
end
