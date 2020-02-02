//==============================================================================
//	Description
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Tab_WeaponPref extends Settings_Tabs;

struct WeapItem
{
	var class<Weapon>	WeapClass;
	var int				WeapPriority;
	var int             CrosshairIndex;
	var bool			bAltFireMode;
	var bool			bClassicModel;
	var color			CustomColor;
	var float			CrosshairScale;
};

var array<WeapItem>		WeaponsList;

var automated GUISectionBackground i_BG, i_BG2, i_BG3;
var automated GUIImage i_Crosshair, i_CrosshairBG, i_Shadow, i_Bk;
var automated GUIGFXButton	b_Up, b_Down;
var automated GUIListBox	lb_Weapons;
var automated GUIScrollTextBox	lb_Desc;
var automated moCheckbox	ch_Swap, ch_WeaponCrosshair, ch_ClassicModel;
var automated moComboBox	co_Crosshair;
var automated moSlider		sl_Red, sl_Blue, sl_Green, sl_Alpha, sl_CrosshairScale;

var SpinnyWeap			SpinnyWeap; // MUST be set to null when you leave the window
var() vector				SpinnyWeapOffset;

var bool bWeaponCrosshair, bSwap;
var int iCrosshair, WeaponIndex;
var color	cCrosshair;

var float MaxCrosshairWidth, MaxCrosshairHeight, fScale;

var localized string HiddenText, LoadingText;

var config bool bDebugPriority, bDebugScale, bDebugWeapon;

function int CompareWeaponPriority(GUIListElem ElemA, GUIListElem ElemB)
{
	local int PA, PB, Result;
	local class<Weapon> WA, WB;

	WA = class<Weapon>(ElemA.ExtraData);
	WB = class<Weapon>(ElemB.ExtraData);
	PA = WA.default.Priority;
	PB = WB.default.Priority;

	Result = PB - PA;
	if ( Result != 0 || ElemA.Item == "" || ElemB.Item == "" )
		return Result;

	Result = StrCmp(ElemA.Item, ElemB.Item);
	if ( Result != 0 )
		return Result;

	return StrCmp(ElemA.ExtraStrData, ElemB.ExtraStrData);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local array<CacheManager.CrosshairRecord> CustomCrosshairs;

	Super.InitComponent(MyController, MyOwner);
	cCrosshair = class'HUD'.default.CrosshairColor;

	co_Crosshair.MyComboBox.MyListBox.MyList.bInitializeList = false;
	class'CacheManager'.static.GetCrosshairList(CustomCrosshairs);
	for(i = 0;i < CustomCrosshairs.Length;i++)
		co_Crosshair.AddItem(CustomCrosshairs[i].FriendlyName, CustomCrosshairs[i].CrosshairTexture);

	co_Crosshair.ReadOnly(true);
	co_Crosshair.MyComboBox.Edit.bAlwaysNotify = True;

	lb_Weapons.List.bDropSource=True;
	lb_Weapons.List.bDropTarget=True;
	lb_Weapons.List.bMultiSelect=False;

	i_BG2.ManageComponent(lb_Weapons);

	i_BG3.ManageComponent(ch_WeaponCrosshair);
	i_BG3.ManageComponent(sl_Red);
	i_BG3.ManageComponent(sl_Green);
   	i_BG3.ManageComponent(sl_Blue);
    i_BG3.ManageComponent(sl_Alpha);
    i_BG3.ManageComponent(sl_CrosshairScale);
    i_BG3.ManageComponent(co_Crosshair);


	if ( bDebugWeapon )
		OnKeyEvent = CoolOnKeyEvent;
}

