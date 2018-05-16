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
    for k, v in pairs(_G) do
        if slash_cmd == v then
            return true
        end
    end
end

function item_link_to_string(itemLink)
    return itemLink:match("|H(.*)|h%[(.*)%]|h")
end

function get_or_create_maco(name)
    macroId = GetMacroIndexByName(name)
    if macroId == 0 then
        macroId = CreateMacro(name, "INV_MISC_QUESTIONMARK", "", nil);
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