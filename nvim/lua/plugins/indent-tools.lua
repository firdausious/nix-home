-- Jumping along the indents ([i, ]i)
-- Text object (dii, cai, yii, vai, etc.)

---@type LazySpec
return {
  "nvimdev/indentmini.nvim",
  event = "User AstroFile",
  opts = {
    exclude = { "help", "alpha" },
  },
}
