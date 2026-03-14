Config = {
    World = {
        WHITELISTED_WORLD = {"zhbsV","vujxB","vujxC","vujxG","vujxL","vujxM","vujxN","vujxP","vujxZ","sxfaB","sxfaJ","sxfaL","sxfaP","ptdeB","ptdeI","cykoE","cykoG","cykoR","cydzI","cydzL","cydzM","aqctC","aqcte","aqctH","aqctQ"}
        TAKE_PLATFORM_WORLD = "saveku000|b19",
        STORAGE_X = 38,
        STORAGE_Y = 19
    },
    DROP_AMOUNT = 80, 
    DelaySettings = {  
        DELAY_PLACE = 120,
        DELAY_BREAK = 150  
    },  
    PLAT_ID = 102,
    WEBHOOK_URL = "https://discord.com/api/webhooks/1479853594416124016/Da1c-O02WM5AenCTT5GaKihq6oevBXvhjN4Br_lWQhkO_ESm8BcGMNTIf3bxIiVZW6_P",
    MESSAGE_ID = "1479953461448671425",
    RECONNECT_DELAY = 15,  
    USE_RANDOM_DELAY = true 
}

-- Optimization Settings
ChangeValue("[C] Antibounce", true)
ChangeValue("[C] No render shadow", true)
ChangeValue("[C] No render name", true)
ChangeValue("[C] No render particle", true)
ChangeValue("[C] Modfly v2", true)

local e = {
    crown = "<:crown:1477099247777353908>",
    online = "<a:online:1477099070110568579>",
    offline = "<a:warningbro:1337084933507645523>", 
    verif = "<a:Verif:1477099247777353908>",
    loading = "<a:loding:1477098771325124752>",
    arrow = "<a:ARROW:1378507917564579982>",
    warn = "<a:warningbro:1337084933507645523>",
    wlds = "<a:wlds:1351793663339921448>",
    char = "<:char_gt:1311762258329600030>",
    lvl = "<:Level:1311762258329600030>"
}

local lastX, lastY = 0, 0
local isPlayerMoving = true
local isOfflineNotified = false
local lastPacketTime = 0
local lastActivityTime = os.clock()
index_world = 1
dpc = Config.DelaySettings.DELAY_PLACE
dbk = Config.DelaySettings.DELAY_BREAK

-- =========================================
-- FIX: REMOVED GETPING TO PREVENT ERROR
-- =========================================

function markActivity()
    lastActivityTime = os.clock()
end

function getSmartDelay(baseDelay)
    if Config.USE_RANDOM_DELAY then
        return baseDelay + math.random(-15, 45)
    end
    return baseDelay
end

function sendWebhook(info_tambahan)
    local local_player = GetLocal()
    local statusEmoji, statusText, color, name, worldName
    local currentX, currentY = 0, 0
    local gems, level = 0, 0

    if not local_player or not local_player.pos then
        statusEmoji = e.offline
        statusText = "DISCONNECTED / RECONNECTING"
        color = 15158332 
        name = "Unknown (Offline)"
        worldName = "EXIT"
    else
        currentX, currentY = math.floor(local_player.pos.x / 32), math.floor(local_player.pos.y / 32)
        local timeSinceLastAct = os.clock() - lastActivityTime
        local isStuck = timeSinceLastAct > 60
        isPlayerMoving = (currentX ~= lastX or currentY ~= lastY)
        lastX, lastY = currentX, currentY
        name = local_player.name
        local pInfo = GetPlayerInfo()
        gems = pInfo and pInfo.gems or 0
        level = pInfo and pInfo.level or 0
        worldName = OnWorld()
        if isPlayerMoving and not isStuck then
            statusEmoji = e.online statusText = "ONLINE" color = 3066993 
        else
            statusEmoji = e.warn statusText = "STUCK / IDLE" color = 15158332 
        end
    end
    
    local content = string.format([[{"embeds": [{"title": "%s **RexV Monitor**","description": "%s **Player:** %s","color": %d,"fields": [{"name": "Status", "value": "%s **%s**", "inline": true},{"name": "%s Posisi", "value": "%d, %d", "inline": true},{"name": "%s Level", "value": "**%d**", "inline": true},{"name": "%s Gems", "value": "%d", "inline": true},{"name": "%s World", "value": "%s", "inline": true},{"name": "%s Info", "value": "%s", "inline": false}],"footer": { "text": "Last Update: %s | Auto-Resume Active" }}]}]], e.crown, e.char, name, color, statusEmoji, statusText, e.arrow, currentX, currentY, e.lvl, level, e.wlds, gems, e.verif, worldName, e.loading, info_tambahan, os.date("%H:%M:%S"))
    MakeRequest(Config.WEBHOOK_URL .. "/messages/" .. Config.MESSAGE_ID, "PATCH", {["Content-Type"] = "application/json"}, content)
