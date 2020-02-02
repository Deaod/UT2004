//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to
// login in the PreLogin() function, and also controls whether or not a player
// can enter as a spectator or a game administrator.
//
//=============================================================================
class AccessControl extends Info Config;

struct AdminPlayer
{
	var xAdminUser	User;
	var PlayerReplicationInfo PRI;
};

var xAdminUserList		Users;
var xAdminGroupList		Groups;
var protected array<AdminPlayer>	LoggedAdmins;
var config array< class<xPrivilegeBase> >	PrivClasses;
var array<xPrivilegeBase>		PrivManagers;
var string AllPrivs;

var globalconfig array<string>   IPPolicies;
var	localized string          IPBanned;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
var localized string          SessionBanned;
var localized string		  KickedMsg;
var localized string          DefaultKickReason;
var localized string		  IdleKickReason;
var class<AdminBase>		  AdminClass;

var bool bReplyToGUI;
var bool bDontAddDefaultAdmin;

var private              string AdminName;
var private globalconfig string AdminPassword;	    // Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		// Password to enter game.
var globalconfig float          LoginDelaySeconds;  // Delay between login attempts

var globalconfig bool 			bBanByID;		// Set to true to ban by CDKey hash
var globalconfig Array<string>	BannedIDs;		// Holds information about how got banned

var transient Array<string> SessionIPPolicies; // sjs
var transient array<string> SessionBannedIDs;

const PROPNUM = 4;
var localized string 		ACDisplayText[PROPNUM];
var localized string		ACDescText[PROPNUM];

event PreBeginPlay()
{
	local xAdminUser  NewUser;

	Super.PreBeginPlay();

    assert( Users == None );
	Users = new(Level.xLevel) class'xAdminUserList';
    assert( Groups == None );
	Groups = new(Level.xLevel) class'xAdminGroupList';

	if (!bDontAddDefaultAdmin)
	{
		Groups.Add(Groups.CreateGroup("Admin", "", 255));
		NewUser = Users.Create(AdminName, AdminPassword, "");
		NewUser.AddGroup(Groups.FindByName("Admin"));
		Users.Add(NewUser);
		AdminName = "Admin";
	}
	InitPrivs();
}

function InitPrivs();

function SaveAdmins()
{
	AdminPassword = Users.Get(0).Password;
}

function bool AdminLogin( PlayerController P, string Username, string Password)
{
	if ( ValidLogin(Username, Password) )
	{
		P.PlayerReplicationInfo.bAdmin = true;
		return true;
	}
	return false;
}

function bool AdminLogout( PlayerController P )
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		return true;
	}
	return false;
}

function AdminEntered( PlayerController P, string Username)
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged in as Administrator.");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator." );
}

function AdminExited( PlayerController P )
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged out.");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.");
}

function bool IsAdmin(PlayerController P)
{
	return P.PlayerReplicationInfo.bAdmin;
}

function SetAdminFromURL(string N, string P)
{
local xAdminUser NewUser;
local xAdminGroup NewGroup;

	Log("SetAdminFromURL called");
	NewGroup = Groups.CreateGroup("URL::Admin", "", 255);
	NewGroup.bMasterAdmin = true;
	Groups.Add(NewGroup);
	NewUser = Users.Create(N, P, "");
	NewUser.AddGroup(NewGroup);
	Users.Add(NewUser);
	AdminName = N;
	SetAdminPassword(P);
}

function bool SetAdminPassword(string P)
{
	AdminPassword = P;
	return true;
}

function SetGamePassword(string P)
{
	GamePassword = P;
}

function bool RequiresPassword()
{
	return GamePassword != "";
}

function xAdminUser GetAdmin( PlayerController PC)
{
	return None;
}

function string GetAdminName( PlayerController PC)
{
	return AdminName;
}

function Kick( string S )
{
	local Controller C, NextC;

    for ( C=Level.ControllerList; C!=None; C=NextC )
    {
		NextC = C.NextController;
        if ( C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.PlayerName~=S )
        {
            if (PlayerController(C) != None)
				KickPlayer(PlayerController(C));
			else if ( C.PlayerReplicationInfo.bBot )
            {
				if (C.Pawn != None)
					C.Pawn.Destroy();
				if (C != None)
					C.Destroy();
            }
            break;
        }
    }
}

function SessionKickBan( string S ) // sjs
{
	local PlayerController P;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S
			&&	(NetConnection(P.Player)!=None) )
		{
			BanPlayer(P, true);
		}
}

function KickBan( string S )
{
	local PlayerController P;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S
			&&	(NetConnection(P.Player)!=None) )
		{
			BanPlayer(P);
			return;
		}
}

function bool KickPlayer(PlayerController C)
{
	// Do not kick logged admins
	if (C != None && !IsAdmin(C) && NetConnection(C.Player)!=None )
    {
		// TODO implement a way for admins to specify the reason
		C.ClientNetworkMessage("AC_Kicked",DefaultKickReason);
		if (C.Pawn != None)
			C.Pawn.Destroy();
		if (C != None)
			C.Destroy();
		return true;
    }
	return false;
}

