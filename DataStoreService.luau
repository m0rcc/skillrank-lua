local DSS = game:GetService("DataStoreService")
local Database = DSS:GetDataStore("Data")

local RS = game:GetService("RunService")

local SS = game:GetService("ServerStorage")
local leaderboardClone = SS:FindFirstChild("Leaderstats")

local ongoingData = {}

game.Players.PlayerAdded:Connect(function(player)
    local leaderstats = leaderboardClone:Clone()
    leaderstats.Name = "leaderstats"
    
    local playerUserID = player.UserId
    
    local success = nil
    local plrData = nil
    local loadAttempts = 1
    
    repeat
        success, plrData = pcall(function()
            return Database:GetAsync(playerUserID) -- return to plrData if success
        end)

        loadAttempts += 1
        if not success then
            print("Unsuccessful attempt/s in loading: "..loadAttempts,". For: "..player.Name)
            warn(plrData)
        end

    until success or loadAttempts == 8
    
    if success then
        print("Accessed data storage for: "..player.Name)
        if not plrData then
            print("Setting default data stats to: "..player.Name)
            plrData = {
                ["Cash"] = 100,
                ["Experience"] = 0,
                ["Level"] = 1
            }
        end
        ongoingData[playerUserID] = plrData
    else
        warn("Unable to load data for: "..player.Name)
        player:Kick("Unabled to load your data, try again later!")
    end
    
    -- Changing values for each stat: 
    
    local ldrs_stats = {leaderstats:WaitForChild("Cash"), leaderstats:WaitForChild("Experience"), leaderstats:WaitForChild("Level")}
    
    -- Referring from the table above. [plrData] >>>
    
    ldrs_stats[1].Value = ongoingData[playerUserID].Cash -- Cash [In-session, current leaderstats]
    ldrs_stats[1].Changed:Connect(function()
        ongoingData[playerUserID].Cash = ldrs_stats[1].Value
    end)
    
    ldrs_stats[2].Value = ongoingData[playerUserID].Experience -- Experience / XP [In-session, current leaderstats]
    ldrs_stats[2].Changed:Connect(function()
        ongoingData[playerUserID].Experience = ldrs_stats[2].Value
    end)
    
    ldrs_stats[3].Value = ongoingData[playerUserID].Level -- Level [In-session, current leaderstats]
    ldrs_stats[3].Changed:Connect(function()
        ongoingData[playerUserID].Level = ldrs_stats[3].Value
    end)
    
    leaderstats.Parent = player
    
end)

local function playerExiting(player)

    local playerUserID = player.UserId
    if ongoingData[playerUserID] then -- If ongoingData's changed / if there's any ongoingData [sessionData]

        local success = nil
        local err = nil
        local saveAttempts = 1

        repeat
            success, err = pcall(function()
                Database:SetAsync(playerUserID, ongoingData[playerUserID])
            end)

            saveAttempts += 1
            if not success then
                print("Unsuccessful attempt/s in saving: "..saveAttempts)
                warn(err)
            end

        until success or saveAttempts == 8

        if not success then
            warn("Unsuccessfully saved data for: "..player.Name)
        else
            print("Successfully saved data for: "..player.Name)
        end
    end
    
end

game.Players.PlayerRemoving:Connect(playerExiting)

local function gameShutdown()
    if RS:IsStudio() then
        warn("Server shutdown function disabled, in-studio.")
        return
    end
    
    warn("Server shutting down!")
    for _, player in ipairs(game.Players:GetPlayers()) do -- ipairs start from top to bottom
        task.spawn(function()
            playerExiting(player)
        end)
    end
end

game:BindToClose(gameShutdown)
