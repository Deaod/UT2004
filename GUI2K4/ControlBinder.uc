//==============================================================================
//  Created on: 11/23/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class ControlBinder extends KeyBindMenu;

var localized string BindingLabel[150];

function LoadCommands()
{
	local int i;

	Super.LoadCommands();

	// Update the MultiColumnList's sortdata array to reflect the indexes of our Bindings array
    for (i = 0; i < Bindings.Length; i++)
    	li_Binds.AddedItem();
}

function MapBindings()
{
	LoadCustomBindings();
	Super.MapBindings();
}

protected function LoadCustomBindings()
{
	local int i;
	local array<string> KeyBindClasses;
    local class<GUIUserKeyBinding> CustomKeyBindClass;

    // Load custom keybinds from .int files
    PlayerOwner().GetAllInt("XInterface.GUIUserKeyBinding",KeyBindClasses);
	for (i = 0; i < KeyBindClasses.Length; i++)
	{
		CustomKeyBindClass = class<GUIUserKeyBinding>(DynamicLoadObject(KeyBindClasses[i],class'Class'));
		if (CustomKeyBindClass != None)
			AddCustomBindings( CustomKeyBindClass.default.KeyData );
    }
}

function AddCustomBindings( array<GUIUserKeyBinding.KeyInfo> KeyData )
{
	local int i;

	for ( i = 0; i < KeyData.Length; i++ )
		CreateAliasMapping( KeyData[i].Alias, KeyData[i].KeyLabel, KeyData[i].bIsSection );
}

function ClearBindings()
{
	local int i, max;

	Super.ClearBindings();
	Bindings = default.Bindings;
	max = Min(Bindings.Length, ArrayCount(BindingLabel));
	for ( i = 0; i < max; i++ )
	{
		if ( BindingLabel[i] != "" )
			Bindings[i].KeyLabel = BindingLabel[i];
	}
}

