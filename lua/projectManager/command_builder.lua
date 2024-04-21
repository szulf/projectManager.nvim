local gui_builder = require('projectManager.gui_builder')
local data_io = require('projectManager.project_data_io')

local command_builder = {}

local buf, win

function command_builder.init()
	command_builder.build_create_project_cmd()
	command_builder.build_project_list_cmd()
end

function command_builder.build_create_project_cmd()
	vim.api.nvim_create_user_command('CreateProject',
		function(opts)
			vim.ui.input({ prompt = 'Enter priority of the project: ' }, function(input)
				data_io.add_project(opts.fargs[1], input)
			end)
		end, { nargs = 1 })
end

function command_builder.build_project_list_cmd()
	vim.api.nvim_create_user_command('ProjectList',
		function()
			gui_builder.open_project_list_window()
		end, {})
end

return command_builder
