local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CLE_SECRETE = "Made by vmp"

local MOTS_RARES = {
    "secret", "eternal", "divine"
}

local RARES = {
    ["Secret"]  = Color3.fromRGB(60, 60, 60),
    ["Eternal"] = Color3.fromRGB(255, 182, 193),
    ["Divine"]  = Color3.fromRGB(255, 215, 0),
}

local CFG = {
    ESP_Actif = false,
    AutoSteal_Actif = false,
    WalkSpeed_Actif = false,
    Snipe_Actif = false,
    WalkSpeedValeur = 30,
    SnipeDureeCible = 8,
    SnipeCooldown = 3,
    SegmentMax = 8,
    AutoStealDistance = 12,
    AutoStealCooldown = 0.3,
}

local VITESSE_MAX_SAFE = 60

local function randName()
    local p = {"Cache", "Sys", "Cfg", "Ref", "Node", "Data"}
    return p[math.random(1, #p)] .. math.random(10000, 99999)
end

local function getPosition(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if pp then return pp.Position end
    end
    return nil
end

local function estUnOeuf(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false, nil end
    local nom = obj.Name:lower()
    local estOeuf = nom:find("egg") or nom:find("oeuf")
        or obj:GetAttribute("IsEgg") or obj:GetAttribute("EggType")
    if not estOeuf then return false, nil end

    for _, mot in ipairs(MOTS_RARES) do
        if nom:find(mot) then
            for k, v in pairs(RARES) do
                if k:lower():find(mot) or mot:find(k:lower()) then
                    return true, k, v
                end
            end
            return true, "Rare", Color3.fromRGB(255, 200, 0)
        end
    end

    local attr = obj:GetAttribute("Rarity") or obj:GetAttribute("Rarete")
    if attr and type(attr) == "string" then
        for k, v in pairs(RARES) do
            if attr:lower():find(k:lower()) then return true, k, v end
        end
    end
    return false, nil
end

local gui = Instance.new("ScreenGui")
gui.Name = randName()
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 300, 0, 180)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
keyFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Parent = gui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 10)

local keyHeader = Instance.new("Frame")
keyHeader.Size = UDim2.new(1, 0, 0, 38)
keyHeader.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
keyHeader.BorderSizePixel = 0
keyHeader.Parent = keyFrame
Instance.new("UICorner", keyHeader).CornerRadius = UDim.new(0, 10)

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -20, 1, 0)
keyTitle.Position = UDim2.new(0, 15, 0, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔒 Vérification"
keyTitle.TextColor3 = Color3.new(1, 1, 1)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 14
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyHeader

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -30, 0, 25)
keyLabel.Position = UDim2.new(0, 15, 0, 50)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Entre la clé d'accès :"
keyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 12
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -30, 0, 34)
keyInput.Position = UDim2.new(0, 15, 0, 80)
keyInput.BackgroundColor3 = Color3.fromRGB(30, 33, 40)
keyInput.BorderSizePixel = 0
keyInput.Text = ""
keyInput.PlaceholderText = "Mot de passe..."
keyInput.PlaceholderColor3 = Color3.fromRGB(100, 103, 112)
keyInput.TextColor3 = Color3.new(1, 1, 1)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 12
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 6)

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(1, -30, 0, 34)
keyButton.Position = UDim2.new(0, 15, 0, 125)
keyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
keyButton.Text = "Valider"
keyButton.TextColor3 = Color3.new(1, 1, 1)
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 13
keyButton.Parent = keyFrame
Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0, 6)

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -30, 0, 15)
keyStatus.Position = UDim2.new(0, 15, 0, 162)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 10
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.Parent = keyFrame

local dragKT, dragKS, startKP
keyFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragKT, dragKS, startKP = true, i.Position, keyFrame.Position
    end