defaultproperties
{
     BindingLabel(0)="Movement"
     BindingLabel(1)="Forward"
     BindingLabel(2)="Backward"
     BindingLabel(3)="Strafe Left"
     BindingLabel(4)="Strafe Right"
     BindingLabel(5)="Jump"
     BindingLabel(6)="Walk"
     BindingLabel(7)="Crouch"
     BindingLabel(8)="Strafe Toggle"
     BindingLabel(9)="Looking"
     BindingLabel(10)="Turn Left"
     BindingLabel(11)="Turn Right"
     BindingLabel(12)="Look Up"
     BindingLabel(13)="Look Down"
     BindingLabel(14)="Center View"
     BindingLabel(15)="Toggle "BehindView""
     BindingLabel(16)="Toggle Camera Mode"
     BindingLabel(17)="Weapons"
     BindingLabel(18)="Fire"
     BindingLabel(19)="Alt-Fire"
     BindingLabel(20)="Throw Weapon"
     BindingLabel(21)="Best Weapon"
     BindingLabel(22)="Next Weapon"
     BindingLabel(23)="Prev Weapon"
     BindingLabel(24)="Last Weapon"
     BindingLabel(25)="Weapon Selection"
     BindingLabel(26)="Super Weapon"
     BindingLabel(27)="Shield Gun"
     BindingLabel(28)="Assault Rifle"
     BindingLabel(29)="Bio-Rifle"
     BindingLabel(30)="Shock Rifle"
     BindingLabel(31)="Link Gun"
     BindingLabel(32)="Minigun"
     BindingLabel(33)="Flak Cannon"
     BindingLabel(34)="Rocket Launcher"
     BindingLabel(35)="Lightning Rifle"
     BindingLabel(36)="Translocator"
     BindingLabel(37)="Communication"
     BindingLabel(38)="Say"
     BindingLabel(39)="Team Say"
     BindingLabel(40)="In Game Chat"
     BindingLabel(41)="Speech Menu"
     BindingLabel(42)="Activate Microphone"
     BindingLabel(43)="Speak in Public Channel"
     BindingLabel(44)="Speak in local Channel"
     BindingLabel(45)="Speak in Team Channel"
     BindingLabel(46)="Toggle Public Channel"
     BindingLabel(47)="Toggle Local Channel"
     BindingLabel(48)="Toggle Team Channel"
     BindingLabel(49)="Taunts"
     BindingLabel(50)="Pelvic Thrust"
     BindingLabel(51)="Ass Smack"
     BindingLabel(52)="Throat Cut"
     BindingLabel(53)="Brag"
     BindingLabel(54)="Hud"
     BindingLabel(55)="Grow Hud"
     BindingLabel(56)="Shrink Hud"
     BindingLabel(57)="Show Radar Map"
     BindingLabel(58)="ScoreBoard Toggle"
     BindingLabel(59)="ScoreBoard"
     BindingLabel(60)="Game"
     BindingLabel(61)="Use"
     BindingLabel(62)="Pause"
     BindingLabel(63)="Screenshot"
     BindingLabel(64)="Find Red Base"
     BindingLabel(65)="Find Blue Base"
     BindingLabel(66)="Next Inventory Item"
     BindingLabel(67)="Previous Inventory Item"
     BindingLabel(68)="Activate Current Inventory Item"
     BindingLabel(69)="Show Personal Stats"
     BindingLabel(70)="View Next Player's Stats"
     BindingLabel(71)="Server Info"
     BindingLabel(72)="Vehicle Horn"
     BindingLabel(73)="Miscellaneous"
     BindingLabel(74)="Menu"
     BindingLabel(75)="Music Player"
     BindingLabel(76)="Voting Menu"
     BindingLabel(77)="Toggle Console"
     BindingLabel(78)="View Connection Status"
     BindingLabel(79)="Cancel Pending Connection"
     Bindings(0)=(bIsSectionLabel=True,KeyLabel="Movement")
     Bindings(1)=(KeyLabel="Forward",Alias="MoveForward")
     Bindings(2)=(KeyLabel="Backward",Alias="MoveBackward")
     Bindings(3)=(KeyLabel="Strafe Left",Alias="StrafeLeft")
     Bindings(4)=(KeyLabel="Strafe Right",Alias="StrafeRight")
     Bindings(5)=(KeyLabel="Jump",Alias="Jump")
     Bindings(6)=(KeyLabel="Walk",Alias="Walking")
     Bindings(7)=(KeyLabel="Crouch",Alias="Duck")
     Bindings(8)=(KeyLabel="Strafe Toggle",Alias="Strafe")
     Bindings(9)=(bIsSectionLabel=True,KeyLabel="Looking")
     Bindings(10)=(KeyLabel="Turn Left",Alias="TurnLeft")
     Bindings(11)=(KeyLabel="Turn Right",Alias="TurnRight")
     Bindings(12)=(KeyLabel="Look Up",Alias="LookUp")
     Bindings(13)=(KeyLabel="Look Down",Alias="LookDown")
     Bindings(14)=(KeyLabel="Center View",Alias="CenterView")
     Bindings(15)=(KeyLabel="Toggle "BehindView"",Alias="ToggleBehindView")
     Bindings(16)=(KeyLabel="Toggle Camera Mode",Alias="ToggleFreeCam")
     Bindings(17)=(bIsSectionLabel=True,KeyLabel="Weapons")
     Bindings(18)=(KeyLabel="Fire",Alias="Fire")
     Bindings(19)=(KeyLabel="Alt-Fire",Alias="AltFire")
     Bindings(20)=(KeyLabel="Throw Weapon",Alias="ThrowWeapon")
     Bindings(21)=(KeyLabel="Best Weapon",Alias="SwitchToBestWeapon")
     Bindings(22)=(KeyLabel="Next Weapon",Alias="NextWeapon")
     Bindings(23)=(KeyLabel="Prev Weapon",Alias="PrevWeapon")
     Bindings(24)=(KeyLabel="Last Weapon",Alias="SwitchToLastWeapon")
     Bindings(25)=(KeyLabel="Weapon Selection")
     Bindings(26)=(KeyLabel="Super Weapon",Alias="SwitchWeapon 0")
     Bindings(27)=(KeyLabel="Shield Gun",Alias="SwitchWeapon 1")
     Bindings(28)=(KeyLabel="Assault Rifle",Alias="SwitchWeapon 2")
     Bindings(29)=(KeyLabel="Bio-Rifle",Alias="SwitchWeapon 3")
     Bindings(30)=(KeyLabel="Shock Rifle",Alias="SwitchWeapon 4")
     Bindings(31)=(KeyLabel="Link Gun",Alias="SwitchWeapon 5")
     Bindings(32)=(KeyLabel="Minigun",Alias="SwitchWeapon 6")
     Bindings(33)=(KeyLabel="Flak Cannon",Alias="SwitchWeapon 7")
     Bindings(34)=(KeyLabel="Rocket Launcher",Alias="SwitchWeapon 8")
     Bindings(35)=(KeyLabel="Lightning Rifle",Alias="SwitchWeapon 9")
     Bindings(36)=(KeyLabel="Translocator",Alias="SwitchWeapon 10")
     Bindings(37)=(bIsSectionLabel=True,KeyLabel="Communication")
     Bindings(38)=(KeyLabel="Say",Alias="Talk")
     Bindings(39)=(KeyLabel="Team Say",Alias="TeamTalk")
     Bindings(40)=(KeyLabel="In Game Chat",Alias="InGameChat")
     Bindings(41)=(KeyLabel="Speech Menu",Alias="SpeechMenuToggle")
     Bindings(42)=(KeyLabel="Activate Microphone",Alias="VoiceTalk")
     Bindings(43)=(KeyLabel="Speak in Public Channel",Alias="Speak Public")
     Bindings(44)=(KeyLabel="Speak in local Channel",Alias="Speak Local")
     Bindings(45)=(KeyLabel="Speak in Team Channel",Alias="Speak Team")
     Bindings(46)=(KeyLabel="Toggle Public Chatroom",Alias="TogglePublicChat")
     Bindings(47)=(KeyLabel="Toggle Local Chatroom",Alias="ToggleLocalChat")
     Bindings(48)=(KeyLabel="Toggle Team Chatroom",Alias="ToggleTeamChat")
     Bindings(49)=(bIsSectionLabel=True,KeyLabel="Taunts")
     Bindings(50)=(KeyLabel="Pelvic Thrust",Alias="taunt pthrust")
     Bindings(51)=(KeyLabel="Ass Smack",Alias="taunt asssmack")
     Bindings(52)=(KeyLabel="Throat Cut",Alias="taunt throatcut")
     Bindings(53)=(KeyLabel="Brag",Alias="taunt gesture_point")
     Bindings(54)=(bIsSectionLabel=True,KeyLabel="Hud")
     Bindings(55)=(KeyLabel="Grow Hud",Alias="GrowHud")
     Bindings(56)=(KeyLabel="Shrink Hud",Alias="ShrinkHud")
     Bindings(57)=(KeyLabel="Show Radar Map",Alias="ToggleRadarMap")
     Bindings(58)=(KeyLabel="ScoreBoard",Alias="ShowScores")
     Bindings(59)=(KeyLabel="ScoreBoard (QuickView)",Alias="ScoreToggle")
     Bindings(60)=(bIsSectionLabel=True,KeyLabel="Game")
     Bindings(61)=(KeyLabel="Use",Alias="use")
     Bindings(62)=(KeyLabel="Pause",Alias="Pause")
     Bindings(63)=(KeyLabel="Screenshot",Alias="shot")
     Bindings(64)=(KeyLabel="Find Red Base",Alias="basepath 0")
     Bindings(65)=(KeyLabel="Find Blue Base",Alias="basepath 1")
     Bindings(66)=(KeyLabel="Next Inventory Item",Alias="InventoryNext")
     Bindings(67)=(KeyLabel="Previous Inventory Item",Alias="InventoryPrevious")
     Bindings(68)=(KeyLabel="Activate Current Inventory Item",Alias="InventoryActivate")
     Bindings(69)=(KeyLabel="Show Personal Stats",Alias="ShowStats")
     Bindings(70)=(KeyLabel="View Next Player's Stats",Alias="NextStats")
     Bindings(71)=(KeyLabel="Server Info",Alias="ServerInfo")
     Bindings(72)=(KeyLabel="Vehicle Horn",Alias="playvehiclehorn 0")
     Bindings(73)=(bIsSectionLabel=True,KeyLabel="Miscellaneous")
     Bindings(74)=(KeyLabel="Menu",Alias="ShowMenu")
     Bindings(75)=(KeyLabel="Music Player",Alias="MusicMenu")
     Bindings(76)=(KeyLabel="Voting Menu",Alias="ShowVoteMenu")
     Bindings(77)=(KeyLabel="Toggle Console",Alias="ConsoleToggle")
     Bindings(78)=(KeyLabel="View Connection Status",Alias="Stat Net")
     Bindings(79)=(KeyLabel="Cancel Pending Connection",Alias="Cancel")
     Headings(0)="Action"
     PageCaption="Configure Keys"
}
