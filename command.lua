local S = modinfo.S
local F = minetest.formspec_escape
local FS = function(...)
	return F(S(...))
end
local f = string.format

local pairs_by_key = futil.table.pairs_by_key

local function show_mods_formspec(name, row)
	local fs_parts = {
		"size[13,7.5]",
		f("label[0,-0.1;%s]", FS("mods")),
		"button_exit[12.5,-0.15;0.5,0.5;quit;X]",
		"box[0,5.5;12.8,1.5;#000]",
	}

	row = tonumber(row) or 0
	local selected_mod
	local rows = {f("#FFF,0,%s,%s", F(S("mod")), F(S("description")))}

	local i = 1
	for _, element in ipairs(modinfo.elements) do
		i = i + 1
		if i == row then
			selected_mod = element
		end
		local modpack_mods = modinfo.modpacks[element]
		if modpack_mods then
			table.insert(rows, f("#7F7,0,%s,%s", F(element), F(modinfo.modpack_descriptions[element])))
			for _, modname in ipairs(modpack_mods) do
				i = i + 1
				if i == row then
					selected_mod = modname
				end
				table.insert(rows, f("#7AF,1,  %s,%s", F(modname), F(modinfo.mod_descriptions[modname])))
			end

		else
			table.insert(rows, f("#7AF,0,%s,%s", F(element), F(modinfo.mod_descriptions[element])))
		end
	end

	local info = {}
	if row > 0 then
		for k, v in pairs_by_key(modinfo.mod_info[selected_mod] or {}) do
			if k == "url" then
				table.insert_all(fs_parts, {
					f("textarea[0.3,5;12.7,0.5;;;URL: %s]", F(v)),
					"tooltip[0.3,5;12.7,0.5;select and copy;#000;#FFF]"
				})

			else
				table.insert(info, f("%s,%s", F(tostring(k)), F(tostring(v))))
			end
		end
	end

	table.insert_all(fs_parts, {
		"tablecolumns[color;tree;text;text]",
		f("table[0,0.5;12.8,4.3;list;%s;%i]", table.concat(rows, ","), row),
		"tablecolumns[text;text]",
		f("table[0,5.5;12.8,1.9;info;%s;0]", table.concat(info, ",")),
	})

	minetest.show_formspec(name, "modinfo:modinfo", table.concat(fs_parts, ""))
end

minetest.register_chatcommand("modinfo", {
	description = "get info about mods",
	func = show_mods_formspec,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "modinfo:modinfo" or fields.quit then
		return
	end

	if fields.list then
		local event = minetest.explode_table_event(fields.list)
		if event.type ~= "INV" then
			local name = player:get_player_name()
			show_mods_formspec(name, event.row)
		end
	end
end)
