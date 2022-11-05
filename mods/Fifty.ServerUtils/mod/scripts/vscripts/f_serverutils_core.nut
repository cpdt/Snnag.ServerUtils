global function FSU_init

global function FSU_RegisterCommand

global function FSU_CanCreatePoll
global function FSU_CreatePoll
global function FSU_GetPollResultIndex
global function FSU_IsDedicated

struct commandStruct
{
  string usage
  void functionref( entity, array < string > ) callback // Callback when it's called
  array < string > abbreviations // Command abbreviations
  string group // Group, used for help
  bool functionref( entity ) visible // Should show to player ?
}

// List of registered commands
table < string, commandStruct > commands

// Poll stuff
// Used to check if a poll is on
array < string > poll_options
// other poll stuff
table < entity, int > votes
float poll_time
float poll_start
string poll_before
int poll_result
bool poll_show_result


// init
void function FSU_init ()
{
  AddCallback_OnClientConnected ( OnClientConnected )
  AddCallback_OnPlayerRespawned ( OnPlayerRespawned )
  
  
  // Register commands
  FSU_RegisterCommand( "help", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "help <page>\x1b[0m Lists registered commands", "core", FSU_C_Help, [ "h" ] )
  FSU_RegisterCommand( "rules", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "rules\x1b[0m Lists rules", "core", FSU_C_Rules)
  FSU_RegisterCommand( "vote", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "vote <number>\x1b[0m Allows you to vote on polls", "core", FSU_C_Vote )
  FSU_RegisterCommand( "usage", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "usage\x1b[0m <command> Prints usage of provided command", "core", FSU_C_Usage )
  FSU_RegisterCommand( "report", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "report <player>\x1b[0m Creates a report and prints it in console so you can copy it", "core", FSU_C_Report )
  if( FSU_GetBool("FSU_ENABLE_SWITCH") )
    FSU_RegisterCommand( "switch", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "switch\x1b[0m switches team", "core", FSU_C_Switch )
  
  AddCallback_OnReceivedSayTextMessage( CheckForCommand )
  
  
  if ( FSU_GetBool( "FSU_ENABLE_REPEAT_BROADCAST" ) && GetMapName() != "mp_lobby" )
    thread RepeatBroadcastMessages_Threaded ()
}

// callbacks
void function OnClientConnected ( entity player )
{
  Chat_ServerPrivateMessage(player, "\x1b[97mWelcome to \x1b[95mYour Local Bunnings\x1b[97m, where lowest prices are just the beginning.", false)
  Chat_ServerPrivateMessage(player, "\x1b[93mRules:", false)
  Chat_ServerPrivateMessage(player, "\x1b[33m 1. Keep it chill. Competitive talk is fine but aggression and slurs will not be tolerated.", false)
  Chat_ServerPrivateMessage(player, "\x1b[33m 2. Do not spam the chat. This includes spam mods and macros.", false)
  Chat_ServerPrivateMessage(player, "\x1b[33m 3. Cheating or working around the game's controls is banned.", false)
  Chat_ServerPrivateMessage(player, "Report rule breakers on the Northstar Discord - \x1b[94mdiscord.gg/northstar", false)
  Chat_ServerPrivateMessage(player, "View available chat commands with \x1b[92m!help\x1b[0m. Questions? Contact \x1b[94mcpdt#5830\x1b[0m on Discord.", false)
  
  ShowActivePoll( player )
}

void function OnPlayerRespawned ( entity player )
{
  ShowActivePoll( player )
}

void function ShowActivePoll( entity player )
{
  // If a poll is active try to show it to late joiners
  // This means we need to calc new length
  if ( FSU_CanCreatePoll() )
    return
  
  string poll_text
  foreach ( _index, line in poll_options )
    poll_text += _index + 1 + ". " + line + "\n"
  
  // Show poll to late joiners, we need to calculate new_length so it ends at the same time for all players
  // This is just visual
  if ( GetGameState() > eGameState.Playing )
    SendHudMessage( player, poll_before + "\n" + poll_text , 0.3, 0.1, 240, 180, 40, 230, 0.2, poll_time - ( Time() - poll_start ), 0.2)
  else
    SendHudMessage( player, poll_before + "\n" + poll_text , 0.005, 0.3, 240, 180, 40, 230, 0.2, poll_time - ( Time() - poll_start ), 0.2)
}

