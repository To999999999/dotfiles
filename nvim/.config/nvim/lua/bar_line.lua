return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      vim.o.laststatus = 0

      require("lualine").setup({
        options = {
          theme = "ayu_light",
        },

        winbar = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },

        inactive_winbar = {
          lualine_c = { "filename" },
        },

        sections = {},
        inactive_sections = {},
      })
    end,
  },
}
