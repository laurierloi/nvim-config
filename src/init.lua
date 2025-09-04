-- Byte-code loader
vim.loader.enable()

-- Leader
vim.g.mapleader = ","

-- Basics
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.termguicolors = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.colorcolumn = "80,120"

-- Folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>zo", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "<leader>zc", "zM", { desc = "Close all folds" })

-- Autocommands for tabs per filetype
local ft_opts = {
    python = "setlocal shiftwidth=4 softtabstop=4 expandtab",
    javascript = "setlocal shiftwidth=2 softtabstop=2 expandtab",
    typescript = "setlocal shiftwidth=2 softtabstop=2 expandtab",
    html = "setlocal shiftwidth=2 softtabstop=2 expandtab",
    css = "setlocal shiftwidth=2 softtabstop=2 expandtab",
    yaml = "setlocal shiftwidth=2 softtabstop=2 expandtab textwidth=100",
    vue = "setlocal shiftwidth=2 softtabstop=2 expandtab",
    robot = "setlocal shiftwidth=8 softtabstop=8 tabstop=8 noexpandtab",
    c = "setlocal shiftwidth=8 softtabstop=8 tabstop=8 noexpandtab",
    cpp = "setlocal shiftwidth=8 softtabstop=8 tabstop=8 noexpandtab",
    vhdl = "setlocal shiftwidth=8 softtabstop=8 tabstop=8 noexpandtab",
}
for ft, cmd in pairs(ft_opts) do
    vim.api.nvim_create_autocmd("FileType", { pattern = ft, command = cmd })
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    { "nvim-lua/plenary.nvim" },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>o", builtin.oldfiles, { desc = "Recent files" })
            vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Word under cursor" })
            vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Buffers" })
            vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Help" })

            local t = require("telescope")
            t.setup {
                defaults = { file_ignore_patterns = { "node_modules" } },
                pickers = { find_files = { hidden = true } },
                extensions = { fzf = { case_mode = "smart_case" } },
            }
            pcall(t.load_extension, "fzf") -- or "zf-native"
        end,
    },
    {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = { "mfussenegger/nvim-dap", "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension("dap")
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function() require("telescope").load_extension("ui-select") end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup {
                options = { theme = "auto" },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            }
        end,
    },
    {
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            local navic = require("nvim-navic")
            vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
            navic.setup { highlight = true }
        end,
    },
    {
        "stevearc/aerial.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = { backends = { "lsp", "treesitter", "markdown" } },
        config = function()
            require("aerial").setup {
                backends = { "lsp", "treesitter", "markdown" },
                layout = { default_direction = "prefer_right" },
            }
            vim.keymap.set("n", "<leader>no", "<cmd>AerialToggle!<CR>", { desc = "Toggle outline" })
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup {
                view = { side = "right" },
            }
            vim.keymap.set("n", "<leader>nn", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
        end,
    },
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-lualine/lualine.nvim" },
    { "tpope/vim-fugitive" },
    {
        "lewis6991/gitsigns.nvim",
        opts = { current_line_blame = true },
        keys = {
            { "]h",  function() require("gitsigns").next_hunk() end,  desc = "Next hunk" },
            { "[h",  function() require("gitsigns").prev_hunk() end,  desc = "Prev hunk" },
            { ",ts", function() require("gitsigns").stage_hunk() end, desc = "Git: stage hunk" },
            { ",tr", function() require("gitsigns").reset_hunk() end, desc = "Git: reset hunk" },
        },
    },
    { "nvim-pack/nvim-spectre",           keys = { { ",sr", "<cmd>Spectre<CR>", desc = "Search & replace (project)" } } },
    {
        "Shatur/neovim-session-manager",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local Path = require("plenary.path")
            require("session_manager").setup({
                sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"),
                autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
            })
        end,
    },
    {
        "coffebar/neovim-project",
        dependencies = { "nvim-telescope/telescope.nvim", "Shatur/neovim-session-manager" },
        opts = {
            projects = {
                "~/devs/*",
                "~/.config/nvim",
            },
            last_session_on_start = true,
            dashboard_mode = false,
            datapath = vim.fn.stdpath("data"), -- ~/.local/share/nvim/
            forget_project_keys = {
                -- insert mode: Ctrl+d
                i = "<C-d>",
                -- normal mode: d
                n = "d"
            },
            detection_methods = { "pattern" }, -- enable auto-detection
            patterns = { ".git", "Makefile", "package.json", "pyproject.toml" },
        },
        session_manager_opts = {
            autosave_ignore_dirs = {
                vim.fn.expand("~"), -- don't create a session for $HOME/
                "/tmp",
            },
            autosave_ignore_filetypes = {
                -- All buffers of these file types will be closed before the session is saved
                "ccc-ui",
                "gitcommit",
                "gitrebase",
                "qf",
                "toggleterm",
            },
        },
        picker = {
            type = "telescope",     -- one of "telescope", "fzf-lua", or "snacks"
            preview = {
                enabled = true,     -- show directory structure in Telescope preview
                git_status = true,  -- show branch name, an ahead/behind counter, and the git status of each file/folder
                git_fetch = true,   -- fetch from remote, used to display the number of commits ahead/behind, requires git authorization
                show_hidden = true, -- show hidden files/folders
            },
        },
    },
    { "preservim/nerdcommenter" },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim",          build = ":MasonUpdate" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "L3MON4D3/LuaSnip" },
    { "rust-lang/rust.vim" },
    { "mfukar/robotframework-vim" },
    { "posva/vim-vue" },
    { "onsails/lspkind.nvim" },
    { "tpope/vim-surround" },
    { "tpope/vim-repeat" },
    {
        "NeogitOrg/neogit",
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
        config = function()
            require("neogit").setup { integrations = { diffview = true } }
            vim.keymap.set("n", "<leader>tt", ":Neogit kind=split<CR>", { desc = "Git dashboard" })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = {
                    "python", "bash", "javascript", "typescript", "rust", "lua",
                    "html", "css", "json", "vue", "vhdl", "markdown",
                },
                highlight = { enable = true },
                indent = { enable = true },
            }
        end,
    },
    -- Conform
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = { "ConformInfo" },
        config = function()
            require("conform").setup {
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "ruff --fix" },
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    vue = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },
                    json = { "prettier" },
                    markdown = { "prettier" },
                    sh = { "shfmt" },
                    rust = { "rustfmt" },
                    terraform = { "terraform_fmt" },
                    hcl = { "terraform_fmt" },
                },
                format_on_save = {
                    timeout_ms = 1000,
                    lsp_fallback = true,
                },
            }
        end,
    },
    -- GitHub Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup {
                suggestion = { enabled = false },
                panel = { enabled = false },
                filetypes = {
                    ["*"] = true,
                },
            }
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end,
    },
    {
        "mfussenegger/nvim-dap",
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spec = {
                { ",",  group = "Leader" },
                { ",t", group = "Git" },         -- you’re using ,t for Git
                { ",d", group = "Debug" },       -- your DAP prefix
                { ",g", group = "Search" },      -- grep
                { ",e", group = "Explorer" },    -- nvim-tree (right)
                { ",o", group = "Outline" },     -- aerial
                { ",x", group = "Diagnostics" }, -- Trouble
            },
        },
    },
    {
        "folke/trouble.nvim",
        opts = {},
        keys = {
            { ",xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (doc/workspace)" },
            { ",xr", "<cmd>Trouble lsp toggle<CR>",         desc = "LSP references/symbols" },
        },
    },
    { "numToStr/Comment.nvim", opts = {} },
    { "folke/flash.nvim",      opts = {} },
    { "folke/lazydev.nvim",    ft = "lua", opts = {} },
    -- lint
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                -- Python
                python = { "ruff" },

                -- JavaScript / TypeScript / Vue
                javascript = { "eslint" },
                typescript = { "eslint" },
                vue = { "eslint" },

                -- Lua
                lua = { "selene" },

                -- Shell
                sh = { "shellcheck" },

                -- Terraform / HCL
                terraform = { "tflint" },
                hcl = { "tflint" },

                -- YAML
                yaml = { "yamllint" },

                -- Markdown
                markdown = { "markdownlint-cli2" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },
    {
        "b0o/SchemaStore.nvim",
        ft = { "json", "yaml" },
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.jsonls.setup {
                settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
            }
            lspconfig.yamlls.setup {
                settings = { yaml = { schemaStore = { enable = false }, schemas = require("schemastore").yaml.schemas() } },
            }
        end,
    }
})

