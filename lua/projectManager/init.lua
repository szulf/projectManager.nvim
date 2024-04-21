local M = {}
local data_io = require('projectManager.project_data_io')
local gui_builder = require('projectManager.gui_builder')
local command_builder = require('projectManager.command_builder')

function M.setup(opts)
	local opt = opts or {}

	vim.keymap.set("n", "<leader>h", function()
		if opt.name then
			print("hello, " .. opt.name)
		else
			print("hello")
		end
	end)
end

data_io.init()
gui_builder.init()
command_builder.init()

return M
