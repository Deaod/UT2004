//==============================================================================
//  Created on: 01/02/2004
//  Configures match rules for match setup
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MatchSetupRules extends MatchSetupPanelBase;

var automated RemotePlayInfoPanel p_Rules;

function InitPanel()
{
	Super.InitPanel();
	Group = class'VotingReplicationInfo'.default.OptionID;
}

function bool HandleResponse(string Type, string Info, string Data)
{
	local array<string> Parts;
	local string str1, str2;

	if ( Type ~= Group )
	{
		log("RULES HandleResponse Info '"$Info$"'  Data '"$Data$"'",'MapVoteDebug');
		if ( Info == class'VotingReplicationInfo'.default.AddID )
		{
			Split(Data, Chr(27),Parts);
			Parts.Length = 3;
			p_Rules.ReceivedRule( Parts[0], Parts[1], Parts[2] );
			p_Rules.bUpdate = True;
		}

		if ( Info == class'VotingReplicationInfo'.default.UpdateID && Divide(Data, Chr(27), str1, str2) )
			ReceiveValue( str1, str2 );

		return true;
	}

	return false;
}

function ReceiveValue( string SettingName, string NewValue )
{
	p_Rules.ReceivedValue( SettingName, NewValue );
}

function SendValue( string SettingName, string NewValue )
{
	SendCommand( Group $ ":" $ SettingName $ ";" $ NewValue );
}

function LoggedIn()
{
	Super.LoggedIn();
	p_Rules.ClearRules();
	p_Rules.bRefresh = true;
}

function ReceiveComplete()
{
	p_Rules.bUpdate = true;
	p_Rules.Refresh();
}

defaultproperties
{
     Begin Object Class=RemotePlayInfoPanel Name=PIPanel
         SettingChanged=MatchSetupRules.SendValue
         WinHeight=1.000000
         OnActivate=PIPanel.InternalOnActivate
     End Object
     p_Rules=RemotePlayInfoPanel'xVoting.MatchSetupRules.PIPanel'

     PanelCaption="Rules"
}
