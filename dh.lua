-- AUTO REROLL FIEND - Main Script (Loadstring Version)
-- วิธีใช้: loadstring(game:HttpGet("YOUR_URL"))()
-- หรือ: loadstring(readfile("main_loadstring.lua"))()

print("========================================")
print("🎯 AUTO REROLL FIEND SYSTEM")
print("⚡ Optimized for 5 Windows")
print("========================================")

-- สุ่มดีเลย์เริ่มต้น (0-10 วินาที)
local initialDelay = math.random(0, 10)
if initialDelay > 0 then
    print("⏳ รอ " .. initialDelay .. " วินาที (กระจายจอ)")
    wait(initialDelay)
end

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =====================================
-- CONFIGURATION
-- =====================================
local CONFIG = {
    WEBHOOK_URL = "https://discord.com/api/webhooks/1462944559045804225/qO1XQ6KjCZpWGaRiqX-8A-HeKq2Rpil1kZXUUaeOCDx9aJ_N02QgszWkX3osyC6cQTv9",
    WEBHOOK_COOLDOWN = 5, -- วินาที
    TIMEOUT_GUI = 8,
    TIMEOUT_SHORT = 6,
    RARE_FIENDS = {"Gun", "Angel"},
    ALL_FIENDS = {"Nail", "Shark", "Violence", "Blood", "Gun", "Angel"}
}

-- =====================================
-- UTILITY FUNCTIONS
-- =====================================

