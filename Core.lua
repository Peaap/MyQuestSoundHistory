local addonName = "MyQuestSoundHistory"
local L = _G.MQSH_L
local f = CreateFrame("Frame")

f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == addonName then
        CreateSettingsPanel()
        SLASH_MYQUESTSOUNDHISTORY1 = "/MQSH"
        SLASH_MYQUESTSOUNDHISTORYCLEAR1 = "/MQSHC"
        SlashCmdList["MYQUESTSOUNDHISTORY"] = function()
            InterfaceOptionsFrame_OpenToCategory(addonName)
        end
        SlashCmdList["MYQUESTSOUNDHISTORYCLEAR"] = function()
            if MQSH_QuestDB then
                MQSH_QuestDB = {}
                print(L["QUEST_DB_CLEARED"])
            else
                print(L["QUEST_DB_EMPTY"])
            end
            if MQSH_Char_HistoryDB then
                MQSH_Char_HistoryDB = {}
                print(L["CHAR_HISTORY_CLEARED"])
            else
                print(L["CHAR_HISTORY_EMPTY"])
            end
        end

        if MQSH_Config and MQSH_Config.enableSoundAnouncer then
            if _G.SoundAnouncer_OnLoad then 
                _G.SoundAnouncer_OnLoad()
            end
        end
        if MQSH_Config and MQSH_Config.enableHistory then
            if _G.QuestDataBaseController_OnLoad then 
                _G.QuestDataBaseController_OnLoad()
            end
        end
    end
end)
