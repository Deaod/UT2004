//====================================================================
//  UT2K4 footer panel
//
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_Footer extends ButtonFooter;

var automated GUIImage          i_Status;
var automated moCheckBox        ch_Standard;
var automated GUITitleBar       t_StatusBar;
var automated GUIButton b_Join, b_Spectate, b_Back, b_Refresh, b_Filter;

var UT2K4ServerBrowser p_Anchor;

function bool InternalOnClick(GUIComponent Sender)
{
    if (GUIButton(Sender) == None)
        return false;

    if (Sender == b_Back)
    {
        Controller.CloseMenu(False);
        return true;
    }

    if ( Sender == b_Join )
    {
    	p_Anchor.JoinClicked();
    	return true;
    }

    if ( Sender == b_Spectate )
    {
    	p_Anchor.SpectateClicked();
    	return true;
    }

    if ( Sender == b_Refresh )
    {
    	p_Anchor.RefreshClicked();
    	return true;
    }

    if ( Sender == b_Filter )
    {
    	p_Anchor.FilterClicked();
    	return true;
    }


    return false;
}

function UpdateActiveButtons(UT2K4Browser_Page CurrentPanel)
{
    if (CurrentPanel == None)
        return;

	UpdateButtonState( b_Join,     CurrentPanel.IsJoinAvailable( b_Join.Caption ) );
	UpdateButtonState( b_Refresh,  CurrentPanel.IsRefreshAvailable( b_Refresh.Caption ) );
	UpdateButtonState( b_Spectate, CurrentPanel.IsSpectateAvailable( b_Spectate.Caption ) );
	UpdateButtonState( b_Filter,   CurrentPanel.IsFilterAvailable( b_Filter.Caption ) );

	if ( b_Filter.MenuState == MSAT_Disabled )
		ch_Standard.Hide();
	else ch_Standard.Show();
}


function UpdateButtonState( GUIButton But, bool Active )
{
	if ( Active )
		EnableComponent(But);
	else DisableComponent(But);
}

function PositionButtons( Canvas C )
{
	local bool b;

	b                 = b_Filter.bVisible;
	b_Filter.bVisible = false;

	super.PositionButtons(C);

	b_Filter.bVisible = b;
	b_Filter.WinLeft  = GetMargin();
}

function float GetButtonLeft()
{
	local bool bWasVisible;
	local float Result;

	bWasVisible = b_Filter.bVisible;
	b_Filter.bVisible = False;

	Result = Super.GetButtonLeft();
	b_Filter.bVisible = bWasVisible;

	return Result;
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=OnlyStandardCheckBox
         CaptionWidth=0.900000
         Caption="Standard Servers Only"
         OnCreateComponent=OnlyStandardCheckBox.InternalOnCreateComponent
         FontScale=FNS_Small
         Hint="Only display standard servers (no mutators) in the server browser.  This option overrides filter settings."
         WinTop=0.093073
         WinLeft=0.020000
         WinWidth=0.243945
         WinHeight=0.308203
         TabOrder=5
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=False
     End Object
     ch_Standard=moCheckBox'GUI2K4.UT2k4Browser_Footer.OnlyStandardCheckBox'

     Begin Object Class=GUITitleBar Name=BrowserStatus
         bUseTextHeight=False
         Justification=TXTA_Right
         FontScale=FNS_Small
         WinTop=0.030495
         WinLeft=0.238945
         WinWidth=0.761055
         WinHeight=0.390234
         bBoundToParent=True
         bScaleToParent=True
     End Object
     t_StatusBar=GUITitleBar'GUI2K4.UT2k4Browser_Footer.BrowserStatus'

     Begin Object Class=GUIButton Name=BrowserJoin
         Caption="JOIN"
         StyleName="FooterButton"
         WinTop=0.085678
         WinLeft=611.000000
         WinWidth=124.000000
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=2
         bBoundToParent=True
         OnClick=UT2k4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserJoin.InternalOnKeyEvent
     End Object
     b_Join=GUIButton'GUI2K4.UT2k4Browser_Footer.BrowserJoin'

     Begin Object Class=GUIButton Name=BrowserSpec
         Caption="SPECTATE"
         StyleName="FooterButton"
         WinTop=0.085678
         WinLeft=0.771094
         WinWidth=0.114648
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2k4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserSpec.InternalOnKeyEvent
     End Object
     b_Spectate=GUIButton'GUI2K4.UT2k4Browser_Footer.BrowserSpec'

     Begin Object Class=GUIButton Name=BrowserBack
         Caption="BACK"
         StyleName="FooterButton"
         Hint="Return to the previous menu"
         WinTop=0.085678
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=4
         bBoundToParent=True
         OnClick=UT2k4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserBack.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'GUI2K4.UT2k4Browser_Footer.BrowserBack'

     Begin Object Class=GUIButton Name=BrowserRefresh
         Caption="REFRESH"
         StyleName="FooterButton"
         WinTop=0.085678
         WinLeft=0.885352
         WinWidth=0.114648
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=3
         bBoundToParent=True
         OnClick=UT2k4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserRefresh.InternalOnKeyEvent
     End Object
     b_Refresh=GUIButton'GUI2K4.UT2k4Browser_Footer.BrowserRefresh'

     Begin Object Class=GUIButton Name=BrowserFilter
         Caption="FILTERS"
         bAutoSize=True
         StyleName="FooterButton"
         Hint="Filters allow more control over which servers will appear in the server browser lists."
         WinTop=0.036482
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=0
         bBoundToParent=True
         OnClick=UT2k4Browser_Footer.InternalOnClick
         OnKeyEvent=BrowserFilter.InternalOnKeyEvent
     End Object
     b_Filter=GUIButton'GUI2K4.UT2k4Browser_Footer.BrowserFilter'

     ButtonHeight=0.040000
     bFullHeight=False
     Justification=TXTA_Right
     WinTop=0.936927
     WinHeight=0.062422
}
