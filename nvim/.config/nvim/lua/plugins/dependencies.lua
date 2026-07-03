------------------------------------------------------------
-- Module
------------------------------------------------------------

local dependencies = {}

------------------------------------------------------------
-- Missing dependency notifications
------------------------------------------------------------

local pending_missing_notifications = {}

local function notify_missing(group, missing)
	table.insert(pending_missing_notifications, {
		group = group,
		missing = missing,
	})
end

function dependencies.flush_missing_notifications()
	vim.schedule(function()
		for _, item in ipairs(pending_missing_notifications) do
			vim.notify(
				"Skipping " .. item.group .. ". Missing: " .. table.concat(item.missing, ", "),
				vim.log.levels.WARN,
				{ title = "Neovim plugins" }
			)
		end

		pending_missing_notifications = {}
	end)
end

------------------------------------------------------------
-- Dependency checks
------------------------------------------------------------

function dependencies.check(group, required_commands)
	local missing = {}

	for _, command in ipairs(required_commands) do
		if type(command) == "string" then
			if vim.fn.executable(command) ~= 1 then
				table.insert(missing, command)
			end
		else
			local found = false

			for _, candidate in ipairs(command) do
				if vim.fn.executable(candidate) == 1 then
					found = true
					break
				end
			end

			if not found then
				table.insert(missing, table.concat(command, " | "))
			end
		end
	end

	if #missing > 0 then
		notify_missing(group, missing)
		return false
	end

	return true
end

------------------------------------------------------------
-- Module
------------------------------------------------------------

return dependencies
