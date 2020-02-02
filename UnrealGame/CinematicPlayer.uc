// ====================================================================
//  Class:  UnrealGame.CinematicPlayer
//  Parent: UnrealGame.UnrealPlayer
//
//  <Enter a description here>
// ====================================================================

class CinematicPlayer extends UnrealPlayer;

function string FindMenu()
{
	local int i;
	local ScriptedSequence SS;

	if ( Level.Game.CurrentGameProfile != none )
	{
		// SP menu is started natively on disconnect
		return "";
	}

	foreach AllActors(class'ScriptedSequence',SS)
	{
		for (i=0;i<SS.Actions.Length;i++)
		{
			if (ACTION_GotoMenu(SS.Actions[i])!=None)
				return ACTION_GotoMenu(SS.Actions[i]).GetMenuName();
		}
	}

	return class'GameEngine'.default.MainMenuClass;		// Default back to the main menu
}

exec function Fire( optional float F )
{
	ShowMenu();
}

exec function AltFire( optional float F )
{
	ShowMenu();
}

exec function ShowMenu()
{
	GotoMenu(FindMenu());
}

exec function GotoMenu(string MenuName)
{
	if (MenuName != "") Player.GUIController.OpenMenu(MenuName);
	ConsoleCommand( "DISCONNECT" );
}

defaultproperties
{
}
