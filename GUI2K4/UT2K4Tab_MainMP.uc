//==============================================================================
//  Created on: 12/11/2003
//  Host Multiplayer implementation of maplist tab
//  This version allows configuration of maplists
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_MainMP extends UT2K4Tab_MainBase;
/*
// Maplist controls
var automated GUIListBox 		lb_ActiveMaps, lb_AllMaps;
var automated GUIButton			b_Add, b_AddAll, b_Remove, b_RemoveAll, b_MoveUp, b_MoveDown,
								b_New, b_Delete, b_Load, b_Save, b_Use;
var automated GUIEditBox        ed_MapName;
var automated GUIComboBox       co_Maplist;
var automated GUILabel			LB1,LB2;

var GUIButton SizingButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

	if (lb_AllMaps.List != None)
	{
		lb_AllMaps.List.bDropSource = True;
		lb_AllMaps.List.bDropTarget = True;
		lb_AllMaps.List.OnDblClick = ModifyMapList;
		lb_AllMaps.List.OnDragDrop = RemoveDragDrop;
		lb_AllMaps.List.AddLinkObject( b_Add, True );
		lb_AllMaps.List.CheckLinkedObjects = InternalCheckLinkedObj;
	}

	if (lb_ActiveMaps.List != None)
	{
		lb_ActiveMaps.List.bDropSource = True;
		lb_ActiveMaps.List.bDropTarget = True;
		lb_ActiveMaps.List.OnDblClick = ModifyMapList;
		lb_ActiveMaps.List.OnDragDrop = AddDragDrop;
		lb_ActiveMaps.List.AddLinkObject( b_Remove, True );
		lb_ActiveMaps.List.AddLinkObject( b_MoveUp, True );
		lb_ActiveMaps.List.AddLinkObject( b_MoveDown, True );
		lb_ActiveMaps.List.CheckLinkedObjects = InternalCheckLinkedObj;
	}

    co_Maplist.List.bInitializeList = False;
    GetSizingButton();

}

function GUIButton GetSizingButton()
{
	if ( IsLarger( SizingButton, b_New) )
		SizingButton = b_New;
	if ( IsLarger( SizingButton, b_Delete) )
		SizingButton = b_Delete;
	if ( IsLarger( SizingButton, b_Load) )
		SizingButton = b_Load;
	if ( IsLarger( SizingButton, b_Save) )
		SizingButton = b_Save;
	if ( IsLarger( SizingButton, b_Use) )
		SizingButton = b_Use;

	return SizingButton;
}

protected function bool IsLarger(GUIButton Current, GUIButton Test)
{
	// <hack>
	Test.bBoundToParent = False;
	Test.bScaleToParent = False;
	// </hack>

	if ( Current == None || Len(Test.Caption) > Len(Current.Caption) )
		return true;

	return false;
}
protected function SetSize(GUIButton But, coerce float L, coerce float T, coerce float W, coerce float H)
{
	if ( But == None )
		return;

	But.WinTop = T;
	But.WinLeft = L;
	But.WinWidth = W;
	But.WinHeight = H;
}


// Called when a new gametype is selected
function InitGameType()
{
    local int i;
    local array<CacheManager.GameRecord> Games;
    local bool bReload;

	// Save any maplist that was currently configured before changing the gametype.
	StoreMapList();

	// Get a list of all gametypes.
    class'CacheManager'.static.GetGameTypeList(Games);
	for (i = 0; i < Games.Length; i++)
    {
        if (Games[i].ClassName ~= Controller.LastGameType)
        {
        	bReload = CurrentGameType.MapPrefix != Games[i].MapPrefix;
            CurrentGameType = Games[i];
            GameIndex = MapHandler.GetGameIndex(CurrentGameType.ClassName);
            break;
        }
    }

    if ( i == Games.Length )
    	return;

    // Refresh the custom maplist combo
    ReloadCustomMaplists();

    if ( bReload )
    	InitMaps();
    else InitMaplist();
}

// Query the CacheManager for the maps that correspond to this gametype, then fill the main list
function InitMaps( optional string MapPrefix )
{
    local int i, j;
    local bool bTemp;
    local string Package, Item;
    local array<string> LinkSetupNames;
    local DecoText DT;

	// Make sure we have a map prefix
	if ( MapPrefix == "" )
		MapPrefix = GetMapPrefix();

	// Temporarily disable notification in all components
    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

	// Get the list of maps for the current gametype
	class'CacheManager'.static.GetMapList( Maps, MapPrefix );
	lb_AllMaps.List.Clear();

	for ( i = 0; i < Maps.Length; i++ )
	{
		DT = None;

		// If this was a UT2003 map, then it will have deco text associated with it - load the deco text
		if ( class'CacheManager'.static.Is2003Content(Maps[i].MapName) )
		{
			if ( Maps[i].TextName != "" )
			{
				if ( !Divide(Maps[i].TextName, ".", Package, Item) )
				{
					Package = "XMaps";
					Item = Maps[i].TextName;
				}

				DT = class'xUtil'.static.LoadDecoText( Package, Item );
			}
		}

		// Otherwise, if we only want to display official maps, and this map isn't an official map, skip it
		else if ( bOnlyShowOfficial && !class'CacheManager'.static.IsBPContent(Maps[i].MapName) && !class'CacheManager'.static.Is2004Content(Maps[i].MapName) )
			continue;

		Item = "";
		if ( CurrentGameType.MapPrefix ~= "ONS" && Controller.bExpertMode )
		{
			j = InStr(Maps[i].ExtraInfo, "LinkSetups=");
			if ( j != -1 )
				Item = Mid(Maps[i].ExtraInfo, j + 11);

			if ( Item == "" )
				lb_AllMaps.List.Add(Maps[i].MapName);	// Change this line to 'Item = DefaultText;' to list default link setup when there are none in the list
			else
			{
				//Add official setups
				Split(Item, ";", LinkSetupNames);
				for ( j = 0; j < LinkSetupNames.Length; j++ )
					lb_AllMaps.List.Add( Maps[i].MapName @ "(" $ LinkSetupNames[j] @ LinkText $ ")", DT,"?LinkSetup=" $ LinkSetupNames[j] );
				lb_AllMaps.List.Add(Maps[i].MapName @ "(" $ AutoSelectText @ LinkText $ ")", DT);
			}

			//Add custom setups
			LinkSetupNames = GetPerObjectNames(Maps[i].MapName, "ONSPowerLinkCustomSetup");
			for ( j = 0; j < LinkSetupNames.Length; j++ )
				lb_AllMaps.List.Add( Maps[i].MapName @ "(" $ LinkSetupNames[j] @ LinkText $ ")", DT,"?LinkSetup=" $ LinkSetupNames[j] );

		}
		else lb_AllMaps.List.Add( Maps[i].MapName, DT );
	}

	InitMapList();
    Controller.bCurMenuInitialized = bTemp;
}

// Fill the Active & Inactive lists with the appropriate maps
function InitMapList()
{
	local class<MapList> MLClass;
	local MapList ML;
	local string MaplistClass;
	local int i;
	local array<string> NewActiveMaps;

	// Disable OnChange calls
	lb_ActiveMaps.List.bNotify = False;
	lb_AllMaps.List.bNotify = False;

	// Clear the active list
	lb_AllMaps.List.LoadFrom( lb_ActiveMaps.List );
	lb_ActiveMaps.List.Clear();

	// Update the current custom maplist index
	RecordIndex = MapHandler.GetRecordIndex(GameIndex, co_Maplist.GetText());

	// Get the list of active maps from the MaplistManager
	NewActiveMaps = MapHandler.GetMapList(GameIndex, RecordIndex);

	// This should never actually happen, since MapHandler will always create default lists.
	if ( NewActiveMaps.Length == 0 )
	{
		MaplistClass = GetMaplistClass();
		if ( MaplistClass != "" )
			MLClass = class<MapList>(DynamicLoadObject(MaplistClass, class'class'));

		if (MLClass!=None)
		{
			ML = PlayerOwner().spawn(MLClass);
			if (ML!=None)
				NewActiveMaps = ML.Maps;
		}
	}

	for ( i = 0; i < NewActiveMaps.Length; i++ )
		AddMap(NewActiveMaps[i]);

	CurrentMaplistLoaded();
	lb_ActiveMaps.List.bNotify = True;
	lb_AllMaps.List.bNotify = True;
}

// Fill the custom maplist selection combo with the custom maplists for this gametype
function ReloadCustomMaplists(optional string CurrentMaplist)
{
	local int i, Index, Current;
	local array<string> Ar;

	// Disable OnChange calls
	co_Maplist.List.bNotify = False;

	Index = MapHandler.GetGameIndex(CurrentGameType.ClassName);
	Ar = MapHandler.GetMapListNames(Index);

	Current = MapHandler.GetRecordIndex(Index, CurrentMaplist);
	if ( Current == -1 )
		Current = MapHandler.GetActiveList(Index);

	co_Maplist.List.bNotify = False;
	co_Maplist.List.Clear();
	for ( i = 0; i < Ar.Length; i++ )
		co_Maplist.AddItem(Ar[i]);
	co_Maplist.List.bNotify = True;

	CurrentMaplist = MapHandler.GetMaplistTitle(Index, Current);
	co_Maplist.SetText(CurrentMaplist, True);

	co_Maplist.List.bNotify = True;
}

// =====================================================================================================================
// =====================================================================================================================
//  Utility functions - handles all special stuff that should happen whenever events are received on the page
// =====================================================================================================================
// =====================================================================================================================

// Do not allow two lists to both have valid indexes at the same time - we use whichever map is selected in any
// of the three lists to determine the starting map for the game.
/*
function UpdateIndexes( GUIListBase List )
{
	local bool bTemp;

	// Disable notification
	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	if ( List == lb_AllMaps.List && lb_AllMaps.List.IsValid() )
		lb_ActiveMaps.List.SetIndex(-1);

	else if ( List == lb_ActiveMaps.List && lb_ActiveMaps.List.IsValid() )
		lb_AllMaps.List.SetIndex(-1);

	Controller.bCurMenuInitialized = bTemp;
}
*/
event SetVisibility( bool bIsVisible )
{
	Super.SetVisibility(bIsVisible);

	if ( bIsVisible )
		CheckSaveStatus();
}

