return {
  'nvim-treesitter/nvim-treesitter-context',
  opts = {
    max_lines = 3,
    separator = '━',
  },
  config = function(_, opts)
    require('treesitter-context').setup(opts or {})

    vim.keymap.set('n', '<leader>Tc', '<cmd>TSContextToggle<CR>', {
      desc = 'Toggle Treesitter Context',
    })

    vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = false })
  end,
}
