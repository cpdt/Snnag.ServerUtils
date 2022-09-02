global function FSU_Map_init

array < entity > playersWantingToChangeMap
array < entity > playersWantingToSkipMap
array < string > map_list
string next_map
array <string> maps


void function FSU_Map_init ()
{
  if ( FSU_GetBool("FSU_ENABLE_RTV") )
    FSU_RegisterCommand( "rtv","\x1b[113m" + FSU_GetString("FSU_PREFIX") + "rtv\x1b[0m If enough players vote a poll to change map will start", "map", FSU_C_Rtv )
  if ( FSU_GetBool("FSU_ENABLE_SKIP") )
    FSU_RegisterCommand( "skip","\x1b[113m" + FSU_GetString("FSU_PREFIX") + "skip\x1b[0m If enough players vote the current map will be skipped", "map", FSU_C_Skip )

  
  if ( GetMapName() != "mp_lobby" )
  {
    thread RockTheVoteMapChange_Threaded ()
    thread SkipCurrentMap_Threaded ()
    if ( FSU_GetBool( "FSU_ENABLE_MAP_VOTE_BEFORE_MATCH_END" ) )
    {
      AddCallback_GameStateEnter( eGameState.Postmatch, EndOfMatchMapChange_Threaded )
      AddCallback_GameStateEnter( eGameState.Playing, EndOfMatchMapVote_Threaded )
    }
  }
  
  
  for( int i = 0; i < 4; i++ )
    maps.extend( split( GetConVarString( "FSU_MAP_ARRAY_" + i ),"," ) )
}



void function EndOfMatchMapVote_Threaded ()
{
  float end_time = expect float ( GetServerVar("gameEndTime") )
  end_time -= FSU_GetFloat("FSU_VOTE_TIME_BEFORE_POSTMATCH")
  
  
  while ( Time() < end_time ) 
    WaitFrame()
  
  if ( !FSU_CanCreatePoll() )
    return
  
  Chat_ServerBroadcast( "Map voting has began! Use \x1b[113m\"!vote <number>\"\x1b[0m to vote" ) 
  
  CreateMapsSelection()
  FSU_CreatePoll( GetFormattedMapsArray(), "Next map vote", 60, true )
  
  wait 60
  
  
  if ( FSU_GetPollResultIndex() == -1 )
  {
    Chat_ServerBroadcast( "No votes cast! Map will change based on playlist!" )
    return
  }
  
  next_map = map_list[ FSU_GetPollResultIndex() ]
}

void function EndOfMatchMapChange_Threaded ()
{
  wait GAME_POSTMATCH_LENGTH - 1
  
  // Voted for a map, change to it
  if ( next_map != "")
    GameRules_ChangeMap( next_map, GetNextMode() )
  
  // No map voted, use playlist
  if ( FSU_GetBool("FSU_DO_CUSTOM_PLAYLIST") )
  {
    // Why would you do this
    if ( maps.len() == 0 )
      return
    
    // We're listen and want to go to lobby -> return
    if( !FSU_IsDedicated() && GetConVarBool("ns_should_return_to_lobby") )
      return
    
    // Map is in the array
    if( maps.contains( GetMapName() ) )
    {
      // Get Map index, is there a func for this?? i do not know :)
      int index = 1
      foreach( map in maps )
      {
        if ( GetMapName() == map )
          break
        
        index++
      }
      
      // We have index get next map in array
      if ( index == maps.len() )
        index = 0
      
      GameRules_ChangeMap( maps[index], GetNextMode() )
    }
    else
    {
      GameRules_ChangeMap( maps[0], GetNextMode() )
    }
  }
}

void function RockTheVoteMapChange_Threaded ()
{
  while ( playersWantingToChangeMap.len() < GetPlayerArray().len() * FSU_GetFloat("FSU_MAPCHANGE_FRACTION") || GetGameState() != eGameState.Playing )
    WaitFrame()
  
  
  
  CreateMapsSelection()
  
  if ( !FSU_CanCreatePoll() )
  {
    Chat_ServerBroadcast( "Can't create poll. Waiting untill current poll ends." )
    while ( !FSU_CanCreatePoll() )
      WaitFrame()
  }
  
  Chat_ServerBroadcast( "Map voting has began! Use \x1b[113m\"!vote <number>\"\x1b[0m to vote" ) 
  
  FSU_CreatePoll( GetFormattedMapsArray(), "Next map vote", 60, false )
  
  wait 60
  
  
  if ( FSU_GetPollResultIndex() == -1 )
  {
    Chat_ServerBroadcast( "No votes cast! You can call \x1b[113m!rtv\x1b[0m again to vote!" ) 
    
    playersWantingToChangeMap.clear()
    map_list.clear()
    
    thread RockTheVoteMapChange_Threaded()
    return
  }
  
  next_map = map_list[ FSU_GetPollResultIndex() ]
  
  Chat_ServerBroadcast( "\x1b[113m" + FSU_Localize( next_map ) + "\x1b[0m won! Changing map in 5s" ) 
  
  wait 5
  
  GameRules_ChangeMap( next_map, GetNextMode() )
}

