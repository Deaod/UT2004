//==============================================================================
//  Created on: 12/11/2003
//  Instant Action version of maplist tab
//  This version displays single maplist with preview images
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_MainSP extends UT2K4Tab_MainBase;

// Preview controls
var automated GUISectionBackground sb_Selection, sb_Preview, sb_Options;
var automated AltSectionBackground asb_Scroll;

var automated GUIScrollTextBox  lb_MapDesc;
var automated GUITreeListBox    lb_Maps;
var() editconst noexport GUITreeList       li_Maps;
var automated moButton	        b_Maplist;
var automated moButton          b_Tutorial;
var automated GUIImage          i_MapPreview, i_DescBack;
var automated GUILabel          l_MapAuthor, l_MapPlayers, l_NoPreview;

var() localized string MapCaption, BonusVehicles, BonusVehiclesMsg;

var config string LastSelectedMap; // Used to keep track of the map which was selected the last time we were in the menus

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local array<CacheManager.MapRecord> TutMaps;

    Super.InitComponent(MyController, MyOwner);

	if ( lb_Maps != None )
		li_Maps = lb_Maps.List;

	if ( li_Maps != None )
	{
	    li_Maps.OnDblClick = MapListDblClick;
	    li_Maps.bSorted = True;
	    lb_Maps.NotifyContextSelect = HandleContextSelect;
	}

    class'CacheManager'.static.GetMaplist(TutMaps, "TUT");

    TutorialMaps.Length = TutMaps.Length;
    for ( i = 0; i < TutMaps.Length; i++ )
    	TutorialMaps[i] = TutMaps[i].MapName;

	lb_Maps.bBoundToParent=false;
	lb_Maps.bScaleToParent=false;

	sb_Selection.ManageComponent(lb_Maps);

	asb_Scroll.ManageComponent(lb_MapDesc);

	if (CurrentGameType.GameTypeGroup==3)
	{
		ch_OfficialMapsOnly.Checked(false);
		ch_OfficialMapsOnly.DisableMe();
	}
	else
		ch_OfficialMapsOnly.EnableMe();

    sb_Options.ManageComponent(ch_OfficialMapsOnly);
    sb_Options.ManageComponent(b_Maplist);
    sb_Options.ManageComponent(b_Tutorial);

    InitMapHandler();
}


// Called when a new gametype is selected
function InitGameType()
{
    local int i;
    local array<CacheManager.GameRecord> Games;
    local bool bReloadMaps;

	// Get a list of all gametypes.
    class'CacheManager'.static.GetGameTypeList(Games);
	for (i = 0; i < Games.Length; i++)
    {
        if (Games[i].ClassName ~= Controller.LastGameType)
        {
        	bReloadMaps = CurrentGameType.MapPrefix != Games[i].MapPrefix;
            CurrentGameType = Games[i];
            break;
        }
    }

    if ( i == Games.Length )
    	return;

	// Update the gametype label's text
    SetGameTypeCaption();

    // Should the tutorial button be enabled?
    CheckGameTutorial();

    // Load Maps for the new gametype, but only if it uses a different maplist
    if (bReloadMaps)
   		InitMaps();

    // Set the selected map
    i = li_Maps.FindIndexByValue(LastSelectedMap);
    if ( i == -1 )
    	i = 0;
    li_Maps.SetIndex(i);
    li_Maps.Expand(i);

	// Load the information (screenshot, desc., etc.) for the currently selected map
//    ReadMapInfo(li_Maps.GetParentCaption());
}

function bool OrigONSMap(string MapName)
{
	if (
		 MapName ~= "ONS-ArcticStronghold" ||
		 MapName ~= "ONS-Crossfire" ||
		 MapName ~= "ONS-Dawn" ||
		 MapName ~= "ONS-Dria" ||
		 MapName ~= "ONS-FrostBite" ||
		 MapName ~= "ONS-Primeval" ||
		 MapName ~= "ONS-RedPlanet" ||
		 MapName ~= "ONS-Severance" ||
		 MapName ~= "ONS-Torlan"
		)
		return true;

	return false;
}


