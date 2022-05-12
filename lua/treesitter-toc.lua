local M = {}

M.gather = function(bufnr)
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
      table.insert(headings, {lvl, content:sub(start_col + 1):gsub('^%s+', '')})
    end
  end
  return headings
end

M.create_toc = function(bufnr)
  local toc = {''}
  for i, h in pairs(M.gather(bufnr)) do
    table.insert(toc, string.rep(' ', 4 * h[1] - 4) .. '- ' .. h[2])
  end
  table.insert(toc, '')
  return toc
end

M.insert_toc = function(bufnr)
  local n = vim.fn.line('.')
  local toc = M.create_toc(bufnr)
  vim.fn.append(n, toc)
end


return M
