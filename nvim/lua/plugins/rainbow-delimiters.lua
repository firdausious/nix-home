---@type LazySpec
return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "User AstroFile",
    main = "rainbow-delimiters.setup",
    opts = {
      condition = function(bufnr)
        local excluded_filetypes = {
          "notify", "noice", "lazy", "mason", "oil", "fugitive", "alpha"
        }
        local filetype = vim.bo[bufnr].filetype
        if vim.tbl_contains(excluded_filetypes, filetype) then
          return false
        end
        local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
        return ok and parser ~= nil
      end,
    },
  },
}
