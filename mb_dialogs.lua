
TAG_DIALOGS = {
    "You can boost as a Tagger using the button shown on the boost hud element. This allows you to run faster than the runners!",
    "Hey, why are you reading this? Go play the game instead.",
    "This mod was made by EmeraldLockdown.",
    "MarioHunt was really the first mod I saw that edited vanilla stuff within a gamemode, so be sure to check that mod out!",
    "Achievement titles and trails are a great way to show off how far you are in Tag! Also, that's probably not something to be proud of >:)",
    "sm64.us.f3dex2e. The reason why many exectutables in the pc port is named this is cuz, idk some guy thought of it. The reason that guy thought of it is because sm64 is the game, us is the region, and f3dex2e is the grucode.",
    "Hey " .. strip_hex(get_player_name_without_title(0)) .. ", how do you do today? Also, if you changed your name I'm not gonna be happy, cuz this sign will be outdated :(",
    "I will never sellout to any sponser, you can trust me on that!",
    "Have you heard of our sponser, Raid Shadow Legends?",
    "Have you heard of our sponser, NordVPN?",
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
