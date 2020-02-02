//==============================================================================
//  Created on: 11/19/2003
//  Menu for configuring speech binds
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class SpeechBinder extends KeyBindMenu;

var string VoiceType;
var class<TeamVoicePack> VoiceClass;

var UT2K4Tab_PlayerSettings tp_Player;
var transient bool bNoMatureLanguage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local UT2K4SettingsPage Setting;

	Super.InitComponent(MyController, MyOwner);

	bNoMatureLanguage = MyController.ViewportOwner.Actor.bNoMatureLanguage;
	if ( ParentPage != None && UT2K4SettingsPage(ParentPage) != None )
	{
		Setting = UT2K4SettingsPage(ParentPage);
		for ( i = 0; i < Setting.c_Tabs.TabStack.Length; i++ )
			if ( Setting.c_Tabs.TabStack[i] != None && Setting.c_Tabs.TabStack[i].MyPanel != None && UT2K4Tab_PlayerSettings(Setting.c_Tabs.TabStack[i].MyPanel) != None )
			{
				tp_Player = UT2K4Tab_PlayerSettings(Setting.c_Tabs.TabStack[i].MyPanel);
				tp_Player.VoiceTypeChanged = VoiceChanged;
				break;
			}
	}
}

function LoadCommands()
{
	local int i;
	local array<string> VoiceCommands;

	Super.LoadCommands();

	ResetVoiceClass();
	if ( VoiceClass == None )
		return;

	//////////////////////////////// ACKNOWLEDGEMENTS /////////////////////////////////////////////
	CreateAliasMapping("", class'ExtendedConsole'.default.SMStateName[2], True );

	VoiceClass.static.GetAllAcks( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech ACK" @ i, VoiceCommands[i], False );

	//////////////////////////////// FRIENDLY FIRE /////////////////////////////////////////////
	CreateAliasMapping( "", class'ExtendedConsole'.default.SMStateName[3], True);

	VoiceClass.static.GetAllFFire( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech FRIENDLYFIRE" @ i, VoiceCommands[i], False );

	//////////////////////////////// ORDERS /////////////////////////////////////////////
	CreateAliasMapping( "", class'ExtendedConsole'.default.SMStateName[4], True);

	VoiceClass.static.GetAllOrder( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech ORDER" @ i, VoiceCommands[i], False );


	//////////////////////////////// OTHER /////////////////////////////////////////////
	CreateAliasMapping( "", class'ExtendedConsole'.default.SMStateName[5], True);

	VoiceClass.static.GetAllOther( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech OTHER" @ i, VoiceCommands[i], False );

	//////////////////////////////// LOAD TAUNTS /////////////////////////////////////////////
	CreateAliasMapping( "", class'ExtendedConsole'.default.SMStateName[6], True );

	VoiceClass.static.GetAllTaunt( VoiceCommands, bNoMatureLanguage );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech TAUNT" @ i, VoiceCommands[i], False );
}

function ResetVoiceClass()
{
	local PlayerController PC;
	local string CharString;
	local xUtil.PlayerRecord Rec;

	PC = PlayerOwner();
	VoiceClass = None;

	if ( VoiceType != "" )
		VoiceClass = class<TeamVoicePack>(DynamicLoadObject(VoiceType,class'Class',true));

	if ( VoiceClass == None && PC.PlayerReplicationInfo != None )
	{
		if ( PC.PlayerReplicationInfo.VoiceType != None && class<TeamVoicePack>(PC.PlayerReplicationInfo.VoiceType) != None )
			VoiceClass = class<TeamVoicePack>(PC.PlayerReplicationInfo.VoiceType);
		else if ( PC.PlayerReplicationInfo.VoiceTypeName != "" )
			VoiceClass = class<TeamVoicePack>(DynamicLoadObject(PC.PlayerReplicationInfo.VoiceTypeName,class'Class'));
	}

	if ( VoiceClass == None )
	{
		VoiceType = PC.GetURLOption("Voice");
		if ( VoiceType == "" )
		{
			CharString = PC.GetURLOption("Character");
			if ( CharString != "" )
			{
				Rec = class'xUtil'.static.FindPlayerRecord(CharString);
				if ( Rec.VoiceClassName != "" )
					VoiceType = Rec.VoiceClassName;

				else if ( Rec.Species != None )
					VoiceType = Rec.Species.static.GetVoiceType(Rec.Sex ~= "Female", PC.Level);
			}
		}


		if ( VoiceType != "" )
			VoiceClass = class<TeamVoicePack>(DynamicLoadObject(VoiceType, class'Class'));
	}

	VoiceType = "";
}

function VoiceChanged(string NewVoiceType)
{
	VoiceType = NewVoiceType;
}

defaultproperties
{
     Headings(0)="Phrase"
     PageCaption="Speech Binder"
}