-- Mason + LSP
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = {
        "pyright",
        "bashls",
        "lua_ls",
        "rust_analyzer",
        "vue_ls",
        "html",
        "cssls",
        "jsonls",
        "terraformls",
    }
}

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP keymaps (now with telescope loaded safely)
local function lsp_on_attach(_, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>lg", builtin.lsp_definitions, opts)
    vim.keymap.set("n", "<leader>lr", builtin.lsp_references, opts)
    vim.keymap.set("n", "<leader>li", builtin.lsp_implementations, opts)
    vim.keymap.set("n", "<leader>lt", builtin.lsp_type_definitions, opts)
    vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format { async = true } end, opts)
    vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ln", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>lp", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>lD", builtin.diagnostics, opts)
    vim.keymap.set("n", "<leader>ldd", function() builtin.diagnostics({ bufnr = 0 }) end, opts)
end

local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
local vue_plugin = {
    name = '@vue/typescript-plugin',
    languages = { 'vue' },
    configNamespace = 'typescript',
}
local vtsls_config = {
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    vue_plugin,
                },
            },
        },
    },
    filetypes = tsserver_filetypes,
}

local ts_ls_config = {
    init_options = {
        plugins = {
            vue_plugin,
        },
    },
    filetypes = tsserver_filetypes,
}