// Query the CacheManager for the maps that correspond to this gametype, then fill the main list
function InitMaps( optional string MapPrefix )
{
    local int i, j, k, BV;
    local bool bTemp;
    local string Package, Item, CurrentItem, Desc;
    local GUITreeNode StoredItem;
    local DecoText DT;
    local array<string> CustomLinkSetups;

	// Make sure we have a map prefix
	if ( MapPrefix == "" )
		MapPrefix = GetMapPrefix();

	// Temporarily disable notification in all components
    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

	if ( li_Maps.IsValid() )
		li_Maps.GetElementAtIndex(li_Maps.Index, StoredItem);

	// Get the list of maps for the current gametype
	class'CacheManager'.static.GetMapList( CacheMaps, MapPrefix );
	if ( MapHandler.GetAvailableMaps(MapHandler.GetGameIndex(CurrentGameType.ClassName), Maps) )
	{
		li_Maps.bNotify = False;
		li_Maps.Clear();

		for ( i = 0; i < Maps.Length; i++ )
		{

			DT = None;
			if ( class'CacheManager'.static.IsDefaultContent(Maps[i].MapName) )
			{
				if ( bOnlyShowCustom )
					continue;
			}
			else if ( bOnlyShowOfficial )
				continue;

			j = FindCacheRecordIndex(Maps[i].MapName);
			if ( class'CacheManager'.static.Is2003Content(Maps[i].MapName) )
			{
				if ( CacheMaps[j].TextName != "" )
				{
					if ( !Divide(CacheMaps[j].TextName, ".", Package, Item) )
				{
						Package = "XMaps";
						Item = CacheMaps[j].TextName;
					}
				}

				DT = class'xUtil'.static.LoadDecoText(Package, Item);
			}

			if ( DT != None )
				Desc = JoinArray(DT.Rows, "|");
			else
				Desc =CacheMaps[j].Description;

			li_Maps.AddItem( Maps[i].MapName, Maps[i].MapName, ,,Desc);

			// for now, limit this to power link setups only
			if ( CurrentGameType.MapPrefix ~= "ONS" )
			{

				// Big Hack Time for the bonus pack

				CurrentItem = Maps[i].MapName;
				for (BV=0;BV<2;BV++)
				{
					if ( Maps[i].Options.Length > 0 )
					{
						Package = CacheMaps[j].Description;

						// Add the "auto link setup" item
						li_Maps.AddItem( AutoSelectText @ LinkText, Maps[i].MapName $ "?LinkSetup=Random", CurrentItem,,Package );

						// Now add all official link setups
						for ( k = 0; k < Maps[i].Options.Length; k++ )
						{
							li_Maps.AddItem(Maps[i].Options[k].Value @ LinkText, Maps[i].MapName $ "?LinkSetup=" $ Maps[i].Options[k].Value, CurrentItem,,Package );
						}
					}

					// Now to add the custom setups
					CustomLinkSetups = GetPerObjectNames(Maps[i].MapName, "ONSPowerLinkCustomSetup");
					for ( k = 0; k < CustomLinkSetups.Length; k++ )
					{
						li_Maps.AddItem(CustomLinkSetups[k] @ LinkText, Maps[i].MapName $ "?" $ "LinkSetup=" $ CustomLinkSetups[k], CurrentItem,,Package);
					}

					if ( !OrigONSMap(Maps[i].MapName) )
						break;

					else if (BV<1 && Controller.bECEEdition)
                    {
						li_Maps.AddItem( Maps[i].MapName$BonusVehicles, Maps[i].MapName, ,,BonusVehiclesMsg$Package);
						CurrentItem=CurrentItem$BonusVehicles;
					}

					if ( !Controller.bECEEdition )	// Don't do the second loop if not the ECE
						break;

				}

			}
		}
	}

	if ( li_Maps.bSorted )
		li_Maps.SortList();

	if ( StoredItem.Caption != "" )
	{
		i = li_Maps.FindFullIndex(StoredItem.Caption, StoredItem.Value, StoredItem.ParentCaption);
		if ( i != -1 )
			li_Maps.SilentSetIndex(i);
	}

	li_Maps.bNotify = True;

    Controller.bCurMenuInitialized = bTemp;
}

// =====================================================================================================================
// =====================================================================================================================
//  Utility functions - handles all special stuff that should happen whenever events are received on the page
// =====================================================================================================================
// =====================================================================================================================

