class UT2ArenaConfig extends UT2K3GUIPage;

var array<class<Weapon> >	WeaponClass;
var array<String>			WeaponDesc;

var moComboBox				WeaponCombo;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	WeaponCombo = moComboBox(Controls[4]);

	// Spawn 'please wait' screen while we DLO the weapons
	if ( Controller.OpenMenu("XInterface.UT2LoadingWeaponsArena") )
		UT2LoadingWeaponsArena(Controller.TopPage()).StartLoad(self);
}

function bool InternalOnClick(GUIComponent Sender)
{
	class'MutArena'.default.ArenaWeaponClassName = WeaponCombo.GetExtra();
	class'MutArena'.static.StaticSaveConfig();

	Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=DialogBackground
         StyleName="ComboListBox"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=DialogBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2ArenaConfig.DialogBackground'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.600000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=UT2ArenaConfig.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2ArenaConfig.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="Weapon Arena"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.325000
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'XInterface.UT2ArenaConfig.DialogText'

     Begin Object Class=GUILabel Name=DialogText2
         Caption="Choose the weapon to populate your Arena."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         WinTop=0.390626
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.UT2ArenaConfig.DialogText2'

     Begin Object Class=moComboBox Name=WeaponSelect
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         Caption="Weapon"
         OnCreateComponent=WeaponSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.467448
         WinLeft=0.293750
         WinWidth=0.431641
         WinHeight=0.040000
     End Object
     Controls(4)=moComboBox'XInterface.UT2ArenaConfig.WeaponSelect'

     WinTop=0.300000
     WinHeight=0.400000
}
