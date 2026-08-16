local L = _G.MQSH_L

-- Safe wrapper for quest log selection
local function WithQuestLogSelection(index, func)
    local prev = GetQuestLogSelection()
    SelectQuestLogEntry(index)
    local ok, err = pcall(func)
    if prev and prev > 0 then
        SelectQuestLogEntry(prev)
    end
end

-- Clean whitespace from location strings
local function CleanLocationString(str)
    if not str then return nil end
    return str:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", " ")
end

-- Get quest ID and data from quest log
local function GetQuestIDAndData(questLogIndex, currentNPC)
    local questID, questData = nil, nil

    WithQuestLogSelection(questLogIndex, function()
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, qID = GetQuestLogTitle(questLogIndex)
        if qID and qID ~= 0 then
            questID = qID
        end
        local questType = questTag

        if questID then
            local description, objectivesText = GetQuestLogQuestText()
            local questGroup = nil
            
            for i = questLogIndex - 1, 1, -1 do
                local headerTitle, headerLevel, headerTag, headerSuggestedGroup, isHeader = GetQuestLogTitle(i)
                if isHeader then
                    questGroup = headerTitle
                    break
                end
            end
            
            if questGroup and (questGroup:lower():find(L["PATTERN_STORY"]) or questGroup:lower():find("story")) then
                questType = L["QUEST_TYPE_STORY"]
                questGroup = nil
            end

            if questGroup and not questGroup:lower():find(L["PATTERN_SPECIAL"]) and questType and not questType:lower():find(L["PATTERN_RAID"]) and not questType:lower():find(L["PATTERN_DUNGEON"]) then
                questGroup = nil
            end

            local locationName = CleanLocationString(GetRealZoneText() or GetZoneText())
            
            local x, y = 0, 0
            if SetMapToCurrentZone then SetMapToCurrentZone() end
            if GetPlayerMapPosition then
                x, y = GetPlayerMapPosition("player")
                x = math.floor((x or 0) * 10000) / 100
                y = math.floor((y or 0) * 10000) / 100
            end
            local coordinates = { x = x, y = y }

            local npcName = nil
            
            if currentNPC and currentNPC ~= "" then
                npcName = currentNPC
            else
                npcName = L["UNKNOWN_NPC"]
            end

            -- Objectives
            local objectives = {}
            local numObjectives = GetNumQuestLeaderBoards()
            if numObjectives and numObjectives > 0 then
                for i = 1, numObjectives do
                    local desc, type = select(1, GetQuestLogLeaderBoard(i))
                    if desc and type ~= "item" then
                        table.insert(objectives, desc)
                    end
                end
            end

            -- Rewards
            local rewards = {
                items   = {},
                choices = {},
                money   = GetQuestLogRewardMoney(),
                xp      = GetQuestLogRewardXP(),
            }

            local numRewards = GetNumQuestLogRewards()
            if numRewards and numRewards > 0 then
                for i = 1, numRewards do
                    local itemName, itemTexture, numItems, quality, isUsable = GetQuestLogRewardInfo(i)
                    if itemName then
                        local itemLink = GetQuestLogItemLink("reward", i)
                        local itemID = nil
                        if itemLink then
                            itemID = tonumber(itemLink:match("item:(%d+)"))
                        end
                        table.insert(rewards.items, {
                            name    = itemName,
                            itemID  = itemID,
                        })
                    end
                end
            end

            local numChoices = GetNumQuestLogChoices()
            if numChoices and numChoices > 0 then
                for i = 1, numChoices do
                    local itemName, itemTexture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i)
                    if itemName then
                        local itemLink = GetQuestLogItemLink("choice", i)
                        local itemID = nil
                        if itemLink then
                            itemID = tonumber(itemLink:match("item:(%d+)"))
                        end
                        table.insert(rewards.choices, {
                            name    = itemName,
                            itemID  = itemID,
                        })
                    end
                end
            end

            local timeAccepted = date("%d.%m.%y %H:%M:%S")

            questData = {
                title           = title,
                level           = level,
                description     = description,
                objectivesText  = objectivesText,
                objectives      = objectives,
                rewards         = rewards,
                npcName         = npcName,
                mainZone        = locationName,
                coordinates     = coordinates,
                timeAccepted    = timeAccepted,
                questGroup      = questGroup,
                questType       = questType,
            }
        end
    end)

    return questID, questData
