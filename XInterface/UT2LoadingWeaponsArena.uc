class UT2LoadingWeaponsArena extends UT2K3GUIPage;

var UT2ArenaConfig	Config;

event Timer()
{
	local int i;

	// Initialise weapon list. Sort based on current priority - highest priority first
	Controller.GetWeaponList(Config.WeaponClass, Config.WeaponDesc);

	for(i=0; i<Config.WeaponClass.Length; i++)
	{
		Config.WeaponCombo.AddItem( Config.WeaponClass[i].default.ItemName, None, String(Config.WeaponClass[i]) );

		// If this is the currently selected one - put it in the dialog
		if( class'MutArena'.default.ArenaWeaponClassName == String(Config.WeaponClass[i]) )
		{
			Config.WeaponCombo.SetText( Config.WeaponClass[i].default.ItemName );
		}
	}

	Config = None;
	Controller.CloseMenu();
}

function StartLoad(UT2ArenaConfig arena )
{
	Config = arena;

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
     Controls(0)=GUIButton'XInterface.UT2LoadingWeaponsArena.LoadWeapBackground'

     Begin Object Class=GUILabel Name=LoadWeapText
         Caption="Loading Weapon Database"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.471667
         WinHeight=32.000000
     End Object
     Controls(1)=GUILabel'XInterface.UT2LoadingWeaponsArena.LoadWeapText'

     WinTop=0.425000
     WinHeight=0.150000
}
