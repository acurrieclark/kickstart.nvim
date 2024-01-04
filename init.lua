-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    config = function()
      local git_signs = require('gitsigns')

      require('which-key').register({
          s = {
            [[<cmd>lua require("persistence").load()<cr>]], 'Load Directory Session'
          },
          z = {
            "<cmd>NoNeckPain<cr>", "Zen Mode"
          },
          o = {
            "<cmd>OrganizeImports<cr>", "Organize Imports"
          },
          e = {
            name = "Explorer",
            e = { "<cmd>Neotree current<cr>", "Open at Current File" },
            g = { "<cmd>Neotree git_status<cr>", "Git Status" },
            b = { "<cmd>Neotree buffers<cr>", "Buffers" },
            d = { "<cmd>Neotree document_symbols<cr>", "Document Symbols" },
          },
          g = {
            name = "Git",
            p = { git_signs.prev_hunk, "Previous Hunk" },
            r = { git_signs.reset_hunk, "Reset Hunk" },
            n = { git_signs.next_hunk, "Next Hunk" },
            h = { git_signs.preview_hunk, "Preview Hunk" },
          },
          f = {
            name = "Find"
          },
          d = {
            name = "Document"
          },
          C = {
            "<cmd>bufdo :Bdelete<cr>", "Close All Buffers"
          },
          c = {
            "<cmd>Bdelete<cr>", "Close Buffer"
          },
          w = {
            name = "Workspace",
          },
        },
        { prefix = "<leader>" }
      )
    end
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',  opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

-- Minimum lines at top and bottom when scrolling
vim.opt.scrolloff = 5

-- Unified statusline
vim.opt.laststatus = 3

-- Don't show mode status anywhere but in LuaLine
vim.opt.showmode = false

-- Don't continue comments with o and O
local custom_o_formatting = vim.api.nvim_create_augroup('CustomOFormatting', { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = '*',
  callback = function()
    vim.opt.formatoptions:remove({ 'o' })
  end,
  group = custom_o_formatting,
})

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev({
    severity = vim.diagnostic.severity.ERROR,
  })
