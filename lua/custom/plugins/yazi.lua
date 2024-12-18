---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  event = 'VimEnter',
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '\\',
      function()
        require('yazi').yazi(nil, vim.fn.getcwd())
      end,
      desc = "Open the file manager in nvim's working directory",
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
  },
}
