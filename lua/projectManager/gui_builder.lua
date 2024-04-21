local data_io = require('projectManager.project_data_io')

local gui_builder = {}
gui_builder.window_type = nil
gui_builder.chosen_project_id = nil

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
	for i, v in ipairs(project.tasks) do
		table.insert(to_display, string.format('\tName: %s', v.name))
		table.insert(to_display, string.format('\tDescription: %s', v.desc))
		table.insert(to_display, string.format('\tPriority: %s', v.priority))
		table.insert(to_display, string.format('\tStatus: %s', v.status))
		if not (i == #project.tasks) then
			table.insert(to_display, string.rep('-', 15))
		end
	end

	return to_display, nil
end

local function center(str)
	local width = vim.api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(' ', shift) .. str
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

function gui_builder.set_mappings_list()
	local mappings = {
		['<cr>'] = 'open_project_details_window()',
		q = 'close_window()',
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("todolist.gui_builder").' .. v .. '<cr>', { nowait = true, noremap = true, silent = true })
	end
end

function gui_builder.set_mappings_details()
	local mappings = {
		-- might make so that comments and tasks can be folded with control while hovering on then
		-- thats a plan for the future tho
		-- ['<cr>'] = '',
		c = 'decide_comment_task_creation()',
		q = 'close_window()',
	}

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("todolist.gui_builder").' .. v .. '<cr>', { nowait = true, noremap = true, silent = true })
	end
end

function gui_builder.open_project_list_window()
	gui_builder.build_window()
	gui_builder.render_all_projects()
end

function gui_builder.open_project_details_window()
	local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
	if r <= 3 then
		print('Please select a valid line')
		return
	end
	local project_id = r - 3

	gui_builder.close_window()
	gui_builder.build_window()
	gui_builder.render_project_by_id(project_id)
	gui_builder.chosen_project_id = project_id
end

function gui_builder.open_project_details_window_by_id(project_id)
	gui_builder.build_window()
	gui_builder.render_project_by_id(project_id)
end

function gui_builder.decide_comment_task_creation()
	if gui_builder.chosen_project_id == nil then return end
	local val = true
	val = false
	if val then
		vim.ui.input({ prompt = 'Enter the content of the comment: ' }, function(input)
			data_io.add_comment(gui_builder.chosen_project_id, input)
		end)
	else
		local task = {
			name = 'test name',
			desc = 'tesc description',
			priority = 0,
			status = 0
		}
		data_io.add_task(gui_builder.chosen_project_id, task)
	end
	gui_builder.open_project_details_window_by_id(gui_builder.chosen_project_id)
end

return gui_builder
