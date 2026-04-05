require("lazy").setup({
  ---@type AstroNvimOpts
  {
    "AstroNvim/AstroNvim",
    import = "astronvim.plugins",
    opts = {
      mapleader = " ",
      maplocalleader = " ",
      icons_enabled = true,
      pin_plugins = false,
      update_notifications = true,
    },
  },
  { import = "plugins" },
} --[[@as LazySpec]], {
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
