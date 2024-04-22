-- Needed functionalities
-- Adding and deleting projects from gui
-- and changing task name in the 'Project List' window
--
-- Auto open project named like the top directory of cwd
-- CreateProject command with no args creates a project named like top folder of cwd
-- Changing the working directory with vim.cmd('cd asdf') after selecting a project and clicking something like g
--
-- Create a help window thats gonna show all bindings
-- I feel like i will forget half the keybinds by the time i get to this but fuck it
--
-- Maybe do the highlights not really important tho
-- Maybe but really maybe make those keybinds rebindable

local dkjson = require('dkjson')

local path = os.getenv('HOME') .. '/projects.json'

local data_io = {}

local function file_exists(filepath)
	local f = io.open(filepath, 'r')
	if f ~= nil then io.close(f) return true else return false end
end

function data_io.init()
	if not file_exists(path) then
		local file, err = io.open(path, 'w')
		if err or file == nil then return err end
		local projects = {}

		file:write(dkjson.encode(projects, { indent = false }))
		io.close(file)
	end

	return nil
end

function data_io.get_all_projects()
	local file, err = io.open(path, 'r')
	if err or file == nil then return nil, err end
	local str = file:read()
	io.close(file)

	local projects, _, err = dkjson.decode(str)
	if err or projects == nil then return nil, err end

	return projects, nil
end

function data_io.get_project_by_id(project_id)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return nil, err end
	return projects[project_id], nil
end

function data_io.add_project(name, priority)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local file, err = io.open(path, 'w')
	if err or file == nil then return err end

	local project = {
		name = name,
		priority = priority,
		status = 0,
		comments = {},
		tasks = {},
	}
	table.insert(projects, project)
	file:write(dkjson.encode(projects, { indent = false }))

	io.close(file)
end

function data_io.add_comment(project_id, comment)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local file, err = io.open(path, 'w')
	if err or file == nil then return err end

	table.insert(projects[project_id].comments, comment)
	file:write(dkjson.encode(projects, { indent = false }))

	io.close(file)
end

function data_io.add_task(project_id, task)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local file, err = io.open(path, 'w')
	if err or file == nil then return err end

	table.insert(projects[project_id].tasks, task)
	file:write(dkjson.encode(projects, { indent = false }))

	io.close(file)
end

function data_io.remove_comment(project_id, comment_id)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local file, err = io.open(path, 'w')
	if err or file == nil then return err end

	table.remove(projects[project_id].comments, comment_id)
	file:write(dkjson.encode(projects, { indent = false }))

	io.close(file)
end

function data_io.remove_task(project_id, task_id)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return err end
	local file, err = io.open(path, 'w')
	if err or file == nil then return err end

	table.remove(projects[project_id].tasks, task_id)
	file:write(dkjson.encode(projects, { indent = false }))

	io.close(file)
end

function data_io.get_task_by_id(project_id, task_id)
	local projects, err = data_io.get_all_projects()
	if err or projects == nil then return nil, err end

	return projects[project_id].tasks[task_id], nil
end

data_io.edit = {
	name = function(project_id, new_name)
		local projects, err = data_io.get_all_projects()
		if err or projects == nil then return err end
		local file, err = io.open(path, 'w')
		if err or file == nil then return err end

		projects[project_id].name = new_name
		file:write(dkjson.encode(projects, { indent = false }))

		io.close(file)
	end,
	priority = function(project_id, new_priority)
		local projects, err = data_io.get_all_projects()
		if err or projects == nil then return err end
		local file, err = io.open(path, 'w')
		if err or file == nil then return err end

		projects[project_id].priority = new_priority
		file:write(dkjson.encode(projects, { indent = false }))

		io.close(file)
	end,
	status = function(project_id, new_status)
		local projects, err = data_io.get_all_projects()
		if err or projects == nil then return err end
		local file, err = io.open(path, 'w')
		if err or file == nil then return err end

		projects[project_id].status = new_status
		file:write(dkjson.encode(projects, { indent = false }))

		io.close(file)
	end,
	comment = function(project_id, comment_id, new_comment)
		local projects, err = data_io.get_all_projects()
		if err or projects == nil then return err end
		local file, err = io.open(path, 'w')
		if err or file == nil then return err end

		projects[project_id].comments[comment_id] = new_comment
		file:write(dkjson.encode(projects, { indent = false }))

		io.close(file)
	end,
	task = {
		name = function(project_id, task_id, new_name)
			local projects, err = data_io.get_all_projects()
			if err or projects == nil then return err end
			local file, err = io.open(path, 'w')
			if err or file == nil then return err end

			projects[project_id].tasks[task_id].name = new_name
			file:write(dkjson.encode(projects, { indent = false }))

			io.close(file)
		end,
		priority = function(project_id, task_id, new_priority)
			local projects, err = data_io.get_all_projects()
			if err or projects == nil then return err end
			local file, err = io.open(path, 'w')
			if err or file == nil then return err end

			projects[project_id].tasks[task_id].priority = new_priority
			file:write(dkjson.encode(projects, { indent = false }))

			io.close(file)
		end,
		status = function(project_id, task_id, new_status)
			local projects, err = data_io.get_all_projects()
			if err or projects == nil then return err end
			local file, err = io.open(path, 'w')
			if err or file == nil then return err end

			projects[project_id].tasks[task_id].status = new_status
			file:write(dkjson.encode(projects, { indent = false }))

			io.close(file)
		end,
		desc = function(project_id, task_id, new_desc)
			local projects, err = data_io.get_all_projects()
			if err or projects == nil then return err end
			local file, err = io.open(path, 'w')
			if err or file == nil then return err end

			projects[project_id].tasks[task_id].desc = new_desc
			file:write(dkjson.encode(projects, { indent = false }))

			io.close(file)
		end,
	},
}

return data_io
