class Tab_WeaponPref extends UT2K3TabPanel;

var GUIListBox 			MyCurWeaponList;
var moCheckBox			SwitchWeaponCheckBox;
var GUIScrollTextBox	WeaponDescriptionBox;

var class<Weapon>		MyCurWeapon;

var SpinnyWeap			SpinnyWeap; // MUST be set to null when you leave the window
var vector				SpinnyWeapOffset;

var bool				bWeapPrefInitialised;
var bool				bChanged;
var bool				bUseDefaultPriority;

function int CompareWeaponPriority(GUIListElem ElemA, GUIListElem ElemB)
{
	local int PA, PB;
	local class<Weapon> WA, WB;

	WA = class<Weapon>(ElemA.ExtraData);
	WB = class<Weapon>(ElemB.ExtraData);


	if(bUseDefaultPriority)
	{
//		PA = WA.Default.DefaultPriority;
//		PB = WB.Default.DefaultPriority;
	}
	else
	{
		PA = WA.Default.Priority;
		PB = WB.Default.Priority;
	}

	return PB - PA;
}

function ShowPanel(bool bShow)
{
	if(!bWeapPrefInitialised)
	{
		MyCurWeaponList.List.CompareItem = CompareWeaponPriority;

		// Spawn 'please wait' screen while we DLO the weapons
		if ( Controller.OpenMenu("xinterface.UT2LoadingWeapons") )
			UT2LoadingWeapons(Controller.TopPage()).StartLoad(self);
	}

	Super.ShowPanel(bShow);

	if (!bShow && bWeapPrefInitialised)
		WeapApply(none);

}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	MyCurWeaponList = GUIListBox(Controls[0]);
	SwitchWeaponCheckBox = moCheckBox(Controls[4]);
	WeaponDescriptionBox = GUIScrollTextBox(Controls[5]);

	// Set up 'auto-switch weapon' check box
	SwitchWeaponCheckBox.Checked( !class'Engine.PlayerController'.default.bNeverSwitchOnPickup );
}

function UpdateWeaponPriorities()
{
	local int i;
	local class<Weapon> W;

	// Allocate priority values from 1 upwards
	for(i=0; i<MyCurWeaponList.List.ItemCount; i++)
	{
		W = class<Weapon>(MyCurWeaponList.List.GetObjectAtIndex(i));
		W.default.Priority = MyCurWeaponList.List.ItemCount - i;
		W.static.StaticSaveConfig();
	}
}

// Resort the weapons using their 'default' priority
function bool WeapDefaults(GUIComponent Sender)
{
	bUseDefaultPriority=true;

	MyCurWeaponList.List.SortList();
	MyCurWeaponList.List.SetIndex(0);
	UpdateCurrentWeapon();

	bChanged=true;
	bUseDefaultPriority=false;

	return true;
}

function bool WeapApply(GUIComponent Sender)
{
	if (bChanged)
		UpdateWeaponPriorities();

	bChanged=false;

	return true;
}

Delegate OnDeActivate()
{
	WeapApply(Self);
}

function SwapWeapons(int IndexA, int IndexB)
{
	// Swap it with the one above
	MyCurWeaponList.List.Swap(IndexA, IndexB);

	// Make 'apply' button visible
	bChanged=true;
}

function bool WeapUp(GUIComponent Sender)
{
	local int currPos;

	// Can't do any sorting if only one thing in the list!
	if(MyCurWeaponList.List.ItemCount == 0)
		return true;

	currPos = MyCurWeaponList.List.Index;

	// No room to move up
	if(currPos == 0)
		return true;

	SwapWeapons(currPos, currPos-1);
	MyCurWeaponList.List.Index = currPos-1;

	return true;
}

function bool WeapDown(GUIComponent Sender)
{
	local int currPos;

	if(MyCurWeaponList.List.ItemCount == 0)
		return true;

	currPos = MyCurWeaponList.List.Index;

	if(currPos == MyCurWeaponList.List.ItemCount - 1)
		return true;

	SwapWeapons(currPos, currPos+1);
	MyCurWeaponList.List.Index = currPos+1;

	return true;
}

