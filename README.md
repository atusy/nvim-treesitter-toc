# nvim-treesitter-toc

Insert a TOC of a document based on nvim-treesitter.

This project is WIP and currently support only markdown.


## Usage

Directly run a lua function `require('treesitter-toc').insert_toc()`, or define a custom command that calls the function.

``` lua
vim.api.nvim_create_user_command(
  'Tocify',
  "require('treesitter-toc').insert_toc()",
  {}
)
```

