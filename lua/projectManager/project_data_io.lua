-- Needed functionalities
-- change task display to only name
-- and create a 'Task Details' window, entered with enter
-- just like the project display
--
-- deleting comments and tasks
-- editing comments and tasks and changing priorities and statuses, no idea how to do it
-- Auto open project named like the top directory of cwd
-- CreateProject command with no args creates a project named like top folder of cwd
-- Changing the working directory with vim.cmd('cd asdf') after selecting a project and clicking something like g
-- Maybe do the highlights not really important tho

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

return data_io
