local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.java" },
    -- add Treesitter for C++ and Java support
    {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "cpp", "java" },
          highlight = { enable = true },
        })
      end,
    },
    -- add LSP config for C++ and Java support
    {
      "neovim/nvim-lspconfig",
      config = function()
        -- C++ LSP configuration
        require("lspconfig").clangd.setup({})
        -- Java LSP configuration
        require("lspconfig").jdtls.setup({})
      end,
    },
    -- add Mason and Mason-LSPconfig
    {
      "williamboman/mason.nvim",
      run = ":MasonUpdate", -- :MasonUpdate updates registry contents
    },
    {
      "williamboman/mason-lspconfig.nvim",
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { "clangd", "jdtls" },
        })
      end,
    },
    -- install Tokyonight theme
    { "folke/tokyonight.nvim" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "github_dark", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Set the colorscheme without transparency
require("tokyonight").setup({
  transparent = false, -- Disable transparency
})

vim.cmd("colorscheme tokyonight")

-- Function to run the current file
function RunFile()
  -- Save the current file
  vim.cmd("write")

  -- Get the file extension
  local file_ext = vim.fn.expand("%:e")

  -- Define the command to run based on file type
  local cmd = ""
  if file_ext == "cpp" then
    cmd = "g++ % -o %< && ./%<"
  elseif file_ext == "java" then
    local file_name = vim.fn.expand("%:t:r") -- get the file name without extension
    cmd = "javac % && java -cp . " .. file_name
  elseif file_ext == "py" then
    cmd = "python3 %"
  else
    print("File type not supported!")
    return
  end

  -- Open a terminal and run the command
  vim.cmd("split | terminal " .. cmd)
end

-- Map the function to a keybinding
vim.api.nvim_set_keymap("n", "<F5>", ":lua RunFile()<CR>", { noremap = true, silent = true })
