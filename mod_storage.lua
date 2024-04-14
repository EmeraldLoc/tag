-- an easy to use mod storage system, fully "encrypted"
-- cross compatible with ex-coop and coopdx

--------------------------
-- encryption functions --
--------------------------

-- the encryption key
local encryptionKey = ""

-- get all characters used in encryption
local characters = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "_", "-"
}

local function retrieve_key_table()
    local references = {}

    -- while we haven't reached the end of our encryption key...
    local i = 1
    while i < encryptionKey:len() do
        -- ...get reference
        local reference = encryptionKey:sub(i + 1, i + 1)

        -- append character and reference to table
        table.insert(references, reference)

        -- increment pair count by 2
        i = i + 2
    end

    return references
end

function generate_key()
    -- retrieve key if it exists
    if  mod_storage_load("encryptionKey1") ~= nil
    and mod_storage_load("encryptionKey2") ~= nil
    and encryptionKey == "" then
        encryptionKey = mod_storage_load("encryptionKey1") .. mod_storage_load("encryptionKey2")

        if #encryptionKey ~= #characters * 2 then
            -- invalid/outdated encrpytion key, regenerate
            encryptionKey = ""
        end
    end

    -- check if key exists, if it doesn't, generate a new key
    if encryptionKey == "" then
        -- key doesn't exist, generate a new one and save the key

        -- assign each character to reference a different, random character
        local references = {}
        for _ = 1, #characters do
            local referenceCharacter = math.random(1, #characters)

            while table.contains(references, characters[referenceCharacter]) do
                referenceCharacter = math.random(1, #characters)
            end

            table.insert(references, characters[referenceCharacter])
        end

        -- create a key based off of all the references
        for i = 1, #references do
            encryptionKey = encryptionKey .. characters[i] .. references[i]
        end

        -- save key into 2 parts
        mod_storage_save("encryptionKey1", encryptionKey:sub(1, encryptionKey:len() / 2))
        mod_storage_save("encryptionKey2", encryptionKey:sub(encryptionKey:len() / 2 + 1, encryptionKey:len()))
    end
end

---@param str string
function encrypt_string(str)
    if str == nil then return "" end
    generate_key()

    -- get key into table
    local references = retrieve_key_table()

    -- loop thru each character
    local encryptedStr = ""
    for i = 1, #str do
        -- get table pos
        local pos = table.pos_of_element(characters, str:sub(i, i))

        -- get reference and add to encrypted string
        if references[pos] ~= nil then
            encryptedStr = encryptedStr .. references[pos]
        else
            encryptedStr = encryptedStr .. str:sub(i, i)
        end
    end

    return encryptedStr
end

function decrypt_string(str)
    if str == nil then return nil end
    generate_key()
    -- get key into table
    local references = retrieve_key_table()

    -- loop thru each character
    local decryptedString = ""
    for i = 1, #str do
        -- get table pos
        local pos = table.pos_of_element(references, str:sub(i, i))

        -- get reference and add to encrypted string
        if references[pos] ~= nil then
            decryptedString = decryptedString .. characters[pos]
        else
            decryptedString = decryptedString .. str:sub(i, i)
        end
    end

    return decryptedString
end

----------------------
-- saving functions --
----------------------
---@param key string
---@param value string
function save_string(key, value)
    -- save directly to storage, no conversion needed
    mod_storage_save(key, encrypt_string(value))
end

---@param key string
---@param value boolean
function save_bool(key, value)
    -- convert value to string
    local strValue = tostring(value)
    -- add tag_bool_ to the beginning
    strValue = "tag_bool_" .. strValue
    -- save
    mod_storage_save(key, encrypt_string(strValue))
    encrypt_string(strValue)
end

---@param key string
---@param value integer
function save_int(key, value)
    -- convert value to string
    local strValue = tostring(value)
    -- add tag_int_ to the beginning
    strValue = "tag_int_" .. strValue
    -- save
    mod_storage_save(key, encrypt_string(strValue))
end

-----------------------
-- loading functions --
-----------------------

---@param key string
---@return string
function load_string(key)
    -- return storage data
    return tostring(decrypt_string(mod_storage_load(key)))
end

---@param key string
---@return boolean|nil
function load_bool(key)
    -- get storage data
    local data = decrypt_string(mod_storage_load(key))
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
    local data = decrypt_string(mod_storage_load(key))
    -- sanity check
    if data == nil then return nil end
    -- remove the tag_int_ part from the string
    data = data:gsub("tag_int_", "")
    -- return converted int from string
    return tonumber(data)
end