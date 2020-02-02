//==============================================================================
// UT2004 Style Question Page
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class GUI2K4QuestionPage extends GUIQuestionPage;

function bool ButtonClick(GUIComponent Sender)
{
	local int T;

	T = GUIButton(Sender).Tag;
	ParentPage.InactiveFadeColor=ParentPage.Default.InactiveFadeColor;
	if ( NewOnButtonClick(T) ) Controller.CloseMenu( bool(T & (QBTN_Cancel|QBTN_Abort)) );
	OnButtonClick(T);
	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=imgBack
         Image=Texture'2K4Menus.NewControls.Display2'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowY=10
         WinTop=0.297917
         WinHeight=0.401563
     End Object
     Controls(0)=GUIImage'GUI2K4.GUI2K4QuestionPage.imgBack'

     Begin Object Class=GUILabel Name=lblQuestion
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.450000
         WinLeft=0.150000
         WinWidth=0.700000
         WinHeight=0.200000
     End Object
     Controls(1)=GUILabel'GUI2K4.GUI2K4QuestionPage.lblQuestion'

     WinTop=0.000000
     WinHeight=1.000000
}
