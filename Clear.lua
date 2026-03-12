Config = {
    World = {
        WHITELISTED_WORLD = {"VNCUZ","VZYMQ","UCKXH","YDCPP","IWQLN","OZHTJ","RSXUV","LDETJ","CNVEP","LQBVL","GXMUK","EBPEX","IGDDV","PZDQP","CKPZU","OGRKE","LJCTI"},
        TAKE_PLATFORM_WORLD = "saveku000|b19",
        STORAGE_X = 40,
        STORAGE_Y = 20
    },
    DROP_AMOUNT = 100, 
    DelaySettings = {  
        DELAY_PLACE = 200,
        DELAY_BREAK = 200  
    },  
    PLAT_ID = 102,
    WEBHOOK_URL = "https://discord.com/api/webhooks/1479853594416124016/Da1c-O02WM5AenCTT5GaKihq6oevBXvhjN4Br_lWQhkO_ESm8BcGMNTIf3bxIiVZW6_P",
    MESSAGE_ID = "1479953461448671425"
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
    char = "<:char_gt:1311762258329600030>"
}

local lastX, lastY = 0, 0
local isPlayerMoving = true
local isOfflineNotified = false
local lastPacketTime = 0
index_world = 1
dpc = Config.DelaySettings.DELAY_PLACE
dbk = Config.DelaySettings.DELAY_BREAK

-- =========================================
-- REVISI SYSTEM: AUTO RECONNECT & RUN
-- =========================================

function checkConn()
    if GetLocal() == nil or GetLocal().pos == nil then
        if not isOfflineNotified then
            LogToConsole("`4[RexV]`0 Connection Lost! Menunggu login kembali...")
            isOfflineNotified = true
        end
        while GetLocal() == nil or GetLocal().pos == nil do Sleep(5000) end
        isOfflineNotified = false
        log("Reconnected! Melanjutkan script...")
        Sleep(2000)
    end
end

function OnWorld()
    local n = GetWorld()
    if type(n) == "table" and n.name then return n.name:upper() end
    return "EXIT"
end

function sendWebhook(info_tambahan)
    local local_player = GetLocal()
    if not local_player then return end
    local currentX, currentY = math.floor(local_player.pos.x / 32), math.floor(local_player.pos.y / 32)
    isPlayerMoving = (currentX ~= lastX or currentY ~= lastY)
    lastX, lastY = currentX, currentY
    local statusEmoji = isPlayerMoving and e.online or e.offline
    local statusText = isPlayerMoving and "ONLINE" or "OFFLINE (IDLE)"
    local color = isPlayerMoving and 3066993 or 15158332
    local gems = GetPlayerInfo() and GetPlayerInfo().gems or 0
    local content = string.format([[{"embeds": [{"title": "%s **RexV Monitor**","description": "%s **Player:** %s","color": %d,"fields": [{"name": "Status", "value": "%s **%s**", "inline": true},{"name": "%s Posisi", "value": "%d, %d", "inline": true},{"name": "%s Gems", "value": "%d", "inline": true},{"name": "%s World", "value": "%s", "inline": true},{"name": "%s Info", "value": "%s", "inline": false}],"footer": { "text": "Last Update: %s | Auto-Resume Active" }}]}]], e.crown, e.char, local_player.name, color, statusEmoji, statusText, e.arrow, currentX, currentY, e.wlds, gems, e.verif, OnWorld(), e.loading, info_tambahan, os.date("%H:%M:%S"))
    MakeRequest(Config.WEBHOOK_URL .. "/messages/" .. Config.MESSAGE_ID, "PATCH", {["Content-Type"] = "application/json"}, content)
end

function pos() checkConn() return math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32) end

function packet(t, v, x, y)
    checkConn()
    local currentTime = os.clock() * 1000
    if currentTime - lastPacketTime < 50 then Sleep(50 - (currentTime - lastPacketTime)) end
    SendPacketRaw(false, {type = t, value = v, px = x, py = y, x = GetLocal().pos.x, y = GetLocal().pos.y})
    lastPacketTime = os.clock() * 1000
end

