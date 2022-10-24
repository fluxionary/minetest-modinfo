local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local f = string.format

assert(
	type(futil.version) == "number" and futil.version >= os.time({year = 2022, month = 10, day = 24}),
	"please update futil"
)

local ie = minetest.request_insecure_environment()
if not ie then
	error(table.concat({
		f("%s requires an insecure environment in order to get mod metadata.", modname),
		f("add %s to `secure.trusted_mods` value in minetest.conf. it is comma delimited.", modname)
	}, "\n"))
end

modinfo = {
	author = "flux",
	license = "AGPL_v3",
	version = os.time({year = 2022, month = 10, day = 12}),
	fork = "flux",

	modname = modname,
	modpath = modpath,
	S = S,
	ie = ie,

	has = {
	},

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
	end,
}

modinfo.dofile("insecure_settings")
modinfo.dofile("compile_info")
modinfo.dofile("command")

modinfo.ie = nil
modinfo.InsecureSettings = nil