function bool BanPlayer(PlayerController C, optional bool bSession)
{
local string IP;

	if (IsAdmin(C))
		return false;

	IP = C.GetPlayerNetworkAddress();
	if( CheckIPPolicy(IP) == 0 )
	{
		IP = Left(IP, InStr(IP, ":"));
		if (bSession)
		{
			Log("Adding Session Ban for: "$IP@C.GetPlayerIDHash()@C.PlayerReplicationInfo.PlayerName);

			if (bBanByID)
            	SessionBannedIDs[SessionBannedIDs.Length] = C.GetPlayerIDHash()$"|"$C.PlayerReplicationInfo.PlayerName;
			else
	            SessionIPPolicies[SessionIPPolicies.Length] = "DENY;"$IP;

			SaveConfig();
			C.ClientNetworkMessage("AC_SessionBan",Level.Game.GameReplicationInfo.AdminEmail);
		}
		else
		{
			Log("Adding Global Ban for: "$IP@C.GetPlayerIDHash()@C.PlayerReplicationInfo.PlayerName);

			if (bBanByID)
				BannedIDs[BannedIDs.Length] = C.GetPlayerIDHash()@C.PlayerReplicationInfo.PlayerName;
            else
				IPPolicies[IPPolicies.Length] = "DENY;"$IP;

			SaveConfig();
			C.ClientNetworkMessage("AC_Ban",Level.Game.GameReplicationInfo.AdminEmail);
		}

		if ( C.Pawn != None )
			C.Pawn.Destroy();
		C.Destroy();
		return true;
	}
	return false;
}

function bool KickBanPlayer(PlayerController P)
{
local string IP;

	if (!IsAdmin(P))
	{
		IP = P.GetPlayerNetworkAddress();
		if( CheckIPPolicy(IP) == 0 )
		{
			IP = Left(IP, InStr(IP, ":"));
			Log("Adding Global Ban for: "$IP@P.GetPlayerIDHash()@P.PlayerReplicationInfo.PlayerName);

			if (bBanById)
				BannedIDs[BannedIDs.Length] = P.GetPlayerIDHash()@P.PlayerReplicationInfo.PlayerName;
        	else
				IPPolicies[IPPolicies.Length] = "DENY;"$IP;

			SaveConfig();
			P.ClientNetworkMessage("AC_Ban",Level.Game.GameReplicationInfo.AdminEmail);
		}
		else P.ClientNetworkMessage("AC_Kicked",DefaultKickReason);
		if ( P.Pawn != None )
			P.Pawn.Destroy();

		P.Destroy();
		return true;
	}
	return false;
}

function bool CheckOptionsAdmin( string Options)
{
	local string InAdminName, InPassword;

	InPassword = Level.Game.ParseOption( Options, "Password" );
	InAdminName= Level.Game.ParseOption( Options, "AdminName" );
	return ValidLogin(InAdminName, InPassword);
}

function bool ValidLogin(string UserName, string Password)
{
	return (AdminPassword != "" && Password==AdminPassword);
}

function xAdminUser GetLoggedAdmin(PlayerController P)
{
	return Users.Get(0);
}

function xAdminUser GetUser(string uname)
{
	return None;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
    string PlayerID,
	out string Error,
	out string FailCode,
	bool bSpectator
)
{
	// Do any name or password or name validation here.
	local string InPassword;
	local bool   bAdmin;
	local int Result;

	Error="";
	InPassword = Level.Game.ParseOption( Options, "Password" );
	bAdmin = CheckOptionsAdmin(Options);

	if( (Level.NetMode != NM_Standalone) && !bAdmin && Level.Game.AtCapacity(bSpectator) )
	{
		// TODO: Check Login to make room for Master Admins if not enuff specs.

		FailCode="SERVERFULL";
//		Error=Level.Game.GameMessageClass.Default.MaxedOutMessage;

		// Must clear error string so that client doesn't receive additional connection failed messages
		Error = "";
	}
	else if	( GamePassword!="" && caps(InPassword)!=caps(GamePassword) && !bAdmin )
	{
		if( InPassword == "" )
		{
			Error = "";
			FailCode = "NEEDPW";
		}
		else
		{
			Error = "";
			FailCode = "WRONGPW";
		}
	}

	Result = CheckIPPolicy(Address);
	if ( Result == 0 && bBanByID )
		Result = CheckID(PlayerID);

	if ( Result > 0 )
	{
		if ( Result == 1 )
		{
			Error = "";
			FailCode = "SESSIONBAN";
		}

		else if ( Result == 2 )
		{
			Error = "";
			FailCode = "LOCALBAN";
		}
	}
}


