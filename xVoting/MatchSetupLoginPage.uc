class MatchSetupLoginPage extends LargeWindow;

var automated GUILabel l_Title;
var automated moEditBox ed_UserID;
var automated moEditBox ed_Password;
var automated GUIButton b_LogIn;
var automated GUIButton b_Cancel;

var VotingReplicationInfo VRI;
//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local VotingReplicationInfo RI;
	Super.InitComponent(Mycontroller, MyOwner);

	ed_Password.MyEditBox.bConvertSpaces = true;

    // find the VotingReplicationInfo
	foreach AllObjects(class 'VotingReplicationInfo', RI)
	{
		if( RI.PlayerOwner != None && RI.PlayerOwner == PlayerOwner())
		{
			VRI = RI;
			break;
		}
	}
	if(VRI == None)
		Controller.CloseAll(false);

	ed_Password.MyEditBox.bMaskText=true;
	ed_UserID.SetComponentValue(PlayerOwner().PlayerReplicationInfo.PlayerName);
}
//------------------------------------------------------------------------------------------------
function bool InternalOnClick(GUIComponent Sender)
{
	if(Sender==b_Login && Len(ed_UserID.GetText())>0 && len(ed_Password.GetText())>0 )
	{
		VRI.MatchSetupLogin(ed_UserID.GetText(), ed_Password.GetText());
		setTimer(1, true);
	}

	if(Sender==b_Cancel)
		Controller.CloseAll(false);

	return true;
}
//------------------------------------------------------------------------------------------------
function timer()
{
	Super.timer();

	if(VRI != None && VRI.bMatchSetupPermitted)
		Controller.CloseMenu(false);
}
//------------------------------------------------------------------------------------------------
function bool UserIDKeyPress(out byte Key, out byte State, float delta)
{
	if((Key == 13) && (State==1)) // Enter Key
	{
		ed_Password.SetFocus(none);
		return true;
	}

	if((Key == 40) && (State==1)) // Up Down
	{
		ed_Password.SetFocus(none);
		return true;
	}
	return false;
}
//------------------------------------------------------------------------------------------------
function bool PasswordKeyPress(out byte Key, out byte State, float delta)
{
	if((Key == 13) && (State==1)) // Enter Key
	{
		if(Len(ed_UserID.GetText())>0 && len(ed_Password.GetText())>0 )
		{
			VRI.MatchSetupLogin(ed_UserID.GetText(), ed_Password.GetText());
			setTimer(1, true);
		}
		return true;
	}

	if((Key == 38) && (State==1)) // Up Key
	{
		ed_UserID.SetFocus(none);
		return true;
	}
	return false;
}
//------------------------------------------------------------------------------------------------
function Closed(GUIComponent Sender, bool bCancelled)
{
	VRI = None;
	Super.Closed(Sender, bCancelled);
}
//------------------------------------------------------------------------------------------------
event bool NotifyLevelChange()
{
	VRI = None;
	return Super.NotifyLevelChange();
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     Begin Object Class=GUILabel Name=TitleLabel
         Caption="Match Setup Login"
         TextAlign=TXTA_Center
         TextColor=(B=255)
         TextFont="UT2SmallFont"
         WinTop=0.287500
         WinLeft=0.302813
         WinWidth=0.382813
         WinHeight=0.053125
         RenderWeight=1.000000
     End Object
     l_Title=GUILabel'xVoting.MatchSetupLoginPage.TitleLabel'

     Begin Object Class=moEditBox Name=UserIDEditBox
         Caption="UserID"
         OnCreateComponent=UserIDEditBox.InternalOnCreateComponent
         WinTop=0.366667
         WinLeft=0.301250
         WinWidth=0.381250
         WinHeight=0.033750
         TabOrder=1
         OnKeyEvent=MatchSetupLoginPage.UserIDKeyPress
     End Object
     ed_UserID=moEditBox'xVoting.MatchSetupLoginPage.UserIDEditBox'

     Begin Object Class=moEditBox Name=PasswordEditBox
         Caption="Password"
         OnCreateComponent=PasswordEditBox.InternalOnCreateComponent
         WinTop=0.431667
         WinLeft=0.300000
         WinWidth=0.382500
         WinHeight=0.031250
         TabOrder=2
         OnKeyEvent=MatchSetupLoginPage.PasswordKeyPress
     End Object
     ed_Password=moEditBox'xVoting.MatchSetupLoginPage.PasswordEditBox'

     Begin Object Class=GUIButton Name=LoginButton
         Caption="Login"
         WinTop=0.526667
         WinLeft=0.330000
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=1.000000
         TabOrder=3
         OnClick=MatchSetupLoginPage.InternalOnClick
         OnKeyEvent=LoginButton.InternalOnKeyEvent
     End Object
     b_Login=GUIButton'xVoting.MatchSetupLoginPage.LoginButton'

     Begin Object Class=GUIButton Name=CancelButton
         Caption="Cancel"
         WinTop=0.526667
         WinLeft=0.536249
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=1.000000
         TabOrder=4
         OnClick=MatchSetupLoginPage.InternalOnClick
         OnKeyEvent=CancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'xVoting.MatchSetupLoginPage.CancelButton'

     bAllowedAsLast=True
     OpenSound=Sound'MenuSounds.selectDshort'
     WinTop=0.248697
     WinLeft=0.000000
     WinWidth=1.000000
     WinHeight=0.352864
}