ClServer_MessageStruct function CheckForCommand( ClServer_MessageStruct message )
{
  // Unsure if needed, better to check before we do anything funny
  if ( message.message.len() == 0)
    return message
  
  // Check if message starts wit prefix
  if ( message.message.find( FSU_GetString("FSU_PREFIX") ) != 0 )
    return message
  
  // We now confirmed the user is trying to run a command
  array < string > splitMsg = split( message.message, " " )
  
  // Get args from message
  string command = splitMsg[0].tolower()
  array < string > args
  foreach ( _index, string arg in splitMsg )
    if ( _index != 0 )
      args.append( arg )
  
  
  // Log
  printt("[FSU]", message.player.GetPlayerName(), message.player.GetUID(), "ran command \"" + message.message +"\"")
  
  
  // Dont show their message to anyone
  // Also null out as many things as we can
  // This is to protect info such as passwords and such
  message.shouldBlock = true
  message.message = ""
  
  // Try to execute cammand
  if( command in commands )
  {
    if( commands[ command ].callback != null )
    {
      if( commands[ command ].visible != null && !commands[ command ].visible( message.player ) )
      {
        Chat_ServerPrivateMessage( message.player, "Unknown command: \x1b[113m\"" + command + "\"\x1b[0m", false )
        return message
      }
      commands[ command ].callback( message.player, args )
    }
  }
  // Check for abbreviations
  else
  {
    foreach ( cmd, cmdStruct in commands )
      foreach ( abv in cmdStruct.abbreviations )
        if ( FSU_GetString("FSU_PREFIX") + abv == command )
        {
          if( cmdStruct.visible != null && !cmdStruct.visible( message.player ) )
          {
            Chat_ServerPrivateMessage( message.player, "Unknown command: \x1b[113m\"" + command + "\"\x1b[0m", false )
            return message
          }
          cmdStruct.callback( message.player, args )
          printt("[FSU]", message.player.GetPlayerName(), message.player.GetUID(), "ran command \"" + message.message +"\"")
          return message
        }
    Chat_ServerPrivateMessage( message.player, "Unknown command: \x1b[113m\"" + command + "\"\x1b[0m", false )
  }
  
  
  return message
}

void function RepeatBroadcastMessages_Threaded ()
{
  int index
  
  array<string> messages
  
  for ( int i = 0; i < 5; i++ )
  {
    if ( FSU_GetString( "fsu_broadcast_message_" + i ) == "" )
      continue
    
    messages.append( FSU_GetString( "fsu_broadcast_message_" + i ) )
  }
  
  while ( true )
  {
    wait RandomIntRange( FSU_GetFloat( "FSU_REPEAT_BROADCAST_TIME_MIN" ), FSU_GetFloat( "FSU_REPEAT_BROADCAST_TIME_MAX" ) )
    
    
    if( FSU_GetBool( "FSU_REPEAT_BROADCAST_RANDOMISE" ) )
      index = RandomInt( messages.len() )
    
    Chat_ServerBroadcast( messages[ index ] )
    
    index++
    if ( index >= messages.len() )
      index = 0
  }
}

// command register
void function FSU_RegisterCommand ( string command, string usage, string group, void functionref( entity, array < string > ) callbackFunc, array < string > abbreviations = [], bool functionref( entity ) visibilityFunc = null )
{
  foreach( _index, abbv in abbreviations )
    abbreviations[ _index ] = abbv.tolower()
  
  commandStruct _command
  _command.usage = usage
  _command.group = group
  _command.callback = callbackFunc
  _command.abbreviations = abbreviations
  _command.visible = visibilityFunc
  
  
  commands[ FSU_GetString("FSU_PREFIX") + command.tolower() ] <- _command
  printt( "[FSU] Registered command:", command )
}

// poll stuff
//public
bool function FSU_CanCreatePoll ()
{
  return poll_options.len() == 0 ? true : false
}

