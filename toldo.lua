---[===[ Dependencies
local path = require("pl.path")
local argparse = require("argparse")
---]===]

-- function to get this folder from any pwd path
local function get_script_path()
	local script_dir = path.dirname(_G.arg[0])
	if #script_dir == 0 then
		script_dir = "./"
	end
	return script_dir
end

-- Adding this path to the package.path to handle requires
THIS_DIR = get_script_path()

-- Adding dep (dependencies) folder
package.path = THIS_DIR .. "/dep/?.lua;" .. THIS_DIR .. "/dep/?/init.lua;" .. package.path
-- Adding lib (libraries) folder
package.path = THIS_DIR .. "/lib/?.lua;" .. THIS_DIR .. "/lib/?/init.lua;" .. package.path

local parser = argparse():name("toldo"):description("Todo list with lua.")

local Models = require("models")
local flatdb = require("flatdb")
local db = flatdb(THIS_DIR .. "/db")

-- Gen a CategoryManager Instance
local CategoryManager = Models.CategoryManager(db)()


--[=[
CategoryManager:add_category("test")
CategoryManager:list_categories()
CategoryManager:rm_category("test")
CategoryManager:list_categories()
local ci, ct = CategoryManager:get_category("Default")
print(ci, ct.name)
ct:rm_task(1)
ct:add_task("ok")
ct:list_tasks()
--]=]

---[====[ cli commands


parser:command_target("command")

common_option_cat = { "-c --category", "To specify the category. (instead of Default)" }
common_argument_index = { "index", "Index of the task (use `toldo list` to get the task index)." }
local cmds = {
	add = {
		text = "add",
		summary = "Add a new task.",
		call = function(args) print("Add") end,
		arguments = {
			{ "content", 'The task content text. (between " ")' }
		},
		options = {
			common_option_cat,
		},
		flags = {},
	},
	list = {
		text = "list",
		summary = "List all tasks.",
		call = function(args) print("List") end,
		arguments = {},
		options = {
			common_option_cat,
		},
		flags = {
			{ "-C --categories", "List from All categories" },
		},
	},
	rm = {
		text = "rm",
		summary = "Remove a task.",
		call = function(args) print("Remove") end,
		arguments = {
			common_argument_index,
		},
		options = {
			common_option_cat,
		},
		flags = {},
	},
	check = {
		text = "check",
		summary = "Check a task.",
		call = function(args) print("Check") end,
		arguments = {
			common_argument_index,
		},
		options = {
			common_option_cat,
		},
		flags = {},
	},
	edit = {
		text = "edit",
		summary = "Edit a task.",
		call = function(args) print("Edit") end,
		arguments = {
			common_argument_index,
			{ "content", "The new content of the task." }
		},
		options = {
			common_option_cat,
		},
		flags = {},
	},
}

for k, cmd in pairs(cmds) do
	local parser_cmd = parser:command(cmd.text):summary(cmd.summary)
	for k, argument in ipairs(cmd.arguments) do
		parser_cmd:argument(unpack(argument))
	end
	for k, option in ipairs(cmd.options) do
		parser_cmd:option(unpack(option))
	end
	for k, flag in ipairs(cmd.flags) do
		parser_cmd:flag(unpack(flag))
	end
end


--]====]

-- ARGS variable
local args = parser:parse()



local active_command = args.command
for k, v in pairs(cmds) do
	if active_command == v.text then
		v.call(args)
	end
end