function string Play()
{
	local int i;

	StoreMapList();

	i = MapHandler.GetActiveMap(GameIndex,RecordIndex);
	if ( lb_ActiveMaps.List.IsValidIndex(i) )
		return GetMapURL(lb_ActiveMaps.List, i);
	else return GetMapURL(lb_ActiveMaps.List, 0);
}

// Mapname has value only when initializing list
function bool AddMap(optional string MapName)
{
	local int i;
	local array<GUIListElem> PendingElements;


	if ( MapName != "" )
	{
		lb_AllMaps.List.bNotify = False;
		for ( i = 0; i < lb_AllMaps.List.Elements.Length; i++ )
			if ( MapName ~= (StripMapName(lb_AllMaps.List.Elements[i].Item) $ lb_AllMaps.List.Elements[i].ExtraStrData) )
				break;

		if ( i != lb_AllMaps.List.Elements.Length )
		{
			PendingElements[0] = lb_AllMaps.List.Elements[i];
			lb_AllMaps.List.RemoveElement(PendingElements[0],,True);
			lb_ActiveMaps.List.AddElement(PendingElements[0]);

			// Do not call call MapHandler.AddMap() since MapName only has a value when adding maps FROM maphandler
			// MapHandler.AddMap(GameIndex, RecordIndex, StripMapName(PendingElements[0].Item) $ PendingElements[0].ExtraStrData);
		}
		else log("AddMap() didn't find map named"@MapName);
	}

	else
	{
		if ( !lb_AllMaps.List.IsValid() )
			return false;

		lb_AllMaps.List.bNotify = False;
		PendingElements = lb_AllMaps.List.GetPendingElements(True);
		for ( i = 0; i < PendingElements.Length; i++ )
		{
			lb_AllMaps.List.RemoveElement(PendingElements[i],,True);
			lb_ActiveMaps.List.AddElement(PendingElements[i]);
			MapHandler.AddMap(GameIndex, RecordIndex, StripMapName(PendingElements[i].Item) $ PendingElements[i].ExtraStrData);
		}
	}

	lb_AllMaps.List.bNotify = True;
	lb_AllMaps.List.ClearPendingElements();
	lb_AllMaps.List.SetIndex(lb_AllMaps.List.Index);

	return true;
}

