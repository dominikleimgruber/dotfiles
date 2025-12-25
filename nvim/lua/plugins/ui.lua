return {
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      require("transparent").setup({
        -- This table ensures extra UI elements like the sidebar stay transparent
        extra_groups = {
          "NormalFloat",
          "NvimTreeNormal",
          "NeoTreeNormal",
          "MasonNormal",
        },
      })
    end,
  },
}
