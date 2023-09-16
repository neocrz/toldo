local Mod = function(CategoryManager, DB)
    local CategoryManager = CategoryManager
    local DB = DB
    local cmdsf = {}

    local p_category_notexist = function(category) -- str --> None
        print("Category '" .. category .. "' does not exits.")
    end

    local p_erro_default = function() --> None
        print("Error while acessing the 'Default' category.")
    end

    cmdsf.add = function(args) -- table, CategoryManager --> None
        local content = args.content or nil
        local category = args.category or nil
        local new_category = args.new_category or nil
        local k, cat

        if new_category then
            if #content > 0 then
                CategoryManager:add_category(content)
                return print("Added category: " .. content)
            else
                print("Category name should be at least 1 character long.")
            end
        else --> if isn't a new category, then add a task
            --> add task to a category
            if category then
                k, cat = CategoryManager:get_category(category)
                if not k then
                    return p_category_notexist(category)
                end
            else --> if no category given, then add to Default
                k, cat = CategoryManager:get_category("Default")
                if not k then
                    return p_erro_default()
                end
            end
            cat:add_task(content)
            return true
        end
    end

    cmdsf.check = function(args) -- args table --> None
        local index = args.index or nil
        local category = args.category or nil
        local k, cat
        if category then
            k, cat = CategoryManager:get_category(category)
            if not k then
                return p_category_notexist(category)
            end
        else --> Default
            k, cat = CategoryManager:get_category("Default")
            if not k then
                return p_erro_default()
            end
        end
        cat:check_task(tonumber(index))
    end

    cmdsf.rm = function(args) -- args table --> None
        local index = args.index or nil
        local category = args.category or nil
        local rm_cat = args.rm_cat or nil
        local k, cat
        if rm_cat then
            CategoryManager:rm_category(rm_cat)
        else
            if category then
                k, cat = CategoryManager:get_category(category)
                if not k then
                    return p_category_notexist(category)
                end
            else --> Default
                k, cat = CategoryManager:get_category("Default")
                if not k then
                    return p_erro_default()
                end
            end
            cat:rm_task(tonumber(index))
        end
    end

    cmdsf.list = function(args) -- table, CategoryManager --> None
        local index = args.index or nil
        local categories = args.categories or nil
        local category = args.category or nil
        local list_all = args.list_all or nil

        local k, cat
        if category then
            k, cat = CategoryManager:get_category(category)

            if not k then return p_category_notexist(category) end

            print("'" .. category .. "' Tasks:")

            cat:list_tasks(); print("")
        end
        if categories then
            print("Categories:");
            -- if -CL then do this
            if list_all then
                CategoryManager:list_categories(); print("")
                -- if only -C
            else
                return CategoryManager:list_categories(), print("")
            end
        end

        -- List Notes
        if list_all then
            print("All Notes:")
            for k, v in ipairs(DB.categories) do
                cat = CategoryManager:to_category(v)
                print("--From '" .. cat.name .. "':")
                if cat then
                    cat:list_tasks(); print("")
                end
            end
        elseif not categories and not category then --> Default
            print("'Default' tasks:")
            k, cat = CategoryManager:get_category("Default")
            if not k then
                return p_erro_default()
            end
            cat:list_tasks(); print("")
        end
    end

    return cmdsf
end

return Mod