void function SkipCurrentMap_Threaded ()
{
  while ( playersWantingToSkipMap.len() < GetPlayerArray().len() * FSU_GetFloat("FSU_MAPCHANGE_FRACTION") || GetGameState() != eGameState.Playing )
    WaitFrame()
  
  
  Chat_ServerBroadcast( "\x1b[113m" + playersWantingToSkipMap.len() + "\x1b[0m players want to skip this map! Skipping map in 5s" ) 
  
  wait 5
  
  if ( GetConVarBool("ns_should_return_to_lobby") )
    GameRules_EndMatch()
  
  // No map voted, use playlist
  if ( FSU_GetBool("FSU_DO_CUSTOM_PLAYLIST") )
  {
    // Why would you do this
    if ( maps.len() == 0 )
      return
    
    // We're listen and want to go to lobby -> return
    if( !FSU_IsDedicated() && GetConVarBool("ns_should_return_to_lobby") )
      return
    
    // Map is in the array
    if( maps.contains( GetMapName() ) )
    {
      // Get Map index, is there a func for this?? i do not know :)
      int index = 1
      foreach( map in maps )
      {
        if ( GetMapName() == map )
          break
        
        index++
      }
      
      // We have index get next map in array
      if ( index == maps.len() )
        index = 0
      
      GameRules_ChangeMap( maps[index], GetNextMode() )
    }
    else
    {
      GameRules_ChangeMap( maps[0], GetNextMode() )
    }
  }
}

// !rtv
void function FSU_C_Rtv ( entity player, array < string > args )
{
  if ( GetMapName() == "mp_lobby" )
  {
    Chat_ServerPrivateMessage( player, "Can't rtv in lobby", false )
    return
  }
  
  if ( GetGameState() != eGameState.Playing )
  {
    Chat_ServerPrivateMessage( player, "Can't rtv in this game state", false )
    return
  }
  
  
  if ( playersWantingToChangeMap.find( player ) != -1 )
  {
    Chat_ServerPrivateMessage( player, "You have already voted!", false )
    return
  }
  
  playersWantingToChangeMap.append( player )
  
  
  int required_players = int ( GetPlayerArray().len() * FSU_GetFloat("FSU_MAPCHANGE_FRACTION") )
  // rounding down when int division, if there's only one player it would dislpay [1/0] normally
  if ( required_players == 0 )
    required_players = 1
  
  Chat_ServerBroadcast( "\x1b[113m[" + playersWantingToChangeMap.len() + "/" + required_players + "]\x1b[0m players want to change map (!rtv)" ) 
}

// !skip
void function FSU_C_Skip ( entity player, array < string > args )
{
  if ( GetMapName() == "mp_lobby" )
  {
    Chat_ServerPrivateMessage( player, "Can't skip in lobby", false )
    return
  }
  
  if ( GetGameState() != eGameState.Playing )
  {
    Chat_ServerPrivateMessage( player, "Can't skip in this game state", false )
    return
  }
  
  
  if ( playersWantingToSkipMap.find( player ) != -1 )
  {
    Chat_ServerPrivateMessage( player, "You have already voted!", false )
    return
  }
  
  playersWantingToSkipMap.append( player )
  
  
  int required_players = int ( GetPlayerArray().len() * FSU_GetFloat("FSU_MAPCHANGE_FRACTION") )
  // rounding down when int division, if there's only one player it would dislpay [1/0] normally
  if ( required_players == 0 )
    required_players = 1
  
  Chat_ServerBroadcast( "\x1b[113m[" + playersWantingToSkipMap.len() + "/" + required_players + "]\x1b[0m players want to skip this map (!skip)" ) 
}

void function CreateMapsSelection()
{
  
  // randomise the array
  for ( int i = 0; i < 7; i++ )
  {
    string map = maps[ RandomInt ( maps.len() ) ]
    if ( map_list.find( map ) != -1 )
    {
      i--
      continue
    }
    
    if( map == GetMapName() )
    {
      i--
      continue
    }
    
    map_list.append( map )
  }
}

array < string > function GetFormattedMapsArray()
{
  array < string > formatted_array
  foreach ( map in map_list )
    formatted_array.append( FSU_Localize( map ) )
  
  return formatted_array
}

string function GetNextMode()
{
  if ( FSU_GetArray("FSU_MODE_ARRAY").len() == 0 )
    return GameRules_GetGameMode()
  
  bool found = false
  foreach ( string mode in FSU_GetArray("FSU_MODE_ARRAY") )
  {
    if( found )
      return mode
    
    if ( mode == GameRules_GetGameMode() )
      found = true
  }
  
  return FSU_GetArray("FSU_MODE_ARRAY")[0]
}