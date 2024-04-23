local data_io = require('projectManager.project_data_io')

local gui_builder = {}
gui_builder.window_type = nil
gui_builder.chosen_project_id = nil
gui_builder.chosen_task_id = nil

local win, buf

local function get_projects_string()
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return nil, err end
	local to_display = {}

	for _, v in ipairs(projects) do
		table.insert(to_display, string.format('%s', v.name))
	end

	return to_display, nil
end

local function get_project_string_by_id(project_id)
	local project, err = data_io.get_project_by_id(project_id)
	if err or project == nil then return nil, err end
	local to_display = {}

	table.insert(to_display, string.format('Name: %s', project.name))
	table.insert(to_display, string.format('Priority: %s', project.priority))
	table.insert(to_display, string.format('Status: %s', project.status))
	table.insert(to_display, 'Comments:')
	for _, v in ipairs(project.comments) do
		table.insert(to_display, string.format('\t%s', v))
	end

	table.insert(to_display, 'Tasks:')
	for _, v in ipairs(project.tasks) do
		table.insert(to_display, string.format('\t%s', v.name))
	end

	return to_display, nil
end

local function get_task_string_by_id(task_id)
	local task, err = data_io.get_task_by_id(gui_builder.chosen_project_id, task_id)
	if err or task == nil then return nil, err end
	local to_display = {}

	table.insert(to_display, string.format('Name: %s', task.name))
	table.insert(to_display, string.format('Priority: %s', task.priority))
	table.insert(to_display, string.format('Status: %s', task.status))
	table.insert(to_display, string.format('Description: %s', task.desc))

	return to_display, nil
end

local function center(str)
	local width = vim.api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(' ', shift) .. str
end

local function get_current_project_name()
	local cwd, _, err = vim.loop.cwd()
	if cwd == nil then return nil, err end
	local slash_position = string.find(string.reverse(cwd), '/')
	if slash_position == nil then return nil, nil end
	local curr_project = string.sub(cwd, slash_position + 1)
	return curr_project
end

function gui_builder.init()

end

function gui_builder.close_window()
	vim.api.nvim_win_close(win, true)
	win = nil
end

function gui_builder.build_window()
	if win and vim.api.nvim_win_is_valid(win) then
		gui_builder.close_window()
	end
	buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

	local width = vim.api.nvim_get_option('columns')
	local height = vim.api.nvim_get_option('lines')

	local win_width = math.ceil(width * 0.6)
	local win_height = math.ceil(height * 0.8 - 4)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local opts = {
		style = 'minimal',
		relative = 'editor',
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	local border_opts = {
		style = 'minimal',
		relative = 'editor',
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local border_buf = vim.api.nvim_create_buf(false, true)
	local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
	local middle_line = '║' .. string.rep(' ', win_width) .. '║'
	for _ = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

	vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	-- local border_win = vim.api.nvim_open_win(border_buf, true, border_opts)
	vim.api.nvim_open_win(border_buf, true, border_opts)
	win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	-- dont know why doesnt work
	-- fix later
	-- vim.api.nvim_buf_set_option(buf, 'cursorlineopt', 'line')
end

function gui_builder.render_all_projects()
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		center('Project List'),
		'',
		string.rep('═', vim.api.nvim_win_get_width(0)),
	})

	local to_display, err = get_projects_string()
	if err or to_display == nil then return end
	local list = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for _, v in ipairs(to_display) do
		table.insert(list, v)
	end

	if list == nil then
		vim.api.nvim_buf_set_option(buf, 'modifiable', false)
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	gui_builder.set_mappings_list()
end

function gui_builder.render_project_by_id(project_id)
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		center('Project Details'),
		'',
		string.rep('═', vim.api.nvim_win_get_width(0)),
	})

	local to_display, err = get_project_string_by_id(project_id)
	if err or to_display == nil then return end
	local list = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for _, v in ipairs(to_display) do
		table.insert(list, v)
	end

	if list == nil then
		vim.api.nvim_buf_set_option(buf, 'modifiable', false)
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	gui_builder.set_mappings_details()
end

function gui_builder.render_task_by_id(task_id)
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		center('Task Details'),
		'',
		string.rep('═', vim.api.nvim_win_get_width(0)),
	})

	local to_display, err = get_task_string_by_id(task_id)
	if err or to_display == nil then return end
	local list = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for _, v in ipairs(to_display) do
		table.insert(list, v)
	end

	if list == nil then
		vim.api.nvim_buf_set_option(buf, 'modifiable', false)
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	gui_builder.set_mappings_tasks()
end