function log(x)
    SendVariantList({[0] = "OnTextOverlay", [1] = "`2[ RexV Script ]`0 : " .. x})
    LogToConsole("`2[ RexV Script ]`0 : " .. x)
end

-- =========================================
-- LOGIC FARMING (TIDAK BERUBAH)
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
        FindPath(Config.World.STORAGE_X, Config.World.STORAGE_Y, 400) Sleep(1000)
        for _, id in ipairs(seeds) do
            if GetItemCount(id) >= Config.DROP_AMOUNT then
                SendPacket(2, "action|drop\nitemID|" .. id) Sleep(500)
                SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. id .. "|\ncount|" .. Config.DROP_AMOUNT) Sleep(1000)
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
    local worldName = x:match("([^|]+)"):upper()
    if OnWorld() == worldName then return true end
    log("Warping to " .. x) Sleep(5000)
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
        if dx <= r and dy <= r then packet(11, obj.oid, obj.pos.x + 6, 0) Sleep(150) end
    end
end

function moveAct(action, x, y, id, delay)
    checkConn() packet(3, id or 18, x, y)
    Sleep(delay or (action == "place" and dpc or dbk))
end

function clearArea(positions, yStart, yEnd)
    for _, pos_pair in pairs(positions) do
        for y = yStart, yEnd do
            for _, x in pairs(pos_pair) do
                while GetTile(x, y).bg == 14 or GetTile(x, y).fg == 2 do
                    storeItems() FindPath(x <= 1 and 1 or 98, y - 1, 400) moveAct("hit", x, y)
                    if GetTile(x, y).bg == 0 then collect(2) end
                    clearTrash()
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
            local item = nil
            for _, v in pairs(GetObjectList()) do if v.id == Config.PLAT_ID then item = v break end end
            if not item then break end
            FindPath(math.floor(item.pos.x / 32), math.floor(item.pos.y / 32), 400) collect(2) Sleep(500)
        end
        warp(Config.World.WHITELISTED_WORLD[index_world], true)
    end
    for _, x in pairs({1, 98}) do
        for py = 2, 52, 2 do
            while GetTile(x, py).fg == 0 do FindPath(x, py - 1, 400) moveAct("place", x, py, Config.PLAT_ID) end
        end
    end
end

function farmAndPlace()
    local plantY = 23
    local function farmSeeds()
        while GetItemCount(2) == 0 do
            storeItems() 
            for x = 2, 22 do
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
            if x + 2 > 97 then break end
            while GetTile(x, y).fg == 0 or GetTile(x+1, y).fg == 0 or GetTile(x+2, y).fg == 0 do
                storeItems() farmSeeds() FindPath(x+1, y-1, 400)
                for i = 0, 2 do if GetTile(x+i, y).fg == 0 and GetItemCount(2) > 0 then moveAct("place", x+i, y, 2) end end
            end
        end
    end
end

-- =========================================
-- MAIN EXECUTION (AUTO-RUN REVISI)
-- =========================================

log("RexV Started")
RunThread(function() while true do if GetLocal() then sendWebhook("Running...") end Sleep(10000) end end)

while index_world <= #Config.World.WHITELISTED_WORLD do
    checkConn()
    local currentWorld = Config.World.WHITELISTED_WORLD[index_world]
    
    -- REVISI: Cek apakah bot sudah di world tujuan (setelah reconnect)
    if OnWorld() == currentWorld:upper() or warp(currentWorld, false) then
        sendWebhook("Cleaning " .. OnWorld())
        
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
            checkConn() local lava = findNearest(px, py)
            if not lava then break end
            storeItems() FindPath(lava.x, lava.y - 1, 400)
            px, py = lava.x, lava.y
            for dx = -1, 1 do for dy = -1, 1 do if GetTile(px+dx, py+dy).fg == 4 then moveAct("hit", px+dx, py+dy) end end end
            collect(5) clearTrash()
        end

        farmAndPlace() finalSweep()
        index_world = index_world + 1
    else
        index_world = index_world + 1
    end
    Sleep(2000)
end

log("Done!")
sendWebhook("All Worlds Done!")
