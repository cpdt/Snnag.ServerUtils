# Fifty.ServerUtils
A framework for chat command based server mods. Doesn't spam the chat, doesn't cover your HUD with unnecessarily large messages, doesn't have a dogwater auto-balance.

The mod is separated into modules all of which have extensive settings and apart from the core can be entirely disabled.

### Core
The core module implements a **chat** and a **poll** handler. For more information on the API check the API section.

Welcome message example:

![image](https://user-images.githubusercontent.com/64418963/162582553-c10af292-1f2b-4495-af90-203e9b25aa6f.png)

Poll example:

![image](https://user-images.githubusercontent.com/64418963/162508135-ba6b3551-1a6a-4e54-8b42-7ccbd2870cee.png)

### Other
- Map voting
    - Adds map voting functionality at the end of the match or with the command `!rtv`
- Spam filter
    - Filters repeating messages
    - Filters messages sent too fast
- Team Shuffle/Balance
    - Shuffle teams on game start
    - Auto balance mid-game
- Admin utils
    - Mute/Unmute players

## Commands
*`!help <page>`* - Lists commands the player is allowed to see ( check the *API* section ). Is paged to not spam the chat.

*`!name`* - Returns the name of the server ( `ns_server_name` ).

*`!owner`* - Returns the owner ( `fsu_owner` ).

*`!mods <page>`* - Lists installed mods ( `fsu_mods` ).

*`!rules <page>`* - Lists rules ( `fsu_rules` ).

*`!vote`* - Allows you to vote if a poll is active.

*`!usage <command>`* - Returns the command usage ( check the *API* section ).

*`!discord`* - Returns the discord message ( `fsu_discord` ).

*`!rtv`* - Rock the vote, if enough players vote ( `FSU_MAPCHANGE_FRACTION` ) a map vote will start.

*`!skip`* - If enough players vote ( `FSU_MAPCHANGE_FRACTION` ) the map will be skipped based on playlist.

*`!report <player>`* - Creates a valid report in the calling players console

*`!switch`* - Allows you to switch teams ( `FSU_ENABLE_SWITCH`)

## Admin commands
*`!login`* - Allows you to use the rest of admin commands

*`!logout`* - Logout

*`!mute <player>`* - Mute player

*`!unmute <player>`* - Unmute player

# Settings
|               **CONVAR**               |                           **USAGE**                          |                 **NOTE**                 |
|:--------------------------------------:|:------------------------------------------------------------:|:----------------------------------------:|
|                                        |                          *MESSAGES*                          |                                          |
| `fsu_welcome_message_before`           | 1st message in welcome stack                                 |                                          |
| `fsu_owner`                            | Owner, used in `!owner` and welcome message                  |                                          |
| `fsu_commands`                         | List of commands you want to display in your welcome message |                                          |
| `fsu_mods`                             | List of mods, used in `!mods` and welcome message            |                                          |
| `fsu_rules`                            | List of rules, used in `!rules` and welcome message          |                                          |
| `fsu_discord`                          | Discord, used in `!discord`                                  |                                          |
| `fsu_welcome_message_after`            | Last message in welcome stack                                |                                          |
| `fsu_broadcast_message_X`              | Messages broadcast during match                              | You can only have up to 5                |
|                                        |                          *SETTINGS*                          |                                          |
| `FSU_PREFIX`    | Allows you to change the prefix                            |                                          |
| `FSU_ADMIN_UIDS`    | List of admin UIDs                            |Needs to be same length as `FSU_ADMIN_PASSWORDS`  |
| `FSU_ADMIN_PASSWORDS`    | List of admin passwords                            |Needs to be same length as `FSU_ADMIN_UIDS`  |
| `FSU_EXCLUDE_ADMINS_FROM_CHAT_FILTER`    | Exclude admins from chat filter                            |                                          |
| `FSU_ALLOWED_CHAT_FILTER_TRIGGERS`    | How many times a player can trigger the chat filter before `FSU_CHAT_FILTER_TRIGGER_PUNISHMENT`      |                                          |
| `FSU_CHAT_FILTER_TRIGGER_PUNISHMENT`    | Punishment after `FSU_ALLOWED_CHAT_FILTER_TRIGGERS` was reached                           |Currently only `"mute"` and `""` ( no punishment ) works|
| `FSU_WELCOME_ENABLE_MESSAGE_BEFORE`    | Show `fsu_welcome_message_before`                            |                                          |
| `FSU_WELCOME_ENABLE_MESSAGE_AFTER`     | Show `fsu_welcome_message_after`                             |                                          |
| `FSU_WELCOME_ENABLE_OWNER`             | Show `fsu_owner`                                             |                                          |
| `FSU_WELCOME_ENABLE_COMMANDS`          | Show `fsu_commands`                                          |                                          |
| `FSU_WELCOME_ENABLE_RULES`             | Show `fsu_rules`                                             |                                          |
| `FSU_ENABLE_REPEAT_BROADCAST`          | Should periodically broadcast messages ?                     |                                          |
| `FSU_REPEAT_BROADCAST_RANDOMISE`       | Should randomise order of broadcast messages ?               |                                          |
| `FSU_REPEAT_BROADCAST_TIME_MIN`        | Minimum time in-between broadcast messages                   |                                          |
| `FSU_REPEAT_BROADCAST_TIME_MAX`        | Maximum time in-between broadcast messages                   |                                          |
| `FSU_ENABLE_SPAM_FILTER`               | Should filter spam                                           |                                          |
| `FSU_SPAM_MESSAGE_TIME_LIMIT`          | Minimum allowed time between messages sent                   |                                          |
| `FSU_SPAM_SIMMILAR_MESSAGE_WEIGHT`     | How similar can sent messages be                             | The smaller the less sensitive           |
| `FSU_SHUFFLE_TEAMS_ON_MATCH_START`     | Should shuffle teams on game start                           |                                          |
| `FSU_BALANCE_TEAMS_MID_GAME`           | Should balance teams mid-game                                | Triggers on player death                 |
| `FSU_BALANCE_ALLOWED_TEAM_DIFFERENCE`  | Allowed difference in players before balancing               |                                          |
| `FSU_BALANCE_MODE_BLACKLIST`           | Blacklist of modes for balance                               |                                          |
| `FSU_SHUFFLE_MODE_BLACKLIST`           | Blacklist of modes for shuffle                               |                                          |
| `FSU_TEAM_MAP_BLACKLIST`               | Blacklist of maps for balance && shuffle                     |                                          |
| `FSU_ENABLE_MAP_VOTE_BEFORE_MATCH_END` | Automatically create a map vote before match end             |                                          |
| `FSU_ENABLE_RTV`                       | Enable `!rtv` command                                        |                                          |
| `FSU_ENABLE_SKIP`                      | Enable `!skip` command                                       |                                          |
| `FSU_ENABLE_SWITCH`                      | Enable `!switch` command                                       |                                          |
| `FSU_MAPCHANGE_FRACTION`               | Fraction of votes needed for `!rtv` and `!skip`              |                                          |
| `FSU_VOTE_TIME_BEFORE_POSTMATCH`       | Time before postmatch to trigger map vote                    | The vote takes 20s!                      |
| `FSU_DO_CUSTOM_PLAYLIST`               | Should use `FSU_MAP_ARRAY_X` as a custom map playlist        |                                          |
| `FSU_MAP_ARRAY_X`                      | List of maps for mapvote and custom playlist                 | Divided into 4 ConVars due to size limit |
| `FSU_MODE_ARRAY` | List of modes to cycle through | Test your rotation, some combinations may crash! |

# API
Chat callbacks support [ANSI escape codes](https://r2northstar.readthedocs.io/en/latest/reference/northstar/chathooks.html#ansi-escape-codes), these allow you to change the colour of your text. An example of such a code is `\x1b[113m` which changes the colour to orange.

## Global functions
##### `void function FSU_RegisterCommand ( string command, string usage, string group, void functionref( entity, array < string > ) callbackFunc, array < string > abbreviations = [], bool functionref( entity ) visibilityFunc = null )`
Registers your custom command
1. `command`
    - Your command, needs to have a `"!"`at the start
    - Example: `"!help"`
2. `usage`
    - Explanation of what the command does
    - Example: `"\x1b[113m!vote\x1b[0m <number> Allows you to vote on polls"`
3. `group`
    - Currently unused, but in the future it'll be used to categorize the commands
    - Something like `!help <page/group>` is planned
4. `callbackFunc`
    - This function gets called when the player calls your command
    - `entity` is player
    - `array < string >` is an array of arguments, args[0] would be the first argument, the command isn't passed in
5. `abbreviations `
    - Abbreviations of the command
    - Example: `[ "!dc", "!dikord", "!dicsord" ]`
6. `visibilityFunc `
    - Decides if the player can see the command ( For example if the `!help` command only shows allowed commands, same goes for `!usage` )

##### `bool function FSU_CanCreatePoll ()`
Returns `true` if you can create a poll, there can only be one poll at a time so to not conflict make sure you check this!

##### `void function FSU_CreatePoll ( array < string > options, string before, float duration, bool show_result )`
Creates the poll. It is not recommended to pass an array larger than 7.
1. `options`
    - A list of options
2. `before`
    - A string put on the first line. An example use of this would be `"Vote for a map!"`
3. `duration`
    - Duration of the poll in seconds
4. `show_result`
    - Decides if a message announcing the poll winner should be broadcast

##### `int function FSU_GetPollResultIndex ()`
Returns the index of the option which won the poll.

If the 1st option won it will return 0.

If there were no votes cast it returns -1.

( For more such as `FSU_Mute` Check code for global functions )