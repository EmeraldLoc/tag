
---@param showWelcomeMessage boolean
---@param showBoostMessage boolean
function show_rules(showWelcomeMessage, showBoostMessage)

    local text = ""

    -- if we show the welcome message, show the welcome message
    if showWelcomeMessage then
        text = "Welcome to \\#316BE8\\Tag\n\\#FFFFFF\\The Rules:\n\n"

        djui_chat_message_create(text)
    end

    -- set text depending on the gamemode
    if gGlobalSyncTable.gamemode == FREEZE_TAG then
        text = "The Gamemode is \\#7ec0ee\\Freeze Tag\n\\#316BE8\\Runners \\#FFFFFF\\run away from the \\#E82E2E\\Taggers \\#FFFFFF\\and save the \\#7ec0ee\\Frozen\nFrozen \\#FFFFFF\\wait for a \\#316BE8\\Runner \\#FFFFFF\\to save them or becomes a \\#E82E2E\\Tagger\nTagger \\#FFFFFF\\tags \\#316BE8\\Runners \\#FFFFFF\\and guards the \\#7ec0ee\\Frozen\n\\#316BE8\\Runners \\#FFFFFF\\will have a radar showing them where the \\#7ec0ee\\Frozen \\#FFFFFF\\are, and \\#E82E2E\\Taggers \\#FFFFFF\\will have a radar showing them where the \\#316BE8\\Runners \\#FFFFFF\\are"
    elseif gGlobalSyncTable.gamemode == TAG then
        text = "The Gamemode is \\#316BE8\\Tag\n\\#316BE8\\Runners \\#FFFFFF\\run away from the \\#E82E2E\\Taggers\nTaggers \\#FFFFFF\\must tag \\#316BE8\\Runners \\#FFFFFF\\to no longer be a \\#E82E2E\\Tagger\n\\#FFFFFF\\If your a \\#316BE8\\Runner \\#FFFFFF\\and the round ends, you win!\nWhen you die as a \\#316BE8\\Runner \\#FFFFFF\\or join late, you become \\#BF3636\\Eliminated\\#FFFFFF\\, you can only watch as an \\#BF3636\\Eliminated \\#FFFFFF\\player\n\\#FFFFFF\\If all \\#316BE8\\Runners \\#FFFFFF\\become \\#BF3636\\Eliminated\\#FFFFFF\\, then the \\#E82E2E\\Taggers \\#FFFFFF\\win!\nThe \\#E82E2E\\Taggers \\#FFFFFF\\will have a radar showing where the \\#316BE8\\Runners \\#FFFFFF\\are"
    elseif gGlobalSyncTable.gamemode == INFECTION then
        text = "The Gamemode is \\#24D636\\Infection\n\\#24D636\\Infected \\#FFFFFF\\players much chase \\#316BE8\\Runners\\#FFFFFF\\. If a \\#24D636\\Infected \\#FFFFFF\\player catches a \\#316BE8\\Runner\\#FFFFFF\\, then the \\#316BE8\\Runner becomes \\#24D636\\Infected."
    end

    djui_chat_message_create(text)

    -- if we show the boost message, show it depending on the gamemode
    if showBoostMessage then
        if gGlobalSyncTable.gamemode == INFECTION then
            text = text .. "\n\n\\#24D636\\Infected\\#FFFFFF\\ players can boost their way to victory\nThe ui at the bottom of your screen will tell you the status of your speed boost\nTo use the speed boost, hit the button binded to Y"
        elseif gGlobalSyncTable.gamemode == TAG or gGlobalSyncTable.gamemode == FREEZE_TAG then
            text = text .. "\n\n\\#E82E2E\\Taggers\\#FFFFFF\\ can boost their way to victory\nThe ui at the bottom of your screen will tell you the status of your speed boost\nTo use the speed boost, hit the button binded to Y"
        end

        djui_chat_message_create(text)
    end
end