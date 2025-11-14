---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    servers = {
      ts_ls = false, -- TypeScript Language Server (already disabled)
      html = false,  -- HTML Language Server
      cssls = false, -- CSS Language Server
      tailwindcss = false, -- Tailwind CSS Language Server
      emmet_language_server = false, -- Emmet Language Server
      cssmodules_ls = false, -- CSS Modules Language Server
      jsonls = false, -- JSON Language Server
      yamlls = false, -- YAML Language Server
      lua_ls = false, -- Lua Language Server
      pyright = false, -- Python Language Server
      pylance = false, -- Pylance Language Server
      gopls = false, -- Go Language Server
      rust_analyzer = false, -- Rust Language Server
      sqls = false, -- SQL Language Server
      prismals = false, -- Prisma Language Server
      dockerls = false, -- Docker Language Server
      bashls = false, -- Bash Language Server
      graphql = false, -- GraphQL Language Server
      lemminx = false, -- XML Language Server
      -- Add any other language servers here to disable them
    },
    features = {
      -- Configuration table of features provided by AstroLSP
      autoformat = false, -- enable or disable auto formatting on start
      inlay_hints = false, -- nvim >= 0.10
      codelens = false,
      semantic_tokens = false,
    },
    -- Configuration options for controlling formatting with language servers
    formatting = {
      -- control auto formatting on save
      format_on_save = false,
      -- disable formatting capabilities for specific language servers
      disabled = {},
      -- default format timeout
      timeout_ms = 600000,
    },
    capabilities = {
      workspace = {
        didChangeWatchedFiles = { dynamicRegistration = true },
      },
    },
  },
}
