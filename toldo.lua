-- external Dependencies
local path = require("pl.path")
local argparse = require("argparse")


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



-- Extenal dependency (path based)
local flatdb = require("flatdb")

local Models = require("models")
local parser = argparse():name("toldo"):description("Todo list with lua.")


local db = flatdb(THIS_DIR .. "/db")

-- Gen a CategoryManager Instance
local CategoryManager = Models.CategoryManager(db)()
-- Get command_case functions with what to do
local cmds_functions = require("cmdsf")(CategoryManager, db)




parser:command_target("command")

common_option_cat = { "-c --category", "To specify the category. (instead of Default)" }
common_argument_index = { "index", "Index of the task (use `toldo list` to get the task index)." }
local cmds = {
	add = {
		text = "add",
		summary = "Add a new task.",
		call = function(args) cmds_functions.add(args) end,
		arguments = {
			{ { "content", 'The task content text. (between " ")' } }
		},
		options = { -- add priority of the task in the future
			common_option_cat,
		},
		flags = {
			{ "-N --new-category", "To add new category (content will be the name)" },
		},
	},
	list = {
		text = "list",
		summary = "List all tasks.",
		call = function(args) cmds_functions.list(args) end,
		arguments = {},
		options = {
			common_option_cat,
		},
		flags = {
			{ "-L --list-all",   "List tasks from All categories" },
			{ "-C --categories", "List All categories" },
		},
	},
	rm = {
		text = "rm",
		summary = "Remove a task.",
		call = function(args) cmds_functions.rm(args) end,
		arguments = {
			{ common_argument_index, "?" },
		},

		options = {
			common_option_cat,
			{ "-N --rm-cat", "Remove a category" },
		},
		flags = {},
	},
	check = {
		text = "check",
		summary = "Check a task.",
		call = function(args) cmds_functions.check(args) end,
		arguments = {
			{ common_argument_index },
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
			{ common_argument_index },
			{ { "content", "The new content of the task." } },
		},
		options = {
			common_option_cat,
		},
		flags = {},
	},
}
-- for each command (add, rm, ...)
for k, cmd in pairs(cmds) do
	-- New command parser
	local parser_cmd = parser:command(cmd.text):summary(cmd.summary)
	-- Add arguments
	for k, argument in ipairs(cmd.arguments) do
		if argument[2] then
			parser_cmd:argument(unpack(argument[1])):args(argument[2])
		else
			parser_cmd:argument(unpack(argument[1]))
		end
	end
	-- add options
	for k, option in ipairs(cmd.options) do
		parser_cmd:option(unpack(option))
	end
	-- add flags
	for k, flag in ipairs(cmd.flags) do
		parser_cmd:flag(unpack(flag))
	end
end

local args = parser:parse()
-- get the active selected command
local active_command = args.command
for k, v in pairs(cmds) do
	-- check what command is
	if active_command == v.text then
		v.call(args)
		break
	end
end
