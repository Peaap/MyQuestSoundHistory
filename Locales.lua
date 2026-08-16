-- Localization table for MyQuestSoundHistory
local _, ns = ...

local L = {}
ns.L = L

local locale = GetLocale()

-- Default (English) strings
L["QUEST_DB_CLEARED"] = "MQSH: Quest database cleared"
L["QUEST_DB_EMPTY"] = "MQSH: Quest database is empty"
L["CHAR_HISTORY_CLEARED"] = "MQSH: Character quest history cleared"
L["CHAR_HISTORY_EMPTY"] = "MQSH: Character quest history is empty"

-- Settings
L["SOUND_ANNOUNCER_MODULE"] = "Quest sound announcer module"
L["HISTORY_MODULE"] = "Quest history module"
L["HISTORY_SETTINGS_DESC"] = "Quest history settings will be here."
L["SOUND_COMPLETE"] = "Quest completion sound"
L["SOUND_STAGE_COMPLETE"] = "Stage completion sound"
L["SOUND_PROGRESS"] = "Quest progress sound"

-- Quest Overlay
L["QUEST_HISTORY"] = "History"
L["QUEST_HISTORY_TITLE"] = "Quest History"
L["QUESTS_COUNT"] = "Quests: "
L["WITHOUT_GROUPS"] = "No grouping"
L["CURRENT_PLAYER"] = "Current character"
L["SORT_TITLE"] = "Sort"
L["SORT_BY_LEVEL"] = "By level"
L["SORT_BY_NAME"] = "By name"
L["SORT_BY_ID"] = "By ID"
L["SORT_BY_ACCEPT_DATE"] = "By accept date"
L["SORT_BY_COMPLETION_DATE"] = "By completion date"

-- Quest Details
L["ACCEPTED"] = "Accepted:"
L["COORDINATES"] = "Coordinates:"
L["FROM_NPC"] = "From:"
L["LOCATION"] = "Location:"
L["COMPLETED"] = "Completed:"
L["COMPLETED_AT_NPC"] = "Turned in to:"
L["COMPLETION_LOCATION"] = "Completion location:"
L["COMPLETION_COORDINATES"] = "Completion coordinates:"
L["DESCRIPTION"] = "Description:"
L["REWARDS"] = "Rewards:"
L["YOU_ALSO_RECEIVE"] = "You will also receive: "
L["EXPERIENCE"] = "Experience: "
L["UNKNOWN_NPC"] = "Unknown NPC"
L["UNKNOWN_LOCATION"] = "Unknown location"
L["ALL_QUESTS"] = "All quests"

-- Quest Types
L["QUEST_TYPE_STORY"] = "(Story)"
L["QUEST_TYPE_GROUP"] = "(Group)"
L["QUEST_TYPE_DUNGEON"] = "(Dungeon)"
L["QUEST_TYPE_RAID"] = "(Raid)"

-- Quest group detection keywords (used for pattern matching in quest log headers)
L["PATTERN_STORY"] = "story"
L["PATTERN_SPECIAL"] = "special"
L["PATTERN_RAID"] = "raid"
L["PATTERN_DUNGEON"] = "dungeon"

-- Russian localization
if locale == "ruRU" then
    L["QUEST_DB_CLEARED"] = "MQSH: База данных квестов полностью очищена"
    L["QUEST_DB_EMPTY"] = "MQSH: База данных квестов пуста"
    L["CHAR_HISTORY_CLEARED"] = "MQSH: История квестов персонажа очищена"
    L["CHAR_HISTORY_EMPTY"] = "MQSH: История квестов персонажа пуста"

    L["SOUND_ANNOUNCER_MODULE"] = "Модуль звукового анонсера квестов"
    L["HISTORY_MODULE"] = "Модуль истории квестов"
    L["HISTORY_SETTINGS_DESC"] = "Здесь будут настройки истории квестов."
    L["SOUND_COMPLETE"] = "Звук завершения квеста"
    L["SOUND_STAGE_COMPLETE"] = "Звук завершения этапа"
    L["SOUND_PROGRESS"] = "Звук прогресса квеста"

    L["QUEST_HISTORY"] = "История"
    L["QUEST_HISTORY_TITLE"] = "История квестов"
    L["QUESTS_COUNT"] = "Квестов: "
    L["WITHOUT_GROUPS"] = "Без группировки"
    L["CURRENT_PLAYER"] = "Текущий персонаж"
    L["SORT_TITLE"] = "Сортировка"
    L["SORT_BY_LEVEL"] = "По уровню"
    L["SORT_BY_NAME"] = "По названию"
    L["SORT_BY_ID"] = "По ID"
    L["SORT_BY_ACCEPT_DATE"] = "По дате принятия"
    L["SORT_BY_COMPLETION_DATE"] = "По дате завершения"

    L["ACCEPTED"] = "Принят:"
    L["COORDINATES"] = "Координаты:"
    L["FROM_NPC"] = "От кого:"
    L["LOCATION"] = "Локация:"
    L["COMPLETED"] = "Завершен:"
    L["COMPLETED_AT_NPC"] = "Завершен у:"
    L["COMPLETION_LOCATION"] = "Локация завершения:"
    L["COMPLETION_COORDINATES"] = "Координаты завершения:"
    L["DESCRIPTION"] = "Описание:"
    L["REWARDS"] = "Награды:"
    L["YOU_ALSO_RECEIVE"] = "Вы также получите: "
    L["EXPERIENCE"] = "Опыт: "
    L["UNKNOWN_NPC"] = "Неизвестный NPC"
    L["UNKNOWN_LOCATION"] = "Неизвестная локация"
    L["ALL_QUESTS"] = "Все квесты"

    L["QUEST_TYPE_STORY"] = "(Сюжетный)"
    L["QUEST_TYPE_GROUP"] = "(Групповой)"
    L["QUEST_TYPE_DUNGEON"] = "(Подземелье)"
    L["QUEST_TYPE_RAID"] = "(Рейд)"

    L["PATTERN_STORY"] = "сюжет"
    L["PATTERN_SPECIAL"] = "особ"
    L["PATTERN_RAID"] = "рей"
    L["PATTERN_DUNGEON"] = "подземель"
end

-- Make L accessible globally for all modules
_G.MQSH_L = L