end

function checkConn()
    -- REVISI: Menghapus GetPing() karena API tidak support
    if GetLocal() == nil or GetLocal().pos == nil then
        if not isOfflineNotified then
            sendWebhook("Connection Lost! Reconnecting...")
            isOfflineNotified = true
        end
        while GetLocal() == nil or GetLocal().pos == nil do 
            Sleep(5000) 
        end
        isOfflineNotified = false
        sendWebhook("Reconnected! Resuming Task...")
        Sleep(3000)
    end
end

function OnWorld()
    local n = GetWorld()
    if type(n) == "table" and n.name then return n.name:upper() end
    return "EXIT"
end

function pos() checkConn() return math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32) end

function packet(t, v, x, y)
    checkConn()
    local currentTime = os.clock() * 1000
    local jitter = math.random(0, 30)
    if currentTime - lastPacketTime < (50 + jitter) then Sleep((50 + jitter) - (currentTime - lastPacketTime)) end
    SendPacketRaw(false, {type = t, value = v, px = x, py = y, x = GetLocal().pos.x, y = GetLocal().pos.y})
    lastPacketTime = os.clock() * 1000
end

function log(x)
    SendVariantList({[0] = "OnTextOverlay", [1] = "`2[ RexV Script ]`0 : " .. x})
    LogToConsole("`2[ RexV Script ]`0 : " .. x)
end

-- =========================================
-- LOGIC FARMING (TETAP SAMA)
-- =========================================

function clearTrash()
    local trashItems = {11, 10, 2914, 5024, 5026, 5028, 5030, 5032, 5034, 5036, 5038, 5040, 5042, 5044}
    for _, id in ipairs(trashItems) do
        local count = GetItemCount(id)
        if count > 50 then
            SendPacket(2, "action|trash\nitemID|" .. id) Sleep(500)
            SendPacket(2, "action|dialog_return\ndialog_name|trash_item\nitemID|" .. id .. "|\ncount|" .. count) Sleep(500)
        end
    end
    for _, id in ipairs({2, 14, 4, 5}) do
        local count = GetItemCount(id)
        if count > 195 then
            SendPacket(2, "action|trash\nitemID|" .. id) Sleep(500)
            SendPacket(2, "action|dialog_return\ndialog_name|trash_item\nitemID|" .. id .. "|\ncount|20") Sleep(500)
        end
    end
end