void function FSU_CreatePoll ( array < string > options, string before, float duration, bool show_result )
{
  if ( options.len() > 7 )
    printt("[FSU] Polls larger than 7 may interfere with chat box!")
  
  poll_start = Time()
  poll_time = duration
  poll_before = before
  poll_show_result = show_result
  
  foreach( option in options )
    poll_options.append( option )
  
  string poll_text
  foreach ( _index, line in poll_options )
    poll_text += _index + 1 + ". " + line + "\n"
  
  
  if ( GetGameState() > eGameState.Playing )
    foreach( player in GetPlayerArray() )
      SendHudMessage( player, poll_before + "\n" + poll_text , 0.3, 0.1, 240, 180, 40, 230, 0.2, poll_time, 0.2)
  else
    foreach( player in GetPlayerArray() )
      SendHudMessage( player, poll_before + "\n" + poll_text , 0.005, 0.3, 240, 180, 40, 230, 0.2, poll_time, 0.2)
  
  thread FSU_PollEndTimeWatcher_Threaded ()
}

int function FSU_GetPollResultIndex ()
{
  return poll_result
}

// private
void function FSU_PollEndTimeWatcher_Threaded ()
{
  wait poll_time
  
  // Count votes
  if ( votes.len() == 0 )
  {
    poll_options.clear()
    poll_result = -1
    return
  }
  
  array < int > votes_counted
  foreach ( option in poll_options )
    votes_counted.append(0)
  
  
  foreach ( player, index in votes )
    votes_counted[ index - 1 ]++
  
  int poll_result_votes
  // Could sort but this is prob shorter
  foreach ( _index, count in votes_counted )
  {
    if ( poll_result_votes < count )
    {
      poll_result_votes = count
      poll_result = _index
    }
  }
  
  if ( poll_show_result )
    Chat_ServerBroadcast( "Poll ended! \x1b[113m" + poll_options[ FSU_GetPollResultIndex() ] + "\x1b[0m won!"  )
  
  poll_options.clear()
  votes.clear()
}

bool function FSU_IsDedicated()
{
	return NSIsDedicated()
}

// !help
void function FSU_C_Help ( entity player, array < string > args )
{
  string returnMessage
  int page
  
  
  array < string > allowedCommands
  foreach ( cmd, cmdStruct in commands )
    if ( cmdStruct.visible == null || cmdStruct.visible( player ) )
      allowedCommands.append( cmd )
  
  
  int pages = allowedCommands.len() % 5 == 0 ? ( allowedCommands.len() / 5 ) : ( allowedCommands.len() / 5 + 1 )
  
  if ( args.len() != 0 )
    page = args[0].tointeger() - 1
  
  if ( args.len() != 0 && args[0].tointeger() > pages )
  {
    Chat_ServerPrivateMessage( player, "Maximum number of pages is \x1b[113m" + pages + "\x1b[0m!", false )
    return
  }
  
  if ( args.len() != 0 && !IsValidVoteInt( args[0], pages ) )
  {
    Chat_ServerPrivateMessage( player, "Invalid argument!", false )
    return
  }
  
  
  int _index = 0
  foreach ( cmd in allowedCommands )
  {
    if ( _index >= page * 5 && _index < ( page + 1 ) * 5 )
      returnMessage += "\n    \x1b[113m-\x1b[0m " + cmd
      
    _index++
  }
  
  returnMessage += "\nShowing page \x1b[113m[" + ( page + 1 ) + "/" + pages + "]\x1b[0m"
  
  Chat_ServerPrivateMessage( player, "Commands: " + returnMessage, false )
}

// !rules
void function FSU_C_Rules ( entity player, array < string > args )
{
  Chat_ServerPrivateMessage(player, "\x1b[93mRules:", false)
  Chat_ServerPrivateMessage(player, "\x1b[33m 1. Keep it chill. Competitive talk is fine but aggression and slurs will not be tolerated.", false)
  Chat_ServerPrivateMessage(player, "\x1b[33m 2. Do not spam the chat. This includes spam mods and macros.", false)
  Chat_ServerPrivateMessage(player, "\x1b[33m 3. Cheating or working around the game's controls is banned.", false)
  Chat_ServerPrivateMessage(player, "Report rule breakers on the Northstar Discord - \x1b[94mdiscord.gg/northstar", false)
}

