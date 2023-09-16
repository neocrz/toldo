local Class = require("classic")



-- OBS. if is init (this will be the folder name) else it will be the module file
local pathOfThisMod = ...                           -- pathOfThisMod is now 'lib.foo.bar'
local folderOfThisFile = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'


local Models = {}
Models.CategoryManager = require(pathOfThisMod .. ".CategoryManager")

return Models
