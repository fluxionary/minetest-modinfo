local private_state = ...
local ie = private_state.ie

local InsecureSettings = futil.class1()

local function parse(fh, filepath)
	local linenum = 0
	local values = {}
	local state = "normal"
	local multikey
	local multiline

	for line in fh:lines() do
		linenum = linenum + 1
		line = line:trim()
		if state == "group" then
			if line:sub(-1) == "}" then
				table.insert(multiline, line)
				values[multikey] = table.concat(multiline, "\n"):trim()
				multikey = nil
				multiline = nil
				state = "normal"
			else
				table.insert(multiline, line)
			end
		elseif state == "multiline" then
			if line:sub(-3) == '"""' then
				table.insert(multiline, line:sub(1, -4))
				values[multikey] = table.concat(multiline, "\n"):trim()
				multikey = nil
				multiline = nil
				state = "normal"
			end
		elseif state == "normal" then
			if #line > 0 and line:sub(1, 1) ~= "#" then
				local key, value = line:match("^([^=]+)=(.*)$")
				if not (key and value) then
					error(("invalid conf file %q line %i"):format(filepath, linenum))
				end

				key = key:trim()
				value = value:trim()

				if key == "" then
					error(("blank key in %q line %i"):format(filepath, linenum))
				end

				if value:sub(1, 1) == "{" and value:sub(-1) ~= "}" then
					state = "group"
					multikey = key
					multiline = { value }
				elseif value:sub(1, 3) == '"""' and (value:sub(-3) ~= '"""' or #value < 6) then
					state = "multiline"
					multikey = key
					multiline = { value:sub(4) }
				else
					values[key] = value
				end
			end
		else
			error(("somehow in invalid state %q line %i"):format(state, linenum))
		end
	end

	return values
end

function InsecureSettings:_init(filepath)
	local fh = ie.io.open(filepath)

	self._values = parse(fh, filepath)
	-- TODO: catch exceptions, close file, and rethrow

	ie.io.close(fh)
end

function InsecureSettings:get(key)
	return self._values[key]
end

function InsecureSettings:get_bool(key, default)
	local value = self._values[key]
	if key == nil then
		return default
	else
		return value:lower() == "true"
	end
end

function InsecureSettings:get_np_group(key)
	error("TODO") -- TODO, but probably will never do
end

function InsecureSettings:get_names()
	return futil.list(pairs(self._values))
end

function InsecureSettings:to_table()
	return table.copy(self._values)
end

function InsecureSettings:set(key, value)
	error("can't set values for insecure settings (not ours)")
end

function InsecureSettings:set_bool(key, value)
	error("can't set values for insecure settings (not ours)")
end

function InsecureSettings:set_np_group(key, value)
	error("can't set values for insecure settings (not ours)")
end

function InsecureSettings:remove(key)
	error("can't set values for insecure settings (not ours)")
end

function InsecureSettings:write()
	error("can't set values for insecure settings (not ours)")
end

private_state.InsecureSettings = InsecureSettings