end, { desc = 'Go to previous error' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next({
    severity = vim.diagnostic.severity.ERROR,
  })
end, { desc = 'Go to next error' })
vim.keymap.set('n', '[w', function()
  vim.diagnostic.goto_prev({
    severity = vim.diagnostic.severity.WARN,
  })
end, { desc = 'Go to previous warning' })
vim.keymap.set('n', ']w', function()
  vim.diagnostic.goto_next({
    severity = vim.diagnostic.severity.WARN,
  })
end, { desc = 'Go to next warning' })
vim.keymap.set('n', '<leader>di', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

-- Quickly envoke the q macro
vim.keymap.set('n', 'Q', "@q")
vim.keymap.set('v', 'Q', ":norm @q<CR>")

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Select next/previous buffer
vim.keymap.set('n', '<C-l>', ":bnext<CR>", { silent = true })
vim.keymap.set('n', '<C-h>', ":bprevious<CR>", { silent = true })

-- Remap Accidental capitals
vim.cmd([[
  cnoreabbrev W w
  cnoreabbrev Wq wq
  cnoreabbrev WQ wq
  cnoreabbrev Q! q!
]])

-- When joining lines, keep the same cursor position
vim.keymap.set("n", "J", "mzJ`z")

-- When moving up and down the page, or searching, keep the cursor centred
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Move to just before the last character on the line and enter insert mode
vim.keymap.set("n", "<C-;>", "$i")

-- delete/change selection, but don't add to paste register
vim.keymap.set({ "v" }, "<leader>d", [["_d]])
vim.keymap.set({ "v" }, "<leader>c", [["_c]])

-- add a line above/below current line
vim.keymap.set("n", "]<space>", [[o<Esc>0"_Dk]])
vim.keymap.set("n", "[<space>", [[O<Esc>0"_Dj]])

-- Define the function to check if the current line is empty
local function is_line_empty()
  local line = vim.api.nvim_get_current_line()
  return line:gsub('%s', '') == ''
end

-- Function to input a sequence of keys
local function input_keys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), 'n', true)
end

-- Define the function to perform the custom "o" behavior
function CustomO()
  -- Check if the current line is empty or not
  if is_line_empty() then
    -- If the line is empty, add an additional new line below the new one
    input_keys('o<Esc>O')
  else
    -- If the line has content, use the normal `o` command
    input_keys('o')
  end
end

-- `o` behaves as expected on a line with content, but adds an additional line below if empty
vim.api.nvim_set_keymap('n', 'o', ':lua CustomO()<CR>', { noremap = true, silent = true })

-- Save all buffers when leaving nvim
vim.cmd([[
  augroup Autosave
    autocmd!
    autocmd BufLeave,FocusLost * silent! wall
  augroup END
]])

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  extensions = {
    ["ui-select"] = {
      layout_strategy = "center",
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
        width = function(_, max_columns, _)
          return math.min(max_columns, 80)
        end,

        height = function(_, _, max_lines)
          return math.min(max_lines, 15)
        end,
        anchor = "CENTER"
      },
      border = true,
      borderchars = {
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    }
  },
  defaults = {
    path_display = { 'smart' },
    layout_strategy = 'vertical',
    layout_config = {
      anchor = 'N',
      mirror = true,
      width = 140,
      prompt_position = 'bottom',
      preview_cutoff = 1,
    },
    mappings = {
      i = {
        ["<C-k>"] = require('telescope.actions').move_selection_previous, -- move to prev result
        ["<C-j>"] = require('telescope.actions').move_selection_next,     -- move to next result
        ["<Esc>"] = require('telescope.actions').close,                   -- close telescope
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

local telescope_functions = require('telescope.functions')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>fr', telescope_functions.old_files, { desc = 'Recent Files' })
vim.keymap.set('n', '<leader>fR', telescope_functions.all_old_files, { desc = 'All Recent Files' })
vim.keymap.set('n', '<leader>fb', telescope_functions.buffers, { desc = 'Existing Buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>f/', telescope_live_grep_open_files, { desc = 'Grep [/] in Open Files' })
vim.keymap.set('n', '<leader>fT', require('telescope.builtin').builtin, { desc = 'Find Telescope Methods' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').git_files, { desc = 'Git Files' })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'All Files' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Help' })
vim.keymap.set('n', '<leader>fw', require('telescope.builtin').grep_string, { desc = 'Find Current Word' })
vim.keymap.set('n', '<leader>fs', require('telescope.builtin').live_grep, { desc = 'Grep' })
vim.keymap.set('n', '<leader>fS', ':LiveGrepGitRoot<cr>', { desc = 'Grep on Git Root' })
vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = 'Workplace Diagnostics' })
vim.keymap.set('n', '<leader>fp', require('telescope.builtin').resume, { desc = 'Resume Search' })
vim.keymap.set('n', '<leader>dd', function()
    require('telescope.builtin').diagnostics({
      bufnr = 0,
      previewer = false,
    })
  end,
  { desc = 'Document Diagnostics' })
vim.keymap.set('n', '<leader>ft', function()
  require("telescope._extensions.todo-comments").exports.todo({
    keywords = "TODO",
  })
end, { desc = 'Todo List' })
vim.keymap.set('n', '<leader>ds', telescope_functions.document_symbols, { desc = 'Document Symbols' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'svelte', 'html', 'regex', 'markdown_inline' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

local svelte_hack_group = vim.api.nvim_create_augroup("svelte_ondidchangetsorjsfile", { clear = true })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>r', vim.lsp.buf.rename, 'Rename')
  nmap('<c-cr>', vim.lsp.buf.code_action, 'Code Action')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('gy', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<M-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  -- HACK: to make Svelte files work with LSP when updates are made to project ts files
  if client.name == "svelte" then
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        client.notify("$/onDidChangeTsOrJsFile", {
          uri = ctx.file,
          changes = {
            { text = table.concat(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false), "\n") },
          },
        })
      end,
      group = svelte_hack_group,
    })
  end
end

-- document existing key chains
require('which-key').register {
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- TODO: Add keymap to organize imports in any language
local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end

local util = require 'lspconfig.util'

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  denols = {
    root_dir = function(fname)
      return util.root_pattern('deno.json', 'deno.jsonc')(fname)
    end,
  },
  eslint = {},
  tsserver = {
    filetypes = { 'javascript', 'typescript', 'svelte' },
    root_dir = function(fname)
      return util.root_pattern(".git")(fname)
          or util.root_pattern('tsconfig.json')(fname)
          or util.root_pattern('package.json', 'jsconfig.json')(fname)
    end,
    commands = {
      OrganizeImports = {
        organize_imports,
        description = "Organize Imports"
      }
    }
  },
  intelephense = {},
  tailwindcss = {},
  svelte = {
    root_dir = function(fname)
      return util.root_pattern('svelte.config.js')(fname)
          or util.root_pattern('package.json', 'tsconfig.json')(fname)
    end,
    commands = {
      OrganizeImports = {
        organize_imports,
        description = "Organize Imports"
      }
    }
  },
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        diagnostics = { disable = { 'missing-fields' } },
      },
    }
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    local config = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    local server_config = servers[server_name]

    if server_config then
      for k, v in pairs(server_config) do
        config[k] = v
      end
    end

    require('lspconfig')[server_name].setup(config);
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        return fallback()
      end
    end),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        return fallback()
      end
    end),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-c>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ['<s-CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        return fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        return fallback()
      end
    end, { 'i', 's' }),
    ['<esc>'] = cmp.mapping(function(fallback)
      local entries = cmp.get_entries()
      if cmp.visible() and #entries > 1 then
        cmp.abort()
      else
        return fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
