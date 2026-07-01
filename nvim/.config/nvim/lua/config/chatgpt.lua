------------------------------------------------------------
-- Lazy loading state
------------------------------------------------------------

local loaded = false

------------------------------------------------------------
-- ChatGPT commands to wrap
------------------------------------------------------------

local wrapper_commands = {
	"ChatGPT",
	"ChatGPTCompleteCode",
	"ChatGPTRun",
	"ChatGPTEditWithInstructions",
}

------------------------------------------------------------
-- Load ChatGPT.nvim
------------------------------------------------------------

local function load_chatgpt()
	if loaded then
		return
	end

	-- Remove temporary wrapper commands so the real plugin commands can be used.
	for _, command in ipairs(wrapper_commands) do
		pcall(vim.api.nvim_del_user_command, command)
	end

	-- Load ChatGPT.nvim and its dependencies.
	vim.cmd.packadd("nui.nvim")
	vim.cmd.packadd("trouble.nvim")
	vim.cmd.packadd("ChatGPT.nvim")

	local home = vim.fn.expand("$HOME")

	require("chatgpt").setup({
		api_key_cmd = "gpg --decrypt " .. home .. "/.config/nvim/chatGPT_API_key.txt.gpg",
	})

	loaded = true
end

------------------------------------------------------------
-- Run ChatGPT command
------------------------------------------------------------

local function run_chatgpt_command(command, opts)
	load_chatgpt()

	local command_opts = {
		cmd = command,
		bang = opts.bang,
		args = opts.fargs,
	}

	if opts.range and opts.range > 0 then
		command_opts.range = { opts.line1, opts.line2 }
	end

	vim.api.nvim_cmd(command_opts, {})
end

------------------------------------------------------------
-- Lazy wrapper commands
------------------------------------------------------------

for _, command in ipairs(wrapper_commands) do
	vim.api.nvim_create_user_command(command, function(opts)
		run_chatgpt_command(command, opts)
	end, {
		bang = true,
		nargs = "*",
		range = true,
	})
end

------------------------------------------------------------
-- Keymap helper
------------------------------------------------------------

local function chatgpt_keymap(lhs, command, args, description)
	vim.keymap.set("n", lhs, function()
		run_chatgpt_command(command, {
			bang = false,
			fargs = args or {},
			range = 0,
		})
	end, { desc = description })
end

------------------------------------------------------------
-- ChatGPT keymaps
------------------------------------------------------------

chatgpt_keymap("<leader>aa", "ChatGPT", {}, "Open ChatGPT")
chatgpt_keymap("<leader>ac", "ChatGPTCompleteCode", {}, "Complete code with ChatGPT")
chatgpt_keymap("<leader>at", "ChatGPTRun", { "add_tests" }, "Create tests with ChatGPT")
chatgpt_keymap("<leader>ae", "ChatGPTRun", { "explain_code" }, "Explain code with ChatGPT")
chatgpt_keymap("<leader>af", "ChatGPTRun", { "fix_bugs" }, "Fix bugs with ChatGPT")
chatgpt_keymap("<leader>ad", "ChatGPTRun", { "docstring" }, "Create docstring with ChatGPT")
chatgpt_keymap("<leader>ao", "ChatGPTRun", { "optimize_code" }, "Optimize code with ChatGPT")
chatgpt_keymap("<leader>as", "ChatGPTRun", { "summarize" }, "Summarize with ChatGPT")
chatgpt_keymap("<leader>aT", "ChatGPTRun", { "translate" }, "Translate with ChatGPT")
chatgpt_keymap("<leader>ai", "ChatGPTEditWithInstructions", {}, "Edit with instructions with ChatGPT")
