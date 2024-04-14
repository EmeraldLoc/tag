
local function packet_recieve(p)
    if p.packetType ~= PACKET_TYPE_CHAT_MESSAGE_GLOBAL then return end

    djui_chat_message_create(p.data)
end

hook_event(HOOK_ON_PACKET_RECEIVE, packet_recieve)