// 0 - accept, 1 - sessionban, 2 - permanent ban
function int CheckIPPolicy(string Address, optional bool bSilent)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<IPPolicies.Length; i++)
	{
		if ( Divide( IPPolicies[i], ";", Policy, Mask ) )
		{
			if(Policy ~= "ACCEPT")
				bAcceptPolicy = True;
			else if(Policy ~= "DENY")
				bAcceptPolicy = False;
			else
				continue;

			j = InStr(Mask, "*");
			if(j != -1)
			{
				if(Left(Mask, j) == Left(Address, j))
				{
					bAcceptAddress = bAcceptPolicy;
					LastMatchingPolicy = i;
				}
			}
			else
			{
				if(Mask == Address)
				{
					bAcceptAddress = bAcceptPolicy;
					LastMatchingPolicy = i;
				}
			}
		}
	}

	if( !bAcceptAddress )
	{
		if ( !bSilent )
			Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);

		return 2;
	}

    // check session polices
    for(i=0; i<SessionIPPolicies.Length && SessionIPPolicies[i] != ""; i++ )
    {
    	Divide( SessionIPPolicies[i], ";", Policy, Mask );
	    if(Policy ~= "ACCEPT")
		    bAcceptPolicy = True;
	    else if(Policy ~= "DENY")
		    bAcceptPolicy = False;
	    else
		    continue;

	    j = InStr(Mask, "*");
	    if(j != -1)
	    {
		    if(Left(Mask, j) == Left(Address, j))
		    {
			    bAcceptAddress = bAcceptPolicy;
			    LastMatchingPolicy = i;
		    }
	    }
	    else
	    {
		    if(Mask == Address)
		    {
			    bAcceptAddress = bAcceptPolicy;
			    LastMatchingPolicy = i;
		    }
	    }
    }

    if ( !bAcceptAddress )
    {
    	if ( !bSilent )
   		    Log("Denied connection for "$Address$" with Session IP policy "$SessionIPPolicies[LastMatchingPolicy]);

   		return 1;
   	}

	return 0;
}

// Stubs in preparation of multi-admin system
function bool CanPerform(PlayerController P, string Action)
{
	// Filter out any Admin Users/Group/commands
	if (!AllowPriv(Action))
		return false;

	// Standard Admin actions only performed by Admin
	return P.PlayerReplicationInfo.bAdmin;
}

function bool AllowPriv(string priv)
{
	if (Left(priv, 1) ~= "A" || Left(priv, 1) ~= "G")
		return false;

	return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	i=0;
	PlayInfo.AddSetting(default.ServerGroup,      "GamePassword", default.ACDisplayText[i++], 240, 1, "Text",      "16",,True,True);
	PlayInfo.AddSetting(default.ServerGroup,        "IPPolicies", default.ACDisplayText[i++], 254, 1, "Text",      "15",,True,True);
	PlayInfo.AddSetting(default.ServerGroup,     "AdminPassword", default.ACDisplayText[i++], 255, 1, "Text",      "16",,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "LoginDelaySeconds", default.ACDisplayText[i++], 200, 1, "Text", "3;0:999",,True,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "GamePassword": 	  return default.ACDescText[0];
		case "IPPolicies":		  return default.ACDescText[1];
		case "AdminPassword":	  return default.ACDescText[2];
		case "LoginDelaySeconds": return default.ACDescText[3];
	}

	return Super.GetDescriptionText(PropName);
}

// 0 - ok, 1 - session, 2 - perm
function int CheckID(string CDHash)
{
    local int i;

    if ( class'LevelInfo'.static.IsDemoBuild() )
    	return 0;

    for (i=0;i<BannedIDs.Length;i++)
    	if ( CDHash~=Left(BannedIDs[i],32) )
    		return 2;

    for (i=0;i<SessionBannedIDs.Length;i++)
    	if ( CDHash~=Left(SessionBannedIDs[i],32) )
    		return 1;

    return 0;
}

defaultproperties
{
     IPPolicies(0)="ACCEPT;*"
     IPBanned="Your IP address has been banned on this server."
     WrongPassword="The password you entered is incorrect."
     NeedPassword="You need to enter a password to join this game."
     SessionBanned="Your IP address has been banned from the current game session."
     KickedMsg="You have been forcibly removed from the game."
     DefaultKickReason="None specified"
     IdleKickReason="Kicked for idling."
     AdminClass=Class'Engine.Admin'
     bBanByID=True
     ACDisplayText(0)="Game Password"
     ACDisplayText(1)="Access Policies"
     ACDisplayText(2)="Admin Password"
     ACDisplayText(3)="Login Delay"
     ACDescText(0)="If this password is set, players will have to enter it to join this server."
     ACDescText(1)="Specifies IP addresses or address ranges which have been banned."
     ACDescText(2)="Password required to login with administrator privileges on this server."
     ACDescText(3)="Number of seconds user must wait after an unsuccessful login attempt before able to login again."
}