end

local function QuestDataBaseController_OnLoad()
    if not MQSH_QuestDB then
        MQSH_QuestDB = {}
    end
    if not MQSH_Char_HistoryDB then
        MQSH_Char_HistoryDB = {}
    end

    local currentNPC = nil
    local questComplete = false
    
    local function GetInfoForHistory()
        local questID = nil
        local questData = nil
        
        -- When QUEST_COMPLETE fires, we need to find the quest being turned in.
        -- Check selected quest log entry for its ID.
        local selIndex = GetQuestLogSelection()
        if selIndex and selIndex > 0 then
            local _, _, _, _, _, _, _, _, qID = GetQuestLogTitle(selIndex)
            if qID and qID ~= 0 then
                questID = qID
                questData = MQSH_QuestDB[questID]
            end
        end
        
        return questID, questData
    end

    local completedQuestID = nil

    local function SaveQuestInfoToHistory()
        local questID = completedQuestID
        local questData = nil
        
        if questID then
            questData = MQSH_QuestDB[questID]
            local x, y = 0, 0
            if SetMapToCurrentZone then SetMapToCurrentZone() end
            if GetPlayerMapPosition then
                x, y = GetPlayerMapPosition("player")
                x = math.floor((x or 0) * 10000) / 100
                y = math.floor((y or 0) * 10000) / 100
            end
            local completionCoordinates = { x = x, y = y }
            
            local completionNPC = currentNPC or L["UNKNOWN_NPC"]
            local historyData = {
                timeCompleted = date("%d.%m.%y %H:%M:%S"),
                completionNPC = completionNPC,
                completionLocation = CleanLocationString(GetRealZoneText() or GetZoneText()),
                completionCoordinates = completionCoordinates
            }
            
            MQSH_Char_HistoryDB[questID] = historyData
        end
    end
    
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("QUEST_ACCEPTED")
    frame:RegisterEvent("GOSSIP_SHOW")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_FINISHED")
    frame:RegisterEvent("GOSSIP_CLOSED")
    frame:RegisterEvent("QUEST_COMPLETE")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "GOSSIP_SHOW" or event == "QUEST_DETAIL" then
            currentNPC = UnitName("npc")
        elseif event == "QUEST_COMPLETE" then
            -- Find quest ID by matching the title from the turn-in dialog
            local titleText = GetTitleText and GetTitleText() or nil
            local foundQuestID = nil
            
            if titleText and titleText ~= "" then
                for qID, qData in pairs(MQSH_QuestDB) do
                    if qData.title == titleText then
                        foundQuestID = qID
                        break
                    end
                end
            end
            
            completedQuestID = foundQuestID
            questComplete = true
            currentNPC = UnitName("npc")
        elseif event == "QUEST_ACCEPTED" then
            local questLogIndex = ...
            local npcName = currentNPC
            questComplete = false
            completedQuestID = nil
            -- Use a simple OnUpdate frame as a delay since C_Timer doesn't exist
            local delayFrame = CreateFrame("Frame")
            local elapsed = 0
            delayFrame:SetScript("OnUpdate", function(self, dt)
                elapsed = elapsed + dt
                if elapsed >= 0.05 then
                    self:SetScript("OnUpdate", nil)
                    local questID, questData = GetQuestIDAndData(questLogIndex, npcName)
                    if questID and questData and not MQSH_QuestDB[questID] then
                        MQSH_QuestDB[questID] = questData
                    end
                    currentNPC = nil
                end
            end)
        elseif event == "GOSSIP_CLOSED" then
            currentNPC = nil
        elseif event == "QUEST_FINISHED" then
            if questComplete == true then
                SaveQuestInfoToHistory()
                questComplete = false
                currentNPC = nil
                completedQuestID = nil
            else
                questComplete = false
                completedQuestID = nil
            end
        end
    end)
end

_G.QuestDataBaseController_OnLoad = QuestDataBaseController_OnLoad
