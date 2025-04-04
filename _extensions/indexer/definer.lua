local helper = require 'helper'
local indexer = require 'indexer'

local NAME = 'definer'
local DEFINER = {}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

local function ensureLatexDeps()
  quarto.doc.include_text(
    'in-header',
    '\\definecolor{emphcolour}{RGB}{204, 51, 51}')
end

local function ensureHtmlDeps()
  quarto.doc.include_text(
    'in-header',
    [[<style>
    .indexer-emph {
      color: rgb(204, 51, 51);
    }
    </style>]])
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

-- '\\textcolor{emphcolour}{\\emph{' .. args[1] .. '}}')

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

return DEFINER