end)
keyFrame.InputChanged:Connect(function(i)
    if dragKT and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragKS
        keyFrame.Position = UDim2.new(startKP.X.Scale, startKP.X.Offset + d.X, startKP.Y.Scale, startKP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragKT = false end
end)

local accesAccorde = false
local tentatives = 0
local MAX_TENTATIVES = 5

local function lancerScriptPrincipal()
    if accesAccorde then return end
    accesAccorde = true
    keyFrame:Destroy()

    local espFolder = Instance.new("Folder")
    espFolder.Name = randName()
    espFolder.Parent = CoreGui

    local espObjects = {}
    local raresTrouvees = {}

    local function creerESP(objet, rarete, couleur)
        if espObjects[objet] then return end

        local highlight = Instance.new("Highlight")
        highlight.FillColor = couleur
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = objet

        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 160, 0, 45)
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 500
        bb.Parent = objet

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0.6, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "⭐ " .. rarete
        lbl.TextColor3 = couleur
        lbl.TextStrokeTransparency = 0
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.Parent = bb

        local dist = Instance.new("TextLabel")
        dist.Size = UDim2.new(1, 0, 0.4, 0)
        dist.Position = UDim2.new(0, 0, 0.6, 0)
        dist.BackgroundTransparency = 1
        dist.TextColor3 = Color3.fromRGB(220, 220, 220)
        dist.TextStrokeTransparency = 0
        dist.TextScaled = true
        dist.Font = Enum.Font.Gotham
        dist.Parent = bb

        espObjects[objet] = {highlight = highlight, billboard = bb, dist = dist}
    end

    local function supprimerESP(objet)
        if espObjects[objet] then
            if espObjects[objet].highlight then espObjects[objet].highlight:Destroy() end
            if espObjects[objet].billboard then espObjects[objet].billboard:Destroy() end
            espObjects[objet] = nil
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.4)
            if not CFG.ESP_Actif then
                for obj in pairs(espObjects) do supprimerESP(obj) end
                raresTrouvees = {}
                continue
            end

            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local nouvelles = {}

            for _, obj in ipairs(workspace:GetDescendants()) do
                local isEgg, rarete, couleur = estUnOeuf(obj)
                if isEgg and rarete then
                    if not espObjects[obj] then creerESP(obj, rarete, couleur) end
                    local pos = getPosition(obj)
                    if pos and hrp and espObjects[obj] then
                        local d = math.floor((hrp.Position - pos).Magnitude)
                        espObjects[obj].dist.Text = d .. " studs"
                        table.insert(nouvelles, {
                            nom = obj.Name, rarete = rarete,
                            distance = d, couleur = couleur,
                            objet = obj, position = pos,
                        })
                    end
                end
            end

            for obj in pairs(espObjects) do
                if not obj.Parent then supprimerESP(obj) end
            end

            raresTrouvees = nouvelles
        end
    end)

    local dernierSteal = 0

    local function tenterRamassage(oeuf)
        local cd = oeuf:FindFirstChildOfClass("ClickDetector")
        if cd then pcall(fireclickdetector, cd) return true end
        local pp = oeuf:FindFirstChildOfClass("ProximityPrompt")
        if not pp and oeuf:IsA("Model") then
            pp = oeuf:FindFirstChildOfClass("ProximityPrompt", true)
        end
        if pp then pcall(fireproximityprompt, pp) return true end
        if oeuf:IsA("Tool") then
            pcall(function() oeuf.Parent = LP.Character end)
            return true
        end
        return false
    end

    task.spawn(function()
        while true do
            task.wait(0.1)
            if not CFG.AutoSteal_Actif then continue end

            local now = tick()
            if now - dernierSteal < CFG.AutoStealCooldown then continue end

            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local cible, distMin = nil, CFG.AutoStealDistance
            for _, obj in ipairs(workspace:GetDescendants()) do
                local isEgg, rarete = estUnOeuf(obj)
                if isEgg and rarete then
                    local pos = getPosition(obj)
                    if pos then
                        local d = (hrp.Position - pos).Magnitude
                        if d < distMin then distMin = d cible = obj end
                    end
                end
            end

            if cible and tenterRamassage(cible) then
                dernierSteal = now
            end
        end
    end)

    local function appliquerWalkSpeed(valeur)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if CFG.WalkSpeed_Actif then
            hum.WalkSpeed = math.min(valeur, VITESSE_MAX_SAFE)
        else
            hum.WalkSpeed = 16
        end
    end

    LP.CharacterAdded:Connect(function(char)
        task.wait(1)
        if CFG.WalkSpeed_Actif then appliquerWalkSpeed(CFG.WalkSpeedValeur) end
    end)

    local function deplacerSegmente(positionDepart, positionArrivee, dureeCible)
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local distanceTotale = (positionArrivee - positionDepart).Magnitude
        if distanceTotale < 1 then return true end

        local nbSegments = math.ceil(distanceTotale / CFG.SegmentMax)
        local dureeParSegment = dureeCible / nbSegments
        local direction = (positionArrivee - positionDepart).Unit

        hrp.Anchored = true
        local positionActuelle = positionDepart

        for i = 1, nbSegments do
            local reste = (positionArrivee - positionActuelle).Magnitude
            local pas = math.min(CFG.SegmentMax, reste)
            local cibleSegment = positionActuelle + direction * pas

            if i == nbSegments then
                cibleSegment = positionArrivee
            end

            local tween = TweenService:Create(
                hrp,
                TweenInfo.new(dureeParSegment, Enum.EasingStyle.Linear),
                {CFrame = CFrame.new(cibleSegment)}
            )
            tween:Play()
            tween.Completed:Wait()

            positionActuelle = cibleSegment
        end

        hrp.Anchored = false
        return true
    end

    local snipeEnCours = false
    local dernierSnipe = 0

    local function snipeRare(objetCible)
        if snipeEnCours then return false end
        if not objetCible or not objetCible.Parent then return false end

        local now = tick()
        if now - dernierSnipe < CFG.SnipeCooldown then return false end

        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local cframeDepart = hrp.CFrame
        local positionDepart = cframeDepart.Position

        local posCible = getPosition(objetCible)
        if not posCible then return false end
        local positionArrivee = posCible + Vector3.new(0, 3, 0)

        snipeEnCours = true
        dernierSnipe = now

        task.spawn(function()
            deplacerSegmente(positionDepart, positionArrivee, CFG.SnipeDureeCible / 2)

            task.wait(0.2)
            tenterRamassage(objetCible)
            task.wait(0.2)

            deplacerSegmente(positionArrivee, positionDepart, CFG.SnipeDureeCible / 2)

            local hrp2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                hrp2.CFrame = cframeDepart
            end

            snipeEnCours = false
        end)

        return true
    end

    task.spawn(function()
        while true do
            task.wait(0.5)
            if not CFG.Snipe_Actif then continue end
            if snipeEnCours then continue end

            local now = tick()
            if now - dernierSnipe < CFG.SnipeCooldown then continue end

            local cible, distMin = nil, math.huge
            for _, info in ipairs(raresTrouvees) do
                if info.objet and info.objet.Parent then
                    if info.distance < distMin then
                        distMin = info.distance
                        cible = info.objet
                    end
                end
            end

            if cible then snipeRare(cible) end
        end
    end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 420)
    frame.Position = UDim2.new(0.5, -160, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local dragT, dragS, startP
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragT, dragS, startP = true, i.Position, frame.Position
        end
    end)
    frame.InputChanged:Connect(function(i)
        if dragT and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragS
            frame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragT = false end
    end)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
    header.BorderSizePixel = 0
    header.Parent = frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local titre = Instance.new("TextLabel")
    titre.Size = UDim2.new(1, -60, 1, 0)
    titre.Position = UDim2.new(0, 15, 0, 0)
    titre.BackgroundTransparency = 1
    titre.Text = "Steal An Egg | Rare Sniper"
    titre.TextColor3 = Color3.new(1, 1, 1)
    titre.Font = Enum.Font.GothamBold
    titre.TextSize = 13
    titre.TextXAlignment = Enum.TextXAlignment.Left
    titre.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        CFG.ESP_Actif, CFG.AutoSteal_Actif = false, false
        CFG.WalkSpeed_Actif, CFG.Snipe_Actif = false, false
        appliquerWalkSpeed(16)
        for obj in pairs(espObjects) do supprimerESP(obj) end
        gui:Destroy()
    end)

    local function creerToggle(nom, y, variable, onChange)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 36)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
        btn.Text = nom .. " : OFF"
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            CFG[variable] = not CFG[variable]
            if CFG[variable] then
                btn.Text = nom .. " : ON"
                btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                btn.Text = nom .. " : OFF"
                btn.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            if onChange then onChange(CFG[variable]) end
        end)
        return btn
    end

    creerToggle("👁️ ESP Rares", 50, "ESP_Actif")
    creerToggle("🥚 Auto Steal", 90, "AutoSteal_Actif")
    creerToggle("🏃 WalkSpeed", 130, "WalkSpeed_Actif", function(on)
        appliquerWalkSpeed(on and CFG.WalkSpeedValeur or 16)
    end)
    creerToggle("🚀 Snipe Auto (A→B→A)", 170, "Snipe_Actif")

    local wsLabel = Instance.new("TextLabel")
    wsLabel.Size = UDim2.new(0.9, 0, 0, 18)
    wsLabel.Position = UDim2.new(0.05, 0, 0, 212)
    wsLabel.BackgroundTransparency = 1
    wsLabel.Text = "WalkSpeed : " .. CFG.WalkSpeedValeur .. " (max " .. VITESSE_MAX_SAFE .. ")"
    wsLabel.TextColor3 = Color3.fromRGB(150, 153, 162)
    wsLabel.Font = Enum.Font.Gotham
    wsLabel.TextSize = 11
    wsLabel.TextXAlignment = Enum.TextXAlignment.Left
    wsLabel.Parent = frame

    local wsFrame = Instance.new("Frame")
    wsFrame.Size = UDim2.new(0.9, 0, 0, 10)
    wsFrame.Position = UDim2.new(0.05, 0, 0, 234)
    wsFrame.BackgroundColor3 = Color3.fromRGB(40, 43, 52)
    wsFrame.BorderSizePixel = 0
    wsFrame.Parent = frame
    Instance.new("UICorner", wsFrame).CornerRadius = UDim.new(0, 4)

    local wsFill = Instance.new("Frame")
    wsFill.Size = UDim2.new(0.3, 0, 1, 0)
    wsFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    wsFill.BorderSizePixel = 0
    wsFill.Parent = wsFrame
    Instance.new("UICorner", wsFill).CornerRadius = UDim.new(0, 4)

    local wsBtn = Instance.new("TextButton")
    wsBtn.Size = UDim2.new(0, 22, 0, 22)
    wsBtn.Position = UDim2.new(0.3, -11, 0.5, -11)
    wsBtn.BackgroundColor3 = Color3.new(1, 1, 1)
    wsBtn.Text = ""
    wsBtn.Parent = wsFrame
    Instance.new("UICorner", wsBtn).CornerRadius = UDim.new(1, 0)

    local wsActif = false
    local function majWS(i)
        local x = i.Position.X - wsFrame.AbsolutePosition.X
        local p = math.clamp(x / wsFrame.AbsoluteSize.X, 0, 1)
        wsFill.Size = UDim2.new(p, 0, 1, 0)
        wsBtn.Position = UDim2.new(p, -11, 0.5, -11)
        CFG.WalkSpeedValeur = math.floor(16 + p * (VITESSE_MAX_SAFE - 16))
        wsLabel.Text = "WalkSpeed : " .. CFG.WalkSpeedValeur .. " (max " .. VITESSE_MAX_SAFE .. ")"
        if CFG.WalkSpeed_Actif then appliquerWalkSpeed(CFG.WalkSpeedValeur) end
    end
    wsBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then wsActif = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if wsActif and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then majWS(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then wsActif = false end
    end)

    local snLabel = Instance.new("TextLabel")
    snLabel.Size = UDim2.new(0.9, 0, 0, 18)
    snLabel.Position = UDim2.new(0.05, 0, 0, 258)
    snLabel.BackgroundTransparency = 1
    snLabel.Text = "Snipe durée : " .. CFG.SnipeDureeCible .. " secondes (min 7)"
    snLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
    snLabel.Font = Enum.Font.Gotham
    snLabel.TextSize = 11
    snLabel.TextXAlignment = Enum.TextXAlignment.Left
    snLabel.Parent = frame

    local snFrame = Instance.new("Frame")
    snFrame.Size = UDim2.new(0.9, 0, 0, 10)
    snFrame.Position = UDim2.new(0.05, 0, 0, 280)
    snFrame.BackgroundColor3 = Color3.fromRGB(40, 43, 52)
    snFrame.BorderSizePixel = 0
    snFrame.Parent = frame
    Instance.new("UICorner", snFrame).CornerRadius = UDim.new(0, 4)

    local snFill = Instance.new("Frame")
    snFill.Size = UDim2.new(0.2, 0, 1, 0)
    snFill.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
    snFill.BorderSizePixel = 0
    snFill.Parent = snFrame
    Instance.new("UICorner", snFill).CornerRadius = UDim.new(0, 4)

    local snBtn = Instance.new("TextButton")
    snBtn.Size = UDim2.new(0, 22, 0, 22)
    snBtn.Position = UDim2.new(0.2, -11, 0.5, -11)
    snBtn.BackgroundColor3 = Color3.new(1, 1, 1)
    snBtn.Text = ""
    snBtn.Parent = snFrame
    Instance.new("UICorner", snBtn).CornerRadius = UDim.new(1, 0)

    local snActif = false
    local function majSN(i)
        local x = i.Position.X - snFrame.AbsolutePosition.X
        local p = math.clamp(x / snFrame.AbsoluteSize.X, 0, 1)
        snFill.Size = UDim2.new(p, 0, 1, 0)
        snBtn.Position = UDim2.new(p, -11, 0.5, -11)
        CFG.SnipeDureeCible = math.floor(7 + p * 5)
        snLabel.Text = "Snipe durée : " .. CFG.SnipeDureeCible .. " secondes (min 7)"
    end
    snBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then snActif = true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if snActif and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then majSN(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then snActif = false end
    end)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.9, 0, 0, 55)
    info.Position = UDim2.new(0.05, 0, 0, 300)
    info.BackgroundTransparency = 1
    info.Text = "→ Snipe Auto : A→B→A dès qu'un rare apparaît\n→ Clic sur un rare dans le tracker = snipe manuel\n→ Trajet découpé en pas de 8 studs max"
    info.TextColor3 = Color3.fromRGB(120, 123, 132)
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = frame

    local tracker = Instance.new("Frame")
    tracker.Size = UDim2.new(0, 240, 0, 240)
    tracker.Position = UDim2.new(0, 15, 0, 100)
    tracker.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
    tracker.BackgroundTransparency = 0.15
    tracker.BorderSizePixel = 0
    tracker.Visible = false
    tracker.Active = true
    tracker.Parent = gui
    Instance.new("UICorner", tracker).CornerRadius = UDim.new(0, 10)

    local th = Instance.new("TextLabel")
    th.Size = UDim2.new(1, 0, 0, 30)
    th.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
    th.Text = "🔍 Rares sur la map"
    th.TextColor3 = Color3.new(1, 1, 1)
    th.Font = Enum.Font.GothamBold
    th.TextSize = 12
    th.Parent = tracker
    Instance.new("UICorner", th).CornerRadius = UDim.new(0, 10)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -40)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = tracker

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    local tDrag, tStart, tPos
    tracker.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            tDrag, tStart, tPos = true, i.Position, tracker.Position
        end
    end)
    tracker.InputChanged:Connect(function(i)
        if tDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - tStart
            tracker.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset + d.X, tPos.Y.Scale, tPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tDrag = false end
    end)

    local openTracker = Instance.new("TextButton")
    openTracker.Size = UDim2.new(0, 140, 0, 32)
    openTracker.Position = UDim2.new(0, 15, 0, 60)
    openTracker.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    openTracker.Text = "📋 Tracker Rares"
    openTracker.TextColor3 = Color3.new(1, 1, 1)
    openTracker.Font = Enum.Font.GothamBold
    openTracker.TextSize = 11
    openTracker.Parent = gui
    Instance.new("UICorner", openTracker).CornerRadius = UDim.new(0, 8)
    openTracker.MouseButton1Click:Connect(function()
        tracker.Visible = not tracker.Visible
    end)

    task.spawn(function()
        while true do
            task.wait(0.6)
            if not tracker.Visible then continue end

            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
            end

            table.sort(raresTrouvees, function(a, b) return a.distance < b.distance end)

            if #raresTrouvees == 0 then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 25)
                lbl.BackgroundTransparency = 1
                lbl.Text = "Aucun rare détecté..."
                lbl.TextColor3 = Color3.fromRGB(120, 123, 132)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 11
                lbl.Parent = scroll
            else
                for i, inf in ipairs(raresTrouvees) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -8, 0, 30)
                    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
                    btn.BackgroundTransparency = 0.4
                    btn.Text = string.format("  %s • %d studs 🚀", inf.rarete, inf.distance)
                    btn.TextColor3 = inf.couleur
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 11
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.LayoutOrder = i
                    btn.Parent = scroll
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

                    btn.MouseButton1Click:Connect(function()
                        snipeRare(inf.objet)
                    end)
                end
            end
        end
    end)

    local vp = Camera.ViewportSize
    if vp.X < 600 then
        frame.Size = UDim2.new(0, math.min(320, vp.X - 30), 0, 420)
        frame.Position = UDim2.new(0.5, -frame.Size.X.Offset / 2, 0.5, -210)
        tracker.Size = UDim2.new(0, math.min(220, vp.X - 30), 0, 220)
        tracker.Position = UDim2.new(0, 15, 0, vp.Y - 260)
    end

    print("[Rare Sniper] Chargé")
end

keyButton.MouseButton1Click:Connect(function()
    if keyInput.Text == CLE_SECRETE then
        keyStatus.Text = "✓ Accès autorisé"
        keyStatus.TextColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(0.5)
        lancerScriptPrincipal()
    else
        tentatives = tentatives + 1
        local restantes = MAX_TENTATIVES - tentatives
        if restantes <= 0 then
            keyStatus.Text = "✗ Trop de tentatives"
            keyInput.Text = ""
            task.wait(1)
            gui:Destroy()
        else
            keyStatus.Text = "✗ Clé incorrecte (" .. restantes .. " essais restants)"
            keyInput.Text = ""
        end
    end
end)

keyInput.FocusLost:Connect(function(enter)
    if enter then
        keyButton:FireVirtualEvent("MouseButton1Click")
    end
end)