local helper = require 'helper'
local indexer = require 'indexer'

local NAME = 'definer'
local DEFINER = {}

-- Has definer already been set up
DEFINERSETUP = false
-- What named arguments are allowed in the definer
ALLOWEDTERMS = {
  -- definer terms
  'defstyle', 'defindex',
  -- .. and indexer terms
  'idxsortkey', 'idxsee', 'idxnesting', 'idxsuffix', 'idxstyle'
  -- 'idxdisplay',
}

-- ~~~~~~~~~~ setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

local function ensureLatexDeps()
  quarto.doc.include_text(
    'in-header',
    '\\definecolor{defdefcolour}{RGB}{204, 51, 51}')
  quarto.doc.include_text(
    'in-header',
    '\\providecommand{\\defdefsty}{} \\renewcommand{\\defdefsty}[1]{\\textcolor{defdefcolour}{\\textbf{#1}}}')
end

local function ensureHtmlDeps()
  quarto.doc.include_text(
    'in-header',
    [[<style>
    div.definer {
      color: rgb(204, 51, 51);
    }
    </style>]])
end

local function definerSetup()
  if not DEFINERSETUP then
    if quarto.doc.is_format('pdf') or quarto.doc.is_format('latex') then
      ensureLatexDeps()
    elseif quarto.doc.is_format('html') then
      ensureHtmlDeps()
    else
      error('Extension *definer*: definer is only implemented for LaTeX ' ..
            'and HTML outputs.')
    end
    DEFINERSETUP = true
  end
end

-- ~~~~~~~~~~ definer defining ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

function definer(args, kwargs, meta)
  definerSetup()

  if helper.tableLength(args) <= 0 then
    error('Extension *definer*: *definer* no argument given.')
  end

  if helper.tableLength(args) ~= 1 then
    error('Extension *definer*: *definer* expects only 1 argument; '
          .. helper.tableLength(args) .. ' given.')
  end

  helper.validateTableKeys(ALLOWEDTERMS, kwargs)

  if next(meta) ~= nil then
    error('Extension *definer*: *definer* expects 0 meta argument; '
          .. helper.tableLength(meta) .. ' given.')
  end

  if quarto.doc.is_format('pdf') or quarto.doc.is_format('latex') then
    local collector = {}

    -- display the definition
    local text_to_display = args[1]
    local display = pandoc.read(text_to_display, 'markdown').blocks
    assert(helper.tableLength(display) == 1)
    assert(display[1].t == 'Para')

    -- handle defstyle if it's provided
    if type(kwargs['defstyle']) == 'string'
       and kwargs['defstyle'] ~= '' then
      local contents = {}
      table.insert(
        contents,
        pandoc.RawInline('latex', '\\' .. kwargs['defstyle'] .. '{'))
      helper.embedTable(contents, display[1].content)
      table.insert(
        contents,
        pandoc.RawInline('latex', '}'))
      table.insert(collector, pandoc.Para(contents))
    else
      table.insert(collector, display[1])
    end

    -- handle indexing if it's requested
    if type(kwargs['defindex']) == 'string' then
      -- reuse the indexed term
      if kwargs['defindex'] == '' then
        text_to_index = args[1]
      -- use the bespoke term
      else
        text_to_index = kwargs['defindex']
      end
      -- clear irrelevant arguments
      local kwargs_index = helper.shallowCopy(kwargs)
      kwargs_index['defstyle'] = nil
      kwargs_index['defindex'] = nil
      elements = indexer.indexer_add_term({text_to_index}, kwargs_index, meta)
      helper.embedTable(collector, elements)
    end
    return collector
  elseif quarto.doc.is_format('html') then
    -- TODO: implement
    local collector = {}
    table.insert(collector, pandoc.RawBlock('html', '<div class=definer>'))
    local display = pandoc.read(args[1], 'markdown').blocks
    assert(helper.tableLength(display) == 1)
    assert(display[1].t == 'Para')
    table.insert(collector, display[1])
    table.insert(collector, pandoc.RawBlock('html', '</div>'))
    return collector
  end
end
DEFINER.definer = definer

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

return DEFINER
