local Class = require("classic")

local CategoryManager = Class:extend()

local THIS_PATH = ...                          -- pathOfThisMod is now 'lib.foo.bar'
local THIS_FOLDER = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'

return function(DB)
    local DB = DB

    local Category = Class:extend()

    function Category:new(name, tasks)
        self.name = name or nil
        self.tasks = tasks or {}
    end

    function Category:__tostring()
        return self.name
    end

    function Category:add_task(content, priority)
        local task = {
            content = content,
            priority = priority or 1,
            check = false,
        }
        table.insert(self.tasks, task)
        DB:save()
    end

    function Category:rm_task(id)
        if self.tasks[id] then
            table.remove(self.tasks, id)
        else
            print("Index " .. id .. " not found in '" .. self.name .. "'")
        end
        DB:save()
    end

    function Category:edit_task(id, newcontent)
        if self.tasks[id] then
            self.tasks[id].content = newcontent
        else
            print("Index " .. id .. "not found in '" .. self.name .. "'")
        end
        DB:save()
    end

    function Category:check_task(id)
        if self.tasks[id] then
            self.tasks[id].check = not self.tasks[id].check
        else
            print("Index " .. id .. " not found in '" .. self.name .. "'")
        end
        DB:save()
    end

    function Category:list_tasks()
        for k, v in pairs(self.tasks) do
            local check = ""
            if v.check then
                check = " [-] "
            else
                check = " [ ] "
            end

            print(k .. check .. "| " .. v.priority .. " | -> " .. v.content)
        end
    end

    function CategoryManager:check_ifexist_category(category_name)
        local name = category_name or nil
        if not name then
            return print("No name provided for 'check_ifexist_category'")
        end

        for k, v in pairs(DB.categories) do
            if v.name == name then
                return true
            end
        end

        return false
    end

    function CategoryManager:new(db_loc)
        if not DB.categories then DB.categories = {} end

        if not self:check_ifexist_category("Default") then
            table.insert(DB.categories, { name = "Default", tasks = {} })
        end

        DB:save()
    end

    function CategoryManager:clean_categories(_)
        local hard_delete = _ or false
        if hard_delete then
            print("Hard delete.\nDeleting All and making a new Default category.")
            DB.categories = {}
            table.insert(DB.categories, Category("Default"))
        else
            print("Soft delete categories.")
            local k, v = self:get_category("Default")
            if k then
                print("Deleting all categories, except Default.")
                DB.categories = {}
                table.insert(DB.categories, v)
            else
                print("Default category not find. Deleting all categories.")
                DB.categories = {}
                table.insert(DB.categories, Category("Default"))
            end
        end
        DB:save()
    end

    function CategoryManager:list_categories()
        for k, v in ipairs(DB.categories) do
            print(k .. " - " .. v.name)
        end
    end

    function CategoryManager:get_category(name)
        for k, v in ipairs(DB.categories) do
            if v.name == name then
                return k, Category(v.name, v.tasks)
            end
        end
        return false
    end

    function CategoryManager:add_category(name)
        if not self:check_ifexist_category(name) then
            table.insert(DB.categories, { name = name, tasks = {} })
        else
            print("Category already exists.")
        end
        DB:save()
    end

    function CategoryManager:rm_category(name)
        local i, category = self:get_category(name)

        if not i then
            return print("Category does not exist.")
        end

        table.remove(DB.categories, i)

        DB:save()
    end

    return CategoryManager
end
