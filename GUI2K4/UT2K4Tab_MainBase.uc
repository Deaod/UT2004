//==============================================================================
//  Created on: 12/11/2003
//  Base class for main maplist tab in Host Multiplayer / Instant Action areas
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_MainBase extends UT2K4GameTabBase;

var() globalconfig bool bOnlyShowOfficial, bOnlyShowCustom;

var MaplistManager MapHandler;
var array<CacheManager.MapRecord> CacheMaps;
var() array<MaplistRecord.MapItem> Maps;
var array<string> TutorialMaps;
var CacheManager.GameRecord CurrentGameType;

// Common
var automated moCheckBox		ch_OfficialMapsOnly;
var           GUIButton         b_Primary, b_Secondary;

var() localized string MessageNoInfo, AuthorText, PlayerText;
var() localized string FilterText, ClearText;
var() localized string LinkText, DefaultText, AutoSelectText;

var globalconfig string MaplistEditorMenu;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   Super.InitComponent(MyController, MyOwner);

    ch_OfficialMapsOnly.Checked(bOnlyShowOfficial);
}

// Called when a new gametype is selected
function InitGameType();

// Query the CacheManager for the maps that correspond to this gametype, then fill the main list
function InitMaps( optional string MapPrefix );

function HandleContextOpen(GUIComponent Sender, GUIContextMenu Menu, GUIComponent ContextMenuOwner)
{
	if ( !bOnlyShowOfficial )
		Menu.ContextItems[3] = FilterText;
	else Menu.ContextItems[3] = ClearText;
}

function InitMapHandler()
{
	local PlayerController PC;

	PC = PlayerOwner();

	if ( PC.Level.Game != None && MaplistManager(PC.Level.Game.MaplistHandler) != None )
		MapHandler = MaplistManager(PC.Level.Game.MaplistHandler);

	if ( MapHandler == None )
		foreach PC.DynamicActors(class'MaplistManager', MapHandler)
			break;

	if ( MapHandler == None )
		MapHandler = PC.Spawn(class'MaplistManager');
}

// =====================================================================================================================
// =====================================================================================================================
//  Utility functions - handles all special stuff that should happen whenever events are received on the page
// =====================================================================================================================
// =====================================================================================================================

function string GetMapPrefix()
{
    return CurrentGameType.MapPrefix;
}

function string GetRulesClass()
{
    return "";
}

function string GetMapListClass()
{
    return CurrentGameType.MapListClassName;
}

function bool GetIsTeamGame()
{
    return CurrentGameType.bTeamGame && !(GetGameClass() ~= "SkaarjPack.Invasion");
}

function string GetGameClass()
{
    return CurrentGameType.ClassName;
}

function string GetMapName( GUITreeList List, int Index )
{
	local MaplistRecord.MapItem Item;

	if ( List == None )
		return "";

	if ( !List.IsValidIndex(Index) )
		Index = List.Index;

	class'MaplistRecord'.static.CreateMapItem(List.GetValueAtIndex(Index), Item);
	return Item.MapName;
}

// Remove the additional text, and append the extra string data from the list
// Used when passing in a URL for the selected map
function string GetMapURL( GUITreeList List, int Index )
{
	local MaplistRecord.MapItem Item;

	if ( List == None )
		return "";

	if ( !List.IsValidIndex(Index) )
		Index = List.Index;

	class'MaplistRecord'.static.CreateMapItem(List.GetValueAtIndex(Index),Item);
	return Item.FullURL;
}

// Called when the "Only official maps" checkbox is clicked on
function ChangeMapFilter(GUIComponent Sender)
{
	if ( Sender != ch_OfficialMapsOnly )
		return;

	bOnlyShowOfficial = ch_OfficialMapsOnly.IsChecked();
	InitMaps();
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=FilterCheck
         CaptionWidth=0.100000
         ComponentWidth=0.900000
         Caption="Only Official Maps"
         OnCreateComponent=FilterCheck.InternalOnCreateComponent
         Hint="Hides all maps not created by Epic or Digital Extremes."
         WinTop=0.949531
         WinLeft=0.039258
         WinWidth=0.341797
         WinHeight=0.030035
         TabOrder=1
         OnChange=UT2K4Tab_MainBase.ChangeMapFilter
     End Object
     ch_OfficialMapsOnly=moCheckBox'GUI2K4.UT2K4Tab_MainBase.FilterCheck'

     MessageNoInfo="No information available!"
     AuthorText="Author"
     PlayerText="players"
     FilterText="Only Official Maps"
     ClearText="Show All Maps"
     LinkText="Link Setup"
     DefaultText="Default"
     AutoSelectText="Random"
     MaplistEditorMenu="GUI2K4.MaplistEditor"
     WinTop=0.150000
     WinHeight=0.770000
}