-- สุ่มชื่อ
local function generateRandomName()
    local chars = "abcdefghijklmnopqrstuvwxyz"
    local name = ""
    local length = math.random(4, 8)
    
    for i = 1, length do
        local randIndex = math.random(1, #chars)
        name = name .. chars:sub(randIndex, randIndex)
    end
    
    return name
end

-- หา RemoteFunction จาก nil instances
local function getNil(name, className)
    for _, v in pairs(getnilinstances()) do
        if v.ClassName == className and v.Name == name then
            return v
        end
    end
    return nil
end

-- ส่ง Discord Webhook
local function sendDiscordWebhook(fiendType)
    -- Rate Limit Check
    if _G.lastWebhookTime and (tick() - _G.lastWebhookTime) < CONFIG.WEBHOOK_COOLDOWN then
        print("⚠ Webhook Rate Limited - รอ " .. math.ceil(CONFIG.WEBHOOK_COOLDOWN - (tick() - _G.lastWebhookTime)) .. " วินาที")
        return
    end
    _G.lastWebhookTime = tick()
    
    local HttpService = game:GetService("HttpService")
    
    local data = {
        ["content"] = "🎯 **RARE FIEND FOUND!**",
        ["embeds"] = {{
            ["title"] = "✨ " .. fiendType .. " Fiend Detected!",
            ["description"] = "ผู้เล่น: **" .. player.Name .. "**\nพบ: **" .. fiendType .. " Fiend**",
            ["color"] = fiendType == "Gun" and 16776960 or 15844367,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }
    
    local success, response = pcall(function()
        return request({
            Url = CONFIG.WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success then
        print("✓ ส่งแจ้งเตือน Discord สำเร็จ!")
    else
        print("✗ ส่ง Webhook ไม่สำเร็จ:", response)
    end
end

-- =====================================
-- STEP 1: AUTO JOIN GAME
-- =====================================

local function autoJoinGame()
    print("========================================")
    print("📍 ขั้นที่ 1: AUTO JOIN GAME")
    print("========================================")
    
    -- กด Skip (ถ้ามี)
    local function clickSkip()
        print("⏳ กำลังหาปุ่ม Skip...")
        wait(0.5)
        
        local success, playerGui = pcall(function()
            return player:WaitForChild("PlayerGui", CONFIG.TIMEOUT_GUI)
        end)
        
        if not success or not playerGui then
            print("⚠ ไม่พบ PlayerGui - ข้าม Skip")
            return false
        end
        
        local success2, descendants = pcall(function()
            return playerGui:GetDescendants()
        end)
        
        if not success2 then
            print("⚠ ไม่สามารถอ่าน Descendants - ข้าม Skip")
            return false
        end
        
        for _, gui in pairs(descendants) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                local text = string.lower(gui.Name or "")
                if gui:IsA("TextButton") and gui.Text then
                    text = string.lower(gui.Text)
                end
                
                if string.find(text, "skip") then
                    print("✓ พบปุ่ม Skip - กำลังกด...")
                    for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                        connection:Fire()
                    end
                    wait(0.5)
                    return true
                end
            end
        end
        
        print("⚠ ไม่พบปุ่ม Skip")
        return false
    end
    
    -- เรียก Remote เข้าเกม
    local function joinGameWithRemote()
        print("⏳ กำลังเรียก Remote เพื่อเข้าเกม...")
        wait(1)
        
        local success, result = pcall(function()
            local files = ReplicatedStorage:WaitForChild("Files", CONFIG.TIMEOUT_GUI)
            if not files then error("ไม่พบ Files") end
            
            local remotes = files:WaitForChild("Remotes", CONFIG.TIMEOUT_GUI)
            if not remotes then error("ไม่พบ Remotes") end
            
            local loadedRemote = remotes:WaitForChild("Loaded", CONFIG.TIMEOUT_GUI)
            if not loadedRemote then error("ไม่พบ Loaded Remote") end
            
            print("✓ กำลังเรียก Remote...")
            loadedRemote:FireServer()
            print("✓ เรียก Remote สำเร็จ!")
            return true
        end)
        
        if not success then
            print("❌ เรียก Remote ไม่สำเร็จ:", result)
            return false
        end
        
        return true
    end
    
    -- รันขั้นตอน
    wait(1)
    clickSkip()
    
    local joinDelay = math.random(5, 20) / 10
    print("⏳ รอ " .. joinDelay .. " วินาที ก่อนเรียก Remote")
    wait(joinDelay)
    
    if joinGameWithRemote() then
        print("✓ เข้าเกมสำเร็จ!")
        return true
    else
        print("❌ เข้าเกมไม่สำเร็จ")
        return false
    end
end

-- =====================================
-- STEP 2: SELECT CHARACTER (FIEND)
-- =====================================

local function selectCharacter()
    print("========================================")
    print("📍 ขั้นที่ 2: AUTO SELECT CHARACTER")
    print("========================================")
    
    local playerGui = player:WaitForChild("PlayerGui", 15)
    if not playerGui then
        warn("❌ ไม่สามารถโหลด PlayerGui")
        return false
    end
    
    -- รอให้หน้า Character Creation โหลด
    print("⏳ รอให้หน้า Character Creation โหลด...")
    wait(8)
    
    -- ฟังก์ชันรอและหาปุ่ม
    local function waitForButton(buttonName, timeout)
        timeout = timeout or 8
        local startTime = tick()
        
        while (tick() - startTime) < timeout do
            local success, descendants = pcall(function()
                return playerGui:GetDescendants()
            end)
            
            if not success then
                wait(1)
                continue
            end
            
            for _, gui in pairs(descendants) do
                if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                    local name = string.lower(gui.Name or "")
                    local text = ""
                    local parentName = ""
                    
                    if gui:IsA("TextButton") and gui.Text then
                        text = string.lower(gui.Text)
                    end
                    
                    if gui.Parent then
                        parentName = string.lower(gui.Parent.Name or "")
                    end
                    
                    local searchTerm = string.lower(buttonName)
                    if string.find(name, searchTerm) or 
                       string.find(text, searchTerm) or 
                       string.find(parentName, searchTerm) then
                        return gui
                    end
                end
            end
            wait(0.5)
        end
        
        return nil
    end
    
    -- ฟังก์ชันกดปุ่ม
    local function clickButton(buttonName, timeout)
        print("⏳ กำลังรอปุ่ม:", buttonName)
        
        local button = waitForButton(buttonName, timeout)
        
        if button then
            print("✓ พบปุ่ม:", buttonName)
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
            end
            wait(0.5)
            return true
        else
            print("❌ ไม่พบปุ่ม:", buttonName)
            return false
        end
    end
    
    -- ฟังก์ชันหา TextBox
    local function waitForTextBox(timeout)
        timeout = timeout or 12
        local startTime = tick()
        
        print("🔍 กำลังค้นหาช่องใส่ชื่อ...")
        
        while (tick() - startTime) < timeout do
            for _, gui in pairs(playerGui:GetDescendants()) do
                if gui:IsA("TextBox") and gui.Visible then
                    local name = string.lower(gui.Name or "")
                    local parent = gui.Parent and string.lower(gui.Parent.Name or "") or ""
                    
                    if string.find(name, "name") or 
                       string.find(parent, "name") or 
                       string.find(name, "text") or
                       gui.PlaceholderText and string.find(string.lower(gui.PlaceholderText), "name") then
                        print("✓ พบช่องใส่ชื่อ:", gui.Name)
                        return gui
                    end
                    
                    return gui
                end
            end
            wait(1)
        end
        
        return nil
    end
    
    -- ฟังก์ชันใส่ชื่อ
    local function inputName(name, timeout)
        timeout = timeout or 12
        
        local textBox = waitForTextBox(timeout)
        
        if not textBox then
            print("❌ ไม่พบช่องใส่ชื่อ")
            return false
        end
        
        print("📝 กำลังใส่ชื่อ:", name)
        
        local attempts = 0
        local maxAttempts = 3
        
        while attempts < maxAttempts do
            attempts = attempts + 1
            
            textBox.Text = ""
            wait(0.2)
            
            textBox.Text = name
            wait(0.3)
            
            if textBox.Text == name then
                print("✓ ใส่ชื่อสำเร็จ:", textBox.Text)
                
                pcall(function()
                    for _, connection in pairs(getconnections(textBox.FocusLost)) do
                        connection:Fire()
                    end
                end)
                
                wait(0.3)
                return true
            else
                print("⚠ ลองใหม่... (" .. attempts .. "/" .. maxAttempts .. ")")
                wait(0.5)
            end
        end
        
        print("❌ ไม่สามารถใส่ชื่อได้")
        return false
    end
    
    -- เริ่มกระบวนการสร้างตัวละคร
    local randomName = generateRandomName()
    print("📝 ชื่อที่สุ่ม:", randomName)
    
    -- ขั้นที่ 1: ใส่ชื่อ
    if not inputName(randomName) then
        return false
    end
    wait(1)
    
    -- ขั้นที่ 2: เลือกเพศ (Male)
    if not clickButton("male", 10) then
        return false
    end
    wait(1)
    
    -- ขั้นที่ 3: เลือก Race (Fiend)
    if not clickButton("fiend", 10) then
        return false
    end
    wait(1)
    
    -- ขั้นที่ 4: ยืนยัน (COMPLETE เป็นชื่อจริง)
    local confirmed = clickButton("complete", 10) or 
                     clickButton("submit", 5) or 
                     clickButton("confirm", 5) or
                     clickButton("next", 5) or
                     clickButton("create", 5)
    
    if confirmed then
        print("✓ สร้างตัวละครสำเร็จ!")
        return true
    else
        print("❌ ไม่พบปุ่มยืนยัน - ลองเรียก Remote...")
        
        -- ลองใช้ Remote แทน
        wait(2)
        local submitRemote = getNil("SubmitCustomization", "RemoteFunction")
        
        if submitRemote then
            print("✓ พบ SubmitCustomization Remote")
            
            local success, result = pcall(function()
                return submitRemote:InvokeServer(randomName, "Male", "Fiend")
            end)
            
            if success then
                print("✓ เรียก Remote สำเร็จ!")
                return true
            else
                print("❌ เรียก Remote ไม่สำเร็จ:", result)
                return false
            end
        else
            print("❌ ไม่พบ SubmitCustomization Remote")
            return false
        end
    end
end

-- =====================================
-- STEP 3: CHECK FIEND TYPE
-- =====================================

local function checkFiendType()
    print("========================================")
    print("📍 ขั้นที่ 3: CHECK FIEND TYPE")
    print("========================================")
    
    -- รอให้ UI โหลด
    print("⏳ รอให้ UI โหลดเสร็จ...")
    wait(6)
    
    local playerGui = player:WaitForChild("PlayerGui", CONFIG.TIMEOUT_GUI)
    if not playerGui then
        print("❌ ไม่พบ PlayerGui")
        return false, nil
    end
    
    local hud = playerGui:WaitForChild("HUD", CONFIG.TIMEOUT_SHORT)
    if not hud then
        print("❌ ไม่พบ HUD")
        return false, nil
    end
    
    local modeBars = hud:WaitForChild("ModeBars", CONFIG.TIMEOUT_SHORT)
    if not modeBars then
        print("❌ ไม่พบ ModeBars")
        return false, nil
    end
    
    print("✓ UI โหลดเสร็จแล้ว")
    wait(1)
    
    print("🔍 เริ่มเช็ค Fiend Type จาก ModeBars")
    
    local foundFiend = false
    local fiendComponents = {}
    local rareFound = false
    local rareType = ""
    
    -- เช็ค ModeBars
    local success, descendants = pcall(function()
        return modeBars:GetDescendants()
    end)
    
    if not success or not descendants then
        print("❌ ไม่สามารถอ่าน ModeBars Descendants")
        return false, nil
    end
    
    for _, descendant in pairs(descendants) do
        local componentName = descendant.Name
        
        for _, pattern in pairs(CONFIG.ALL_FIENDS) do
            if string.find(componentName, pattern) then
                foundFiend = true
                table.insert(fiendComponents, componentName)
                
                -- เช็คว่าเป็น Rare หรือไม่
                for _, rarePattern in pairs(CONFIG.RARE_FIENDS) do
                    if string.find(componentName, rarePattern) then
                        rareFound = true
                        rareType = rarePattern
                        break
                    end
                end
            end
        end
    end
    
    print("========================================")
    if foundFiend then
        print("✓ พบ Fiend Components:")
        for _, comp in pairs(fiendComponents) do
            print("  → " .. comp)
        end
        
        if rareFound then
            print("🎯 พบ RARE FIEND: " .. rareType .. "!")
            sendDiscordWebhook(rareType)
            return true, rareType
        else
            print("⚠ พบ Fiend แต่ไม่ใช่ Rare")
            return true, "Common"
        end
    else
        print("✗ ไม่พบ Fiend Components")
        return false, nil
    end
end

-- =====================================
-- MAIN EXECUTION
-- =====================================

print("========================================")
print("🚀 เริ่มต้นกระบวนการ...")
print("========================================")

-- Step 1: Join Game
if not autoJoinGame() then
    warn("❌ ไม่สามารถเข้าเกมได้ - หยุดการทำงาน")
    return
end

wait(2)

-- Step 2: Select Character
if not selectCharacter() then
    warn("❌ ไม่สามารถสร้างตัวละครได้ - หยุดการทำงาน")
    return
end

wait(2)

-- Step 3: Check Fiend Type
local isRare, fiendType = checkFiendType()

print("========================================")
if isRare and fiendType and (fiendType == "Gun" or fiendType == "Angel") then
    print("✨ พบ RARE FIEND: " .. fiendType)
    print("🎉 สำเร็จ! หยุดการทำงาน")
else
    print("⚠ ไม่ใช่ Rare Fiend - ต้อง Reroll")
    print("💡 รัน Script นี้อีกครั้งเพื่อ Reroll")
end
print("========================================")
