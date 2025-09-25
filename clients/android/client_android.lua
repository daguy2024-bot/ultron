-- client_android.lua
-- ComputerCraft: Tweaked WebSocket client for command reception
-- police force, thats about it ngl

local ws_url = "ws://your.websocket.server:port" -- Change to your WebSocket server URL
cmd = nil

-- Ensure websocket API is available
if not http.websocket then
    print("WebSocket API not available. Update ComputerCraft: Tweaked.")
    return
end

local id = os.getComputerID()
local ws, err = http.websocket(ws_url)
if not ws then
    print("Failed to connect to WebSocket:", err)
    return
end

print("Connected to WebSocket. Sending computer ID:", id)
ws.send(textutils.serialize({"id" = id}))

function wb() 
    while true do
        local event, url, message = os.pullEvent()
        if event == "websocket_message" and url == ws_url then
            print("Received command:", message)
            cmd = textutils.unserialize(message)
            if cmd then
                if cmd.patrol then
                    watch = true
                    attack = false
                    print("Patrol mode activated.")
                elseif cmd.attack then
                    watch = false
                    attack = true
                    targetUUID = cmd.attackid
                    print("Attack mode activated. Target UUID:", targetUUID)
                elseif cmd.stop then
                    watch = false
                    attack = false
                    print("All actions stopped.")
                end
            else
                print("Invalid command format.")
            end
        elseif event == "websocket_closed" and url == ws_url then
            print("WebSocket closed.")
            break
        end
    end
end

function patrol()
    while true do
        if watch then
            entitylist = android.getNearbyEntities()
            for i, entity in ipairs(entitylist) do
                if entity.name == "minecraft:player" then
                    print("Player detected:", entity.name)
                    ws.send(textutils.serialize({foundplayer = entity.uuid}))
                end
            end
        elseif attack then
            android.attack(targetUUID)
            if android.currentTask() == "idle" then
                print("too far to detect target")
                attack = false
            while android.currentTask() ~= "idle" do
                os.sleep(1)
            end
            attack = false
            print("Target lost or defeated")
            ws.send(textutils.serialize({targetlost = targetUUID}))
        end
    end
end

parrallel.waitForAny(wb, patrol)
ws.close()