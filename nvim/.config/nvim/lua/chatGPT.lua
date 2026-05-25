return {
  {
    "jackMort/ChatGPT.nvim",

    cmd = {
      "ChatGPT",
      "ChatGPTCompleteCode",
      "ChatGPTRun",
      "ChatGPTEditWithInstructions",
    },

    keys = {
      { "<leader>aa", "<cmd>ChatGPT<CR>", desc = "Open ChatGPT" },
      { "<leader>ac", "<cmd>ChatGPTCompleteCode<CR>", desc = "Complete code with ChatGPT" },
      { "<leader>at", "<cmd>ChatGPTRun add_tests<CR>", desc = "Create tests with ChatGPT" },
      { "<leader>ae", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain code with ChatGPT" },
      { "<leader>af", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix bugs with ChatGPT" },
      { "<leader>ad", "<cmd>ChatGPTRun docstring<CR>", desc = "Create docstring with ChatGPT" },
      { "<leader>ao", "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize code with ChatGPT" },
      { "<leader>as", "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize with ChatGPT" },
      { "<leader>aT", "<cmd>ChatGPTRun translate<CR>", desc = "Translate with ChatGPT" },
      { "<leader>ai", "<cmd>ChatGPTEditWithInstructions<CR>", desc = "Edit with instructions with ChatGPT" },
    },

    config = function()
      local home = vim.fn.expand("$HOME")

      require("chatgpt").setup({
        api_key_cmd = "gpg --decrypt " ..
          home ..
          "/.config/nvim/chatGPT_API_key.txt.gpg",
      })
    end,

    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
