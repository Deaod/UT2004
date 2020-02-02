// ====================================================================
//  Class:  XAdmin.xAdminGroupList
//  Parent: XAdmin.xAdminBase
//
//  <Enter a description here>
// ====================================================================

class xAdminGroupList extends xAdminBase;

var private array<xAdminGroup>	Groups;

function int Count()	{ return Groups.Length; }

function xAdminGroup CreateGroup(string GroupName, string Privileges, byte GameSecLevel)
{
local xAdminGroup NewGroup;

	NewGroup = FindByName(GroupName);
	if (NewGroup == None)
	{
		NewGroup = new(None) class'xAdminGroup';
		if (NewGroup != None)
		{
//			Log("Group"@GroupName@" was created");
			NewGroup.Init(GroupName, Privileges, GameSecLevel);
		}
		return NewGroup;
	}
	return None;
}

function Add(xAdminGroup Group)
{
	if (Group != None && !Contains(Group))
	{
		Groups.Length = Groups.Length + 1;
		Groups[Groups.Length - 1] = Group;
	}
}

function Remove(xAdminGroup Group)
{
local int i;

	if (Group != None)
	{
		for (i = 0; i<Groups.Length; i++)
			if (Groups[i] == Group)
			{
				Groups.Remove(i, 1);
				return;
			}
	}
}

function xAdminGroup Get(int index)
{
	if (index<0 || index >= Groups.Length)
		return None;
		
	return Groups[index];
}

function xAdminGroup FindByName(string GroupName)
{
local int i;

	for (i = 0; i<Groups.Length; i++)
		if (Groups[i].GroupName == GroupName)
			return Groups[i];
			
	return None;
}

function bool Contains(xAdminGroup Group)
{
local int i;

	for (i = 0; i<Groups.Length; i++)
		if (Groups[i] == Group)
			return true;
			
	return false;
}

function xAdminGroup FindMasterGroup()
{
local int i;

	for (i = 0; i<Groups.Length; i++)
		if (Groups[i].GameSecLevel == 255)
			return Groups[i];

	return None;
}

function Clear()
{
	Groups.Remove(0, Groups.Length);
}

defaultproperties
{
}
