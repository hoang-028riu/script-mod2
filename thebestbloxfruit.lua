-- Trình quản lý giữ Script khi Server Hop / Rejoin
-- Đảm bảo không bị xung đột khi nhiều script cùng muốn giữ lại.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo biến toàn cục để lưu trữ tập trung (chỉ chạy 1 lần dù script được load nhiều lần)
if not _G.TeleportQueueManager then
    _G.TeleportQueueManager = {
        -- Tìm hàm queue_on_teleport phù hợp với Executor của bạn
        QueueFunc = queue_on_teleport or 
                    (syn and syn.queue_on_teleport) or 
                    (fluxus and fluxus.queue_on_teleport) or 
                    (KRNL_LOADED and queue_on_teleport),
        Scripts = {}, -- Danh sách các đoạn mã cần chạy ở server mới
        HasHooked = false,
        IsTeleporting = false
    }
end

local Manager = _G.TeleportQueueManager

-- Hàm dùng để thêm script vào hàng đợi
local function AutoExecuteOnTeleport(scriptString)
    if not Manager.QueueFunc then
        warn("[TeleportManager]: Executor của bạn không hỗ trợ queue_on_teleport!")
        return false
    end

    -- Thêm script vào danh sách
    table.insert(Manager.Scripts, scriptString)

    -- Nếu chưa tạo sự kiện lắng nghe Teleport thì tạo ngay
    if not Manager.HasHooked then
        Manager.HasHooked = true

        LocalPlayer.OnTeleport:Connect(function(teleportState)
            -- Ngăn chặn việc gọi nhiều lần khi đang dịch chuyển
            if Manager.IsTeleporting then return end
            Manager.IsTeleporting = true

            -- Gom tất cả các script trong danh sách lại thành một kịch bản duy nhất
            local CombinedScript = ""
            
            for i, code in ipairs(Manager.Scripts) do
                -- Bọc mỗi script trong một task.spawn và pcall để nếu 1 script lỗi, các script khác vẫn chạy bình thường
                CombinedScript = CombinedScript .. string.format([[
                    task.spawn(function()
                        local success, err = pcall(function()
                            %s
                        end)
                        if not success then
                            warn("Lỗi khi load lại script phần %d:", err)
                        end
                    end)
                ]], code, i)
            end

            -- Đưa toàn bộ kịch bản đã gom vào hàng đợi của Executor
            Manager.QueueFunc(CombinedScript)
        end)
    end
    
    print("[TeleportManager]: Đã thêm 1 script vào hàng đợi dịch chuyển.")
    return true
end

-- ================================================================= --
-- DANH SÁCH CÁC SCRIPT KẾT HỢP (IY + BLOX FRUITS + CHEST FARM)
-- ================================================================= --

-- 1. Script Infinite Yield
local IY_Script = [[
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
]]

-- 2. Script Blox Fruits Menu
local BloxFruits_Script = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/bloxfruitscriptmenu.lua"))()
]]

-- 3. Script Chest Farm
local ChestFarm_Script = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/chest%20farm"))()
]]

-- Đưa tất cả vào hàng đợi cho server tiếp theo
AutoExecuteOnTeleport(IY_Script)
AutoExecuteOnTeleport(BloxFruits_Script)
AutoExecuteOnTeleport(ChestFarm_Script)

-- ================================================================= --
-- CHẠY TẤT CẢ SCRIPT NGAY TẠI SERVER HIỆN TẠI
-- ================================================================= --

local function ExecuteScript(code)
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(code)()
        end)
        if not success then warn("Lỗi khởi chạy script:", err) end
    end)
end

ExecuteScript(IY_Script)
ExecuteScript(BloxFruits_Script)
ExecuteScript(ChestFarm_Script)
