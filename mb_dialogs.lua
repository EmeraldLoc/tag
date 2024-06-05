
TAG_DIALOGS = {
    "You can boost as a Tagger using the button shown on the boost hud element. This allows you to run faster than the runners!",
    "Hey, why are you reading this? Go play the game instead."
}

local function on_dialog(dialogID)
    local text = TAG_DIALOGS[math.random(1, #TAG_DIALOGS)]
    local wrappedText = wrap_text(text, 250)
    text = ""

    for k, s in ipairs(wrappedText) do
        if k == #wrappedText then
            text = text .. s
        else
            text = text .. s .. "\n"
        end
    end

    smlua_text_utils_dialog_replace(dialogID, 1, 6, 30, 200, text)
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function on_interact(m, o, intee)
    local rM = nil
    for i = 1, MAX_PLAYERS - 1 do
        if gMarioStates[i].marioObj == o then
            ---@type MarioState
            rM = gMarioStates[i]
            break
        end
    end
    if rM == nil then return end

    if rM.action == ACT_READING_SIGN
    or rM.action == ACT_READING_NPC_DIALOG then
        handle_pvp(m.playerIndex, rM.playerIndex)
    end
end

hook_event(HOOK_ON_DIALOG, on_dialog)
hook_event(HOOK_ON_INTERACT, on_interact)
