// Disabled for now





global function FSU_Admin_init

// array< UID >
array<string> loggedin_admins


void function FSU_Admin_init()
{
  FSU_RegisterCommand( "login", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "login <password>\x1b[0m Login as admin", "admin", FSU_C_Login, [], CanBeAdmin )
  FSU_RegisterCommand( "logout", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "logout\x1b[0m Logout", "admin", FSU_C_Logout, [], IsLoggedIn )
  FSU_RegisterCommand( "mute", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "mute <player>\x1b[0m to mute player", "admin", FSU_C_Mute, [], IsLoggedIn )
  FSU_RegisterCommand( "unmute", "\x1b[113m" + FSU_GetString("FSU_PREFIX") + "unmute <player>\x1b[0m to unmute player", "admin", FSU_C_Unmute, [], IsLoggedIn )
}

bool function CanBeAdmin( entity player )
{
  foreach ( admin in FSU_GetArray("FSU_ADMIN_UIDS") )
    if( admin == player.GetUID() )
      return true
  
  return false
}

bool function IsLoggedIn( entity player )
{
  // Check if already logged in
  foreach( uid in loggedin_admins )
  {
    if( player.GetUID() == uid )
    {
      return true
    }
  }
  
  return false
}

bool function Login( entity player )
{  
  // Check if already logged in
  if( IsLoggedIn( player ) )
  {
    Chat_ServerPrivateMessage( player, "Already logged in!", false )
    return false
  }
  
  // Log in
  loggedin_admins.append( player.GetUID() )
  return true
}

bool function Logout( entity player )
{
  if( IsLoggedIn( player ) )
  {
    loggedin_admins.remove( loggedin_admins.find( player.GetUID() ) )
    Chat_ServerPrivateMessage( player, "Logged out!", false )
    return true
  }
  
  return false
}

bool function CheckPlayerDuplicates( entity player )
{
  int occurences = 0
  foreach( p in GetPlayerArray() )
  {
    if( p.GetUID() == player.GetUID() )
      occurences++
  }
  
  // more than one player with same UID, log everyone out
  if( occurences > 1 )
  {
    foreach( p in GetPlayerArray() )
    {
      Chat_ServerPrivateMessage( p, "Found duplicate UID, logging everyone out!", false )
      Logout( player )
    }
    return true
  }
  
  return false
}

// !mute
void function FSU_C_Mute ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, "Missing argument!", false )
    return
  }
  
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      FSU_Mute( p.GetUID() )
      Chat_ServerPrivateMessage( player, "Muted \x1b[113m" + p.GetPlayerName() + "\x1b[0m!", false )
      Chat_ServerPrivateMessage( p, "You were muted!", false )
      return
    }
  }
  
  Chat_ServerPrivateMessage( player, "Couldn't find \x1b[113m" + player.GetPlayerName() + "\x1b[0m!", false )
}

// !unmute
void function FSU_C_Unmute ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, "Missing argument!", false )
    return
  }
  
  foreach ( p in GetPlayerArray() )
  {
    if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null )
    {
      FSU_Unmute( p.GetUID() )
      Chat_ServerPrivateMessage( player, "Unmuted \x1b[113m" + p.GetPlayerName() + "\x1b[0m!", false )
      Chat_ServerPrivateMessage( p, "You were unmuted!", false )
      return
    }
  }
  
  Chat_ServerPrivateMessage( player, "Couldn't find \x1b[113m" + player.GetPlayerName() + "\x1b[0m!", false )
}

// !logout
void function FSU_C_Logout ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( !Logout( player ) )
    Chat_ServerPrivateMessage( player, "Already logged out!", false )
}

// !login
void function FSU_C_Login ( entity player, array < string > args )
{
  if( CheckPlayerDuplicates( player ) )
    return
  
  if ( args.len() == 0 )
  {
    Chat_ServerPrivateMessage( player, "Missing argument!", false )
    return
  }
  
  if ( FSU_GetArray("FSU_ADMIN_UIDS").len() != FSU_GetArray("FSU_ADMIN_PASSWORDS").len() )
  {
    Chat_ServerPrivateMessage( player, "\x1b[113mFSU_ADMIN_UIDS\x1b[0m doesnt match the size \x1b[113mFSU_ADMIN_PASSWORDS\x1b[0m, aborting!", false )
    return
  }
  
  for( int i = 0; i < FSU_GetArray("FSU_ADMIN_UIDS").len(); i++ )
  {
    if( player.GetUID() == FSU_GetArray("FSU_ADMIN_UIDS")[i] )
    {
      if ( args[0] == FSU_GetArray("FSU_ADMIN_PASSWORDS")[i] )
        {
          if( Login( player ) )
            Chat_ServerPrivateMessage( player, "Logged in!", false )
          return
        }
    }
  }
  
  
  Chat_ServerPrivateMessage( player, "Wrong password!", false )
}