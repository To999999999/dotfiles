------------------------------------------------------------
-- Module
------------------------------------------------------------

local plugin_build = {}

------------------------------------------------------------
-- Plugin path helpers
------------------------------------------------------------

local function get_pack_plugin_path(name)
	for _, plugin in ipairs(vim.pack.get()) do
		if plugin.spec and plugin.spec.name == name then
			return plugin.path
		end

		if plugin.path and plugin.path:match("/" .. name .. "$") then
			return plugin.path
		end
	end

	return nil
end

------------------------------------------------------------
-- Telescope fzf-native helpers
------------------------------------------------------------

local function telescope_fzf_is_built(path)
	return path and vim.fn.filereadable(path .. "/build/libfzf.so") == 1
end

function plugin_build.build_telescope_fzf_sync()
	local path = get_pack_plugin_path("telescope-fzf-native.nvim")

	if not path then
		return false
	end

	if telescope_fzf_is_built(path) then
		return true
	end

	vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO, {
		title = "Neovim plugins",
	})

	local result = vim.system({ "make" }, { cwd = path }):wait()

	if result.code == 0 then
		vim.notify("Built telescope-fzf-native successfully", vim.log.levels.INFO, {
			title = "Neovim plugins",
		})
		return true
	end

	vim.notify(
		"Failed to build telescope-fzf-native:\n" .. (result.stderr or ""),
		vim.log.levels.ERROR,
		{ title = "Neovim plugins" }
	)

	return false
end

local function build_telescope_fzf_async(path)
	if not path or telescope_fzf_is_built(path) then
		return
	end

	vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO, {
		title = "Neovim plugins",
	})

	vim.system({ "make" }, { cwd = path }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("Built telescope-fzf-native successfully", vim.log.levels.INFO, {
					title = "Neovim plugins",
				})
			else
				vim.notify(
					"Failed to build telescope-fzf-native:\n" .. (result.stderr or ""),
					vim.log.levels.ERROR,
					{ title = "Neovim plugins" }
				)
			end
		end)
	end)
end

------------------------------------------------------------
-- Plugin build hooks
------------------------------------------------------------

function plugin_build.setup()
	local plugin_build_group = vim.api.nvim_create_augroup("PluginBuildHooks", {
		clear = true,
	})

	vim.api.nvim_create_autocmd("PackChanged", {
		group = plugin_build_group,
		callback = function(event)
			local data = event.data or {}

			if not data.spec or not data.spec.name then
				return
			end

			if data.spec.name == "telescope-fzf-native.nvim" and (data.kind == "install" or data.kind == "update") then
				build_telescope_fzf_async(data.path)
			end
		end,
	})
end

------------------------------------------------------------
-- Module
------------------------------------------------------------

return plugin_build
