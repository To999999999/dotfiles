return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
    },

    config = function()
      local parsers = {
        "bash",
        "c",
        "git_config",
        "gitcommit",
        "gitignore",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "objc",
        "python",
        "query",
        "regex",
        "rust",
        "swift",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      }

      local has_cli = vim.fn.executable("tree-sitter") == 1
      local has_compiler =
        vim.fn.executable("cc") == 1
        or vim.fn.executable("gcc") == 1
        or vim.fn.executable("clang") == 1

      local ts = require("nvim-treesitter")

      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      if has_cli and has_compiler then
        ts.install(parsers)
      else
        local missing = {}

        if not has_cli then
          table.insert(missing, "tree-sitter CLI")
        end

        if not has_compiler then
          table.insert(missing, "C compiler")
        end

        vim.schedule(function()
          vim.notify(
            "Treesitter: parser auto-install skipped. Missing: " .. table.concat(missing, ", "),
            vim.log.levels.INFO,
            { title = "Treesitter" }
          )
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)

          pcall(function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
      })

      -- Incremental selection
      vim.keymap.set("n", "<Leader>ss", function()
        require("nvim-treesitter.incremental_selection").init_selection()
      end, { desc = "Treesitter init selection" })

      vim.keymap.set("x", "<Leader>si", function()
        require("nvim-treesitter.incremental_selection").node_incremental()
      end, { desc = "Treesitter expand node" })

      vim.keymap.set("x", "<Leader>sa", function()
        require("nvim-treesitter.incremental_selection").scope_incremental()
      end, { desc = "Treesitter expand scope" })

      vim.keymap.set("x", "<Leader>sd", function()
        require("nvim-treesitter.incremental_selection").node_decremental()
      end, { desc = "Treesitter shrink node" })

      -- Textobjects
      local ok_textobjects, textobjects = pcall(require, "nvim-treesitter-textobjects")

      if ok_textobjects then
        textobjects.setup({
          select = {
            lookahead = true,

            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "<c-v>",
            },

            include_surrounding_whitespace = true,
          },
        })

        local select = require("nvim-treesitter-textobjects.select")

        vim.keymap.set({ "x", "o" }, "af", function()
          select.select_textobject("@function.outer", "textobjects")
        end, { desc = "Select outer function" })

        vim.keymap.set({ "x", "o" }, "if", function()
          select.select_textobject("@function.inner", "textobjects")
        end, { desc = "Select inner function" })

        vim.keymap.set({ "x", "o" }, "ac", function()
          select.select_textobject("@class.outer", "textobjects")
        end, { desc = "Select outer class" })

        vim.keymap.set({ "x", "o" }, "ic", function()
          select.select_textobject("@class.inner", "textobjects")
        end, { desc = "Select inner class" })

        vim.keymap.set({ "x", "o" }, "as", function()
          select.select_textobject("@local.scope", "locals")
        end, { desc = "Select language scope" })
      else
        vim.schedule(function()
          vim.notify(
            "Treesitter textobjects skipped: plugin not available",
            vim.log.levels.INFO,
            { title = "Treesitter" }
          )
        end)
      end
    end,
  },
}