function bool RemoveMap()
{
	local int i;
	local array<GUIListElem> PendingElements;

	if ( !lb_ActiveMaps.List.IsValid() )
		return false;

	lb_ActiveMaps.List.bNotify = False;
	PendingElements = lb_ActiveMaps.List.GetPendingElements( True );
	for ( i = 0; i < PendingElements.Length; i++ )
	{
		lb_ActiveMaps.List.RemoveElement( PendingElements[i],,True );
		lb_AllMaps.List.AddElement( PendingElements[i] );
		MapHandler.RemoveMap( GameIndex, RecordIndex, StripMapName(PendingElements[i].Item) $ PendingElements[i].ExtraStrData );
	}

	lb_ActiveMaps.List.bNotify = True;
	lb_ActiveMaps.List.ClearPendingElements();
	lb_ActiveMaps.List.SetIndex(lb_ActiveMaps.List.Index);

	return true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local float X, Y;
	local float XL, YL;

	if ( !bPositioned )
		return false;

	// Get the largest caption size
	SizingButton.Style.TextSize(C, SizingButton.MenuState, SizingButton.Caption, XL, YL, SizingButton.FontScale);

	// Add a little space
	XL += 15;
	YL += 10;

	// Don't want it to line up exactly on the edge
	X = (co_Maplist.ActualLeft() + co_Maplist.ActualWidth()) - 18;
	Y = (co_Maplist.ActualTop() + co_Maplist.ActualHeight()) + 15;

	// Delete and New go on first row
	X -= XL;
	SetSize(b_Delete, X, Y, XL, YL);
	X -= XL + 3;
	SetSize(b_New, X, Y, XL, YL);

	// Go back to first column - the rest go on the second row
	X += XL + 3;
	Y += YL + 3;
	SetSize(b_Use, X, Y, XL, YL);

	X -= XL + 3;
	SetSize(b_Save, X, Y, XL, YL);

	X -= XL + 3;
	SetSize(b_Load, X, Y, XL, YL);

	return false;
}

