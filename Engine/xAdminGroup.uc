// ====================================================================
//  Class:  XAdmin.xAdminGroup
//  Parent: XAdmin.xAdminBase
//
//  <Enter a description here>
// ====================================================================

class xAdminGroup extends xAdminBase;

var string GroupName;
var string Privileges;
var byte   GameSecLevel;

// List of Users and Managers for quick display
var xAdminUserList	Users;
var xAdminUserList	Managers;

var bool			bMasterAdmin;

function Created()
{
	Users = new(None) class'xAdminUserList';
	Managers = new(None) class'xAdminUserList';
}

function Init(string sGroupName, string sPrivileges, byte nGameSecLevel)
{
	GroupName = sGroupName;
	Privileges = sPrivileges;
	GameSecLevel = nGameSecLevel;
	if (GroupName == "Admin")
		bMasterAdmin = true;
}

function SetPrivs(string privs)
{
local int i;

	Privileges = privs;
	for (i=0; i<Users.Count(); i++)
		Users.Get(i).RedoMergedPrivs();
}

static function bool ValidName(string uname)
{
local int i;

	if (Len(uname)<5)
		return false;

	for (i=0; i<Len(uname); i++)
		if (Instr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJMLMNOPQRSTUVWXYZ0123456789!%^*(){}[]<>.,", Mid(uname,i,1)) == -1)
			return false;

	return true;
}

function UnlinkUsers()
{
local int i;

	for (i=0; i<Users.Count(); i++)
		Users.Get(i).RemoveGroup(self);

	for (i=0; i<Managers.Count(); i++)
		Managers.Get(i).RemoveManagedGroup(self);
}

function RemoveUser(xAdminUser User)
{
	if (User != None)
	{
		if (Users.Contains(User))
			Users.Remove(User);

		if (Managers.Contains(User))
			Managers.Remove(User);
	}
}

/*
function AddUser(xAdminUser User)			{ Users.Add(User); }
function RemoveUser(xAdminUser User)		{ Users.Remove(User); }
function AddManager(xAdminUser Manager)		{ Managers.Add(Manager); }
function RemoveManager(xAdminUser Manager)	{ Managers.Remove(Manager); }

function bool HasUser(xAdminUser User)			{ return Users.Contains(User); }
function bool HasManager(xAdminUser Manager)	{ return Users.Contains(Manager); }

function xAdminUser FindUserByName(string UserName)		{ return Users.FindByName(UserName); }
function xAdminUser FindManagerByName(string UserName)	{ return Managers.FindByName(UserName); }
 */
function bool HasPrivilege(string priv)
{
	return bMasterAdmin || (InStr("|"$Privileges$"|", "|"$priv$"|") != -1) || Instr("|"$Left(Privileges,1)$"|", "|"$priv$"|") != -1;
}

defaultproperties
{
}
