local M = {}


local gather = function(bufnr)
  bufnr = bufnr or 0
  local filetype = vim.fn.getbufvar(bufnr, '&filetype')
  local parser = require("vim.treesitter").get_parser(bufnr, filetype)
  local node = parser:parse()[1]:root()

  local lvl, start_row, start_col, end_row, end_col, content
  local headings = {}
  for el in node:iter_children() do
    if el:type() == "atx_heading" then
      lvl = string.gsub(
        el:child(0):type(),
        'atx_h([0-9]+)_marker',
        '%1'
      )
      start_row, start_col, end_row, end_col = el:child(1):range()
      content = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
      table.insert(
        headings,
        {level = lvl, content = content:sub(start_col + 1):gsub('^%s+', '')}
      )
    end
  end
  return headings
end


local tocify = function(headings, opts)
  opts = opts or {}
  local depth = opts.depth or 0
  local link = opts.link or 0

  local toc = {''}
  for _, h in pairs(headings) do
    if depth == 0 or depth >= h.level then
      table.insert(toc, string.rep(' ', 4 * h.level - 4) .. '- ' .. h.content)
    end
  end
  table.insert(toc, '')
  return toc
end


M.insert_toc = function(args)
  args = args or {}
  args.bufnr = args.bufnr or 0
  vim.fn.append(
    vim.fn.line('.'),
    tocify(gather(args.bufnr), args)
  )
end


return M
