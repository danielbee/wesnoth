
local empty_pkg = {}

local function resolve_package(pkg_name)
	if pkg_name[#pkg_name] == '/' then
		pkg_name = pkg_name:sub(1, -2)
	end
	if wesnoth.have_file(pkg_name) then return pkg_name end
	if pkg_name:sub(-4) ~= ".lua" then
		if wesnoth.have_file(pkg_name .. ".lua") then
			return pkg_name .. ".lua"
		end
		if pkg_name:sub(1, 4) ~= "lua/" then
			if wesnoth.have_file("lua/" .. pkg_name .. ".lua") then
				return "lua/" .. pkg_name .. ".lua"
			end
		end
	end
	if pkg_name:sub(1, 4) ~= "lua/" then
		if wesnoth.have_file("lua/" .. pkg_name) then
			return "lua/" .. pkg_name
		end
	end
	return nil
end

function wesnoth.require(pkg_name)
	-- First, check if the package is already loaded
	local loaded_name = resolve_package(pkg_name)
	if loaded_name and wesnoth.package[loaded_name] then
		return wesnoth.package[loaded_name]
	end

	-- Next, if it's a single file, load the package with dofile
	if wesnoth.have_file(loaded_name, true) then
		local pkg = wesnoth.dofile(loaded_name)
		wesnoth.package[loaded_name] = pkg or empty_pkg
		return pkg
	else -- If it's a directory, load all the files therein
		local files = wesnoth.read_file(loaded_name)
		local pkg = {}
		for i = files.ndirs + 1, #files do
			if files[i]:sub(-4) == ".lua" then
				local subpkg_name = files[i]:sub(1, -5)
				pkg[subpkg_name] = wesnoth.require(loaded_name .. '/' .. files[i])
			end
		end
		wesnoth.package[loaded_name] = pkg
		return pkg
	end
end