function IntializeWeaponList()
{
	local UT2K4GenericMessageBox Page;

	// Display the "loading" page
	if ( Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox", "", LoadingText) )
	{
		Page = UT2K4GenericMessageBox(Controller.ActivePage);
		Page.RemoveComponent(Page.b_Ok);
		Page.RemoveComponent(Page.l_Text);
		Page.l_Text2.FontScale = FNS_Large;
		Page.l_Text2.WinHeight = 1.0;
		Page.l_Text2.WinTop = 0.0;
		Page.l_Text2.bBoundToParent = True;
		Page.l_Text2.bScaleToParent = True;
		Page.l_Text2.VertAlign = TXTA_Center;
		Page.l_Text2.TextAlign = TXTA_Center;
		Page.bRenderWorld = False;
		Page.OnRendered = ReallyInitializeWeaponList;
	}
}

function ReallyInitializeWeaponList( Canvas C )
{
	local int i;
	local array<CacheManager.WeaponRecord> Records;

	if ( Controller.ActivePage.Tag != 55 )
	{
		Controller.ActivePage.Tag = 55;
		return;
	}

	// Initialise weapon list. Sort based on current priority - highest priority first
	class'CacheManager'.static.GetWeaponList(Records);

	// Disable the combo list's OnChange()
	lb_Weapons.List.bNotify = False;

	lb_Weapons.List.Clear();
	for(i=0; i<Records.Length; i++)
		lb_Weapons.List.Add(Records[i].FriendlyName, DynamicLoadObject(Records[i].ClassName,class'Class'), Records[i].Description);

	lb_Weapons.List.SortList();

	// Spawn spinny weapon actor
	if ( SpinnyWeap == None )
		SpinnyWeap = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	SpinnyWeap.SetRotation(PlayerOwner().Rotation);
	SpinnyWeap.SetStaticMesh(None);

	// Start with first item on list selected
	lb_Weapons.List.SetIndex(0);
	WeaponListInitialized();

	lb_Weapons.List.bNotify = True;

	if ( Controller.ActivePage != PageOwner )
		Controller.CloseMenu(true);

	FocusFirst(none);
}


function ResetClicked()
{
	local int i;
	local bool bTemp;

	Super.ResetClicked();

	class'HUD'.static.ResetConfig("CrosshairStyle");
	class'HUD'.static.ResetConfig("bCrosshairShow");
	class'HUD'.static.ResetConfig("CrosshairColor");
	class'HUD'.static.ResetConfig("CrosshairOpacity");
	class'HUD'.static.ResetConfig("CrosshairScale");
	class'HudBase'.static.ResetConfig("bUseCustomWeaponCrosshairs");

	for (i = 0; i < WeaponsList.Length; i++)
	{
		WeaponsList[i].WeapClass.static.ResetConfig("Priority");
		WeaponsList[i].WeapClass.static.ResetConfig("ExchangeFireModes");
		WeaponsList[i].WeapClass.static.ResetConfig("bUseOldWeaponMesh");
		WeaponsList[i].WeapClass.static.ResetConfig("CustomCrosshairScale");
		WeaponsList[i].WeapClass.static.ResetConfig("CustomCrosshairTextureName");
		WeaponsList[i].WeapClass.static.ResetConfig("CustomCrosshair");
		WeaponsList[i].WeapClass.static.ResetConfig("CustomCrosshairColor");
	}

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	for (i = 0; i < Controls.Length; i++)
		Controls[i].LoadINI();

	lb_Weapons.List.SortList();
	Controller.bCurMenuInitialized = bTemp;

	WeaponListInitialized();
}

function SaveSettings()
{
	local color BlackColor;
	local Weapon InvWeap;
	local PlayerController PC;
	local Texture WeaponTex;
	local bool bSave;
	local int i;

	Super.SaveSettings();
	PC = PlayerOwner();
	if (PC != None && PC.myHUD != None)
	{
		if (PC.myHUD.CrosshairStyle != iCrosshair)
		{
			PC.myHUD.CrosshairStyle = iCrosshair;
			bSave = True;
		}

		if (PC.myHUD.bCrosshairShow != (bWeaponCrosshair || iCrosshair < co_Crosshair.ItemCount() - 1))
		{
			PC.myHUD.bCrosshairShow = (bWeaponCrosshair || iCrosshair < co_Crosshair.ItemCount() - 1);
			bSave = True;
		}

		if (PC.myHUD.CrossHairColor != cCrosshair)
		{
			PC.myHUD.CrosshairColor = cCrosshair;
			bSave = True;
		}

		if (PC.myHUD.CrosshairScale != fScale)
		{
			PC.myHUD.CrosshairScale = fScale;
			bSave = True;
		}


		if (HudBase(PC.myHUD) != None)
		{
			if (HudBase(PC.myHUD).bUseCustomWeaponCrosshairs != bWeaponCrosshair)
			{
				HudBase(PC.myHUD).bUseCustomWeaponCrosshairs = bWeaponCrosshair;
				bSave = True;
			}
		}
	    else if (class'HudBase'.default.bUseCustomWeaponCrosshairs != bWeaponCrosshair)
		{
			class'HudBase'.default.bUseCustomWeaponCrosshairs = bWeaponCrosshair;

			PC.myHUD.SaveConfig();
			class'HudBase'.static.StaticSaveConfig();
			bSave =False;
		}

		if (bSave)
			PC.myHUD.SaveConfig();
	}

	else
	{
		if (class'HUD'.default.CrosshairStyle != iCrosshair)
		{
			class'HUD'.default.CrosshairStyle = iCrosshair;
			bSave = True;
		}

		if (class'HUD'.default.bCrosshairShow != (bWeaponCrosshair || iCrosshair < co_Crosshair.ItemCount()))
		{
			class'HUD'.default.bCrosshairShow = (bWeaponCrosshair || iCrosshair < co_Crosshair.ItemCount());
			bSave = True;
		}

		if (class'HUD'.default.CrosshairColor != cCrosshair)
		{
			class'HUD'.default.CrosshairColor = cCrosshair;
			bSave = true;
		}

		if (class'HUD'.default.CrosshairScale != fScale)
		{
			class'HUD'.default.CrosshairScale = fScale;
			bSave = True;
		}

		if (class'HudBase'.default.bUseCustomWeaponCrosshairs != bWeaponCrosshair)
		{
			class'HudBase'.default.bUseCustomWeaponCrosshairs = bWeaponCrosshair;
			class'HudBase'.static.StaticSaveConfig();
			bSave = False;
		}

		if (bSave)
			class'HUD'.static.StaticSaveConfig();
	}

	for (i = 0; i < WeaponsList.Length; i++)
	{
		bSave = False;
		if (WeaponsList[i].WeapPriority != WeaponsList[i].WeapClass.default.Priority)
		{
			WeaponsList[i].WeapClass.default.Priority = WeaponsList[i].WeapPriority;
			bSave = True;
		}

		if (byte(WeaponsList[i].bAltFireMode) != WeaponsList[i].WeapClass.default.ExchangeFireModes)
		{
			WeaponsList[i].WeapClass.default.ExchangeFireModes = byte(WeaponsList[i].bAltFireMode);
			bSave = True;
		}

		if (WeaponsList[i].bClassicModel != WeaponsList[i].WeapClass.default.bUseOldWeaponMesh)
		{
			WeaponsList[i].WeapClass.default.bUseOldWeaponMesh = WeaponsList[i].bClassicModel;
			bSave = True;
		}

		if ( WeaponsList[i].CrosshairScale != WeaponsList[i].WeapClass.default.CustomCrosshairScale )
		{
			WeaponsList[i].WeapClass.default.CustomCrosshairScale = WeaponsList[i].CrosshairScale;
			bSave = True;
		}

		WeaponTex = GetTexture(WeaponsList[i].CrosshairIndex);
		if (WeaponTex == None) // Hidden crosshair
		{
			if (WeaponsList[i].WeapClass.default.CustomCrosshairTextureName != "")
			{
				WeaponsList[i].WeapClass.default.CustomCrosshairTextureName = "";
				bSave = True;
			}

			if (WeaponsList[i].WeapClass.default.CustomCrosshair != -1)
			{
				WeaponsList[i].WeapClass.default.CustomCrosshair = -1;
				bSave = True;
			}

			if (WeaponsList[i].WeapClass.default.CustomCrosshairColor != BlackColor)
			{
				WeaponsList[i].WeapClass.default.CustomCrosshairColor = BlackColor;
				bSave = True;
			}
		}

		else
		{
			if (WeaponsList[i].WeapClass.default.CustomCrosshairTextureName != string(WeaponTex))
			{
				WeaponsList[i].WeapClass.default.CustomCrosshairTextureName = string(WeaponTex);
				bSave = True;
			}

			if (WeaponsList[i].WeapClass.default.CustomCrosshair != WeaponsList[i].CrosshairIndex)
			{
				WeaponsList[i].WeapClass.default.CustomCrosshair = WeaponsList[i].CrosshairIndex;
				bSave = True;
			}

			if (WeaponsList[i].WeapClass.default.CustomCrosshairColor != WeaponsList[i].CustomColor)
			{
				WeaponsList[i].WeapClass.default.CustomCrosshairColor = WeaponsList[i].CustomColor;
				bSave = True;
			}


		}

		if (PC != None && PC.Pawn != None)
		{
			InvWeap = Weapon(PC.Pawn.FindInventoryType( WeaponsList[i].WeapClass ));
			if (InvWeap != None)
			{
				if (WeaponTex == None)
				{
					InvWeap.CustomCrosshairTexture		= None;
					InvWeap.CustomCrosshairTextureName	= "";
					InvWeap.CustomCrosshairColor		= BlackColor;
					InvWeap.CustomCrosshair				= -1;
				}

				else
				{
					InvWeap.CustomCrosshairTexture		= WeaponTex;
					InvWeap.CustomCrosshairTextureName	= string(WeaponTex);
					InvWeap.CustomCrossHairColor		= WeaponsList[i].CustomColor;
					InvWeap.CustomCrosshair				= WeaponsList[i].CrosshairIndex;
				}

				InvWeap.CustomCrossHairScale            = WeaponsList[i].CrosshairScale;
				InvWeap.ExchangeFireModes           	= byte(WeaponsList[i].bAltFireMode);

				if ( bDebugPriority )
				{
					log("Found weapon of class"@WeaponsList[i].WeapClass@"in Pawn inventory '"$InvWeap.Name$"'. Priority:"$InvWeap.Priority@"New value:"$WeaponsList[i].WeapPriority,'DebugPriority');
				}
				InvWeap.Priority						= WeaponsList[i].WeapPriority;
				InvWeap.bUseOldWeaponMesh				= WeaponsList[i].bClassicModel;
				InvWeap.SaveConfig();
				bSave = False;
			}
			else if ( bDebugPriority )
				log("Did not find any weapons of class"@ WeaponsList[i].WeapClass @"in pawn's inventory",'DebugPriority');
		}

		if (bSave)
			WeaponsList[i].WeapClass.static.StaticSaveConfig();
	}
}

function ShowPanel(bool bShow)
{
	local rotator R;

	Super.ShowPanel(bShow);
	if (bShow)
	{
		if ( bInit )
		{
			lb_Weapons.List.CompareItem = CompareWeaponPriority;
			IntializeWeaponList();
			bInit = False;
		}

		if ( SpinnyWeap != None )
		{
			R = PlayerOwner().Rotation;
			R.Yaw = 31000;
			SpinnyWeap.SetRotation(R);
		}
	}
}

function string InternalOnSaveINI(GUIComponent Sender)
{
	local int i, j, cnt;

	if (Sender == lb_Weapons)
	{
		cnt = lb_Weapons.ItemCount();
		for (i = 0; i < cnt; i++)
		{
			if ( bDebugPriority )
				log("Searching for WeaponList Index for"@i@lb_Weapons.List.GetItemAtIndex(i));
			j = FindWeaponListIndexAt(i);
			if (j != -1)
			{
				if ( bDebugPriority )
				{
					log("Found WeaponListIndex for"@i@":"$j@WeaponsList[j].WeapClass);
					log("Setting WeaponList["$j$"].WeapPriority to:"$cnt - i - 1);
				}

				WeaponsList[j].WeapPriority = cnt - i - 1;
			}
		}
	}
	return "";
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local HudBase Base;

	Base = HudBase(PlayerOwner().myHUD);

	if (GUIMenuOption(Sender) != None)
	{
		if ( Base != None )
		{
			switch (GUIMenuOption(Sender))
			{
			case ch_WeaponCrosshair:
				bWeaponCrosshair = Base.bUseCustomWeaponCrosshairs;
				ch_WeaponCrosshair.Checked(bWeaponCrosshair);
				break;

			case co_Crosshair:
				iCrosshair = Base.CrosshairStyle;
				if (!Base.bUseCustomWeaponCrosshairs)
				{
					co_Crosshair.SetIndex(iCrosshair);
					SetCrosshairGraphic(iCrosshair);
				}
				break;

			case sl_Red:
				if (!Base.bUseCustomWeaponCrosshairs)
					sl_Red.SetValue(cCrosshair.R);
				break;

			case sl_Green:
				if (!Base.bUseCustomWeaponCrosshairs)
					sl_Green.SetValue(cCrosshair.G);
				break;

			case sl_Blue:
				if (!Base.bUseCustomWeaponCrosshairs)
					sl_Blue.SetValue(cCrosshair.B);
				break;

			case sl_Alpha:
				if (!Base.bUseCustomWeaponCrosshairs)
					sl_Alpha.SetValue(cCrosshair.A);
				break;

			case sl_CrosshairScale:
				fScale = Base.CrosshairScale;
				if (!Base.bUseCustomWeaponCrosshairs)
					sl_CrosshairScale.SetValue(fScale);

				break;

			default:
				log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
				GUIMenuOption(Sender).SetComponentValue(s,true);
			}
		}
		else
		{
			switch ( GUIMenuOption(Sender) )
			{
			case ch_WeaponCrosshair:
				bWeaponCrosshair = class'HudBase'.default.bUseCustomWeaponCrosshairs;
				ch_WeaponCrosshair.Checked(bWeaponCrosshair);
				break;

			case co_Crosshair:
				iCrosshair = class'HUD'.default.CrosshairStyle;
				if (!class'HudBase'.default.bUseCustomWeaponCrosshairs)
				{
					co_Crosshair.SetIndex(iCrosshair);
					SetCrosshairGraphic(iCrosshair);
				}
				break;

			case sl_Red:
				if (!class'HudBase'.default.bUseCustomWeaponCrosshairs)
					sl_Red.SetValue(cCrosshair.R);
				break;

			case sl_Green:
				if (!class'HudBase'.default.bUseCustomWeaponCrosshairs)
					sl_Green.SetValue(cCrosshair.G);
				break;

			case sl_Blue:
				if (!class'HudBase'.default.bUseCustomWeaponCrosshairs)
					sl_Blue.SetValue(cCrosshair.B);
				break;

			case sl_Alpha:
				if (!class'HudBase'.default.bUseCustomWeaponCrosshairs)
					sl_Alpha.SetValue(cCrosshair.A);
				break;

			case sl_CrosshairScale:
				fScale = class'HUD'.default.CrosshairScale;
				if (!class'HudBase'.default.bUseCustomWeaponCrosshairs)
					sl_CrosshairScale.SetValue(fScale);

				if ( bDebugScale )
					log("Initial global crosshair scale is"@fScale);

				break;

			default:
				log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
				GUIMenuOption(Sender).SetComponentValue(s,true);
			}
		}
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local int i;
	local float f;

	Super.InternalOnChange(Sender);
	if(Sender == lb_Weapons)
	{
		i = FindWeaponListIndex();
		if (i == WeaponIndex)	// Changed priority
			WeaponsList[WeaponIndex].WeapPriority = lb_Weapons.List.Index;
		else UpdateCurrentWeapon();	// Selected a different weapon
		return;
	}

	switch (GUIMenuOption(Sender))
	{
	case co_Crosshair:
		i = co_Crosshair.GetIndex();
		if (bWeaponCrosshair)
			WeaponsList[WeaponIndex].CrosshairIndex = i;

		else iCrosshair = i;

		SetCrosshairGraphic(i);
		break;

	case ch_WeaponCrosshair:
		bWeaponCrosshair = ch_WeaponCrosshair.IsChecked();
		if (bWeaponCrosshair)
			co_Crosshair.SetIndex(WeaponsList[WeaponIndex].CrosshairIndex);

		else co_Crosshair.SetIndex(iCrosshair);

		break;

	case ch_Swap:
		WeaponsList[WeaponIndex].bAltFireMode = ch_Swap.IsChecked();
		break;

	case ch_ClassicModel:
		WeaponsList[WeaponIndex].bClassicModel = ch_ClassicModel.IsChecked();
		UpdateCurrentWeapon();
		break;

	case sl_Red:
		i = sl_Red.GetValue();
		if (bWeaponCrosshair)
			WeaponsList[WeaponIndex].CustomColor.R = i;
		else cCrosshair.R = i;
		i_Crosshair.ImageColor.R = i;
		break;

	case sl_Blue:
		i = sl_Blue.GetValue();
		if (bWeaponCrosshair)
			WeaponsList[WeaponIndex].CustomColor.B = i;
		else cCrosshair.B = i;

		i_Crosshair.ImageColor.B = i;
		break;

	case sl_Green:
		i = sl_Green.GetValue();
		if (bWeaponCrosshair)
			WeaponsList[WeaponIndex].CustomColor.G = i;
		else cCrosshair.G = i;

		i_Crosshair.ImageColor.G = i;
		break;

	case sl_Alpha:
		i = sl_Alpha.GetValue();
		if (bWeaponCrosshair)
			WeaponsList[WeaponIndex].CustomColor.A = i;
		else cCrosshair.A = i;

		i_Crosshair.ImageColor.A = i;
		break;

	case sl_CrosshairScale:
		f = sl_CrosshairScale.GetValue();
		if (bWeaponCrosshair)
		{
			if ( bDebugScale )
				log("Changing custom crosshair scale for "$WeaponsList[WeaponIndex].WeapClass@"from"@WeaponsList[WeaponIndex].CrosshairScale@"to"@f);
			WeaponsList[WeaponIndex].CrosshairScale = f;
		}
		else
		{
			if ( bDebugScale )
				log("Changing global crosshair scale from "$fScale@"to"@f);
			fScale = f;
		}

		i_Crosshair.WinHeight = f * MaxCrosshairHeight;
		i_Crosshair.WinWidth = f * MaxCrosshairWidth;
	}
}

function WeaponListInitialized()
{
	local int i;
	local WeapItem WI;
	local texture CustomTex;

	if (WeaponsList.Length > 0)
		WeaponsList.Remove(0, WeaponsList.Length);

	// Disable the combo list's OnChange()
	co_Crosshair.MyComboBox.List.bNotify = false;
	for (i = 0; i < lb_Weapons.List.ItemCount; i++)
	{
		WI.WeapClass = class<Weapon>(lb_Weapons.List.GetObjectAtIndex(i));
		WI.WeapPriority = WI.WeapClass.default.Priority;
		WI.CrosshairScale = WI.WeapClass.default.CustomCrosshairScale;

		if ( bDebugScale )
			log("Crosshair scale for "$WI.WeapClass$" is"@WI.CrosshairScale);

		CustomTex = WI.WeapClass.default.CustomCrosshairTexture;
		if (CustomTex == None)
		{
			if (WI.WeapClass.default.CustomCrosshairTextureName != "")
			{
				WI.CrosshairIndex = FindTextureNameIndex(WI.WeapClass.default.CustomCrosshairTextureName);
				if (WI.CrosshairIndex < 0)
				{
					CustomTex = Texture(DynamicLoadObject(WI.WeapClass.default.CustomCrosshairTextureName, class'Texture'));
					if (CustomTex != None)
						WI.CrosshairIndex = FindTextureIndex(CustomTex);
					else log("Could not load specified custom crosshair texture '"$WI.WeapClass.default.CustomCrosshairTextureName$"' for weapon"@WI.WeapClass$". Removing weapon's crosshair from crosshair list.");
				}

				else CustomTex = GetTexture(WI.CrosshairIndex);
			}

			else if (WI.WeapClass.default.CustomCrosshair != -1) // && WI.WeapClass.default.CustomCrosshair < class'HudBase'.default.Crosshairs.Length)
			{
				//CustomTex = Texture(class'HudBase'.default.Crosshairs[WI.WeapClass.default.CustomCrosshair].WidgetTexture);
				//WI.CrosshairIndex = FindTextureIndex(CustomTex);
				CustomTex = GetTexture(WI.WeapClass.default.CustomCrosshair);
				WI.CrosshairIndex = WI.WeapClass.default.CustomCrosshair;
			}

			else WI.CrosshairIndex = -1;
		}

		else
		{
			CustomTex = WI.WeapClass.default.CustomCrosshairTexture;
			WI.CrosshairIndex = FindTextureIndex(CustomTex);
		}

		// don't add this weapon to weapons struct array if we couldn't load a crosshair by now
		if (CustomTex == None && WI.WeapClass.default.CustomCrosshair != -1)
		{
			Warn("Could not load crosshair for weapon"@WI.WeapClass@"so removing from custom weapons list.");
			continue;
		}

		if ( WI.WeapClass.default.OldMesh != None )
			WI.bClassicModel = WI.WeapClass.default.bUseOldWeaponMesh;

		WI.bAltFireMode = WI.WeapClass.default.ExchangeFireModes == 1;
		WI.CustomColor = WI.WeapClass.default.CustomCrosshairColor;

		if (WI.CrosshairIndex == co_Crosshair.ItemCount())
			co_Crosshair.AddItem(co_Crosshair.GetItem(FindTextureNameIndex(WI.WeapClass.default.CustomCrosshairTextureName)), CustomTex);

		WeaponsList[WeaponsList.Length] = WI;
	}

	// Add the "hidden" crosshair to the end of the list, since it won't have a texture
	if ( co_Crosshair.FindIndex(HiddenText) == -1 )
		co_Crosshair.AddItem(HiddenText);

	// Reenable the combo list's OnChange()
	co_Crosshair.MyComboBox.List.bNotify = True;
	UpdateCurrentWeapon();
}

function SwapWeapons(int OriginalLoc, int NewLoc)
{
	lb_Weapons.List.Swap(OriginalLoc, NewLoc);
	lb_Weapons.List.SetIndex(NewLoc);
}

function bool ChangePriority(GUIComponent Sender)
{
	if (lb_Weapons.List.ItemCount > 1)
	{
		if (Sender == b_Up && lb_Weapons.List.Index > 0)
			SwapWeapons(lb_Weapons.List.Index, lb_Weapons.List.Index - 1);

		else if (Sender == b_Down && lb_Weapons.List.Index < lb_Weapons.List.ItemCount - 1)
			SwapWeapons(lb_Weapons.List.Index, lb_Weapons.List.Index + 1);
	}

	return true;
}

function InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z, WX, WY, WZ;
	local rotator CamRot;

	if (WeaponIndex < 0)
		return;

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

	canvas.DrawActorClipped(SpinnyWeap, false, i_BG.ClientBounds[0], i_BG.ClientBounds[1], i_BG.ClientBounds[2] - i_BG.ClientBounds[0], (i_BG.ClientBounds[3] - i_BG.ClientBounds[1])/2, true, 90.0);

}

function UpdateCurrentWeapon()
{
	local PlayerController PC;
	local class<Pickup> pickupClass;
	local class<InventoryAttachment> attachClass;
	local Mesh OldMesh;
	local StaticMesh OldPickup;
	local float defscale;
	local vector Scale3D;
	local int i;

	if(SpinnyWeap == None)
		return;

	WeaponIndex = FindWeaponListIndex();
	if (WeaponIndex < 0)
	{
		PC = PlayerOwner();
		if (PC != None && PC.Pawn != None && PC.Pawn.Weapon != None)
		{
			for (i = 0; i < WeaponsList.Length; i++)
				if (ClassIsChildOf(PC.Pawn.Weapon.Class, WeaponsList[i].WeapClass))
					WeaponIndex = i;
		}

		if (WeaponIndex < 0)
			WeaponIndex = 0;	// must have a weapon selected
	}

	pickupClass = WeaponsList[WeaponIndex].WeapClass.default.PickupClass;
	attachClass = WeaponsList[WeaponIndex].WeapClass.default.AttachmentClass;
	OldMesh = WeaponsList[WeaponIndex].WeapClass.default.OldMesh;

	if ( PickupClass != None && PickupClass.default.StaticMesh != None )
	{
		defscale = PickupClass.default.DrawScale;
		Scale3D = PickupClass.default.DrawScale3D;
	}

	else if ( AttachClass != None && AttachClass.default.Mesh != None )
	{
		defscale = AttachClass.default.DrawScale;
		Scale3D = AttachClass.default.DrawScale3D;
		if ( Scale3D.X > 1.0 )
			Scale3D.X = 1.0;

		if ( Scale3D.Y > 1.0 )
			Scale3D.Y = 1.0;
	}

	else
	{
		defscale = 0.5;
		Scale3D = vect(1,1,1);
	}

	if ( OldMesh != None && !class'LevelInfo'.static.IsDemoBuild() )
	{
		EnableComponent(ch_ClassicModel);
		ch_ClassicModel.SetComponentValue( WeaponsList[WeaponIndex].bClassicModel, True );

		if ( WeaponsList[WeaponIndex].bClassicModel )
		{
			if ( WeaponsList[WeaponIndex].WeapClass.default.OldPickup != "" )
				OldPickup = StaticMesh(DynamicLoadObject(WeaponsList[WeaponIndex].WeapClass.default.OldPickup, class'StaticMesh'));

			if ( OldPickup != None )
			{
				SpinnyWeap.LinkMesh(None);
				SpinnyWeap.SetStaticMesh( OldPickup );
				SpinnyWeap.SetDrawScale(defscale);

				SpinnyWeap.SetDrawScale3D( scale3d );
				for ( i = 0; i < SpinnyWeap.Skins.Length; i++ )
					SpinnyWeap.Skins[i] = None;

				SpinnyWeap.SetDrawType(DT_StaticMesh);
			}
		}
	}

	else
	{
		ch_ClassicModel.SetComponentValue("False", True);
		DisableComponent(ch_ClassicModel);
	}

	if ( OldPickup == None )
	{
		if(pickupClass != None && pickupClass.default.StaticMesh != None)
		{
			SpinnyWeap.LinkMesh( None );
			SpinnyWeap.SetStaticMesh( pickupClass.default.StaticMesh );
			SpinnyWeap.SetDrawScale( defscale );
			SpinnyWeap.SetDrawScale3D( scale3d );

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
			SpinnyWeap.SetDrawScale( 1.3 * defscale );

			// Set skins array on spinnyweap to the same as the pickup class.
			SpinnyWeap.Skins.Length = attachClass.default.Skins.Length;
			for(i=0; i<attachClass.default.Skins.Length; i++)
			{
				SpinnyWeap.Skins[i] = attachClass.default.Skins[i];
			}

			if ( string(WeaponsList[WeaponIndex].WeapClass) == "XWeapons.Translauncher" )
				Scale3D.z *= -1.0;

			// Hack until someone fixes the shock and link models
			if ( (string(WeaponsList[WeaponIndex].WeapClass) != "XWeapons.ShockRifle" && string(WeaponsList[WeaponIndex].WeapClass) != "XWeapons.LinkGun") || WeaponsList[WeaponIndex].bClassicModel )
				SpinnyWeap.SetDrawScale3D( 1.3 * Scale3D );
			SpinnyWeap.SetDrawType(DT_Mesh);
		}
		else
			Log("Could not find graphic for weapon: "$WeaponsList[WeaponIndex].WeapClass);
	}


	i_BG.Caption = lb_Weapons.List.Get();
	lb_Desc.SetContent( lb_Weapons.List.GetExtra() );
	ch_Swap.SetComponentValue( WeaponsList[WeaponIndex].bAltFireMode, True );

	if (bWeaponCrosshair)
	{
		if (WeaponsList[WeaponIndex].CrosshairIndex == -1)
			WeaponsList[WeaponIndex].CrosshairIndex = co_Crosshair.ItemCount() - 1;

		co_Crosshair.SetIndex( WeaponsList[WeaponIndex].CrosshairIndex );
		SetCrosshairGraphic(WeaponsList[WeaponIndex].CrosshairIndex);
	}

	else
	{
		co_Crosshair.SetIndex(iCrosshair);
		SetCrosshairGraphic(iCrosshair);
	}
}

function SetCrossHairGraphic(int Index)
{
	local bool b;

	b = (Index >= 0 && Index < co_Crosshair.ItemCount() - 1) && PlayerOwner().myHUD.bCrosshairShow;
	if (b)
		i_Crosshair.Image = Texture(co_Crosshair.GetObject());

	if (b != i_Crosshair.bVisible)
		i_Crosshair.SetVisibility(b);

	UpdateCrosshairColor();
}

function UpdateCrosshairColor()
{
	if (bWeaponCrosshair)
	{
		i_Crosshair.WinHeight = WeaponsList[WeaponIndex].CrosshairScale * MaxCrosshairHeight;
		i_Crosshair.WinWidth = WeaponsList[WeaponIndex].CrosshairScale * MaxCrosshairWidth;
		i_Crosshair.ImageColor = WeaponsList[WeaponIndex].CustomColor;
		sl_CrosshairScale.SetComponentValue(WeaponsList[WeaponIndex].CrosshairScale, True);
	}
	else
	{
		i_Crosshair.ImageColor = cCrosshair;
		i_Crosshair.WinHeight = fScale * MaxCrosshairHeight;
		i_Crosshair.WinWidth = fScale * MaxCrosshairWidth;
		sl_CrosshairScale.SetComponentValue(fScale, True);
	}

	sl_Red.SetComponentValue(i_Crosshair.ImageColor.R, True);
	sl_Blue.SetComponentValue(i_Crosshair.ImageColor.B, True);
	sl_Green.SetComponentValue(i_Crosshair.ImageColor.G, True);
	sl_Alpha.SetComponentValue(i_Crosshair.ImageColor.A, True);
}

function Texture GetTexture(int i)
{
	if (i >= 0 && i < co_Crosshair.ItemCount())
		return Texture(co_Crosshair.GetItemObject(i));

	return None;
}

function int FindWeaponListIndexAt(int Index)
{
	local int i;
	local class<Weapon> WC;

	WC = class<Weapon>(lb_Weapons.List.GetObjectAtIndex(Index));
	if (WC != None)
		for (i = 0; i < WeaponsList.Length; i++)
			if (WC == WeaponsList[i].WeapClass)
				return i;

	return -1;
}

function int FindWeaponListIndex()
{
	local int i;
	local class<Weapon> WC;

	WC = class<Weapon>(lb_Weapons.List.GetObject());
	for (i = 0; i < WeaponsList.Length; i++)
		if (WC == WeaponsList[i].WeapClass)
			return i;

	return -1;
}

function int FindTextureNameIndex(string TextureName)
{
	local int i, cnt;

	cnt = co_Crosshair.ItemCount();

	for (i = 0; i < cnt; i++)
		if (TextureName ~= string(GetTexture(i)))
			return i;

	if ( Controller.bModAuthor )
	{
		log("Number of crosshairs:"$cnt@"Was looking for"@TextureName,'ModAuthor');
		for (i = 0; i < cnt; i++)
			log(i@"TextureName["$i$"]:"$co_Crosshair.MyComboBox.List.Elements[i].item@"Texture:"$co_Crosshair.MyComboBox.List.Elements[i].ExtraData,'ModAuthor');
	}

	return -1;
}

function int FindTextureIndex(texture WeapTexture)
{
	local int i, cnt;

	cnt = co_Crosshair.ItemCount();

	for (i = 0; i < cnt; i++)
		if (WeapTexture == GetTexture(i))
			break;

	return i;
}

event Opened(GUIComponent Sender)
{
	local rotator R;

	Super.Opened(Sender);

	if ( SpinnyWeap != None )
	{
		R.Yaw = 32768;
		SpinnyWeap.SetRotation(R+PlayerOwner().Rotation);
		SpinnyWeap.bHidden = false;
	}
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);

	if ( SpinnyWeap != None )
		SpinnyWeap.bHidden = true;
}

