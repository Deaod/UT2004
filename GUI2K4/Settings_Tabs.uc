//==============================================================================
//  Base class for all settings pages
//
//  Created by Ron Prestenback
//  © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class Settings_Tabs extends UT2K4TabPanel;

//var automated GUIImage iBackground;

var GUIFooter           t_Footer;
var UT2K4SettingsPage   Setting;
var bool                bAlwaysApply;
var bool                bNeedApply;
var globalconfig bool   bExpert;

var string              PerformanceWarningMenu;
var localized string    PerformanceWarningText;
var float               WarningCounter, WarningLength;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    if ( UT2K4SettingsPage(MyOwner.MenuOwner) != None )
    {
        Setting = UT2K4SettingsPage(MyOwner.MenuOwner);
        bAlwaysApply = bAlwaysApply && Setting.bApplyImmediately;
        t_Footer = Setting.t_Footer;
    }

    Super.InitComponent(MyController, MyOwner);
}

// To catch any weirdness
event Opened(GUIComponent Sender)
{
    if ( (Setting == None || t_Footer == None) && UT2K4SettingsPage(Sender) != None )
    {
        Setting = UT2K4SettingsPage(Sender);
        bAlwaysApply = bAlwaysApply && Setting.bApplyImmediately;
        t_Footer = Setting.t_Footer;
    }

    Super.Opened(Sender);
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);

    if (bShow)
    {
    	if ( Setting.b_Apply != None )
    	{
	        if ( bAlwaysApply )
	        {
	        	DisableComponent(Setting.b_Apply);
	        	Setting.b_Apply.Hide();
	        	Setting.GetSizingButton();
	        }

	        else
	        {
	        	Setting.b_Apply.Show();
	        	Setting.GetSizingButton();

	            if (bNeedApply)
	                EnableComponent(Setting.b_Apply);
	            else DisableComponent(Setting.b_Apply);
	        }
	    }

        Setting.t_Header.SetCaption(Setting.PageCaption @ "|" @ PanelCaption);
    }

    else if (!bAlwaysApply)
    {
        if (Setting.b_Apply.MenuState != MSAT_Disabled)
            bNeedApply = True;
        else bNeedApply = False;
    }
}

function AcceptClicked()
{
    if (!bAlwaysApply)
        DisableComponent(Setting.b_Apply);

    SaveSettings();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);
	if ( bAlwaysApply )
	{
		AcceptClicked();
		return;
	}

	if (!bCancelled)
		SaveSettings();
}

function SaveSettings();
function ResetClicked();

function string GetNativeClassName(string VarName)
{
	local int i;
	local string Str;

	Str = PlayerOwner().ConsoleCommand("get ini:"$VarName@"Class");
	i = InStr(Str, "'");
	if (i != -1)
	{
		Str = Mid(Str, InStr(Str, "'") + 1);
		Str = Left(Str, Len(Str) - 1);
	}

	return Str;
}

function ShowPerformanceWarning( optional float Seconds )
{
	if ( Controller == None || default.bExpert )
		return;

	if ( !Controller.OpenMenu(PerformanceWarningMenu, string(Seconds)) )
	{
	    if ( Seconds <= 0.0 )
		   	Seconds	= 3.5;

		WarningLength = Seconds;
		WarningCounter = 0.0;

		SetTimer( 0.1, True );

		OnRendered = DrawPerfWarn;
	}
}

event Timer()
{
	WarningCounter += 0.1;
}

function DrawPerfWarn( Canvas C )
{
	C.Style = 5;	// Alpha
	C.SetDrawColor( 250, 250, 250, 255 * FMax( ((WarningLength - WarningCounter)/WarningLength), 0.0 ) );
	C.Font = Controller.GetMenuFont("UT2SmallHeaderFont").GetFont(C.SizeX);
	C.DrawTextJustified( PerformanceWarningText, 1, ActualLeft(), ActualTop(), ActualLeft() + ActualWidth(), (ActualTop() + ActualHeight()) * 0.8 );
	if ( WarningCounter >= WarningLength )
	{
		WarningLength  = 0.0;
		WarningCounter = 0.0;
		OnRendered = None;
		KillTimer();
	}
}

function InternalOnChange(GUIComponent Sender)
{
	if ( !bAlwaysApply && Setting.b_Apply != None )
		EnableComponent(Setting.b_Apply);
}

defaultproperties
{
     bAlwaysApply=True
     PerformanceWarningMenu="GUI2K4.UT2K4PerformWarn"
     PerformanceWarningText="The change you are making may adversely affect your performance."
     FadeInTime=0.150000
}
