-- an easy to use mod storage system, cross compatible with ex-coop and coopdx
----------------------
-- saving functions --
----------------------
---@param key string
---@param value string
function save_string(key, value)
    -- save directly to storage, no conversion needed
    mod_storage_save(key, value)
end

---@param key string
---@param value boolean
function save_boolean(key, value)
    -- convert value to string
    local strValue = tostring(value)
    -- add tag_bool_ to the beggining
    strValue = "tag_bool_" .. strValue
    -- save
    mod_storage_save(key, strValue)
end

---@param key string
---@param value integer
function save_int(key, value)
    -- convert value to string
    local strValue = tostring(value)
    -- add tag_int_ to the beggining
    strValue = "tag_int_" .. strValue
    -- save
    mod_storage_save(key, strValue)
end

-----------------------
-- loading functions --
-----------------------

---@param key string
---@return string
function load_string(key)
    -- return storage data
    return mod_storage_load(key)
end

---@param key string
---@return boolean|nil
function load_bool(key)
    -- get storage data
    local data = mod_storage_load(key)
    -- sanity check
    if data == nil then return nil end
    -- remove the tag_bool_ part from the string
    data = data:gsub("tag_bool_", "")
    -- return converted bool from string
    return tobool(data)
end

---@param key string
---@return integer|nil
function load_int(key)
    -- get storage data
    local data = mod_storage_load(key)
    -- sanity check
    if data == nil then return nil end
    -- remove the tag_int_ part from the string
    data = data:gsub("tag_int_", "")
    -- return converted int from string
    return tonumber(data)
end