event Free()
{
	WeaponsList.Remove(0, WeaponsList.Length);
	if ( SpinnyWeap != None )
	{
		SpinnyWeap.Destroy();
		SpinnyWeap = None;
	}

	Super.Free();
}

function bool CoolOnKeyEvent(out byte Key, out byte State, float delta)
{
	local Interactions.EInputKey iKey;
	local vector V;

	iKey = EInputKey(Key);
	V = SpinnyWeap.DrawScale3D;

	if ( state == 1 )
	{
		switch (iKey)
		{
		case IK_E:
	    	SpinnyWeapOffset.X = SpinnyWeapOffset.X - 1;
	        LogSpinnyWeap();
	        return true;
	    case IK_C:
	    	SpinnyWeapOffset.X = SpinnyWeapOffset.X + 1;
	        LogSpinnyWeap();
	        return true;
	    case IK_W:
	    	SpinnyWeapOffset.Z = SpinnyWeapOffset.Z + 1;
	        LogSpinnyWeap();
	        return true;
	    case IK_A:
	    	SpinnyWeapOffset.Y = SpinnyWeapOffset.Y - 1;
	        LogSpinnyWeap();
	        return true;
	    case IK_S:
	    	SpinnyWeapOffset.Z = SpinnyWeapOffset.Z - 1;
	        LogSpinnyWeap();
	        return true;
	    case IK_D:
	    	SpinnyWeapOffset.Y = SpinnyWeapOffset.Y + 1;
	        LogSpinnyWeap();
	        return true;
	    case IK_NumPad8:
	    	V.Z = V.Z + 1;
	    	SpinnyWeap.SetDrawScale3D( V );
	    	LogWeapScale();
	    	return True;
	    case IK_NumPad4:
	    	V.Y = V.Y - 1;
	    	SpinnyWeap.SetDrawScale3D(V);
	    	LogWeapScale();
	    	return True;
	    case IK_NumPad6:
	    	V.Y = V.Y + 1;
	    	SpinnyWeap.SetDrawScale3D(V);
	    	LogWeapScale();
	    	return True;
	    case IK_NumPad2:
	    	V.Z = V.Z - 1;
	    	SpinnyWeap.SetDrawScale3D(V);
	    	LogWeapScale();
	    	return True;
	    case IK_NumPad7:
	    	V.X = V.X - 1;
	    	SpinnyWeap.SetDrawScale3D(V);
	    	LogWeapScale();
	    	return True;
	    case IK_NumPad9:
	    	V.X = V.X + 1;
	    	SpinnyWeap.SetDrawScale3D(V);
	    	LogWeapScale();
	    	return True;
		}
	}


    return false;

}