function bool InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z, WX, WY, WZ;
	local rotator CamRot;

	if(MyCurWeapon != None)
	{
		canvas.GetCameraLocation(CamPos, CamRot);
		GetAxes(CamRot, X, Y, Z);

		if(SpinnyWeap.DrawType == DT_Mesh)
		{
			GetAxes(SpinnyWeap.Rotation, WX, WY, WZ);
			SpinnyWeap.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z) + (30 * WX));
		}
		else
		{
			SpinnyWeap.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z));
		}

		canvas.DrawActor(SpinnyWeap, false, true, 90.0);
	}

	return false;
}

function UpdateCurrentWeapon()
{
	local class<Weapon> currWeap;
	local class<Pickup> pickupClass;
	local class<InventoryAttachment> attachClass;
	local vector Scale3D;
    local bool b;
	local int i;

	if(SpinnyWeap == None)
		return;

	currWeap = class<Weapon>(MyCurWeaponList.List.GetObject());

	if(currWeap != None && currWeap != MyCurWeapon)
	{
		MyCurWeapon = currWeap;
		pickupClass = MyCurWeapon.default.PickupClass;
		attachClass = MyCurWeapon.default.AttachmentClass;

		if(MyCurWeapon != None)
		{
			if(pickupClass != None && pickupClass.default.StaticMesh != None)
			{
				SpinnyWeap.LinkMesh( None );
				SpinnyWeap.SetStaticMesh( pickupClass.default.StaticMesh );
				SpinnyWeap.SetDrawScale( pickupClass.default.DrawScale );
				SpinnyWeap.SetDrawScale3D( pickupClass.default.DrawScale3D );

				// Set skins array on spinnyweap to the same as the pickup class.
				SpinnyWeap.Skins.Length = pickupClass.default.Skins.Length;
				for(i=0; i<pickupClass.default.Skins.Length; i++)
				{
					SpinnyWeap.Skins[i] = pickupClass.default.Skins[i];
				}

				SpinnyWeap.SetDrawType(DT_StaticMesh);
			}
			else if(attachClass != None && attachClass.default.Mesh != None)
			{
				SpinnyWeap.SetStaticMesh( None );
				SpinnyWeap.LinkMesh( attachClass.default.Mesh );
				SpinnyWeap.SetDrawScale( 1.5 * attachClass.default.DrawScale );

				// Set skins array on spinnyweap to the same as the pickup class.
				SpinnyWeap.Skins.Length = attachClass.default.Skins.Length;
				for(i=0; i<attachClass.default.Skins.Length; i++)
				{
					SpinnyWeap.Skins[i] = attachClass.default.Skins[i];
				}

				// Flip attachment (for some reason)
				Scale3D = attachClass.default.DrawScale3D;
				Scale3D.Z *= -1.0;
				SpinnyWeap.SetDrawScale3D( 1.5 * Scale3D );

				SpinnyWeap.SetDrawType(DT_Mesh);
			}
			else
				Log("Could not find graphic for weapon: "$MyCurWeapon);
		}
	}

	WeaponDescriptionBox.SetContent( MyCurWeaponList.List.GetExtra() );

    b = CurrWeap.default.ExchangeFireModes == 1;
	moCheckBox(Controls[8]).Checked(b);

}

function InternalOnChange(GUIComponent Sender)
{
	local bool sw;
	local class<Weapon> currWeap;

	if(Sender == Controls[0])
	{
		UpdateCurrentWeapon();
		OnChange(Self);
	}
	else if(Sender == Controls[4])
	{
		sw = !SwitchWeaponCheckBox.IsChecked();

		// Set for current playercontroller
		PlayerOwner().bNeverSwitchOnPickup = sw;

		// Save for future games
		class'Engine.PlayerController'.default.bNeverSwitchOnPickup = sw;
		class'Engine.PlayerController'.static.StaticSaveConfig();
	}
    else if (Sender==Controls[8])
    {
		currWeap = class<Weapon>(MyCurWeaponList.List.GetObject());

    	if ( moCheckBox(Controls[8]).IsChecked() )
    		CurrWeap.default.ExchangeFireModes = 1;
        else
	        CurrWeap.default.ExchangeFireModes = 0;

    	CurrWeap.static.StaticSaveConfig();
    }

}

