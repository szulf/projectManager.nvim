local gui_builder = require('projectManager.gui_builder')

local command_builder = {}

function command_builder.init()
	command_builder.build_create_project_cmd()
	command_builder.build_project_list_cmd()
end

function command_builder.build_create_project_cmd()
	vim.api.nvim_create_user_command('CreateProject',
		function()
			gui_builder.create_project()
		end, {})
end

function command_builder.build_project_list_cmd()
	vim.api.nvim_create_user_command('ProjectList',
		function()
			gui_builder.open_project_list_win()
		end, {})
end

return command_builder