// Update all components on the preview side with the data from the currently selected map
function ReadMapInfo(string MapName)
{
    local string mDesc;
    local int Index;

    if(MapName == "")
        return;

    if (!Controller.bCurMenuInitialized)
        return;

    Index = FindCacheRecordIndex(MapName);

    if (CacheMaps[Index].FriendlyName != "")
        asb_Scroll.Caption = CacheMaps[Index].FriendlyName;
    else
		asb_Scroll.Caption = MapName;

	UpdateScreenshot(Index);

	// Only show 1 number if min & max are the same
	if ( CacheMaps[Index].PlayerCountMin == CacheMaps[Index].PlayerCountMax )
		l_MapPlayers.Caption = CacheMaps[Index].PlayerCountMin @ PlayerText;
	else l_MapPlayers.Caption = CacheMaps[Index].PlayerCountMin@"-"@CacheMaps[Index].PlayerCountMax@PlayerText;

	mDesc = li_Maps.GetExtra();

    if (mDesc == "")
        mDesc = MessageNoInfo;

	lb_MapDesc.SetContent( mDesc );
    if (CacheMaps[Index].Author != "" && !class'CacheManager'.static.IsDefaultContent(CacheMaps[Index].MapName))
        l_MapAuthor.Caption = AuthorText$":"@CacheMaps[Index].Author;
    else l_MapAuthor.Caption = "";
}

// If this gametype has a tutorial, enable the tutorial button
function CheckGameTutorial()
{
	local int i;

	for ( i = 0; i < TutorialMaps.Length; i++ )
	{
		if ( Mid(TutorialMaps[i], InStr(TutorialMaps[i], "-") + 1) ~= CurrentGameType.GameAcronym )
		{
			EnableComponent(b_Tutorial);
			b_Tutorial.SetComponentValue(TutorialMaps[i],True);
			return;
		}
	}

	DisableComponent(b_Tutorial);
	b_Tutorial.SetComponentValue("",True);
}

function UpdateScreenshot(int Index)
{
	local Material Screenie;

	if ( Index >= 0 && Index < CacheMaps.Length )
	    Screenie = Material(DynamicLoadObject(CacheMaps[Index].ScreenshotRef, class'Material'));

    i_MapPreview.Image = Screenie;
    l_NoPreview.SetVisibility( Screenie == None );
    i_MapPreview.SetVisibility( Screenie != None );
}

event SetVisibility( bool bIsVisible )
{
	Super.SetVisibility(bIsVisible);

	if ( bIsVisible )
	{
	    l_NoPreview.SetVisibility( i_MapPreview.Image == None );
	    i_MapPreview.SetVisibility( i_MapPreview.Image != None );
	}
}

function SetGameTypeCaption()
{
    sb_Selection. Caption = CurrentGameType.GameName@MapCaption;
}

function string Play()
{
	return GetMapURL(li_Maps,-1);
}

function string GetMapURL( GUITreeList List, int Index )
{

	local string URL;

	URL = Super.GetMapURL(List,Index);
	if ( CurrentGameType.MapPrefix ~= "ONS" && InStr(Caps(URL),"?LINKSETUP=") == -1 )
		URL $= "?LinkSetup=Default";

	if ( (InStr(List.GetCaption(),BonusVehicles)>=0) || (InStr(List.GetParentCaption(),BonusVehicles)>=0) )
		URL $= "?BonusVehicles=true";
	else
		URL $= "?BonusVehicles=false";

	return URL;
}

// =====================================================================================================================
// =====================================================================================================================
//  OnClick's
// =====================================================================================================================
// =====================================================================================================================

function MaplistConfigClick( GUIComponent Sender )
{
	local MaplistEditor MaplistPage;

	// open maplist config page
	if ( Controller.OpenMenu(MaplistEditorMenu) )
	{
		MaplistPage = MaplistEditor(Controller.ActivePage);
		if ( MaplistPage != None )
		{
			MaplistPage.MainPanel = self;
			MaplistPage.bOnlyShowOfficial = bOnlyShowOfficial;
			MaplistPage.bOnlyShowCustom = bOnlyShowCustom;
			MaplistPage.Initialize(MapHandler);
		}
	}
}

// Called when a double click is received in the main maplist
function bool MapListDblClick(GUIComponent Sender)
{
	if ( li_Maps.ValidSelection() )
		return p_Anchor.InternalOnClick(p_Anchor.b_Primary);
	else
	{
		if ( CurrentGameType.MapPrefix ~= "ONS" )
		{
			if ( !li_Maps.IsToggleClick(li_Maps.Index) )
				return p_Anchor.InternalOnClick(p_Anchor.b_Primary);
		}
		else return li_Maps.InternalDblClick(Sender);
	}

    return true;
}

