// ====================================================================
//  Class:  UnrealGame.ACTION_GotoMenu
//  Parent: GamePlay.ScriptedAction
//
//  When called, it will transfer the sequecne to a menu
// ====================================================================

class ACTION_GotoMenu extends ScriptedAction
	PerObjectConfig;

var(Action) config string		MenuName;
var(Action) bool		bDisconnect;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController CP;

	if ( MenuName == "" )
		MenuName = class'GameEngine'.default.MainMenuClass;

	ForEach C.AllActors(class'PlayerController',CP)
	{
		CP.ClientOpenMenu(MenuName,bDisconnect);
		return false;
	}

	return false;
}

function string GetMenuName()
{
	if ( MenuName == "" )
		MenuName = class'GameEngine'.default.MainMenuClass;

	return MenuName;
}

function string GetActionString()
{
	return "OpenMenu"@MenuName;
}

defaultproperties
{
     bDisconnect=True
}
