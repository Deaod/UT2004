//==============================================================================
// General message page to display "ladder completed" messages, simple title
// with picture
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4SP_PictureMessage extends LargeWindow;

var automated GUIImage	imgPictureBg, imgPicture;
var automated GUIButton btnOk;
var automated GUILabel lblTitle;

function bool btnOkOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

/**
	param1 = title, param2 = image
*/
event HandleParameters(string Param1, string Param2)
{
	local Material img;
	Super.HandleParameters(Param1, Param2);
	lblTitle.Caption = Param1;
	img = Material(DynamicLoadObject(Param2, class'Material'));
	if (img != none) imgPicture.Image = img;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=SPMimgPictureBg
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.278166
         WinLeft=0.239000
         WinWidth=0.520750
         WinHeight=0.463250
         RenderWeight=0.200000
     End Object
     imgPictureBg=GUIImage'GUI2K4.UT2K4SP_PictureMessage.SPMimgPictureBg'

     Begin Object Class=GUIImage Name=SPMimgPicture
         Image=Texture'2K4Menus.Controls.sectionback'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         X1=0
         Y1=0
         X2=1023
         Y2=767
         WinTop=0.292500
         WinLeft=0.240000
         WinWidth=0.518750
         WinHeight=0.435000
         RenderWeight=0.300000
     End Object
     imgPicture=GUIImage'GUI2K4.UT2K4SP_PictureMessage.SPMimgPicture'

     Begin Object Class=GUIButton Name=SPMbtnOk
         Caption="OK"
         FontScale=FNS_Small
         WinTop=0.765625
         WinLeft=0.401563
         WinWidth=0.200000
         OnClick=UT2K4SP_PictureMessage.btnOkOnClick
         OnKeyEvent=SPMbtnOk.InternalOnKeyEvent
     End Object
     btnOK=GUIButton'GUI2K4.UT2K4SP_PictureMessage.SPMbtnOk'

     Begin Object Class=GUILabel Name=SPLlblTitle
         Caption="no title"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.176667
         WinLeft=0.160000
         WinWidth=0.680000
         WinHeight=0.078750
     End Object
     lblTitle=GUILabel'GUI2K4.UT2K4SP_PictureMessage.SPLlblTitle'

     WinTop=0.150000
     WinLeft=0.150000
     WinWidth=0.700000
     WinHeight=0.700000
}