defaultproperties
{
     SpinnyWeapOffset=(X=150.000000,Y=54.500000,Z=14.000000)
     Begin Object Class=GUIListBox Name=WeaponPrefWeapList
         bVisibleWhenEmpty=True
         OnCreateComponent=WeaponPrefWeapList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="Select order for weapons"
         WinTop=0.083333
         WinLeft=0.022000
         WinWidth=0.400000
         WinHeight=0.696251
         OnChange=Tab_WeaponPref.InternalOnChange
     End Object
     Controls(0)=GUIListBox'XInterface.Tab_WeaponPref.WeaponPrefWeapList'

     Begin Object Class=GUIButton Name=WeaponPrefWeapUp
         Caption="Raise Priority"
         Hint="Increase the priority this weapon will have when picking your best weapon."
         WinTop=0.800000
         WinLeft=0.022000
         WinWidth=0.190000
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_WeaponPref.WeapUp
         OnKeyEvent=WeaponPrefWeapUp.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.Tab_WeaponPref.WeaponPrefWeapUp'

     Begin Object Class=GUIButton Name=WeaponPrefWeapDown
         Caption="Lower Priority"
         Hint="Decrease the priority this weapon will have when picking your best weapon."
         WinTop=0.870000
         WinLeft=0.022000
         WinWidth=0.190000
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_WeaponPref.WeapDown
         OnKeyEvent=WeaponPrefWeapDown.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.Tab_WeaponPref.WeaponPrefWeapDown'

     Begin Object Class=GUIButton Name=WeaponDefaults
         Caption="Defaults"
         Hint="Set the weapon priorities back to default"
         WinTop=0.800000
         WinLeft=0.231250
         WinWidth=0.190000
         WinHeight=0.050000
         OnClick=Tab_WeaponPref.WeapDefaults
         OnKeyEvent=WeaponDefaults.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.Tab_WeaponPref.WeaponDefaults'

     Begin Object Class=moCheckBox Name=WeaponAutoSwitch
         ComponentJustification=TXTA_Left
         Caption="Switch On Pickup"
         OnCreateComponent=WeaponAutoSwitch.InternalOnCreateComponent
         Hint="Automatically change weapons when you pick up a better one."
         WinTop=0.939062
         WinLeft=0.028000
         WinWidth=0.300000
         WinHeight=0.060000
         OnChange=Tab_WeaponPref.InternalOnChange
     End Object
     Controls(4)=moCheckBox'XInterface.Tab_WeaponPref.WeaponAutoSwitch'

     Begin Object Class=GUIScrollTextBox Name=WeaponDescription
         CharDelay=0.001500
         EOLDelay=0.250000
         OnCreateComponent=WeaponDescription.InternalOnCreateComponent
         WinTop=0.656667
         WinLeft=0.449999
         WinWidth=0.532501
         WinHeight=0.278750
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     Controls(5)=GUIScrollTextBox'XInterface.Tab_WeaponPref.WeaponDescription'

     Begin Object Class=GUILabel Name=WeaponPriorityLabel
         Caption="Weapon Priority"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.015000
         WinLeft=0.031914
         WinWidth=0.400000
         WinHeight=32.000000
     End Object
     Controls(6)=GUILabel'XInterface.Tab_WeaponPref.WeaponPriorityLabel'

     Begin Object Class=GUIImage Name=WeaponBK
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.085365
         WinLeft=0.450391
         WinWidth=0.533749
         WinHeight=0.552270
     End Object
     Controls(7)=GUIImage'XInterface.Tab_WeaponPref.WeaponBK'

     Begin Object Class=moCheckBox Name=WeaponSwap
         ComponentJustification=TXTA_Left
         Caption="Swap Fire Mode"
         OnCreateComponent=WeaponSwap.InternalOnCreateComponent
         Hint="Check this box to swap the firing mode on the selected weapon."
         WinTop=0.970312
         WinLeft=0.551437
         WinWidth=0.268750
         WinHeight=0.040000
         OnChange=Tab_WeaponPref.InternalOnChange
     End Object
     Controls(8)=moCheckBox'XInterface.Tab_WeaponPref.WeaponSwap'

     WinTop=0.150000
     WinHeight=0.740000
     OnDraw=Tab_WeaponPref.InternalDraw
}