// =====================================================================================================================
// =====================================================================================================================
//  OnClick's
// =====================================================================================================================
// =====================================================================================================================

// Called when one of the buttons between the maplists are clicked on
function bool ModifyMapList(GUIComponent Sender)
{
	local int Index;
	local string Str;

	if ( Sender == lb_AllMaps )
	{
		AddMap();
		return true;
	}

	if ( Sender == lb_ActiveMaps )
	{
		RemoveMap();
		return true;
	}

	if ( GUIButton(Sender) == None )
		return false;

	switch ( GUIButton(Sender).Caption )
	{
	case b_Add.Caption:
		return AddMap();

	case b_AddAll.Caption:
		if (lb_AllMaps.ItemCount()==0)
			return true;

		for ( Index = 0; Index < lb_AllMaps.List.ItemCount; Index++ )
			MapHandler.AddMap( GameIndex, RecordIndex, lb_AllMaps.List.GetItemAtIndex(Index) );

		lb_ActiveMaps.List.LoadFrom(lb_AllMaps.List,false);
		lb_AllMaps.List.Clear();

		CheckSaveStatus();
		return true;

	case b_Remove.Caption:
		return RemoveMap();

	case b_RemoveAll.Caption:
		if ( lb_ActiveMaps.ItemCount()==0 )
			return true;

		for ( Index = 0; Index < lb_ActiveMaps.List.ItemCount; Index++ )
			MapHandler.RemoveMap( GameIndex, RecordIndex, lb_ActiveMaps.List.GetItemAtIndex(Index) );

		lb_AllMaps.List.LoadFrom(lb_ActiveMaps.List,false);
		lb_ActiveMaps.List.Clear();

		CheckSaveStatus();
		return true;

	case b_MoveUp.Caption:
		if ( !lb_ActiveMaps.List.IsValid() )
			return true;

		Index = lb_ActiveMaps.List.Index;
		Str = GetMapURL(lb_ActiveMaps.List, -1);
		if (index>0)
		{
			lb_ActiveMaps.List.Swap(index,index-1);
			lb_ActiveMaps.List.SetIndex(Index - 1);
		}

		// We've hit the top, disable the Move Up button
		if ( lb_ActiveMaps.List.Index <= 0 )
			DisableComponent(b_MoveUp);

		else if ( lb_ActiveMaps.List.Index < lb_ActiveMaps.List.ItemCount - 1 )
			EnableComponent(b_MoveDown);

		MapHandler.ShiftMap(GameIndex, RecordIndex, Str, -1);
		CheckSaveStatus();

		return true;

	case b_MoveDown.Caption:
		if ( !lb_ActiveMaps.List.IsValid() )
			return true;

		Index = lb_ActiveMaps.List.Index;
		Str = GetMapURL(lb_ActiveMaps.List, -1);

		if (index<lb_ActiveMaps.ItemCount()-1)
		{
			lb_ActiveMaps.List.Swap(index,index+1);
			lb_ActiveMaps.List.SetIndex(Index + 1);
		}

		// We've hit the bottom, disable the Move Down button
		if ( lb_ActiveMaps.List.Index >= lb_ActiveMaps.List.ItemCount - 1 )
			DisableComponent(b_MoveDown);

		else if ( lb_ActiveMaps.List.Index > 0 )
			EnableComponent(b_MoveUp);

		MapHandler.ShiftMap(GameIndex, RecordIndex, Str, 1);
		CheckSaveStatus();

		return true;
	}

	return false;
}

