// ====================================================================
//  Class:  XAdmin.AccessControlIni
//  Parent: Engine.AccessControl
//
//  <Enter a description here>
// ====================================================================

class AccessControlIni extends AccessControl;

var GameConfigSet	ConfigSet;
var AdminBase		CSEditor;

event Destroyed()
{
	if (CSEditor != None)
	{
		ConfigSet.EndEdit(false);
		AdminIni(CSEditor).ConfigSet = None;
		CSEditor = None;
	}
    Super.Destroyed();
}

function InitPrivs()
{
local int i, cnt;
local xPrivilegeBase	xPriv;

	Super.InitPrivs();
	cnt = 0;
	for (i = 0; i<PrivClasses.Length; i++)
	{
		xPriv = new PrivClasses[i];
		if (xPriv != None)
		{
			PrivManagers.Length = cnt+1;
			PrivManagers[cnt] = xPriv;
			cnt++;
			if (xPriv.LoadMsg != "")
				Log(xPriv.LoadMsg);

			// Prepare an AllPrivs string
			if (AllPrivs != "") AllPrivs = AllPrivs $ "|";
			AllPrivs = AllPrivs $ xPriv.MainPrivs $ "|" $xPriv.SubPrivs;
		}
		else
			Log("Invalid Privilege Class:"@PrivClasses[i]);
	}
}

event PreBeginPlay()
{
	Users=new(Level.xLevel) class'xAdminUserList';
	Groups=new(Level.xLevel) class'xAdminGroupList';

	class'xAdminConfigIni'.static.Load(Users, Groups, bDontAddDefaultAdmin);
	ConfigSet = new(Level.xLevel) class'GameConfigSet';
	ConfigSet.Level = Level;
	Super(Info).PreBeginPlay();
	InitPrivs();
}

function SaveAdmins()
{
	class'xAdminConfigIni'.static.Save(Users, Groups);
}

function bool AdminLogin( PlayerController P, string Username, string Password )
{
local xAdminUser	User;
local int index;

	if (P == None)
		return false;

	User = GetLoggedAdmin(P);
	if (User == None)
	{
	 	User = Users.FindByName(UserName);
		if (User != None)
		{
			// Check Password
			if (User.Password == Password)
			{
				index = LoggedAdmins.Length;
				LoggedAdmins.Length = index + 1;
				LoggedAdmins[index].User = User;
				LoggedAdmins[index].PRI = P.PlayerReplicationInfo;
				P.PlayerReplicationInfo.bAdmin = User.bMasterAdmin || User.HasPrivilege("Kp") || User.HasPrivilege("Bp");
			}
			else
				User = None;
		}
	}
	return (User != None);
}

function bool AdminLogout( PlayerController P )
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
		{
			P.PlayerReplicationInfo.bAdmin = false;
			LoggedAdmins.Remove(i, 1);
			return true;
		}
	return false;
}

function SetAdminFromURL(string N, string P)
{
local xAdminGroup xGroup;
local xAdminUser User;

	// Check that there is not a User by that name already
	// TODO: This check should happen MUCH earlier, like at GUI level.
	if (Users.FindByName(N) != None)
	{
		Log("User"@N@"already in user list, please choose another name");
		return;
	}

	// Find an Admin Group .. and if none, add one called URL::Admin (cant be created manually)
	xGroup = Groups.FindByName("URL::Admin");
	if (xGroup == None)
	{
		xGroup = Groups.CreateGroup("URL::Admin", "", 255);
		Groups.Add(xGroup);
	}
	if (xGroup != None)
	{
		xGroup.bMasterAdmin = true;
		xGroup.GameSecLevel = 255;

		// Then create a user to add to that group
		User = Users.Create(N, P, "");
		User.AddGroup(xGroup);
		Users.Add(User);
	}
}

function bool ValidLogin(string UserName, string Password)
{
local xAdminUser  User;

	User = Users.FindByName(UserName);
	return User != None && User.Password == Password;
}

function bool IsAdmin(PlayerController P)
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
			return true;

	return false;
}

function bool IsLogged(xAdminUser User)
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].User == User)
			return true;

	return false;
}
// Each admin can change his own password
function bool SetAdminPassword(string P)
{
	// There is no single Admin Password
	// Todo : Find the master admin password and change it ?
	return false;
}

function bool AllowPriv(string priv)
{
	return true;
}

function SetGamePassword(string P)
{
	// TODO: Check privs b4 calling super
	Super.SetGamePassword(P);
}

function string GetAdminName(PlayerController PC)
{
local xAdminUser User;

	User = GetLoggedAdmin(PC);
	if (User != None)
	{
		return User.UserName;
	}
	return "Unknown";
}

function AdminEntered( PlayerController P, string Username)
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged in as"@Username$".");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator." );
}

// Verify if an admin action can be performed by a player
function bool CanPerform(PlayerController P, string Action)
{
local int i;

	for (i=0; i<LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
			return LoggedAdmins[i].User.HasPrivilege(Action);

	return false;
}

function bool ReportLoggedAdminsTo(PlayerController P)
{
    return false;
}

function bool LockConfigSet(out GameConfigSet GCS, AdminBase Admin)
{
	if (CSEditor == None)
	{
		CSEditor = Admin;
		GCS = ConfigSet;
		return true;
	}
	return false;
}

function bool ReleaseConfigSet(out GameConfigSet GCS, AdminBase Admin)
{
	if (CSEditor == Admin && GCS == ConfigSet)
	{
		CSEditor = None;
		GCS = None;
		return true;
	}
	return false;
}

/////////////////////////////////////////////////////////////////////
// Local Functions Area
//
//

function xAdminUser GetLoggedAdmin(PlayerController P)
{
local int i;

	for (i=0; i < LoggedAdmins.Length; i++)
		if (LoggedAdmins[i].PRI == P.PlayerReplicationInfo)
			return LoggedAdmins[i].User;

	return None;
}

function xAdminUser GetUser(string uname)
{
	return Users.FindByName(uname);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( PropertyName ~= "AdminPassword" )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

defaultproperties
{
     PrivClasses(0)=Class'XAdmin.xKickPrivs'
     PrivClasses(1)=Class'XAdmin.xGamePrivs'
     PrivClasses(2)=Class'XAdmin.xUserGroupPrivs'
     PrivClasses(3)=Class'XAdmin.xExtraPrivs'
     AdminClass=Class'XAdmin.AdminIni'
}
