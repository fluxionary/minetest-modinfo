local get_modnames = minetest.get_modnames
local get_modpath = minetest.get_modpath

local file_exists = futil.file_exists
local path_concat = futil.path_concat
local path_split = futil.path_split

local function get_mod_description(modname)
	local modpath = get_modpath(modname)
	local conf_path = path_concat(modpath, "mod.conf")
	if file_exists(conf_path) then
		local settings = Settings(conf_path)
		local description = settings:get("description")
		if not description then
			return ""
		end
		local lines = string.split(description, "\n", false)
		return lines[1]
	end
	conf_path = path_concat(modpath, "description.txt")
	if file_exists(conf_path) then
		local fh = io.open(conf_path, "r")
		local description = fh:lines()():trim()
		fh:close()
		return description
	end
	return "<missing mod.conf>"
end

local function get_modpack(modname)
	local modpath = get_modpath(modname)
	local pathparts = path_split(modpath)
	local modpack_name = pathparts[#pathparts - 1]
	if modpack_name ~= "worldmods" and modpack_name ~= "mods" then
		return modpack_name
	end
end

local elements = {}
local modpacks = {}
local mod_descriptions = {}

for _, modname in ipairs(get_modnames()) do
	mod_descriptions[modname] = get_mod_description(modname) or ""
	local modpack_name = get_modpack(modname)

	if modpack_name then
		local modpack_mods = modpacks[modpack_name]

		if not modpack_mods then
			table.insert(elements, modpack_name)
			modpack_mods = {}
		end

		table.insert(modpack_mods, modname)
		modpacks[modpack_name] = modpack_mods
	else
		table.insert(elements, modname)
	end
end

table.sort(elements, futil.string.lc_cmp)

modinfo.elements = elements
modinfo.modpacks = modpacks
modinfo.mod_descriptions = mod_descriptions

local mod_info = {}
local keys_to_ignore = {
	"name",
	"depends",
	"optional_depends",
	"min_minetest_version",
	"max_minetest_version",
	"release",
}

for modname in pairs(mod_descriptions) do
	local conf_path = path_concat(get_modpath(modname), "mod.conf")
	if file_exists(conf_path) then
		local info = Settings(conf_path):to_table()
		for _, k in ipairs(keys_to_ignore) do
			info[k] = nil
		end
		mod_info[modname] = info
	else
		mod_info[modname] = {}
	end
end

modinfo.mod_info = mod_info

minetest.register_on_mods_loaded(function()
	for modname, info in pairs(mod_info) do
		if minetest.global_exists(modname) then
			local mod = _G[modname]
			if type(mod) == "table" then
				if mod.information and type(mod.information) == "table" then
					info.license = info.license or mod.information.license
					info.author = info.author or mod.information.author
					info.version = info.version or mod.information.version
					info.description = info.description or mod.information.additional
					info.website = info.website or info.url or mod.information.source
				else
					info.author = info.author or mod.author
					info.version = info.version or mod.version
					info.license = info.license or mod.license
					info.fork = info.fork or mod.fork
				end
			end
		end
	end
end)