function LogSpinnyWeap()
{
	log("Weapon Position X:"$SpinnyWeapOffset.X@"Y:"$SpinnyWeapOffset.Y@"Z:"$SpinnyWeapOffset.Z);
}

function LogWeapScale()
{
	log("DrawScale3D X:"$SpinnyWeap.DrawScale3D.X@"Y:"$SpinnyWeap.DrawScale3D.Y@"Z:"$SpinnyWeap.DrawScale3D.Z);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=WeaponBK
         Caption="Weapon"
         WinTop=0.033334
         WinLeft=0.031641
         WinWidth=0.424999
         WinHeight=0.611250
         OnPreDraw=WeaponBK.InternalPreDraw
     End Object
     i_BG=GUISectionBackground'GUI2K4.UT2K4Tab_WeaponPref.WeaponBK'

     Begin Object Class=GUISectionBackground Name=WeaponPriorityBK
         bFillClient=True
         Caption="Weapon Priorities"
         LeftPadding=0.000000
         RightPadding=0.000000
         WinTop=0.666667
         WinLeft=0.046588
         WinWidth=0.380157
         WinHeight=0.311250
         OnPreDraw=WeaponPriorityBK.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'GUI2K4.UT2K4Tab_WeaponPref.WeaponPriorityBK'

     Begin Object Class=GUISectionBackground Name=WeaponOptionBK
         Caption="Crosshairs"
         BottomPadding=0.300000
         WinTop=0.033334
         WinLeft=0.481641
         WinWidth=0.493749
         WinHeight=0.942501
         OnPreDraw=WeaponOptionBK.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'GUI2K4.UT2K4Tab_WeaponPref.WeaponOptionBK'

     Begin Object Class=GUIImage Name=GameCrossHairImage
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         X1=0
         Y1=0
         X2=64
         Y2=64
         WinTop=0.818914
         WinLeft=0.884109
         WinWidth=0.139453
         WinHeight=0.231445
         RenderWeight=0.550000
     End Object
     i_Crosshair=GUIImage'GUI2K4.UT2K4Tab_WeaponPref.GameCrossHairImage'

     Begin Object Class=GUIImage Name=CrosshairBK
         Image=Texture'2K4Menus.Controls.buttonSquare_b'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageStyle=ISTY_Stretched
         DropShadowX=4
         DropShadowY=4
         WinTop=0.703192
         WinLeft=0.814333
         WinWidth=0.139453
         WinHeight=0.231445
         RenderWeight=0.520000
     End Object
     i_CrosshairBG=GUIImage'GUI2K4.UT2K4Tab_WeaponPref.CrosshairBK'

     Begin Object Class=GUIImage Name=Bk1
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         WinTop=0.300814
         WinLeft=0.046344
         WinWidth=0.394118
         WinHeight=0.324981
     End Object
     i_bk=GUIImage'GUI2K4.UT2K4Tab_WeaponPref.Bk1'

     Begin Object Class=GUIGFXButton Name=WeaponPrefWeapUp
         ImageIndex=6
         Position=ICP_Scaled
         StyleName="ComboButton"
         Hint="Increase the priority this weapon will have when picking your best weapon."
         WinTop=0.773389
         WinLeft=0.419847
         WinWidth=0.028946
         WinHeight=0.038594
         RenderWeight=0.510000
         TabOrder=2
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=UT2K4Tab_WeaponPref.ChangePriority
         OnKeyEvent=WeaponPrefWeapUp.InternalOnKeyEvent
     End Object
     b_Up=GUIGFXButton'GUI2K4.UT2K4Tab_WeaponPref.WeaponPrefWeapUp'

     Begin Object Class=GUIGFXButton Name=WeaponPrefWeapDown
         ImageIndex=7
         Position=ICP_Scaled
         StyleName="ComboButton"
         Hint="Decrease the priority this weapon will have when picking your best weapon."
         WinTop=0.817619
         WinLeft=0.419847
         WinWidth=0.028946
         WinHeight=0.038594
         RenderWeight=0.510000
         TabOrder=3
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=UT2K4Tab_WeaponPref.ChangePriority
         OnKeyEvent=WeaponPrefWeapDown.InternalOnKeyEvent
     End Object
     b_Down=GUIGFXButton'GUI2K4.UT2K4Tab_WeaponPref.WeaponPrefWeapDown'

     Begin Object Class=GUIListBox Name=WeaponPrefWeapList
         bVisibleWhenEmpty=True
         OnCreateComponent=WeaponPrefWeapList.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Select order for weapons"
         WinTop=0.733868
         WinLeft=0.068546
         WinWidth=0.338338
         WinHeight=0.221055
         RenderWeight=0.510000
         TabOrder=1
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnSaveINI=UT2K4Tab_WeaponPref.InternalOnSaveINI
     End Object
     lb_Weapons=GUIListBox'GUI2K4.UT2K4Tab_WeaponPref.WeaponPrefWeapList'

     Begin Object Class=GUIScrollTextBox Name=WeaponDescription
         CharDelay=0.001500
         EOLDelay=0.250000
         bVisibleWhenEmpty=True
         OnCreateComponent=WeaponDescription.InternalOnCreateComponent
         FontScale=FNS_Small
         WinTop=0.378073
         WinLeft=0.063125
         WinWidth=0.362170
         WinHeight=0.188969
         RenderWeight=0.510000
         TabOrder=0
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     lb_Desc=GUIScrollTextBox'GUI2K4.UT2K4Tab_WeaponPref.WeaponDescription'

     Begin Object Class=moCheckBox Name=WeaponSwap
         Caption="Swap Fire Mode"
         OnCreateComponent=WeaponSwap.InternalOnCreateComponent
         Hint="Check this box to swap the firing mode on the selected weapon."
         WinTop=0.753946
         WinLeft=0.540953
         WinWidth=0.225000
         WinHeight=0.040000
         RenderWeight=1.030000
         TabOrder=11
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
     End Object
     ch_Swap=moCheckBox'GUI2K4.UT2K4Tab_WeaponPref.WeaponSwap'

     Begin Object Class=moCheckBox Name=CustomWeaponCrosshair
         CaptionWidth=0.900000
         Caption="Custom Weapon Crosshairs"
         OnCreateComponent=CustomWeaponCrosshair.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enable this option to use weapon-specific crosshairs."
         WinTop=0.881445
         WinLeft=0.027203
         WinWidth=0.463975
         WinHeight=0.040000
         RenderWeight=1.010000
         TabOrder=4
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     ch_WeaponCrosshair=moCheckBox'GUI2K4.UT2K4Tab_WeaponPref.CustomWeaponCrosshair'

     Begin Object Class=moCheckBox Name=WeaponMesh
         Caption="Classic Model"
         OnCreateComponent=WeaponMesh.InternalOnCreateComponent
         Hint="Enable to use the classic model for this weapon"
         WinTop=0.837279
         WinLeft=0.542070
         WinWidth=0.224062
         WinHeight=0.040000
         RenderWeight=1.030000
         TabOrder=12
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
     End Object
     ch_ClassicModel=moCheckBox'GUI2K4.UT2K4Tab_WeaponPref.WeaponMesh'

     Begin Object Class=moComboBox Name=GameCrossHair
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         Caption="Crosshair"
         OnCreateComponent=GameCrossHair.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select your crosshair!"
         WinTop=0.822936
         WinLeft=0.027203
         WinWidth=0.463975
         WinHeight=0.040000
         RenderWeight=1.060000
         TabOrder=5
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     co_Crosshair=moComboBox'GUI2K4.UT2K4Tab_WeaponPref.GameCrossHair'

     Begin Object Class=moSlider Name=GameHudCrossHairR
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.300000
         Caption="Red:"
         LabelColor=(B=0,R=255)
         OnCreateComponent=GameHudCrossHairR.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.480822
         WinLeft=0.027203
         WinWidth=0.644366
         RenderWeight=0.550000
         TabOrder=6
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     sl_Red=moSlider'GUI2K4.UT2K4Tab_WeaponPref.GameHudCrossHairR'

     Begin Object Class=moSlider Name=GameHudCrossHairB
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.300000
         Caption="Blue:"
         LabelColor=(B=255)
         OnCreateComponent=GameHudCrossHairB.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.609094
         WinLeft=0.027203
         WinWidth=0.644366
         RenderWeight=0.550000
         TabOrder=8
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     sl_Blue=moSlider'GUI2K4.UT2K4Tab_WeaponPref.GameHudCrossHairB'

     Begin Object Class=moSlider Name=GameHudCrossHairG
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.300000
         Caption="Green:"
         LabelColor=(B=0,G=255)
         OnCreateComponent=GameHudCrossHairG.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Changes the color of your crosshair."
         WinTop=0.544958
         WinLeft=0.027203
         WinWidth=0.644366
         RenderWeight=0.550000
         TabOrder=7
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     sl_Green=moSlider'GUI2K4.UT2K4Tab_WeaponPref.GameHudCrossHairG'

     Begin Object Class=moSlider Name=GameHudCrossHairA
         MaxValue=255.000000
         bIntSlider=True
         CaptionWidth=0.300000
         Caption="Opacity:"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=GameHudCrossHairA.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Changes the opacity of your crosshair."
         WinTop=0.671927
         WinLeft=0.027203
         WinWidth=0.644366
         RenderWeight=0.550000
         TabOrder=9
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     sl_Alpha=moSlider'GUI2K4.UT2K4Tab_WeaponPref.GameHudCrossHairA'

     Begin Object Class=moSlider Name=GameHudCrosshairScale
         MaxValue=2.000000
         CaptionWidth=0.300000
         Caption="Scale:"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=GameHudCrosshairScale.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Changes the crosshair scale."
         WinTop=0.733124
         WinLeft=0.027203
         WinWidth=0.644366
         RenderWeight=0.550000
         TabOrder=10
         OnChange=UT2K4Tab_WeaponPref.InternalOnChange
         OnLoadINI=UT2K4Tab_WeaponPref.InternalOnLoadINI
     End Object
     sl_CrosshairScale=moSlider'GUI2K4.UT2K4Tab_WeaponPref.GameHudCrosshairScale'

     SpinnyWeapOffset=(X=100.000000,Y=1.500000,Z=-10.000000)
     WeaponIndex=-1
     MaxCrosshairWidth=0.071922
     MaxCrosshairHeight=0.121081
     HiddenText="Hidden"
     LoadingText="...Loading Weapon Database..."
     PanelCaption="Weapons"
     WinTop=0.150000
     WinHeight=0.740000
     OnRendered=UT2K4Tab_WeaponPref.InternalDraw
}
