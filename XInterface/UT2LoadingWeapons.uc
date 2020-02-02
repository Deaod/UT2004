class UT2LoadingWeapons extends UT2K3GUIPage;

var Tab_WeaponPref	WeaponTab;

event Timer()
{
	local int i;
	local array<class<Weapon> > WeaponClass;
	local array<string> WeaponDesc;

	// Initialise weapon list. Sort based on current priority - highest priority first
	Controller.GetWeaponList(WeaponClass, WeaponDesc);

	for(i=0; i<WeaponClass.Length; i++)
	{
		WeaponTab.MyCurWeaponList.List.Add(WeaponClass[i].default.ItemName, WeaponClass[i], WeaponDesc[i]);
	}

	WeaponTab.MyCurWeaponList.List.SortList();

	// Spawn spinny weapon actor
	WeaponTab.SpinnyWeap = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	WeaponTab.SpinnyWeap.SetRotation(PlayerOwner().Rotation);
	WeaponTab.SpinnyWeap.SetStaticMesh(None);

	// Start with first item on list selected
	WeaponTab.MyCurWeaponList.List.SetIndex(0);
	WeaponTab.UpdateCurrentWeapon();

	WeaponTab.bWeapPrefInitialised = true;


	WeaponTab = None;
	Controller.CloseMenu();
}

function StartLoad(Tab_WeaponPref tab )
{
	WeaponTab = tab;

	// Give the menu a chance to render before doing anything...
	SetTimer(0.15);
}

defaultproperties
{
     Begin Object Class=GUIButton Name=LoadWeapBackground
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=LoadWeapBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2LoadingWeapons.LoadWeapBackground'

     Begin Object Class=GUILabel Name=LoadWeapText
         Caption="Loading Weapon Database"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.471667
         WinHeight=32.000000
     End Object
     Controls(1)=GUILabel'XInterface.UT2LoadingWeapons.LoadWeapText'

     WinTop=0.425000
     WinHeight=0.150000
}
