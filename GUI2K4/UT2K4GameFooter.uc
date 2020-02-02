//==============================================================================
//  Created on: 12/14/2003
//  This footer goes on Instant Action & Host Multiplayer pages
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4GameFooter extends ButtonFooter;

var automated GUIButton b_Primary, b_Secondary, b_Back;
var() localized string PrimaryCaption, PrimaryHint, SecondaryCaption, SecondaryHint;

var UT2K4GamePageBase Owner;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	Owner = UT2K4GamePageBase(MenuOwner);
	b_Primary.OnClick = Owner.InternalOnClick;
	b_Secondary.OnClick = Owner.InternalOnClick;
	b_Back.OnClick = Owner.InternalOnClick;
}

function SetupButtons( optional string bPerButtonSizes )
{
	b_Primary.Caption = PrimaryCaption;
	b_Primary.SetHint( PrimaryHint );

	b_Secondary.Caption = SecondaryCaption;
	b_Secondary.SetHint( SecondaryHint );

	Super.SetupButtons(bPerButtonSizes);
}

defaultproperties
{
     Begin Object Class=GUIButton Name=GamePrimaryButton
         StyleName="FooterButton"
         WinTop=0.966146
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.033203
         TabOrder=0
         bBoundToParent=True
         OnKeyEvent=GamePrimaryButton.InternalOnKeyEvent
     End Object
     b_Primary=GUIButton'GUI2K4.UT2K4GameFooter.GamePrimaryButton'

     Begin Object Class=GUIButton Name=GameSecondaryButton
         StyleName="FooterButton"
         WinTop=0.966146
         WinLeft=0.758125
         WinWidth=0.120000
         WinHeight=0.033203
         TabOrder=1
         bBoundToParent=True
         OnKeyEvent=GameSecondaryButton.InternalOnKeyEvent
     End Object
     b_Secondary=GUIButton'GUI2K4.UT2K4GameFooter.GameSecondaryButton'

     Begin Object Class=GUIButton Name=GameBackButton
         Caption="BACK"
         StyleName="FooterButton"
         Hint="Return to Previous Menu"
         WinTop=0.966146
         WinWidth=0.120000
         WinHeight=0.033203
         TabOrder=2
         bBoundToParent=True
         OnKeyEvent=GameBackButton.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'GUI2K4.UT2K4GameFooter.GameBackButton'

}
