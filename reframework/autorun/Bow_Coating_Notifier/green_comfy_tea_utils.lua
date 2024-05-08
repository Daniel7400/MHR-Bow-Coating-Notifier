--[[
    MIT License
    
    Copyright (c) 2023 GreenComfyTea
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

local green_comfy_tea_utils <const> = {
    sdk = {},
    table = {}
};

function green_comfy_tea_utils.table.tostring(table_)
	if type(table_) == "number" or type(table_) == "boolean" or type(table_) == "string" then
		return tostring(table_);
	end

	if green_comfy_tea_utils.table.is_empty(table_) then
		return "{}"; 
	end

	local cache = {};
	local stack = {};
	local output = {};
    local depth = 1;
    local output_str = "{\n";

    while true do
        local size = 0;
        for k,v in pairs(table_) do
            size = size + 1;
        end

        local cur_index = 1;
        for k,v in pairs(table_) do
            if cache[table_] == nil or cur_index >= cache[table_] then

                if string.find(output_str, "}", output_str:len()) then
                    output_str = output_str .. ",\n";
                elseif not string.find(output_str, "\n", output_str:len()) then
                    output_str = output_str .. "\n";
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str);
                output_str = "";

                local key;
                if type(k) == "number" or type(k) == "boolean" then
                    key = "[" .. tostring(k) .. "]";
                else
                    key = "['" .. tostring(k) .. "']";
                end

                if type(v) == "number" or type(v) == "boolean" then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = "..tostring(v);
                elseif type(v) == "table" then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n";
                    table.insert(stack, table_);
                    table.insert(stack, v);
                    cache[table_] = cur_index + 1;
                    break;
                else
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'";
                end

                if cur_index == size then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}";
                else
                    output_str = output_str .. ",";
                end
            else
                -- close the table
                if cur_index == size then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}";
                end
            end

            cur_index = cur_index + 1;
        end

        if size == 0 then
            output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}";
        end

        if #stack > 0 then
            table_ = stack[#stack];
            stack[#stack] = nil;
            depth = cache[table_] == nil and depth + 1 or depth - 1;
        else
            break;
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str);
    output_str = table.concat(output);

    return output_str;
end

function green_comfy_tea_utils.table.tostringln(table_)
	return "\n" .. green_comfy_tea_utils.table.table_tostring(table_);
end

function green_comfy_tea_utils.table.is_empty(table_)
	return next(table_) == nil;
end

function green_comfy_tea_utils.table.deep_copy(original, copies)
	copies = copies or {};
	local original_type = type(original);
	local copy;
	if original_type == "table" then
		if copies[original] then
			copy = copies[original];
		else
			copy = {};
			copies[original] = copy;
			for original_key, original_value in next, original, nil do
				copy[green_comfy_tea_utils.table.deep_copy(original_key, copies)] = green_comfy_tea_utils.table.deep_copy(original_value,copies);
			end
			setmetatable(copy, green_comfy_tea_utils.table.deep_copy(getmetatable(original), copies));
		end
	else -- number, string, boolean, etc
		copy = original;
	end
	return copy;
end

function green_comfy_tea_utils.table.find_index(table_, value, nullable)
	for i = 1, #table_ do
		if table_[i] == value then
			return i;
		end
	end

	if not nullable then
		return 1;
	end

	return nil;
end

function green_comfy_tea_utils.table.merge(...)
	local tables_to_merge = { ... };
	assert(#tables_to_merge > 1, "There should be at least two tables to merge them");

	for key, table_ in ipairs(tables_to_merge) do
		assert(type(table_) == "table", string.format("Expected a table as function parameter %d", key));
	end

	local result = green_comfy_tea_utils.table.deep_copy(tables_to_merge[1]);

	for i = 2, #tables_to_merge do
		local from = tables_to_merge[i];
		for key, value in pairs(from) do
			if type(value) == "table" then
				result[key] = result[key] or {};
				assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key));
				result[key] = green_comfy_tea_utils.table.merge(result[key], value);
			else
				result[key] = value;
			end
		end
	end

	return result;
end

function green_comfy_tea_utils.sdk.generate_enum(type_name)
    local type_def = sdk.find_type_definition(type_name);
	if not type_def then
		return {};
	end;

	local fields = type_def:get_fields();
	local enum = {};

	for i, field in ipairs(fields) do
		if field:is_static() then
			local name = field:get_name();
			local raw_value = field:get_data(nil);

			local enum_entry = {
				name = name,
				value = raw_value;
			};

			table.insert(enum, enum_entry);
		end
	end

	return enum;
end

function green_comfy_tea_utils.sdk.generate_enum_name_as_key(type_name)
    local type_def = sdk.find_type_definition(type_name);
	if not type_def then
		return {};
	end;

	local fields = type_def:get_fields();
	local enum = {};

    for i, field in ipairs(fields) do
		if field:is_static() then
			local name = field:get_name();
			local raw_value = field:get_data(nil);
            enum[name] = raw_value;
		end
	end

	return enum;
end

function green_comfy_tea_utils.sdk.generate_enum_value_as_key(type_name)
    local type_def = sdk.find_type_definition(type_name);
	if not type_def then
		return {};
	end;

	local fields = type_def:get_fields();
	local enum = {};

    for i, field in ipairs(fields) do
		if field:is_static() then
			local name = field:get_name();
			local raw_value = field:get_data(nil);
            enum[raw_value] = name;
		end
	end

	return enum;
end

return green_comfy_tea_utils;