function storeItems()
    local seeds = {3, 15}
    local needsDrop = false
    for _, id in ipairs(seeds) do if GetItemCount(id) >= 200 then needsDrop = true break end end
    if needsDrop then
        local lastWorld = OnWorld()
        warp(Config.World.TAKE_PLATFORM_WORLD, true) Sleep(2000)
        local dropX, dropY = Config.World.STORAGE_X, Config.World.STORAGE_Y
        FindPath(dropX, dropY, 400) Sleep(1000)
        for _, id in ipairs(seeds) do
            if GetItemCount(id) >= Config.DROP_AMOUNT then
                local isTileFull = false
                for _, obj in pairs(GetObjectList()) do
                    if math.floor(obj.pos.x / 32) == dropX and math.floor(obj.pos.y / 32) == dropY then
                        isTileFull = true break
                    end
                end
                if isTileFull then dropX = dropX - 1 FindPath(dropX, dropY, 400) Sleep(500) end
                SendPacket(2, "action|drop\nitemID|" .. id) Sleep(500)
                SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. id .. "|\ncount|" .. Config.DROP_AMOUNT) Sleep(1000)
                markActivity()
            end
        end
        warp(lastWorld, true) Sleep(2000)
    end
end

function finalSweep()
    for _, tile in pairs(GetTiles()) do
        if tile.fg == 3 and tile.extra and tile.extra.progress >= 1 then
            storeItems() FindPath(tile.x, tile.y, 400) moveAct("hit", tile.x, tile.y) collect(3)
        end
    end
    for _, obj in pairs(GetObjectList()) do
        storeItems() local ox, oy = math.floor(obj.pos.x / 32), math.floor(obj.pos.y / 32)
        FindPath(ox, oy, 400) collect(4) clearTrash()
    end
end

function warp(x, ignorePlayer)
    checkConn()
    markActivity()
    local worldName = x:match("([^|]+)"):upper()
    if OnWorld() == worldName then return true end
    log("Warping ke " .. x) Sleep(5000)
    RequestJoinWorld(x)
    local timeout = 0
    repeat Sleep(1000) timeout = timeout + 1 checkConn() until OnWorld() == worldName or timeout > 12
    if not ignorePlayer and #GetPlayerList() > 1 then return false end
    Sleep(2000) return true
end

function findNearest(px, py)
    local nearest, minDist = nil, math.huge
    for _, tile in pairs(GetTiles()) do
        if tile.fg == 4 then
            local dist = math.abs(tile.x - px) + math.abs(tile.y - py)
            if dist < minDist then nearest, minDist = tile, dist end
        end
    end
    return nearest
end

function collect(r)
    r = r or 2 local px, py = pos()
    for _, obj in pairs(GetObjectList()) do
        local dx, dy = math.abs(math.floor(obj.pos.x / 32) - px), math.abs(math.floor(obj.pos.y / 32) - py)
        if dx <= r and dy <= r then 
            packet(11, obj.oid, obj.pos.x + 6, 0) 
            markActivity()
            Sleep(getSmartDelay(150)) 
        end
    end
end

function moveAct(action, x, y, id, delay)
    checkConn() 
    packet(3, id or 18, x, y)
    markActivity()
    local finalDelay = delay or (action == "place" and dpc or dbk)
    Sleep(getSmartDelay(finalDelay))
end

function clearArea(positions, yStart, yEnd)
    for _, pos_pair in pairs(positions) do
        for y = yStart, yEnd do
            for _, x in pairs(pos_pair) do
                checkConn()
                while GetTile(x, y).bg == 14 or GetTile(x, y).fg == 2 do
                    storeItems() FindPath(x <= 1 and 1 or 98, y - 1, 400) moveAct("hit", x, y)
                    if GetTile(x, y).bg == 0 then collect(2) end
                    clearTrash()
                    checkConn()
                end
            end
        end
    end
end

