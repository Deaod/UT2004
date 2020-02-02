//==============================================================================
//  Created on: 01/02/2004
//  Configure general match setup options
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MatchSetupMain extends MatchSetupPanelBase;

var automated moComboBox co_GameType;
var automated moEditBox ed_Params, ed_DemoRec;
var automated moCheckbox ch_DemoRec, ch_Tournament;

var bool bDemoRec, bTournament;
var string GameClass, DemoFilename, Params;

function InitPanel()
{
	Super.InitPanel();

	Group = class'VotingReplicationInfo'.default.GeneralID;
}

function bool HandleResponse(string Type, string Info, string Data)
{
	local string InfoStr, SubType;

	if ( Type ~= Group )
	{
		log("MAIN HandleResponse Info '"$Info$"'  Data '"$Data$"'",'MapVoteDebug');
		if ( !Divide(Info, Chr(27), InfoStr, SubType) )
		{
			log("received unknown general token");
			return true;
		}

		if ( InfoStr ~= class'VotingReplicationInfo'.default.AddID )
		{
			switch ( SubType )
			{
			case class'VotingReplicationInfo'.default.TournamentID:
				bTournament = bool(Data);
				ch_Tournament.SetComponentValue(bTournament,True);
				break;

			case class'VotingReplicationInfo'.default.DemoRecID:
				bDemoRec = bool(Data);
				ch_DemoRec.SetComponentValue(bDemoRec,true);
				if ( bDemoRec )
					EnableComponent(ed_DemoRec);
				else DisableComponent(ed_DemoRec);
				break;

			case class'VotingReplicationInfo'.default.GameTypeID:
				GameClass = Data;
				if ( GameClass != "" )
				{
					co_GameType.MyComboBox.List.bNotify = false;
					co_GameType.Find(Data, ,true);
					co_Gametype.MyComboBox.List.bNotify = true;
				}
				break;

			case class'VotingReplicationInfo'.default.URLID:
				Params = Data;
				ed_Params.SetComponentValue(Params,true);
				break;
			}
		}

		else if ( InfoStr ~= class'VotingReplicationInfo'.default.UpdateID )
		{
			// this setting was changed by someone else
			switch ( SubType )
			{
			case class'VotingReplicationInfo'.default.TournamentID:
				bTournament = bool(Data);
				ch_Tournament.SetComponentValue(bTournament,True);
				break;

			case class'VotingReplicationInfo'.default.DemoRecID:
				bDemoRec = bool(Data);
				ch_DemoRec.SetComponentValue(bDemoRec,true);
				if ( bDemoRec )
					EnableComponent(ed_DemoRec);
				else DisableComponent(ed_DemoRec);
				break;

			case class'VotingReplicationInfo'.default.GameTypeID:
				GameClass = Data;
				if ( GameClass != "" )
				{
					co_GameType.MyComboBox.List.bNotify = false;
					co_GameType.Find(Data, ,true);
					co_Gametype.MyComboBox.List.bNotify = true;
				}
				break;

			case class'VotingReplicationInfo'.default.URLID:
				Params = Data;
				ed_Params.SetComponentValue(Params,true);
				break;
			}
		}

		return true;
	}

	return false;
}

function InternalOnChange( GUIComponent Sender )
{
	if ( Sender == ch_DemoRec )
	{
		if ( ch_DemoRec.IsChecked() )
			EnableComponent(ed_DemoRec);
		else DisableComponent(ed_DemoRec);
	}

	Super.InternalOnChange(Sender);
}

function SubmitChanges()
{
	if ( GameClass != co_GameType.GetExtra() )
		SendCommand( GetCommandString(co_GameType) );

	if ( bTournament != ch_Tournament.IsChecked() )
		SendCommand( GetCommandString(ch_Tournament) );

	if ( bDemoRec != ch_DemoRec.IsChecked() )
		SendCommand( GetCommandString(ch_DemoRec) );

	if ( Params != ed_Params.GetText() )
		SendCommand( GetCommandString(ed_Params) );

	Super.SubmitChanges();
}

function string GetCommandString( GUIComponent Comp )
{
	local string str;

	if ( Comp == None )
		return "";

	str = Group;

	switch ( Comp )
	{
	case co_Gametype:
		str $= ":" $ class'VotingReplicationInfo'.default.GametypeID $ ";" $ co_GameType.GetExtra();
		break;

	case ch_Tournament:
		str $= ":" $ class'VotingReplicationInfo'.default.TournamentID $ ";" $ ch_Tournament.IsChecked();
		break;

	case ch_DemoRec:
		str $= ":" $ class'VotingReplicationInfo'.default.DemoRecID;
		if ( ch_DemoRec.IsChecked() )
			str $= ";" $ ed_DemoRec.GetText();
		break;

	case ed_Params:
		str $= ":" $ class'VotingReplicationInfo'.default.URLID;
		if ( ed_Params.GetText() != "" )
			str $= ";" $ ed_Params.GetText();
		break;
	}

	return str;
}

defaultproperties
{
     Begin Object Class=moComboBox Name=GameTypeCombo
         Caption="Game Type"
         OnCreateComponent=GameTypeCombo.InternalOnCreateComponent
         Hint="Select the gametype to use in the current match"
         WinTop=0.132839
         WinLeft=0.014282
         WinWidth=0.622588
         WinHeight=0.100000
         TabOrder=0
     End Object
     co_GameType=moComboBox'xVoting.MatchSetupMain.GameTypeCombo'

     Begin Object Class=moEditBox Name=CommandLineParamsBox
         bVerticalLayout=True
         LabelJustification=TXTA_Center
         Caption="Additional Command Line Parameters"
         OnCreateComponent=CommandLineParamsBox.InternalOnCreateComponent
         Hint="Specify any additional command line parameters (optional)"
         WinTop=0.734349
         WinLeft=0.008252
         WinWidth=0.986084
         WinHeight=0.200000
         TabOrder=2
     End Object
     ed_Params=moEditBox'xVoting.MatchSetupMain.CommandLineParamsBox'

     Begin Object Class=moEditBox Name=DemoRecBox
         CaptionWidth=0.100000
         Caption="Filename"
         OnCreateComponent=DemoRecBox.InternalOnCreateComponent
         Hint="Enter the name of the demo you'd like to record for this match"
         WinTop=0.457450
         WinLeft=0.391845
         WinWidth=0.591943
         WinHeight=0.100000
         TabOrder=4
     End Object
     ed_DemoRec=moEditBox'xVoting.MatchSetupMain.DemoRecBox'

     Begin Object Class=moCheckBox Name=DemoRecCheckbox
         Caption="Record Demo"
         OnCreateComponent=DemoRecCheckbox.InternalOnCreateComponent
         Hint="Record a server-side demo of this match"
         WinTop=0.459699
         WinLeft=0.011267
         WinWidth=0.353046
         WinHeight=0.100000
         TabOrder=3
         OnChange=MatchSetupMain.InternalOnChange
     End Object
     ch_DemoRec=moCheckBox'xVoting.MatchSetupMain.DemoRecCheckbox'

     Begin Object Class=moCheckBox Name=TournamentCheckbox
         Caption="Tournament Mode"
         OnCreateComponent=TournamentCheckbox.InternalOnCreateComponent
         Hint="All players must be connected to the server before the match can start"
         WinTop=0.295934
         WinLeft=0.012272
         WinWidth=0.353296
         WinHeight=0.100000
         TabOrder=1
     End Object
     ch_Tournament=moCheckBox'xVoting.MatchSetupMain.TournamentCheckbox'

     PanelCaption="General"
}
