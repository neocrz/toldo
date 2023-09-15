local argparse = require("argparse")

local parser = argparse():name("toldo"):description("Todo list with lua.")

local path = require("pl.path")

INIT_DIR = path.dirname(arg[0])
if #INIT_DIR == 0 then
	INIT_DIR = "./"
end
package.path = package.path .. ";" .. INIT_DIR .. "/dep/?.lua;"

local flatdb = require("flatdb")

local db = flatdb(INIT_DIR .. "/db")

if not db.todos then
	db.todos = {}
end

-- CHECK IS A CATEGORY EXISTS, IF NOT, ADD IT
local function create_category(tb)
	if not db.todos[tb] then
		db.todos[tb] = {}
		db.todos[tb].__name = tb
	end
end

-- CHECK IS A CATEGORY IS IN DB
local function category_exists(tb)
	if db.todos[tb] then
		return true
	end
	return false
end

local function list_categories()
	for k, v in pairs(db.todos) do
		if v.__name then
			print(k)
		end
	end
end

-- DEFAULT CATEGORY NAME
local DEFAULT_CT = "_MAIN"
create_category(DEFAULT_CT)
db:save()

local function add_todo(content, _)
	local tb = _ or {}
	local category = tb.category or DEFAULT_CT
	local priority = tb.priority or 1

	create_category(category)

	local todo = {
		content = content,
		check = false,
		priority = priority,
	}

	table.insert(db.todos[category], todo)

	db:save()
end

local function list_todos(_)
	local category = _ or DEFAULT_CT

	if not category_exists(category) then
		print("The category '" .. category .. "' does not exists.")
		return false
	end

	category = db.todos[category]
	print(category.__name)
	for k, v in ipairs(category) do
		local check = ""
		if v.check then
			check = " [x] -> "
		else
			check = " [ ] -> "
		end
		print(tostring(k) .. check .. v.content)
	end
end

local function rm_todo(idx, _)
	local tb = _ or DEFAULT_CT
	local index = tonumber(idx)

	if category_exists(tb) then
		local todo = db.todos[tb][index]
		if todo then
			table.remove(db.todos[tb], index)
		else
			print("The index '" .. idx .. "' does not exist in this category.")
		end
	else
		print("Category '" .. tb .. "' does not exists.")
	end

	db:save()
end

local function check_todo(idx, _)
	local tb = _ or DEFAULT_CT
	local index = tonumber(idx)

	if category_exists(tb) then
		local todo = db.todos[tb][index]

		if todo then
			todo.check = not todo.check
		else
			print("The index '" .. idx .. "' does not exist in this category.")
		end
	else
		print("Category '" .. tb .. "' does not exists.")
	end
	db:save()
end
local function edit_todo(idx, _, content)
	local tb = _ or DEFAULT_CT
	local index = tonumber(idx)

	if category_exists(tb) then
		local todo = db.todos[tb][index]
		if todo then
			todo.content = content or ""
		else
			print("The index '" .. idx .. "' does not exist in this category.")
		end
	else
		print("Category '" .. tb .. "' does not exists.")
	end

	db:save()
end
---[====[ cli commands
local add_cmd = parser:command("add"):summary("Add a task.")
add_cmd:option("-c --category", "To specify the category, without it, task will be added to the default category.")
add_cmd:argument("text", 'The task text. between " "'):args(1)

local list_cmd = parser:command("list"):summary("Lists all the tasks from a category.")
list_cmd:option("-c --category", "To specify another category instead of the default one.")
list_cmd:flag("-C --categories", "List categories")

local rm_cmd = parser:command("rm"):summary("Remove a task.")
rm_cmd:option(
	"-c --category",
	"To specify the category. Without it, the task from the default category with the index will be removed."
)
rm_cmd:argument("index", "Index of the task (use toldo list to get the task indexes).")

local check_cmd = parser:command("check"):summary("Check or uncheck a task.")
check_cmd:option("-c --category", "to specify a category instead of the default one.")
check_cmd:argument("index", "index of the task (use toldo list to get the task's indexes).")

local edit_cmd = parser:command("edit"):summary("Edit a task.")
edit_cmd:option("-c --category", "to specify a category instead of the default one.")
edit_cmd:argument("index", "Index of the task (use toldo list to get the task's indexes).")
edit_cmd:argument("content", "The new content of the task.")
--]====]

-- ARGS variable
local args = parser:parse()

local function print_no_category()
	print("Category does not exists")
end

if args.add then
	if args.category then
		if not category_exists(args.category) then
			print_no_category()
			return false
		end
	end
	if not args.text then
		print("Please provide a task text")
		return false
	end
	add_todo(args.text, args.category)
elseif args.list then
	if args.categories then
		return list_categories()
	end
	if args.category then
		if not category_exists(args.category) then
			print_no_category()
			return false
		end
	end

	list_todos(args.category)
elseif args.rm then
	if args.category then
		if not category_exists(args.category) then
			print_no_category()
			return false
		end
	end

	local index = tonumber(args.index)
	if not index then
		print("Please give me a valid number for the todo index.")
		return false
	end
	rm_todo(args.index, args.category)
elseif args.check then
	if args.category then
		if not category_exists(args.category) then
			print_no_category()
			return false
		end
	end

	local index = tonumber(args.index)
	if not index then
		print("Please give me a valid number for the todo index.")
		return false
	end

	check_todo(index, args.category)
elseif args.edit then
	if args.category then
		if not category_exists(args.category) then
			print_no_category()
			return false
		end
	end

	local index = tonumber(args.index)
	if not index then
		print("Please give me a valid number for the todo index.")
		return false
	end
	edit_todo(args.index, args.category, args.content)
end
