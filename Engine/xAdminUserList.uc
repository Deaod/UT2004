// ====================================================================
//  Class:  XAdmin.xAdminUserList
//  Parent: XAdmin.xAdminBase
//
//  <Enter a description here>
// ====================================================================

class xAdminUserList extends xAdminBase;

var private array<xAdminUser>	Users;

// Returns the number of Users in the list
function int Count()		{ return Users.Length; }

/////////////////////////////////////////////////
// CreateUser : Creates a new user 

function xAdminUser Create(string UserName, string Password, string Privileges)
{
local xAdminUser NewUser;

	NewUser = new(None) class'xAdminUser';
	if (NewUser != None)
		NewUser.Init(UserName, Password, Privileges);

	return NewUser;
}

function Add(xAdminUser NewUser)
{
	if (NewUser != None && !Contains(NewUser))
	{
		Users.Length = Users.Length + 1;
		Users[Users.Length - 1] = NewUser;
	}
}

function xAdminUser Get(int i)
{
	return Users[i];
}

function Remove(xAdminUser User)
{
local int i;

	if (User != None)
	{
		for (i=0; i<Users.Length; i++)
			if (Users[i] == User)
			{
				Users.Remove(i, 1);
				return;
			}
	}
}

function Clear()
{
	Users.Length = 0;
}

function bool Contains(xAdminUser User)
{
local int i;

	if (User != None)
	{
		for (i=0; i<Users.Length; i++)
			if (Users[i] == User)
				return true;
	}
	return false;
}

function xAdminUser FindByName(string UserName)
{
local int i;

	if (UserName != "")
	{
		for (i=0; i<Users.Length; i++)
			if (Users[i].UserName == UserName)
				return Users[i];
	}
	return None;
}

defaultproperties
{
}
