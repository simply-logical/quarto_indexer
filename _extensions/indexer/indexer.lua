local helper = require 'helper'

local NAME = 'indexer'
local INDEXER = {}

-- Has indexer already been set up
INDEXERSETUP = false
-- What named arguments are allowed in the indexer
ALLOWEDTERMS = {
  'idxdisplay', 'idxsortkey', 'idxsee', 'idxnesting', 'idxsuffix'
}

-- ~~~~~~~~~~ setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

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

-- ~~~~~~~~~~ index printing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

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

-- ~~~~~~~~~~ index indexing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

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

  if quarto.doc.is_format('pdf') or quarto.doc.is_format('latex') then
    local collector = {}

    -- handle idxdisplay if it's provided
    if type(kwargs['idxdisplay']) == 'string' then
      -- reuse the indexed term
      if kwargs['idxdisplay'] == '' then
        text_to_display = args[1]
      -- use the bespoke term
      else
        text_to_display = kwargs['idxdisplay']
      end
      display = pandoc.read(text_to_display, 'markdown').blocks
      assert(helper.tableLength(display) == 1)
      assert(display[1].t == 'Para')
      table.insert(collector, display[1])  -- .content
    end

    -- handle idxsortkey if it's provided
    if type(kwargs['idxsortkey']) == 'string'
       and kwargs['idxsortkey'] ~= '' then
      local sortkey = pandoc.read(kwargs['idxsortkey'], 'markdown').blocks
      assert(helper.tableLength(sortkey) == 1)
      assert(sortkey[1].t == 'Para')
      idxsortkey = sortkey[1].content
    else
      idxsortkey = nil
    end

    -- handle idxsee if it's provided
    if type(kwargs['idxsee']) == 'string'
       and kwargs['idxsee'] ~= '' then
      local see = pandoc.read(kwargs['idxsee'], 'markdown').blocks
      assert(helper.tableLength(see) == 1)
      assert(see[1].t == 'Para')
      idxsee = see[1].content
    else
      idxsee = nil
    end

    -- handle idxnesting if it's provided
    if type(kwargs['idxnesting']) == 'string'
       and kwargs['idxnesting'] ~= '' then
      local nesting = pandoc.read(kwargs['idxnesting'], 'markdown').blocks
      assert(helper.tableLength(nesting) == 1)
      assert(nesting[1].t == 'Para')
      idxnesting = nesting[1].content
    else
      idxnesting = nil
    end

    -- handle idxsuffix if it's provided
    if type(kwargs['idxsuffix']) == 'string'
       and kwargs['idxsuffix'] ~= '' then
      local suffix = pandoc.read(kwargs['idxsuffix'], 'markdown').blocks
      assert(helper.tableLength(suffix) == 1)
      assert(suffix[1].t == 'Para')
      idxsuffix = suffix[1].content
    else
      idxsuffix = nil
    end

    -- open the tag
    contents = {pandoc.RawInline('tex', '\\index{')}

    -- inject the sortkey term
    if idxsortkey ~= nil then
      helper.embedTable(contents, idxsortkey)
      table.insert(contents, pandoc.RawInline('tex', '@'))
    end

    -- inject the term nesting
    if idxnesting ~= nil then
      helper.embedTable(contents, idxnesting)
      table.insert(contents, pandoc.RawInline('tex', '!'))
    end

    -- inject the index term
    index = pandoc.read(args[1], 'markdown').blocks
    assert(helper.tableLength(index) == 1)
    assert(index[1].t == 'Para')
    helper.embedTable(contents, index[1].content)

    -- inject the suffix
    if idxsuffix ~= nil then
      table.insert(contents, pandoc.RawInline('tex', ', '))
      helper.embedTable(contents, idxsuffix)
    end

    -- inject the see term
    if idxsee ~= nil then
      table.insert(contents, pandoc.RawInline('tex', '|see{'))
      helper.embedTable(contents, idxsee)
      table.insert(contents, pandoc.RawInline('tex', '}'))
    end

    -- close the tag
    table.insert(contents, pandoc.RawInline('tex', '}'))

    -- inject into AST
    table.insert(collector, pandoc.Para(contents))

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

-- ~~~~~~~~~~ indexer callout mapping ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

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
