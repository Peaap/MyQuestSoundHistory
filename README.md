# MyQuestSoundHistory

A World of Warcraft addon that plays sound alerts for quest events and maintains a quest history.

## Features

### Main Features:
- Sound notifications for quest progress, stage completion, and quest completion
- On-screen objective progress text that displays updates as objectives advance, with automatic fade-out
- Database of accepted quests with detailed information
- Display of quest rewards with icons and tooltips
- Quest history tracked separately for each character

### Commands
- `/MQSH` - Open addon settings
- `/MQSHC` - Clear quest history database (removes all saved quests; temporarily added)

### Interface
A "History" button appears in the quest log, opening a window with:

- A list of all accepted quests (left side)
- Detailed information about the selected quest (right side):
  - Quest description
  - Quest objectives (text + item icons)
  - Rewards (with icons)

## Settings

Settings can be accessed via the `/MQSH` command or through the interface menu:

- Toggle sound notifications on/off
- Toggle quest history on/off
- Select sounds for quest completion, stage completion, and progress events
- Toggle on-screen objective progress text (shows current/total counts as they update)

## Localization

The addon supports English and Russian. The language is detected automatically based on your WoW client locale.

## Version

Current version: 1.0 beta.1

## Author

MottiDowerro (original) | Peaap (fork)
