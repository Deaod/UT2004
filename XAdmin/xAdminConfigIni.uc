// ====================================================================
//  Class:  XAdmin.xAdminConfigIni
//  Parent: Engine.xAdminConfigBase
//
//  Retains the list of Admin Users and Groups and keeps them into an
//  Ini file.
// ====================================================================

class xAdminConfigIni extends xAdminConfigBase
	Config(xAdmin)
	ParseConfig;

struct AdminUser
{
	var string			AdminName;
	var string			Password;
	var string			Privileges;
	var array<string>	Groups;			// A User can be part of multiple groups
	var array<string>	ManagedGroups;
};

struct AdminGroup
{
	var string	GroupName;
	var string	Privileges;
	var byte	GameSecLevel;
};

var config array<AdminUser>		AdminUsers;
var config array<AdminGroup>	AdminGroups;

// TODO: Define when it should return false
static function bool Load(xAdminUserList Users, xAdminGroupList Groups, bool bDontAddDefaultAdmin)
{
local int i;
local xAdminUser	NewUser;
local xAdminGroup	NewGroup;
local AdminUser		User;
local AdminGroup	Group;
local bool			bDirty;

	Log("Loading Admins & Groups");

	// Start with converting groups
	for (i = 0; i<Default.AdminGroups.Length; i++)
	{
		// Make sure a group wasnt already added with a given name (manual tampering of ini file)
		Group = Default.AdminGroups[i];
		if (Groups.FindByName(Group.GroupName) == None)
		{
			NewGroup = Groups.CreateGroup(Group.GroupName, Group.Privileges, Group.GameSecLevel);
			Groups.Add(NewGroup);
		}
	}
	// If there are No Groups, Create a default Group (Admin)
	if (Groups.Count() == 0 || Groups.FindByName("Admin") == None)
	{
		Log("Creating Admin Group");
		Groups.Add(Groups.CreateGroup("Admin", "", 255));
		Groups.Add(Groups.CreateGroup("MatchSetup", "Xm", 240));
		bDirty = true;
	}

	// Then, convert each User
	for (i = 0; i<Default.AdminUsers.Length; i++)
	{
		// Make sure that a user with that name wasnt already added
		User = Default.AdminUsers[i];
		if (Users.FindByName(User.AdminName) == None)
		{
			NewUser = Users.Create(User.AdminName, User.Password, User.Privileges);
			if (NewUser != None)
			{
				NewUser.AddGroupsByName(Groups, User.Groups);
				NewUser.AddManagedGroupsByName(Groups, User.ManagedGroups);

				Users.Add(NewUser);
			}
		}
	}
	// if there are no Users, Create a default User (Admin)
	if (Users.Count() == 0 && !bDontAddDefaultAdmin)
	{
		NewUser = Users.Create("Admin", "Admin", "");
		NewUser.AddGroup(Groups.FindByName("Admin"));
		Users.Add(NewUser);
		bDirty = true;
	}

	if (bDirty)
		Save(Users, Groups);

	return true;
}

static function bool Save(xAdminUserList Users, xAdminGroupList Groups)
{
local int i, j, GrpLen, UserLen;
local xAdminUser User;
local xAdminGroup Group;

	// Fix the sizes of the current structure lists
	Default.AdminUsers.Length = Users.Count();
	Default.AdminGroups.Length = Groups.Count();

	// Rebuild the list of AdminGroups based on current internal list
	GrpLen = 0;
	for (i=0; i<Groups.Count(); i++)
	{
		Group = Groups.Get(i);
		if (Group.GroupName != "URL::Admin")
		{
			Default.AdminGroups[GrpLen].GroupName = Group.GroupName;
			Default.AdminGroups[GrpLen].Privileges = Group.Privileges;
			Default.AdminGroups[GrpLen].GameSecLevel = Group.GameSecLevel;
			GrpLen++;
		}
	}
	Default.AdminGroups.Length = GrpLen;

	// Rebuild the list of AdminUsers based on current internal list
	UserLen = 0;
	for (i=0; i<Users.Count(); i++)
	{
		User = Users.Get(i);
		if (User.GetGroup("URL::Admin") == None)
		{
			Default.AdminUsers[UserLen].AdminName = User.UserName;
			Default.AdminUsers[UserLen].Password = User.Password;
			Default.AdminUsers[UserLen].Privileges = User.Privileges;

			if (User.Groups != None && User.Groups.Count() > 0)
			{
				Default.AdminUsers[UserLen].Groups.Length = User.Groups.Count();
				for (j = 0; j<User.Groups.Count(); j++)
					Default.AdminUsers[UserLen].Groups[j] = User.Groups.Get(j).GroupName;
			}
			if (User.ManagedGroups != None && User.ManagedGroups.Count() > 0)
			{
				Default.AdminUsers[UserLen].ManagedGroups.Length = User.ManagedGroups.Count();
				for (j = 0; j<User.ManagedGroups.Count(); j++)
					Default.AdminUsers[UserLen].ManagedGroups[j] = User.ManagedGroups.Get(j).GroupName;
			}
			UserLen++;
		}
	}
	Default.AdminUsers.Length = UserLen;

	StaticSaveConfig();
	return true;
}

defaultproperties
{
}
