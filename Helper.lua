local L = LibStub("AceLocale-3.0"):GetLocale("KeystrokeLauncher")

-- format table as printable string
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- check if given slash command exists in _G
function slash_cmd_exists(slash_cmd)
    for _, v in pairs(_G) do
        if slash_cmd == v then
            return true
        end
    end
end

function item_link_to_string(itemLink)
    return itemLink:match("|H(.*)|h%[(.*)%]|h")
end

function get_or_create_macro(name, per_char)
    local macroId = GetMacroIndexByName(name)
    if macroId == 0 then
        macroId = CreateMacro(name, "INV_MISC_QUESTIONMARK", "", per_char);
    end
    return macroId
end

function is_nil_or_empty(val)
    if val == nil or val == '' then
        return true
    else
        return false
    end
end

function table.length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- ENUM from https://gist.github.com/szensk/7986347f09742337b36e
-- this enum is really arkward to handle, planing to replace it with something else
local enummt = {
        __index = function(table, key)
            if rawget(table.enums, key) then
            return key
        end
    end
}

function Enumm(t)
    local e = { enums = t }
    return setmetatable(e, enummt)
end

function enumm_to_table(enumm)
    local rv = {}
    for _,v in pairs(enumm) do
        for k1,_ in pairs(v) do
            rv[k1] = L['CONFIG_INDEX_TYPES_'..k1]
        end
    end
    return rv
end

-- https://gist.github.com/haggen/2fd643ea9a261fea2094
local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

function randomString(length)
    if not length or length <= 0 then return '' end
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end