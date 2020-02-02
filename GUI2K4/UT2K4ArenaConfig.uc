class UT2K4ArenaConfig extends BlackoutWindow;

var automated moComboBox	co_Weapon;
var automated GUIButton		b_OK;
var automated GUILabel		l_Title;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<CacheManager.WeaponRecord> Recs;
	local int i;

	Super.InitComponent(MyController, MyOwner);

	class'CacheManager'.static.GetWeaponList(Recs);
	for (i = 0; i < Recs.Length; i++)
		co_Weapon.AddItem(Recs[i].FriendlyName, None, Recs[i].ClassName);

	co_Weapon.ReadOnly(True);
	i = co_Weapon.FindExtra(class'MutArena'.default.ArenaWeaponClassName);
	if (i != -1)
		co_Weapon.SetIndex(i);
}

function bool InternalOnClick(GUIComponent Sender)
{
	class'MutArena'.default.ArenaWeaponClassName = co_Weapon.GetExtra();
	class'MutArena'.static.StaticSaveConfig();

	Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
     Begin Object Class=moComboBox Name=WeaponSelect
         bReadOnly=True
         bVerticalLayout=True
         LabelJustification=TXTA_Center
         ComponentJustification=TXTA_Center
         ComponentWidth=0.250000
         Caption="Choose the weapon to populate your Arena."
         OnCreateComponent=WeaponSelect.InternalOnCreateComponent
         WinTop=0.442760
         WinLeft=0.255078
         WinWidth=0.500782
         WinHeight=0.126563
         TabOrder=0
         bStandardized=False
     End Object
     co_Weapon=moComboBox'GUI2K4.UT2K4ArenaConfig.WeaponSelect'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.563333
         WinLeft=0.400000
         WinWidth=0.200000
         TabOrder=1
         OnClick=UT2K4ArenaConfig.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4ArenaConfig.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="Weapon Arena"
         TextAlign=TXTA_Center
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.391667
         WinHeight=0.058750
     End Object
     l_Title=GUILabel'GUI2K4.UT2K4ArenaConfig.DialogText'

}