function pPlatform()
    local myPlatCount = 0
    for py = 2, 52, 2 do
        if GetTile(1, py).fg == 0 then myPlatCount = myPlatCount + 1 end
        if GetTile(98, py).fg == 0 then myPlatCount = myPlatCount + 1 end
    end
    if myPlatCount > 0 and GetItemCount(Config.PLAT_ID) < myPlatCount then
        warp(Config.World.TAKE_PLATFORM_WORLD, true) 
        while GetItemCount(Config.PLAT_ID) < myPlatCount do
            checkConn()
            local item = nil
            for _, v in pairs(GetObjectList()) do if v.id == Config.PLAT_ID then item = v break end end
            if not item then break end
            FindPath(math.floor(item.pos.x / 32), math.floor(item.pos.y / 32), 400) collect(2) Sleep(500)
        end
        warp(Config.World.WHITELISTED_WORLD[index_world], true)
    end
    for _, x in pairs({1, 98}) do
        for py = 2, 52, 2 do
            while GetTile(x, py).fg == 0 do 
                checkConn()
                FindPath(x, py - 1, 400) moveAct("place", x, py, Config.PLAT_ID) 
            end
        end
    end
end

function farmAndPlace()
    local plantY = 23
    local function farmSeeds()
        while GetItemCount(2) == 0 do
            checkConn()
            storeItems() 
            for x = 2, 22 do
                checkConn()
                if GetItemCount(2) > 180 then break end
                local tile = GetTile(x, plantY)
                if tile.fg == 3 and tile.extra and tile.extra.progress >= 1 then
                    FindPath(x, plantY, 400) moveAct("hit", x, plantY) collect(2)
                elseif tile.fg == 0 and GetItemCount(3) > 0 then
                    FindPath(x, plantY, 400) moveAct("place", x, plantY, 3)
                end
            end
            Sleep(500)
        end
    end
    for y = 52, 2, -2 do
        for x = 2, 97, 3 do
            checkConn()
            if x + 2 > 97 then break end
            while GetTile(x, y).fg == 0 or GetTile(x+1, y).fg == 0 or GetTile(x+2, y).fg == 0 do
                checkConn()
                storeItems() farmSeeds() FindPath(x+1, y-1, 400)
                for i = 0, 2 do if GetTile(x+i, y).fg == 0 and GetItemCount(2) > 0 then moveAct("place", x+i, y, 2) end end
            end
        end
    end
end

-- =========================================
-- MAIN EXECUTION
-- =========================================

log("RexV Final Revision Started")
RunThread(function() while true do sendWebhook("Bot is Farming...") Sleep(10000) end end)

while true do
    checkConn()
    if index_world <= #Config.World.WHITELISTED_WORLD then
        local currentWorld = Config.World.WHITELISTED_WORLD[index_world]
        if OnWorld() == currentWorld:upper() or warp(currentWorld, false) then
            sendWebhook("Working on " .. OnWorld())
            clearArea({{0, 1}, {98, 99}}, 24, 53)
            pPlatform()

            for y = 1, 54, 2 do
                for x = 2, 97, 3 do
                    checkConn()
                    local nClear = false
                    for i = 0, 2 do if (GetTile(x+i, y).bg == 14 or GetTile(x+i, y).fg == 2) then nClear = true break end end
                    if nClear then
                        storeItems() FindPath(x+1, y-2, 400)
                        while nClear do
                            checkConn() nClear = false
                            for i = 0, 2 do
                                if (GetTile(x+i, y).bg == 14 or GetTile(x+i, y).fg == 2) then moveAct("hit", x+i, y) nClear = true end
                            end
                            collect(2) clearTrash()
                        end
                    end
                end
            end

            local px, py = pos()
            while true do
                checkConn() 
                local lava = findNearest(px, py)
                if not lava then break end
                storeItems() FindPath(lava.x, lava.y - 1, 400)
                px, py = lava.x, lava.y
                for dx = -1, 1 do for dy = -1, 1 do if GetTile(px+dx, py+dy).fg == 4 then moveAct("hit", px+dx, py+dy) end end end
                collect(5) clearTrash()
            end

            farmAndPlace() 
            finalSweep()
            log("Selesai world: " .. currentWorld)
            index_world = index_world + 1
        else
            log("Gagal masuk world, skip...")
            index_world = index_world + 1
        end
    else
        log("Semua world selesai!")
        sendWebhook("All Worlds Completed!")
        break 
    end
    Sleep(3000)
end
