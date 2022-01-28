-- Entrypoint for my Neovim configuration!
-- We simply bootstrap packer 

local vim = vim

local execute = vim.api.nvim_command
local fn = vim.fn

local pack_path = fn.stdpath("data") .. "/site/pack"
local fmt = string.format

function ensure (user, repo)
    -- Ensures a given github.com/USER/REPO is cloned in the pack/packer/start directory.
    local install_path = fmt("%s/packer/start/%s", pack_path, repo, repo)
    if fn.empty(fn.glob(install_path)) > 0 then
        execute(fmt("!git clone https://github.com/%s/%s %s", user, repo, install_path))
        execute(fmt("packadd %s", repo))
    end
end

-- Bootstrap essential plugins required for installing and loading the rest.
ensure("wbthomason", "packer.nvim")

require('packer').startup(
    function()
        use 'wbthomason/packer.nvim'
        use 'neovim/nvim-lspconfig'
        use 'nvim-lua/lsp_extensions.nvim'
        use 'hrsh7th/nvim-cmp'
        use 'hrsh7th/cmp-nvim-lsp'
        use 'hrsh7th/cmp-buffer'
        use 'hrsh7th/cmp-path'
        use 'hrsh7th/cmp-cmdline'
        use 'hrsh7th/vim-vsnip'

        use 'kyazdani42/nvim-web-devicons'

        use {'nvim-lualine/lualine.nvim',
            requires = { 'kyazdani42/nvim-web-devicons', opt = true }
        }

        use 'navarasu/onedark.nvim'

        use {'nvim-telescope/telescope.nvim',
            requires = { {'nvim-lua/plenary.nvim'}, {'nvim-lua/popup.nvim'} }
        }

        use 'nvim-telescope/telescope-ui-select.nvim'

        use {'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate'
        }

        local rust_opts = {
            -- rust-tools options
            tools = {
                autoSetHints = true,
                hover_with_actions = true,
                inlay_hints = {
                    show_parameter_hints = false,
                    parameter_hints_prefix = "",
                    other_hints_prefix = "",
                },
            },

            -- all the opts to send to nvim-lspconfig
            -- these override the defaults set by rust-tools.nvim
            -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
            server = {
                -- on_attach is a callback called when the language server attachs to the buffer
                -- on_attach = on_attach,
                settings = {
                    -- to enable rust-analyzer settings visit:
                    -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
                    ["rust-analyzer"] = {
                        -- enable clippy on save
                        checkOnSave = {
                            command = "clippy"
                        },
                    }
                }
            },

        }

        use {'simrat39/rust-tools.nvim',
            after = 'nvim-lspconfig',
            config = function()
                 require('rust-tools').setup(rust_opts)
            end
        }
 
        -- Tabnine (for linux only)
        -- to work on Windows in Powershell, change 'install.sh' to 'install.ps1'
        use {'tzachar/cmp-tabnine', 
            after = 'nvim-cmp',
            run = './install.sh',
            requires = 'hrsh7th/nvim-cmp'
        }


        -- Setup Things!
        require('onedark').setup({
            style = 'darker'
        })
        require('onedark').load()

        require('lualine').setup({
            options = { theme = 'onedark' }
        })
        
        require('lspconfig').pyright.setup({})

        require('telescope').setup({
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown {
                        -- what goes here
                    }
                }
            }
        })

        require('telescope').load_extension('ui-select')


        -- Setup Completion
        local cmp = require('cmp')
        cmp.setup({
            -- Enable LSP snippets
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            mapping = {
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-n>'] = cmp.mapping.select_next_item(),
                -- Add tab support
                ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                ['<Tab>'] = cmp.mapping.select_next_item(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.close(),
                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                })
            },
            -- Installed sources
            sources = {
                { name = 'nvim_lsp' },
                { name = 'vsnip' },
                { name = 'path' },
                { name = 'buffer' },
                { name = 'cmp_tabnine' },
            },
        })
    end
)

-- Appearance
vim.wo.relativenumber = true
vim.wo.number = true
vim.wo.colorcolumn = '120'

-- Editing
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.expandtab = true


vim.wo.relativenumber = true

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<cr>]],
    {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]],
    {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<cr>]],
    {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>lua require('telescope.builtin').help_tags()<cr>]],
    {noremap = true, silent = true})

-- Open diagnostics Windows
-- 
function LspDiagnosticsFocus()
    vim.api.nvim_command('set eventignore=WinLeave')
    vim.api.nvim_command('autocmd CursorMoved <buffer> ++once set eventignore=""')
    vim.diagnostic.open_float(nil,
        {focusable = true,
         scope = 'line',
         close_events = {"CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre", "WinLeave"}
     })
end

vim.api.nvim_set_keymap('n', '<Leader>d', '<Cmd>lua LspDiagnosticsFocus()<CR>', {noremap = true, silent = true})

