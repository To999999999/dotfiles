return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",

    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      local missing = {}

      local has_rg = vim.fn.executable("rg") == 1
      local has_fd = vim.fn.executable("fd") == 1
      local has_make = vim.fn.executable("make") == 1
      local has_compiler =
        vim.fn.executable("cc") == 1
        or vim.fn.executable("gcc") == 1
        or vim.fn.executable("clang") == 1

      if not has_rg then
        table.insert(missing, "ripgrep / rg")
      end

      if not has_fd then
        table.insert(missing, "fd")
      end

      if not has_make then
        table.insert(missing, "make / gnumake")
      end

      if not has_compiler then
        table.insert(missing, "C compiler")
      end

      if #missing > 0 then
        vim.schedule(function()
          vim.notify(
            "Telescope: some features may be unavailable. Missing: " .. table.concat(missing, ", "),
            vim.log.levels.INFO,
            { title = "Telescope" }
          )
        end)
      end

      telescope.setup({
        defaults = {
          path_display = { "truncate" },

          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
      })

      local ok_fzf = pcall(telescope.load_extension, "fzf")

      if not ok_fzf then
        vim.schedule(function()
          vim.notify(
            "Telescope: fzf-native unavailable, using default sorter",
            vim.log.levels.INFO,
            { title = "Telescope" }
          )
        end)
      end

      local keymap = vim.keymap

      keymap.set("n", "<leader>ff", builtin.find_files, {
        desc = "Fuzzy find files in cwd",
      })

      if has_rg then
        keymap.set("n", "<leader>fg", builtin.live_grep, {
          desc = "Find string in cwd",
        })

        keymap.set("n", "<leader>fs", builtin.grep_string, {
          desc = "Find string under cursor in cwd",
        })
      else
        keymap.set("n", "<leader>fg", function()
          vim.notify("Telescope live_grep needs ripgrep / rg", vim.log.levels.INFO, { title = "Telescope" })
        end, {
          desc = "Find string in cwd",
        })

        keymap.set("n", "<leader>fs", function()
          vim.notify("Telescope grep_string needs ripgrep / rg", vim.log.levels.INFO, { title = "Telescope" })
        end, {
          desc = "Find string under cursor in cwd",
        })
      end

      keymap.set("n", "<leader>fr", builtin.oldfiles, {
        desc = "Fuzzy find recent files",
      })

      keymap.set("n", "<leader>fb", builtin.buffers, {
        desc = "Fuzzy find open buffers",
      })

      keymap.set("n", "<leader>fh", builtin.help_tags, {
        desc = "Search help",
      })

      keymap.set("n", "<leader>fk", builtin.keymaps, {
        desc = "Search keymaps",
      })

      keymap.set("n", "<leader>fd", builtin.diagnostics, {
        desc = "Search diagnostics",
      })

      keymap.set("n", "<leader>sr", builtin.resume, {
        desc = "Resume last Telescope search",
      })

      keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, {
        desc = "Search in open files",
      })

      keymap.set("n", "<leader>sn", function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
        })
      end, {
        desc = "Search Neovim files",
      })
    end,
  },
}