// !vote
void function FSU_C_Vote ( entity player, array < string > args )
{
  if ( FSU_CanCreatePoll() )
  {
    Chat_ServerPrivateMessage( player, "No vote currently open!", false )
    return
  }
  
  if ( player in votes )
  {
    Chat_ServerPrivateMessage( player, "You have already voted!", false )
    return
  }
  
  if ( args.len() == 0 )
  {
    string message = "Vote options:\n"
    foreach ( _index, string option in poll_options )
      message += "  \x1b[113m" + ( _index + 1 ) + ".\x1b[0m " + option + "\n"
    Chat_ServerPrivateMessage( player, message, false )
    return
  }
  
  if ( !IsValidVoteInt( args[0], poll_options.len() ) )
  {
    Chat_ServerPrivateMessage( player, "Invalid argument!", false )
    return
  }
  
  int index = args[0].tointeger()
  
  votes[ player ] <- index
  Chat_ServerBroadcast( "\x1b[113m[" + votes.len() + "/" + GetPlayerArray().len() + "]\x1b[0m players have voted!" )
  
  Chat_ServerPrivateMessage( player, "You have voted for \x1b[113m" + poll_options[ index - 1 ] + "\x1b[0m", false )
}

// !usage
void function FSU_C_Usage ( entity player, array < string > args )
{
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, "Usage: !usage <command>", false )
    return
  }
  
  string cmd = args[0].find( FSU_GetString("FSU_PREFIX") ) == 0 ? args[0].tolower() : FSU_GetString("FSU_PREFIX") + args[0].tolower()
  
  if ( cmd in commands )
    Chat_ServerPrivateMessage( player, "Usage: " + commands[ cmd ].usage, false )
  else
  {
    Chat_ServerPrivateMessage( player, "Unknown command passed in!", false )
    return
  }
  
  if ( commands[ cmd ].visible != null && commands[ cmd ].visible( player ) )
  {
    Chat_ServerPrivateMessage( player, "Unknown command passed in!", false ) // Dont have rights
    return
  }
  
  if ( commands[ cmd ].abbreviations.len() == 0 )
    return
  
  
  string abbFinal
  foreach ( _index, abb in commands[ cmd ].abbreviations )
    abbFinal += _index == 0 ? "\x1b[113m" + FSU_GetString("FSU_PREFIX") + abb + "\x1b[0m" : ", \x1b[113m" + FSU_GetString("FSU_PREFIX") + abb + "\x1b[0m"
  Chat_ServerPrivateMessage( player, "Abbreviations: " + abbFinal, false )
}


bool function IsValidVoteInt( string arg, int max )
{
  int _index = arg.tointeger()
  
  if ( _index < 1 )
    return false
  
  if ( _index > max )
    return false
  
  return true
}

// !switch
void function FSU_C_Switch ( entity player, array < string > args )
{
  if ( GetGameState() != eGameState.Playing )
  {
    Chat_ServerPrivateMessage( player, "Can't switch in this game state", false )
    return
  }
  
  int maxTeamSize = GetPlayerArray().len() / 2
  
  if( GetPlayerArrayOfTeam( GetOtherTeam( player.GetTeam() ) ).len() > maxTeamSize )
  {
    Chat_ServerPrivateMessage( player, "Other team has too many players!", false )
    return
  }
  
  SetTeam( player, GetOtherTeam( player.GetTeam() ) )
  Chat_ServerPrivateMessage( player, "Switched teams!", false )
}

// !report
void function FSU_C_Report ( entity player, array < string > args )
{
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, "Usage: \x1b[113m!report <player>\x1b[0m", false )
    return
  }
  
  string message = "\\n\\n////////PLAYER REPORT////////"
  string name = ""
  string uid = ""
  
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      name = "Name: " + p.GetPlayerName()
      uid = "UID: " + p.GetUID()
      break
    }
  }
  
  if ( name == "" )
  {
    Chat_ServerPrivateMessage( player, "Player not found!", false )
    return
  }
  
  
  
  string msg = "script_client print(\"" + message + "\\n" + name + "\\nServer: " + GetConVarString( "ns_server_name" ) + "\\n" + uid + "\\n\")"
  print( msg )
  ClientCommand( player, msg )
  
  Chat_ServerPrivateMessage( player, "Report created! Check your console.", false )
}