// Called when the "Watch Tutorial" button is clicked
function TutorialClicked( GUIComponent Sender )
{
	if ( Sender == b_Tutorial )
	{
		Play();
		PlayerOwner().ConsoleCommand("START"@b_Tutorial.GetComponentValue()$"?quickstart=true?TeamScreen=false");
		Controller.CloseAll(False,true);
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  OnChange's
// =====================================================================================================================
// =====================================================================================================================

// Called when user clicks on a new map in the main maplist
function MapListChange(GUIComponent Sender)
{
	local MaplistRecord.MapItem Item;

    if (!Controller.bCurMenuInitialized)
        return;

	if ( Sender == lb_Maps )
	{
		if ( li_Maps.IsValid() )
		{
			EnableComponent(b_Primary);
			EnableComponent(b_Secondary);
		}

		class'MaplistRecord'.static.CreateMapItem(li_Maps.GetValue(), Item);

		LastSelectedMap = Item.FullURL;
		SaveConfig();
		ReadMapInfo(Item.MapName);
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  Misc. Events
// =====================================================================================================================
// =====================================================================================================================

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if ( moButton(Sender) != None && GUILabel(NewComp) != None )
	{
//		GUILabel(NewComp).TextColor = WhiteColor[3];
		moButton(Sender).InternalOnCreateComponent(NewComp, Sender);
	}
}

function bool HandleContextSelect(GUIContextMenu Sender, int Index)
{
	local string MapName;

	if ( Sender != None )
	{
		switch ( Index )
		{
		case 0:
		case 1:
			MapName = GetMapURL(li_Maps,-1);
			if (MapName != "")
			{
				p_Anchor.PrepareToPlay(MapName, MapName);
				p_Anchor.StartGame(MapName, Index == 1);
			}

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

function int FindCacheRecordIndex(string MapName)
{
    local int i;

    for (i = 0; i < CacheMaps.Length; i++)
        if (CacheMaps[i].MapName == MapName)
            return i;

    return -1;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=SelectionGroup
         bFillClient=True
         Caption="Map Selection"
         WinTop=0.018125
         WinLeft=0.016993
         WinWidth=0.482149
         WinHeight=0.603330
         OnPreDraw=SelectionGroup.InternalPreDraw
     End Object
     sb_Selection=GUISectionBackground'GUI2K4.UT2K4Tab_MainSP.SelectionGroup'

     Begin Object Class=GUISectionBackground Name=PreviewGroup
         bFillClient=True
         Caption="Preview"
         WinTop=0.018125
         WinLeft=0.515743
         WinWidth=0.470899
         WinHeight=0.974305
         OnPreDraw=PreviewGroup.InternalPreDraw
     End Object
     sb_Preview=GUISectionBackground'GUI2K4.UT2K4Tab_MainSP.PreviewGroup'

     Begin Object Class=GUISectionBackground Name=OptionsGroup
         Caption="Options"
         BottomPadding=0.070000
         WinTop=0.642580
         WinLeft=0.018008
         WinWidth=0.482149
         WinHeight=0.351772
         OnPreDraw=OptionsGroup.InternalPreDraw
     End Object
     sb_Options=GUISectionBackground'GUI2K4.UT2K4Tab_MainSP.OptionsGroup'

     Begin Object Class=AltSectionBackground Name=ScrollSection
         bFillClient=True
         Caption="Map Desc"
         WinTop=0.525219
         WinLeft=0.546118
         WinWidth=0.409888
         WinHeight=0.437814
         OnPreDraw=ScrollSection.InternalPreDraw
     End Object
     asb_Scroll=AltSectionBackground'GUI2K4.UT2K4Tab_MainSP.ScrollSection'

     Begin Object Class=GUIScrollTextBox Name=MapDescription
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=MapDescription.InternalOnCreateComponent
         WinTop=0.628421
         WinLeft=0.561065
         WinWidth=0.379993
         WinHeight=0.268410
         bTabStop=False
         bNeverFocus=True
     End Object
     lb_MapDesc=GUIScrollTextBox'GUI2K4.UT2K4Tab_MainSP.MapDescription'

     Begin Object Class=GUITreeListBox Name=AvailableMaps
         bVisibleWhenEmpty=True
         OnCreateComponent=AvailableMaps.InternalOnCreateComponent
         Hint="Click a mapname to see a preview and description.  Double-click to play a match on the map."
         WinTop=0.169272
         WinLeft=0.045671
         WinWidth=0.422481
         WinHeight=0.449870
         TabOrder=0
         OnChange=UT2K4Tab_MainSP.MapListChange
     End Object
     lb_Maps=GUITreeListBox'GUI2K4.UT2K4Tab_MainSP.AvailableMaps'

     Begin Object Class=moButton Name=MaplistButton
         ButtonCaption="Maplist Configuration"
         ComponentWidth=1.000000
         OnCreateComponent=MaplistButton.InternalOnCreateComponent
         Hint="Modify the maps that should be used in gameplay"
         WinTop=0.888587
         WinLeft=0.039258
         WinWidth=0.341797
         WinHeight=0.050000
         TabOrder=2
         OnChange=UT2K4Tab_MainSP.MaplistConfigClick
     End Object
     b_Maplist=moButton'GUI2K4.UT2K4Tab_MainSP.MaplistButton'

     Begin Object Class=moButton Name=TutorialButton
         ButtonCaption="Watch Game Tutorial"
         ComponentWidth=1.000000
         OnCreateComponent=TutorialButton.InternalOnCreateComponent
         Hint="Watch the tutorial for this gametype."
         WinTop=0.913326
         WinLeft=0.556953
         WinWidth=0.348633
         WinHeight=0.050000
         TabOrder=3
         OnChange=UT2K4Tab_MainSP.TutorialClicked
     End Object
     b_Tutorial=moButton'GUI2K4.UT2K4Tab_MainSP.TutorialButton'

     Begin Object Class=GUIImage Name=MapPreviewImage
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.107691
         WinLeft=0.562668
         WinWidth=0.372002
         WinHeight=0.357480
         RenderWeight=0.200000
     End Object
     i_MapPreview=GUIImage'GUI2K4.UT2K4Tab_MainSP.MapPreviewImage'

     Begin Object Class=GUILabel Name=MapAuthorLabel
         Caption="Testing"
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.405278
         WinLeft=0.522265
         WinWidth=0.453285
         WinHeight=0.032552
         RenderWeight=0.300000
     End Object
     l_MapAuthor=GUILabel'GUI2K4.UT2K4Tab_MainSP.MapAuthorLabel'

     Begin Object Class=GUILabel Name=RecommendedPlayers
         Caption="Best for 4 to 8 players"
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.474166
         WinLeft=0.521288
         WinWidth=0.445313
         WinHeight=0.032552
         RenderWeight=0.300000
     End Object
     l_MapPlayers=GUILabel'GUI2K4.UT2K4Tab_MainSP.RecommendedPlayers'

     Begin Object Class=GUILabel Name=NoPreview
         Caption="No Preview Available"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=247)
         TextFont="UT2HeaderFont"
         bTransparent=False
         bMultiLine=True
         VertAlign=TXTA_Center
         WinTop=0.107691
         WinLeft=0.562668
         WinWidth=0.372002
         WinHeight=0.357480
     End Object
     l_NoPreview=GUILabel'GUI2K4.UT2K4Tab_MainSP.NoPreview'

     MapCaption="Maps"
     BonusVehicles=" (Bonus Vehicles)"
     BonusVehiclesMsg="(Includes Bonus Vehicles)|"
     LastSelectedMap="CTF-CheckMate-CWL"
     Begin Object Class=moCheckBox Name=FilterCheck
         CaptionWidth=0.100000
         ComponentWidth=0.900000
         Caption="Only Official Maps"
         OnCreateComponent=FilterCheck.InternalOnCreateComponent
         Hint="Hides all maps not created by Epic or Digital Extremes."
         WinTop=0.772865
         WinLeft=0.051758
         WinWidth=0.341797
         WinHeight=0.030035
         TabOrder=1
         OnChange=UT2K4Tab_MainSP.ChangeMapFilter
     End Object
     ch_OfficialMapsOnly=moCheckBox'GUI2K4.UT2K4Tab_MainSP.FilterCheck'

}
