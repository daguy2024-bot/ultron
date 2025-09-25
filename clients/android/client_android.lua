-- client_android.lua
-- ComputerCraft: Tweaked WebSocket client for command reception
-- police force, thats about it ngl

local ws_url = "ws://your.websocket.server:port" -- Change to your WebSocket server URL
cmd = nil
cross = {
    watch = true,
    attack = false,
    targetUUID = nil
}

post = { -- CHANGE THESE COORDS PER GUARD
    x = 0,
    y = 0,
    z = 0
}

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
    global cross

    while true do
        sleep(0)
        local event, url, message = os.pullEvent()
        if event == "websocket_message" and url == ws_url then
            print("Received command:", message)
            cmd = textutils.unserialize(message)
            if cmd then
                if cmd.patrol then
                    cross.watch = true
                    cross.attack = false
                    print("Patrol mode activated.")
                elseif cmd.attack then
                    cross.watch = false
                    cross.attack = true
                    cross.targetUUID = cmd.attackid
                    print("Attack mode activated. Target UUID:", targetUUID)
                elseif cmd.stop then
                    cross.watch = false
                    cross.attack = false
                    print("All actions stopped.")
                end
            else
                print("Invalid command format.")
            end
        elseif event == "websocket_closed" and url == ws_url then
            print("WebSocket closed. major error")
            break
        end
    end
end

function patrol()
    global cross
    while true do
        sleep(0)
        if cross.watch then
            if not 
            android.moveTo(post.x, post.y, post.z)
            entitylist = android.getNearbyEntities()
            for i, entity in ipairs(entitylist) do
                if entity.name == "minecraft:player" then
                    print("Player detected:", entity.name)
                    ws.send(textutils.serialize({foundplayer = entity.uuid}))
                end
            end
        elseif cross.attack then
            android.attack(targetUUID)
            sleep(0.3)
            if android.currentTask() == "idle" then
                print("too far to detect target")
                cross.attack = false
            while android.currentTask() ~= "idle" do
                os.sleep(1)
            end
            cross.attack = false
            print("Target lost or defeated")
            ws.send(textutils.serialize({targetlost = targetUUID}))
        end
    end
end

while true do
    parrallel.waitForAny(wb, patrol)
end
ws.close()