// Called when one of the custom maplist management buttons are clicked
function bool CustomMaplistClick(GUIComponent Sender)
{
	local int i;
	local array<string> Ar;
	local string Str;

	switch ( Sender )
	{
		case b_New:
			Str = co_Maplist.GetText();

			// Build an array of strings containing the active maps
			Ar.Length = lb_ActiveMaps.List.ItemCount;
			for (i = 0; i < lb_ActiveMaps.List.ItemCount; i++)
				Ar[i] = StripMapName(lb_ActiveMaps.List.Elements[i].Item) $ lb_ActiveMaps.List.Elements[i].ExtraStrData;

			// Since we are creating a new list, instead of changing this one, reset the old one
			MapHandler.ResetList(GameIndex, RecordIndex);
			RecordIndex = MapHandler.AddList(CurrentGameType.ClassName, Str, Ar);

			// Reload maplist names, set the editbox's text to the new maplist's title
			ReloadCustomMaplists(Str);

			// Reload the maplist
			InitMaplist();
			break;

		case b_Delete:

			// Remove the currently loaded maplist
			RecordIndex = MapHandler.RemoveList(GameIndex, RecordIndex);

			// Get the name of the now-current maplist
			Str = MapHandler.GetMapListTitle(GameIndex, RecordIndex);

			// Reload maplist names, set the editbox's text to the new maplist's title
			ReloadCustomMaplists(Str);
			InitMaplist();
			break;

		case b_Load:
			// Load the currently selected list.
			InitMaplist();
			break;

		case b_Save:
			// Might be renaming list, might be saving it...
			Str = co_Maplist.GetText();
			UpdateCustomMapList(Str);

			// Reload the maplist names in case we renamed the maplist
			ReloadCustomMaplists(Str);
			CheckSaveStatus();
			break;

		case b_Use:
			// Copy the currently loaded list to the game's main maplist
			MapHandler.ApplyMapList(GameIndex, RecordIndex);
			CurrentMaplistLoaded();
			break;
	}

	return true;
}
// =====================================================================================================================
// =====================================================================================================================
//  OnChange's
// =====================================================================================================================
// =====================================================================================================================

