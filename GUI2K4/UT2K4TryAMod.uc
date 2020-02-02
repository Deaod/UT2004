//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4TryAMod extends LockedFloatingWindow;

var automated GUIScrollTextBox sb_Info;
var automated GUIImage i_bk;
var localized string InfoText, InfoCaption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local eFontScale fs;
	Super.InitComponent(MyController, MyOwner);

	t_WindowTitle.Style = Controller.GetStyle("NoBackground",fs);
	i_FrameBG.SetVisibility(false);

	sb_Main.bBoundToParent = true;
	sb_Main.bScaleToParent = true;
	sb_Main.Caption = InfoCaption;
	sb_Main.SetPosition(0,0,1,1);
	sb_Main.ManageComponent(sb_Info);
	sb_Info.SetContent(InfoText);
	sb_Main.TopPadding=0.1;
	sb_Main.LeftPadding=0;
	sb_Main.RightPadding=0;
	b_Cancel.SetVisibility(false);

	b_Ok.SetPosition(0.38,0.811524,0.2,b_Ok.WinHeight);
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=sbInfo
         bNoTeletype=True
         TextAlign=TXTA_Center
         OnCreateComponent=sbInfo.InternalOnCreateComponent
         WinHeight=1.000000
         TabOrder=0
     End Object
     sb_Info=GUIScrollTextBox'GUI2K4.UT2K4TryAMod.sbInfo'

     Begin Object Class=GUIImage Name=imgBack
         Image=Texture'2K4Menus.NewControls.NewFooter'
         ImageColor=(A=180)
         ImageStyle=ISTY_Stretched
         WinTop=0.050000
         WinLeft=0.010937
         WinWidth=0.978125
         WinHeight=0.900000
         RenderWeight=0.000010
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_bk=GUIImage'GUI2K4.UT2K4TryAMod.imgBack'

     InfoText="At the bottom of the server browser, there is a checkbox marked [Show Standard Servers Only], which is checked by default.  If you uncheck this box, the server browser will display servers running gameplay modifications which may radically alter gameplay.  If you are looking for something different, try unchecking that box."
     InfoCaption="Special Message..."
     DefaultLeft=0.100000
     DefaultTop=0.195833
     DefaultWidth=0.800000
     DefaultHeight=0.556250
     DesiredFade=150
     WinTop=0.195833
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.556250
}
