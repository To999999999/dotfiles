------------------------------------------------------------
-- Plugin modules
------------------------------------------------------------

local dependencies = require("plugins.dependencies")
local plugin_build = require("plugins.plugin_build")
local plugin_specs = require("plugins.plugin_specs")

------------------------------------------------------------
-- Pack options
------------------------------------------------------------

local pack_opts = {
	load = true,
	confirm = false,
}

local dynamic_pack_opts = {
	load = function() end,
	confirm = false,
}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local added_plugins = {}

local function get_plugin_key(plugin)
	return plugin.src or plugin.name
end

local function add_group(enabled, plugins, opts)
	if not enabled then
		return
	end

	local plugins_to_add = {}

	for _, plugin in ipairs(plugins) do
		local key = get_plugin_key(plugin)

		if key and not added_plugins[key] then
			table.insert(plugins_to_add, plugin)
			added_plugins[key] = true
		end
	end

	if #plugins_to_add > 0 then
		vim.pack.add(plugins_to_add, opts)
	end
end

------------------------------------------------------------
-- Plugin build hooks
------------------------------------------------------------

plugin_build.setup()

------------------------------------------------------------
-- Shared dependencies
------------------------------------------------------------

local shared_dependencies_available = dependencies.check("Shared dependency plugins", {
	"git",
})

add_group(shared_dependencies_available, plugin_specs.dependency_plugins, pack_opts)

------------------------------------------------------------
-- UI
------------------------------------------------------------

add_group(true, plugin_specs.ui_plugins, pack_opts)
require("config.ui")

------------------------------------------------------------
-- Misc
------------------------------------------------------------

add_group(true, plugin_specs.misc_plugins, pack_opts)
require("config.misc")

------------------------------------------------------------
-- Files
------------------------------------------------------------

add_group(true, plugin_specs.file_plugins, pack_opts)
require("config.files")

------------------------------------------------------------
-- Git
------------------------------------------------------------

local git_available = dependencies.check("Git plugins", {
	"git",
})

add_group(git_available, plugin_specs.git_plugins, pack_opts)

if git_available then
	require("config.git")
end

------------------------------------------------------------
-- Telescope
------------------------------------------------------------

local telescope_available = dependencies.check("Telescope plugins", {
	"git",
	"rg",
	"fd",
	"make",
	{ "gcc", "cc", "clang" },
})

add_group(telescope_available, plugin_specs.telescope_plugins, pack_opts)

if telescope_available then
	plugin_build.build_telescope_fzf_sync()
	require("config.telescope")
end

------------------------------------------------------------
-- Treesitter
------------------------------------------------------------

local treesitter_available = dependencies.check("Treesitter plugins", {
	"git",
	"curl",
	"tar",
	"tree-sitter",
	{ "gcc", "cc", "clang" },
})

add_group(treesitter_available, plugin_specs.treesitter_plugins, pack_opts)

if treesitter_available then
	require("config.treesitter")
end

------------------------------------------------------------
-- Completion
------------------------------------------------------------

local completion_available = dependencies.check("Completion plugins", {
	"git",
	"curl",
})

add_group(completion_available, plugin_specs.completion_plugins, pack_opts)

if completion_available then
	require("config.completion")
end

------------------------------------------------------------
-- LSP
------------------------------------------------------------

local lsp_available = dependencies.check("LSP plugins", {
	"git",
	{ "curl", "wget" },
	"unzip",
	"tar",
	"gzip",
})

add_group(lsp_available, plugin_specs.lsp_plugins, pack_opts)

if lsp_available then
	require("config.lsp")
end

------------------------------------------------------------
-- AI
------------------------------------------------------------

local ai_available = dependencies.check("AI plugins", {
	"git",
	"opencode",
})

add_group(ai_available, plugin_specs.ai_plugins, pack_opts)

if ai_available then
	require("config.ai")
end

------------------------------------------------------------
-- ChatGPT
------------------------------------------------------------

local chatgpt_available = dependencies.check("ChatGPT plugins", {
	"git",
	"curl",
})

add_group(chatgpt_available, plugin_specs.chatgpt_plugins, dynamic_pack_opts)

if chatgpt_available then
	require("config.chatgpt")
end

------------------------------------------------------------
-- Missing dependency notifications
------------------------------------------------------------

dependencies.flush_missing_notifications()