// Called when we've selected a new item in the custom maplist combo, or typed in a new name
function MaplistSelectChange(GUIComponent Sender)
{
	local string Str;
	local int Index;

	if ( Sender != co_Maplist )
		return;

	Str = co_Maplist.GetText();

	// If the name in the edit box doesn't match the list's selected item
	if ( Str != co_Maplist.List.Get() )
		TypingNewName();

	else
	{
		// The name shown is the currently selected item of the list
		Index = MapHandler.GetRecordIndex(GameIndex, Str);

		// We selected the currently loaded maplist
		if ( RecordIndex == Index )
			CurrentMaplistLoaded();

		else SelectedItemFromList();
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  Misc. Events
// =====================================================================================================================
// =====================================================================================================================

// Called when a map is dragged from the inactive list to the active list
function bool AddDragDrop(GUIComponent Sender)
{
	local array<GUIListElem> Ar;
	local int i, idx;

	if ( Sender == lb_ActiveMaps.List )
	{
		idx = lb_ActiveMaps.List.DropIndex;
		if ( !lb_ActiveMaps.List.IsValidIndex(idx) )
			idx = lb_ActiveMaps.List.ItemCount;

		if ( Controller.DropSource == lb_AllMaps.List )
			Ar = lb_AllMaps.List.GetPendingElements();

		else if ( Controller.DropSource == lb_ActiveMaps.List )
		{
			Ar = lb_ActiveMaps.List.GetPendingElements();
			for ( i = 0; i < Ar.Length; i++ )
			{
				MapHandler.RemoveMap(GameIndex, RecordIndex, StripMapName(Ar[i].Item) $ Ar[i].ExtraStrData);
				lb_ActiveMaps.List.RemoveElement(Ar[i]);
			}
		}
		// Always insert in reverse order to maintain correct map order
		for ( i = Ar.Length - 1; i >= 0; i-- )
			MapHandler.InsertMap(GameIndex, RecordIndex, StripMapName(Ar[i].Item) $ Ar[i].ExtraStrData, idx);

		lb_ActiveMaps.List.InternalOnDragDrop(lb_ActiveMaps.List);
		return true;
	}

	return false;
}

// Called when maps are dragged from the active list to the inactive list.
function bool RemoveDragDrop(GUIComponent Sender)
{
	local array<GUIListElem> Ar;
	local int i;

	if ( Sender == lb_AllMaps.List )
	{
		if ( Controller.DropSource != lb_ActiveMaps.List )
			return false;

		Ar = lb_ActiveMaps.List.GetPendingElements();
		for (i = 0; i < Ar.Length; i++)
			MapHandler.RemoveMap(GameIndex, RecordIndex, StripMapName(Ar[i].Item) $ Ar[i].ExtraStrData);

		return lb_AllMaps.List.InternalOnDragDrop(Sender);
	}

	return false;
}

// This function overrides GUIList default behavior because we only want to disable the AddAll and RemoveAll
// if those lists are empty
function InternalCheckLinkedObj( GUIListBase List )
{
	if ( List.IsValid() )
		List.EnableLinkedObjects();
	else List.DisableLinkedObjects();

	if ( lb_AllMaps.List.ItemCount > 0 )
		EnableComponent(b_AddAll);
	else DisableComponent(b_AddAll);

	if ( lb_ActiveMaps.List.ItemCount > 0 )
		EnableComponent(b_RemoveAll);
	else DisableComponent(b_RemoveAll);

	if ( lb_ActiveMaps.List.Index == 0 )
		DisableComponent(b_MoveUp);
	else if ( lb_ActiveMaps.List.Index == lb_ActiveMaps.List.ItemCount - 1 )
		DisableComponent(b_MoveDown);

	if ( lb_ActiveMaps.List.ItemCount > 0 )
	{
		EnableComponent( b_Primary );
		EnableComponent( b_Secondary );
	}
	else
	{
		DisableComponent(b_Primary);
		DisableComponent(b_Secondary);
	}

}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if ( moButton(Sender) != None && GUILabel(NewComp) != None )
	{
		GUILabel(NewComp).TextColor = WhiteColor;
		moButton(Sender).InternalOnCreateComponent(NewComp, Sender);
	}
}

function bool HandleContextSelect(GUIContextMenu Sender, int Index)
{
	if ( Sender != None )
	{
		switch ( Index )
		{
		case 0:
			AddMap();
			break;

		case 1:
			RemoveMap();
			break;

		case 3:
			bOnlyShowOfficial = !bOnlyShowOfficial;
			InitMaps();
			ch_OfficialMapsOnly.SetComponentValue(bOnlyShowOfficial, True);
			break;
		}
	}

	return true;
}

// =====================================================================================================================
// =====================================================================================================================
//  Custom Maplist Interface
// =====================================================================================================================
// =====================================================================================================================

function StoreMapList()
{
	MapHandler.ApplyMaplist(GameIndex, RecordIndex);
}

// Pass in NewName to rename the list
function UpdateCustomMaplist(optional string NewName)
{
	if ( NewName == "" )
		NewName = co_Maplist.GetText();

	if ( !(MapHandler.GetMapListTitle(GameIndex, RecordIndex) == NewName) )
		RecordIndex = MapHandler.RenameList(GameIndex, RecordIndex, NewName);

	// If we're saving this gametype's active list, be sure to apply the changes to the real maplist
	if ( MapHandler.GetActiveList(GameIndex) == RecordIndex )
		MapHandler.ApplyMaplist(GameIndex, RecordIndex);

	else MapHandler.SaveMapList(GameIndex, RecordIndex);
}

// Can save & create new, cannot load, delete, or use
function TypingNewName()
{
	DisableComponent(b_Load);
	DisableComponent(b_Delete);
	DisableComponent(b_Use);

	EnableComponent(b_Save);
	EnableComponent(b_New);
}

// Called when we've selected an item, but haven't clicked on load yet
// Can only load
function SelectedItemFromList()
{
	DisableComponent(b_Delete);
	DisableComponent(b_Save);
	DisableComponent(b_Use);
	DisableComponent(b_New);

	EnableComponent(b_Load);
}

// Called when the loaded maplist matches the combobox
// Can do everything but load
// bActive is true if the loaded maplist is the active maplist as well
function CurrentMaplistLoaded()
{
	DisableComponent(b_Load);

	EnableComponent(b_New);
	EnableComponent(b_Delete);

	if ( RecordIndex == MapHandler.GetActiveList(GameIndex)  )
		DisableComponent(b_Use);
	else EnableComponent(b_Use);

	CheckSaveStatus();
}

function ListChanged(GUIComponent Sender)
{
	CheckSaveStatus();
}

function CheckSaveStatus()
{
	if ( MapHandler.MaplistDirty(GameIndex, RecordIndex) )
		EnableComponent(b_Save);
	else DisableComponent(b_Save);
}

DefaultProperties
{
	OnPreDraw=InternalOnPreDraw
// =====================================================================================================================
// =====================================================================================================================
//  Maplist Components
// =====================================================================================================================
// =====================================================================================================================
	Begin Object Class=GUIListBox Name=InactiveMaps
		WinWidth=0.368359
		WinHeight=0.753669
		WinLeft=0.025781
		WinTop=0.108021
		bVisibleWhenEmpty=true
		bSorted=True
		TabOrder=0
		OnChange=ListChanged
	End Object
	lb_AllMaps=InactiveMaps

	Begin Object Class=GUIListBox Name=ActiveMaps
		WinWidth=0.368359
		WinHeight=0.662671
		WinLeft=0.605861
		WinTop=0.108021
		bVisibleWhenEmpty=true
		TabOrder=8
		OnChange=ListChanged
	End Object
	lb_ActiveMaps=ActiveMaps

	Begin Object Class=GUIButton Name=IAMapListUp
		Caption="Up"
		Hint="Move this map higher up in the list"
		WinWidth=0.145000
		WinHeight=0.050000
		WinLeft=0.425000
		WinTop=0.146718
		OnClick=ModifyMapList
		OnClickSound=CS_Up
		TabOrder=1
	End Object
	b_MoveUp=IAMapListUp

	Begin Object Class=GUIButton Name=IAMapListAll
		Caption="Add All"
		Hint="Add all maps to your map list"
		WinWidth=0.145
		WinHeight=0.05
		WinLeft=0.425
		WinTop=0.388905
		OnClick=ModifyMapList
		OnClickSound=CS_Up
		TabOrder=2
	End Object
	b_AddAll=IAMapListAll

	Begin Object Class=GUIButton Name=IAMapListAdd
		Caption="Add"
		Hint="Add the selected maps to your map list"
		WinWidth=0.145
		WinHeight=0.05
		WinLeft=0.425
		WinTop=0.323801
		OnClick=ModifyMapList
		OnClickSound=CS_Up
		TabOrder=3
	End Object
	b_Add=IAMapListAdd

	Begin Object Class=GUIButton Name=IAMapListRemove
		Caption="Remove"
		Hint="Remove the selected maps from your map list"
		WinWidth=0.145
		WinHeight=0.05
		WinLeft=0.425
		WinTop=0.493072
		OnClick=ModifyMapList
		OnClickSound=CS_Down
		TabOrder=4
	End Object
	b_Remove=IAMapListRemove

	Begin Object Class=GUIButton Name=IAMapListClear
		Caption="Remove All"
		Hint="Remove all maps from your map list"
		WinWidth=0.145
		WinHeight=0.05
		WinLeft=0.425
		WinTop=0.558176
		OnClick=ModifyMapList
		OnClickSound=CS_Down
		TabOrder=5
	End Object
	b_RemoveAll=IAMapListClear

	Begin Object Class=GUIButton Name=IAMapListDown
		Caption="Down"
		Hint="Move this map lower down in the list"
		WinWidth=0.145000
		WinHeight=0.050000
		WinLeft=0.425000
		WinTop=0.727450
		OnClick=ModifyMapList
		OnClickSound=CS_Down
		TabOrder=6
	End Object
	b_MoveDown=IAMapListDown

	Begin Object Class=GUIComboBox Name=SelectMaplist
		Hint="Load another maplist or change the name of the currently loaded maplist."
		OnChange=MaplistSelectChange
		WinWidth=0.335802
		WinHeight=0.040000
		WinLeft=0.630479
		WinTop=0.797917
		TabOrder=7
	End Object

	Begin Object Class=GUIButton Name=NewMaplist
		Caption="NEW"
		Hint="Create new custom maplist, using the configured name and active maps"
		OnClick=CustomMaplistClick
		WinWidth=0.096076
		WinHeight=0.050000
		WinLeft=0.772357
		WinTop=0.859114
		TabOrder=8
	End Object

	Begin Object Class=GUIButton Name=DeleteMaplist
		Caption="DELETE"
		Hint"Delete the currently selected maplist.  If this is the last maplist for this gametype, a new default maplist will be generated."
		OnClick=CustomMaplistClick
		WinWidth=0.094120
		WinHeight=0.050000
		WinLeft=0.868247
		WinTop=0.863021
		TabOrder=9
	End Object

	Begin Object Class=GUIButton Name=LoadMaplist
		Caption="LOAD"
		Hint="Load the currently selected maplist"
		OnClick=CustomMaplistClick
		WinWidth=0.096076
		WinHeight=0.050000
		WinLeft=0.679403
		WinTop=0.915104
		TabOrder=10
	End Object

	Begin Object Class=GUIButton Name=SaveMaplist
		Caption="SAVE"
		Hint="Save the selected maps to the currently loaded maplist.  If this is the active maplist, it will applied to the game's map rotation."
		OnClick=CustomMaplistClick
		WinWidth=0.096076
		WinHeight=0.050000
		WinLeft=0.772357
		WinTop=0.915104
		TabOrder=11
	End Object

	Begin Object Class=GUIButton Name=UseMaplist
		Caption="USE"
		Hint="Save & apply this custom maplist to the game's map rotation"
		OnClick=CustomMaplistClick
		WinWidth=0.094120
		WinHeight=0.050000
		WinLeft=0.869226
		WinTop=0.915104
		TabOrder=12
	End Object

    b_New=NewMaplist
    b_Delete=DeleteMaplist
    b_Load=LoadMaplist
    b_Save=SaveMaplist
    b_Use=UseMaplist
    co_Maplist=SelectMaplist
}
*/

defaultproperties
{
}
