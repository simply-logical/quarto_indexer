local helper = require 'helper'

local NAME = 'indexer'
local INDEXER = {}

-- Has indexer already been set up
INDEXERSETUP = false
-- What named arguments are allowed in the indexer
ALLOWEDTERMS = {'idxdisplay'}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

local function ensureLatexDeps()
  quarto.doc.use_latex_package('makeidx')
  quarto.doc.include_text(
    'in-header',
    '\\makeindex')
end

local function ensureHtmlDeps()
  quarto.doc.include_text(
    'in-header',
    [[<style>
    div.indexer {
      display: none;
    }
    </style>]])
end

local function indexerSetup()
  if not INDEXERSETUP then
    if quarto.doc.is_format('pdf') then
      ensureLatexDeps()
    elseif quarto.doc.is_format('html') then
      ensureHtmlDeps()
    else
      error('Extension *indexer*: indexer is only implemented for LaTeX ' ..
            'and HTML outputs.')
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
    -- TODO: implement
    return {
      pandoc.Header(1, 'Index'),
      pandoc.Para('Extension *indexer*: TODO: implement printing the index.')
    }
  end
end
INDEXER.indexer_print = indexer_print

function indexer_add_term(args, kwargs, meta) 
  indexerSetup()

  if #args ~= 1 then
    error('Extension *indexer*: *indexer_add_term* expects only 1 argument; '
          .. #args .. ' given.')
  end

  helper.validateTableKeys(ALLOWEDTERMS, kwargs)

  if next(meta) ~= nil then
    error('Extension *indexer*: *indexer_add_term* expects 0 meta argument; '
          .. helper.tableLength(meta) .. ' given.')
  end

  if quarto.doc.is_format('pdf') then
    collector = {}

    if type(kwargs['idxdisplay']) == 'string'
       and kwargs['idxdisplay'] ~= '' then
      display = pandoc.read(kwargs['idxdisplay'], 'markdown').blocks
      assert(helper.tableLength(display) == 1)
      assert(display[1].t == 'Para')
      table.insert(collector, display[1])  -- .content
    end

    table.insert(collector, pandoc.RawBlock('tex', '\\index{' .. args[1] .. '}'))

    return collector
  elseif quarto.doc.is_format('html') then
    -- TODO: implement
    return pandoc.RawInline(
      'html',
      '<div class=indexer>' .. args[1] .. '</div>'
    )
  end
end
INDEXER.indexer_add_term = indexer_add_term

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

function indexer(args, kwargs, meta)
  indexerSetup()

  if #args <= 0 then
    error('Extension *indexer*: *indexer* no argument given.')
  end

  if args[1] == 'print' then
    return indexer_print()
  elseif args[1] == 'add' then
    if args[2] == nil then
      error('Extension *indexer*: *indexer add* requires index term.')
    end
    return indexer_add_term({args[2]}, kwargs, meta)
  else
    error('Extension *indexer*: unknown command *' .. args[1] .. '*.')
  end
end
INDEXER.indexer = indexer

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

return INDEXER