function gui_builder.set_mappings_list()
	local mappings = {
		['<cr>'] = 'open_project_details_win()',
		c = 'create_project()',
		d = 'remove_project()', -- not implemented yet
		r = 'rename_project()', -- not implemented yet
		q = 'close_window()',
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("projectManager.gui_builder").' .. v .. '<cr>', { nowait = true, noremap = true, silent = true })
	end
end

function gui_builder.set_mappings_details()
	local mappings = {
		['<cr>'] = 'open_task_details_win()',
		['<BS>'] = 'open_project_list_win()',
		c = 'decide_comment_task_creation()',
		d = 'decide_comment_task_removal()',
		r = 'change_property_details()',
		q = 'close_window()',
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("projectManager.gui_builder").' .. v .. '<cr>', { nowait = true, noremap = true, silent = true })
	end
end

function gui_builder.set_mappings_tasks()
	local mappings = {
		['<BS>'] = string.format('open_project_details_win_by_id(%s)', gui_builder.chosen_project_id),
		r = 'change_property_task()',
		q = 'close_window()',
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("projectManager.gui_builder").' .. v .. '<cr>', { nowait = true, noremap = true, silent = true })
	end
end

function gui_builder.open_project_list_win()
	gui_builder.build_window()
	gui_builder.render_all_projects()
end

function gui_builder.open_project_details_win()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	if row <= 3 then
		print('Please select a valid line')
		return
	end
	local project_id = row - 3

	gui_builder.close_window()
	gui_builder.build_window()
	gui_builder.render_project_by_id(project_id)
	gui_builder.chosen_project_id = project_id
end

function gui_builder.open_project_details_win_by_id(project_id)
	gui_builder.build_window()
	gui_builder.render_project_by_id(project_id)
end

function gui_builder.open_task_details_win()
	local project, err = data_io.get_project_by_id(gui_builder.chosen_project_id)
	if err or project == nil then return err end
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local task_line_number = #project.comments + 8
	if row <= task_line_number then
		print('Please select a valid line')
		return
	end
	local task_id = row - task_line_number

	gui_builder.close_window()
	gui_builder.build_window()
	gui_builder.render_task_by_id(task_id)
	gui_builder.chosen_task_id = task_id
end

function gui_builder.open_task_details_win_by_id(task_id)
	gui_builder.build_window()
	gui_builder.render_task_by_id(task_id)
end

function gui_builder.open_current_project_win()
	print(get_current_project_name())
	local curr_project_id = data_io.get_project_id_by_name(get_current_project_name())
	if curr_project_id == nil then
		print("Current directory doesn't have a project connected to it")
		return
	end
	gui_builder.build_window()
	gui_builder.render_project_by_id(curr_project_id)
	gui_builder.chosen_project_id = curr_project_id
end

function gui_builder.decide_comment_task_creation()
	if gui_builder.chosen_project_id == nil then return end

	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local comment_line_number = 6
	if row <= comment_line_number then
		print('Please select a valid line')
		return
	end

	local project, err = data_io.get_project_by_id(gui_builder.chosen_project_id)
	if err or project == nil then return err end
	local create_comment
	if row <= #project.comments + comment_line_number then
		create_comment = true
	else
		create_comment = false
	end

	if create_comment then
		vim.ui.input({ prompt = 'Enter content of the comment: ' },
		function(input)
			data_io.add_comment(gui_builder.chosen_project_id, input)
		end)
	else
		local task = {
			name = 'test name',
			desc = 'tesc description',
			priority = 0,
			status = 0
		}
		vim.ui.input({ prompt = 'Enter task name: ' }, function(input)
			task.name = input
		end)
		vim.ui.input({ prompt = 'Enter task description: ' }, function(input)
			task.desc = input
		end)
		vim.ui.input({ prompt = 'Enter task priority: ' }, function(input)
			task.priority = input
		end)
		data_io.add_task(gui_builder.chosen_project_id, task)
	end
	gui_builder.open_project_details_win_by_id(gui_builder.chosen_project_id)
end

function gui_builder.decide_comment_task_removal()
	if gui_builder.chosen_project_id == nil then return end

	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local comment_line_number = 7
	if row <= comment_line_number then
		print('Please select a valid line')
		return
	end

	local project, err = data_io.get_project_by_id(gui_builder.chosen_project_id)
	if err or project == nil then return err end
	if row == #project.comments + comment_line_number + 1 then
		print('Please select a valid line')
		return
	end

	local remove_comment, id
	if row <= #project.comments + comment_line_number then
		remove_comment = true
		id = row - comment_line_number
	elseif row > #project.comments + comment_line_number + 1 then
		remove_comment = false
		id = row - #project.comments - comment_line_number - 1
	end

	local confirm = false
	vim.ui.input({ prompt = 'Are you sure you want to delete this?[(y)es/(n)o]' }, function(input)
		if input == 'y' or input == 'yes' then
			confirm = true
		end
	end)

	if not confirm then
		return
	end

	if remove_comment then
		data_io.remove_comment(gui_builder.chosen_project_id, id)
	else
		data_io.remove_task(gui_builder.chosen_project_id, id)
	end

	gui_builder.open_project_details_win_by_id(gui_builder.chosen_project_id)
end

function gui_builder.change_property_details()
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local name_line_number = 4
	local priority_line_number = 5
	local status_line_number = 6
	local comment_line_number = 7
	local task_line_number = comment_line_number + #projects[gui_builder.chosen_project_id].comments + 1

	if row == name_line_number then
		vim.ui.input({ prompt = 'Enter the new name: ' }, function(input)
			data_io.edit.name(gui_builder.chosen_project_id, input)
		end)
	elseif row == priority_line_number then
		vim.ui.input({ prompt = 'Enter the new priority: ' }, function(input)
			data_io.edit.priority(gui_builder.chosen_project_id, input)
		end)
	elseif row == status_line_number then
		vim.ui.input({ prompt = 'Enter the new status: ' }, function(input)
			data_io.edit.status(gui_builder.chosen_project_id, input)
		end)
	elseif row > comment_line_number and row < task_line_number then
		vim.ui.input({ prompt = 'Enter the new comment: ' }, function(input)
			local comment_id = row - 7
			data_io.edit.comment(gui_builder.chosen_project_id, comment_id, input)
		end)
	else
		print('Please select a vaild line')
		return
	end

	gui_builder.open_project_details_win_by_id(gui_builder.chosen_project_id)
end

function gui_builder.change_property_task()
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local name_line_number = 4
	local priority_line_number = 5
	local status_line_number = 6
	local description_line_number = 7

	if row == name_line_number then
		vim.ui.input({ prompt = 'Enter the new name: ' }, function(input)
			data_io.edit.task.name(gui_builder.chosen_project_id, gui_builder.chosen_task_id, input)
		end)
	elseif row == priority_line_number then
		vim.ui.input({ prompt = 'Enter the new priority: ' }, function(input)
			data_io.edit.task.priority(gui_builder.chosen_project_id, gui_builder.chosen_task_id, input)
		end)
	elseif row == status_line_number then
		vim.ui.input({ prompt = 'Enter the new status: ' }, function(input)
			data_io.edit.task.status(gui_builder.chosen_project_id, gui_builder.chosen_task_id, input)
		end)
	elseif row == description_line_number then
		vim.ui.input({ prompt = 'Enter the new description: ' }, function(input)
			data_io.edit.task.desc(gui_builder.chosen_project_id, gui_builder.chosen_task_id, input)
		end)
	else
		print('Please select a vaild line')
		return
	end

	gui_builder.open_task_details_win_by_id(gui_builder.chosen_task_id)
end

function gui_builder.create_project()
	local name, priority
	vim.ui.input({ prompt = 'Enter the projects name: '}, function(input)
		name = input
	end)
	vim.ui.input({ prompt = 'Enter the projects priority: '}, function(input)
		priority = input
	end)

	data_io.add_project(name, priority)
	gui_builder.open_project_list_win()
end

function gui_builder.remove_project()
	local logo_display_end_line = 3
	local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
	if row <= logo_display_end_line then
		print('Please select a valid line')
		return
	end
	local project_id = row - logo_display_end_line

	vim.ui.input({ prompt = 'Are you sure you want to delete this?[(y)es, (n)o]' }, function(input)
		if input == 'y' or input == 'yes' then
			data_io.remove_project(project_id)
			gui_builder.open_project_list_win()
		end
	end)
end

function gui_builder.rename_project()
	local logo_display_end_line = 3
	local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
	if row <= logo_display_end_line then
		print('Please select a valid line')
		return
	end
	local project_id = row - logo_display_end_line

	vim.ui.input({ prompt = 'Enter projects name: ' }, function(input)
		data_io.edit.name(project_id, input)
	end)
	gui_builder.open_project_list_win()
end

return gui_builder
