local function SoundAnouncer_OnLoad()
    
    local pendingQuests = {}
    local processPending = false
    local f = CreateFrame("Frame")

    -- Objective progress text display
    local DISPLAY_DURATION = 3.0
    local FADE_DURATION = 1.0
    local LINE_HEIGHT = 20
    local MAX_LINES = 5

    local displayFrame = CreateFrame("Frame", "MQSH_ProgressTextFrame", UIParent)
    displayFrame:SetSize(400, MAX_LINES * LINE_HEIGHT + 20)
    displayFrame:SetPoint("TOP", UIParent, "TOP", 0, -180)
    displayFrame:SetFrameStrata("HIGH")

    local activeLines = {}

    local function CreateProgressLine()
        local line = displayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetFont(line:GetFont(), 14, "OUTLINE")
        line:SetShadowOffset(1, -1)
        line:SetAlpha(0)
        line.elapsed = 0
        line.active = false
        return line
    end

    local linePool = {}
    for i = 1, MAX_LINES do
        linePool[i] = CreateProgressLine()
    end

    local function GetFreeLine()
        for i = 1, MAX_LINES do
            if not linePool[i].active then
                return linePool[i]
            end
        end
        -- Recycle oldest line
        local oldest = linePool[1]
        oldest.active = false
        oldest:SetAlpha(0)
        table.remove(activeLines, 1)
        return oldest
    end

    local function RepositionLines()
        for i, line in ipairs(activeLines) do
            line:ClearAllPoints()
            line:SetPoint("TOP", displayFrame, "TOP", 0, -((i - 1) * LINE_HEIGHT))
        end
    end

    local function ShowProgressText(text, isComplete)
        if not MQSH_Config or not MQSH_Config.enableProgressText then return end

        local line = GetFreeLine()
        line:SetText(text)

        if isComplete then
            line:SetTextColor(0.2, 1.0, 0.2)
        else
            line:SetTextColor(1.0, 0.82, 0.0)
        end

        line:SetAlpha(1)
        line.elapsed = 0
        line.active = true
        table.insert(activeLines, line)
        RepositionLines()
    end

    displayFrame:SetScript("OnUpdate", function(self, elapsed)
        local changed = false
        for i = #activeLines, 1, -1 do
            local line = activeLines[i]
            line.elapsed = line.elapsed + elapsed

            if line.elapsed > DISPLAY_DURATION + FADE_DURATION then
                line.active = false
                line:SetAlpha(0)
                table.remove(activeLines, i)
                changed = true
            elseif line.elapsed > DISPLAY_DURATION then
                local fadeProgress = (line.elapsed - DISPLAY_DURATION) / FADE_DURATION
                line:SetAlpha(1 - fadeProgress)
            end
        end
        if changed then
            RepositionLines()
        end
    end)

    -- Track previous objective state to detect changes
    local prevObjectiveState = {}

    local function GetObjectiveKey(questId, objIndex)
        return questId .. ":" .. objIndex
    end

    local function CaptureObjectiveState(questId)
        local numObjectives = GetNumQuestLeaderBoards(questId)
        if not numObjectives then return end
        for i = 1, numObjectives do
            local text, objType, isCompleted = GetQuestLogLeaderBoard(i, questId)
            local key = GetObjectiveKey(questId, i)
            prevObjectiveState[key] = { text = text, completed = isCompleted }
        end
    end

    local function CheckAndDisplayProgress(questId)
        local numObjectives = GetNumQuestLeaderBoards(questId)
        if not numObjectives or numObjectives == 0 then return end

        for i = 1, numObjectives do
            local text, objType, isCompleted = GetQuestLogLeaderBoard(i, questId)
            local key = GetObjectiveKey(questId, i)
            local prev = prevObjectiveState[key]

            if text and prev then
                local complete = isCompleted and true or false
                -- Only show if the text actually changed from what we last stored
                if prev.text ~= text or (not prev.completed and isCompleted) then
                    ShowProgressText(text, complete)
                end
            end

            -- Update stored state
            if text then
                prevObjectiveState[key] = { text = text, completed = isCompleted }
            end
        end
    end

    f:RegisterEvent("QUEST_WATCH_UPDATE")
    f:RegisterEvent("QUEST_LOG_UPDATE")
    f:RegisterEvent("QUEST_ACCEPTED")
    
    f:SetScript("OnEvent", function(self, event, arg1, arg2)
        if event == "QUEST_WATCH_UPDATE" then
            if arg1 then
                pendingQuests[arg1] = true
                processPending = true
            end
        elseif event == "QUEST_ACCEPTED" then
            -- Capture initial objective state for new quests so we don't show on first load
            if arg1 then
                CaptureObjectiveState(arg1)
            end
        elseif event == "QUEST_LOG_UPDATE" then
            -- Only process if we have a pending quest from QUEST_WATCH_UPDATE
            if not processPending then return end
            processPending = false

            for questId, _ in pairs(pendingQuests) do
                -- Display objective progress text
                CheckAndDisplayProgress(questId)

                if IsQuestWatched(questId) then
                    local numObjectives = GetNumQuestLeaderBoards(questId)
                    
                    if numObjectives and numObjectives > 0 then 
                        local allComplete = true
                        local singleCompleted = false
                    
                        for i = 1, numObjectives do
                            local _, _, isCompleted = GetQuestLogLeaderBoard(i, questId)
                            if isCompleted then
                                singleCompleted = true
                            elseif allComplete then
                                allComplete = false
                            end
                        end
                    
                        if allComplete and MQSH_Config and MQSH_Config.enableWorkComplete then
                            PlaySoundFile(MQSH_Config.workCompleteSound)
                        elseif singleCompleted and MQSH_Config and MQSH_Config.enableSingleComplete then
                            PlaySoundFile(MQSH_Config.singleCompleteSound)
                        elseif not singleCompleted and MQSH_Config and MQSH_Config.enableProgressSound then
                            PlaySoundFile(MQSH_Config.progressSound)
                        end
                    end
                end
            end
            -- Clear all pending after processing
            pendingQuests = {}
        end
    end)

    -- Suppress Blizzard's default objective progress text
    -- In WotLK 3.3.5a, quest objective updates are shown via UI_INFO_MESSAGE on UIErrorsFrame.
    -- We hook AddMessage to filter out lines that match quest objective patterns (e.g., "Something: 4/8")
    if UIErrorsFrame then
        local origAddMessage = UIErrorsFrame.AddMessage
        UIErrorsFrame.AddMessage = function(self, msg, ...)
            if MQSH_Config and MQSH_Config.enableProgressText and msg then
                -- Filter messages that look like objective progress: "Text: X/Y" or completed objectives
                if string.find(msg, ":%s*%d+/%d+") then
                    return
                end
            end
            return origAddMessage(self, msg, ...)
        end
    end

    -- Capture initial state of all tracked quests on load
    local numEntries = GetNumQuestLogEntries()
    if numEntries then
        for i = 1, numEntries do
            local _, _, _, _, isHeader = GetQuestLogTitle(i)
            if not isHeader then
                CaptureObjectiveState(i)
            end
        end
    end
end

_G.SoundAnouncer_OnLoad = SoundAnouncer_OnLoad
