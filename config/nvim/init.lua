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

        use {'nvim-telescope/telescope.nvim',
            requires = { {'nvim-lua/plenary.nvim'} }
        }

        use {'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate'
        }

        use {'simrat39/rust-tools.nvim',
            after = 'nvim-lspconfig',
            config = function()
                 require('rust-tools').setup({})
            end
        }
        
        --require('packer').sync()
        require('lspconfig').pyright.setup({})
    end
)

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
  },
})

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

