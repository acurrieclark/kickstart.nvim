-- Function to check if a directory exists
local function is_directory(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "directory"
end

local function find_tests_directory(filename)
  local current_directory = vim.fn.fnamemodify(filename, ":p:h") -- Get the directory of the given filename

  while current_directory ~= vim.uv.cwd() do                   -- Stop when reaching the root directory
    local tests_directory = current_directory .. '/tests'
    if is_directory(tests_directory) then
      return current_directory
    end

    -- Move up one directory
    current_directory = vim.fn.fnamemodify(current_directory, ':h')
  end

  return vim.uv.cwd() -- No "tests" directory found
end

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "marilari88/neotest-vitest"
  },
  opts = {
    adapters = {
      "neotest-vitest",
    },
    output = { open_on_run = true },
    status = { virtual_text = true },

  },
  config = function(_, opts)
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          -- Replace newline and tab characters with space for more compact diagnostics
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    if opts.adapters then
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        if type(name) == "number" then
          if type(config) == "string" then
            config = require(config)
          end
          adapters[#adapters + 1] = config
        elseif config ~= false then
          local adapter = require(name)
          if type(config) == "table" and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)
            if adapter.setup then
              adapter.setup(config)
            elseif meta and meta.__call then
              adapter(config)
            else
              error("Adapter " .. name .. " does not support setup")
            end
          end
          adapters[#adapters + 1] = adapter
        end
      end
      opts.adapters = adapters
    end

    require("neotest").setup(opts)
  end,
  -- stylua: ignore
  keys = {
    { "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end,                       desc = "Run File" },
    { "<leader>tt", function() require("neotest").run.run(find_tests_directory(vim.fn.expand("%"))) end, desc = "Run Nearest Test Files" },
    { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end,                           desc = "Run All Test Files" },
    { "<leader>tr", function() require("neotest").run.run() end,                                         desc = "Run Nearest" },
    { "<leader>ts", function() require("neotest").summary.toggle() end,                                  desc = "Toggle Summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end,  desc = "Show Output" },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end,                             desc = "Toggle Output Panel" },
    { "<leader>tS", function() require("neotest").run.stop() end,                                        desc = "Stop" },
    { "<leader>tl", function() require("neotest").run.run_last() end,                                    desc = "Run Last" },
  },
}
