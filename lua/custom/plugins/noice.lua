return {
  "folke/noice.nvim",
  event = "VeryLazy",
  -- TODO: Hide Info level messages?
  -- notify = {},
  opts = {
    messages = {
      view_search = false
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
    },
    views = {
      mini = {
        win_options = { winblend = 0 }
      },
    },
  },
}