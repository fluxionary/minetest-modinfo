futil.check_version({ year = 2022, month = 10, day = 24 })

local ie = minetest.request_insecure_environment()
if not ie then
	error(table.concat({
		"modinfo requires an insecure environment in order to get mod metadata.",
		'add "modinfo" to `secure.trusted_mods` value in minetest.conf. it is comma delimited.',
	}, "\n"))
end

modinfo = fmod.create(nil, { ie = ie })

modinfo.dofile("insecure_settings")
modinfo.dofile("compile_info")
modinfo.dofile("command")
