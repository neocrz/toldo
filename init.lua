local argparse = require("argparse")
local parser = argparse()
local flatdb = require("flatdb")

local db = flatdb("./db")

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
end

local function mark_todo(idx, _)
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
end

--[[
add_todo("test")
add_todo("test 2")
add_todo("test 3")
list_todos()

rm_todo(2)
list_todos()

mark_todo(2)
list_todos()
rm_todo(2, "ok")
create_category("ok")
add_todo("teste em ok", { category = "ok" })
list_todos("ok")
list_categories()
--]]

local args = parser:parse()