local vue_ls_config = {}
vim.lsp.config('vtsls', vtsls_config)
vim.lsp.config('vue_ls', vue_ls_config)
vim.lsp.config('ts_ls', ts_ls_config)

vim.lsp.enable({
    "pyright", "bashls", "lua_ls", "rust_analyzer", "vtsls", "vue_ls", "html", "cssls", "jsonls", "yamlls",
    "terraformls",
})


-- Lua
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_attach = lsp_on_attach,
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

-- Completion
local cmp = require("cmp")
cmp.setup {
    snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "copilot" },
        { name = "buffer" },
        { name = "path" },
    }
    ),
}

-- Debug
-- Python DAP
local dap_python = require("dap-python")
dap_python.setup("python3")


local dap = require("dap")
local telescope = require("telescope")

-- Keymaps
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP Continue" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP Step Over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP Step Into" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
    { desc = "DAP Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP Run Last" })

-- Telescope DAP pickers
vim.keymap.set("n", "<leader>dd", telescope.extensions.dap.configurations, { desc = "DAP Configurations" })
vim.keymap.set("n", "<leader>dv", telescope.extensions.dap.variables, { desc = "DAP Variables" })
vim.keymap.set("n", "<leader>df", telescope.extensions.dap.frames, { desc = "DAP Frames" })
vim.keymap.set("n", "<leader>dbp", telescope.extensions.dap.list_breakpoints, { desc = "DAP Breakpoints" })

-- Telescope Project
vim.keymap.set("n", ",pg", "<cmd>NeovimProjectDiscover<CR>", { desc = "Discover Project" })
vim.keymap.set("n", ",ph", "<cmd>NeovimProjectHistory<CR>", { desc = "Project History" })
vim.keymap.set("n", ",pl", "<cmd>NeovimProjectLoadRecent<CR>", { desc = "Load recent Project" })

-- Magic Tab
local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
cmp.setup({
    mapping = {
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end),
    },
})

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

-- Lspkind
local lspkind = require('lspkind')
cmp.setup {
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = {
                -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                -- can also be a function to dynamically calculate max width such as
                -- menu = function() return math.floor(0.45 * vim.o.columns) end,
                menu = 50,            -- leading text (labelDetails)
                abbr = 50,            -- actual suggestion item
            },
            ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
                -- ...
                return vim_item
            end,

            symbol_map = {
                Copilot = "",
            },
        })
    }
}
