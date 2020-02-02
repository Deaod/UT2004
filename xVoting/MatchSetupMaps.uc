//==============================================================================
//  Created on: 01/02/2004
//  Configures maplist for match setup
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MatchSetupMaps extends MatchSetupPanelBase;

var automated GUISectionBackground sb_Avail, sb_Active;
var automated GUIListBox         lb_Avail, lb_Active;
var() editconst noexport GUIList li_Active, li_Avail;
var automated GUIButton			 b_Add, b_AddAll, b_Remove, b_RemoveAll, b_MoveUp, b_MoveDown;

struct MapInfo
{
	var string FriendlyName, Params, URL;
	var int Index;
};

var() array<MapInfo> TrackedMaps;

function InitPanel()
{
	Super.InitPanel();
	Group = class'VotingReplicationInfo'.default.MapID;
}

function LoggedOut()
{
	Super.LoggedOut();

	li_Avail.Clear();
	li_Active.Clear();
}

function bool HandleResponse(string Type, string Info, string Data)
{
	local int i;
	local array<string> Indexes;

	if ( Type ~= Group )
	{
		log("MAPS HandleResponse Info '"$Info$"'  Data '"$Data$"'",'MapVoteDebug');
		if ( Info ~= class'VotingReplicationInfo'.default.AddID )
		{
			ReceiveNewMap(Data);
			return true;
		}

		if ( Info ~= class'VotingReplicationInfo'.default.UpdateID )
		{
			Split(Data, ",", Indexes);
			for ( i = 0; i < Indexes.Length; i++ )
				AddMapByIndex(int(Indexes[i]));
		}

		return true;
	}

	return false;
}

function ReceiveNewMap( string Data )
{
	local int Index, pos;
	local string MapName;

	pos = InStr(Data, ",");
	if ( pos != -1 )
	{
		Index = int(Left(Data,pos));
		MapName = Mid(Data, pos+1);
	}
	else
	{
		log("HandleResponse received weird mapname:"@Data);
		assert(false);
	}

	TrackMapInfo( StripMapName(MapName), "", Index );
	li_Avail.Add(MapName);
}

function TrackMapInfo( string FriendlyName, string URL, int Index )
{
	local int i;

	i = FindTrackingIndex(FriendlyName $ URL);
	if ( i == -1 )
	{
		i = TrackedMaps.Length;
		TrackedMaps.Length = TrackedMaps.Length + 1;
	}

	TrackedMaps[i].FriendlyName = FriendlyName;
	TrackedMaps[i].Params = URL;
	TrackedMaps[i].URL = FriendlyName $ URL;
	TrackedMaps[i].Index = Index;
}

function int FindTrackingIndex( string MapURL )
{
	local int i;

	for ( i = 0; i < TrackedMaps.Length; i++ )
	{
		if ( TrackedMaps[i].URL ~= MapURL )
			return i;
	}

	return -1;
}

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	li_Avail = lb_Avail.List;
	li_Active = lb_Active.List;

	if (li_Avail != None)
	{
		li_Avail.bDropSource = True;
		li_Avail.bDropTarget = True;
		li_Avail.OnDblClick = ModifyMapList;
		li_Avail.AddLinkObject( b_Add, True );
		li_Avail.CheckLinkedObjects = InternalCheckLinkedObj;
		li_Avail.bInitializeList = False;
	}

	if (li_Active != None)
	{
		li_Active.bDropSource = True;
		li_Active.bDropTarget = True;
		li_Active.OnDblClick = ModifyMapList;
		li_Active.AddLinkObject( b_Remove, True );
		li_Active.AddLinkObject( b_MoveUp, True );
		li_Active.AddLinkObject( b_MoveDown, True );
		li_Active.CheckLinkedObjects = InternalCheckLinkedObj;
		li_Active.bInitializeList = False;
	}

	sb_Avail.ManageComponent(lb_Avail);
	sb_Active.ManageComponent(lb_Active);

}

// Mapname has value only when initializing list
function bool AddMap()
{
	local int i;
	local array<GUIListElem> PendingElements;

	if ( !li_Avail.IsValid() )
		return false;

	li_Avail.bNotify = False;
	PendingElements = li_Avail.GetPendingElements(True);
	for ( i = 0; i < PendingElements.Length; i++ )
	{
		li_Avail.RemoveElement(PendingElements[i],,True);
		li_Active.AddElement(PendingElements[i]);
	}

	li_Avail.bNotify = True;
	li_Avail.ClearPendingElements();
	li_Avail.SetIndex(li_Avail.Index);

	return true;
}

function bool RemoveMap()
{
	local int i;
	local array<GUIListElem> PendingElements;

	if ( !li_Active.IsValid() )
		return false;

	li_Active.bNotify = False;
	PendingElements = li_Active.GetPendingElements( True );
	for ( i = 0; i < PendingElements.Length; i++ )
	{
		li_Active.RemoveElement( PendingElements[i],,True );
		li_Avail.AddElement( PendingElements[i] );
	}

	li_Active.bNotify = True;
	li_Active.ClearPendingElements();
	li_Active.SetIndex(li_Active.Index);

	return true;
}

function AddMapByIndex( int Index )
{
	local int i;

	for ( i = 0; i < TrackedMaps.Length; i++ )
	{
		if ( TrackedMaps[i].Index == Index )
		{
			li_Avail.RemoveItem(TrackedMaps[i].URL);
			if ( li_Active.FindIndex(TrackedMaps[i].URL) == -1 )
				li_Active.Add(TrackedMaps[i].URL);

			li_Avail.ClearPendingElements();
			return;
		}
	}
}

function RemoveMapByIndex( int Index )
{
	local int i;

	for ( i = 0; i < TrackedMaps.Length; i++ )
	{
		if ( TrackedMaps[i].Index == Index )
		{
			li_Active.RemoveItem(TrackedMaps[i].URL);

			if ( li_Avail.FindIndex(TrackedMaps[i].URL) == -1 )
				li_Avail.Add(TrackedMaps[i].URL);

			li_Active.ClearPendingElements();
			return;
		}
	}
}

function SubmitChanges()
{
	local int i, idx;
	local string str;

	for ( i = 0; i < li_Active.ItemCount; i++ )
	{
		idx = FindTrackingIndex(li_Active.GetItemAtIndex(i));
		if ( idx != -1 )
		{
			if ( str != "" )
				str $= ",";

			str $= idx;
		}
	}

	SendCommand( Group $ ":" $ str );
	Super.SubmitChanges();
}

// Called when one of the buttons between the maplists are clicked on
singular function bool ModifyMapList(GUIComponent Sender)
{
	local int Index;
	local string Str;

	if ( Sender == lb_Avail )
	{
		AddMap();
		return true;
	}

	if ( Sender == lb_Active )
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
		if (lb_Avail.ItemCount()==0)
			return true;

//		for ( Index = 0; Index < li_Avail.ItemCount; Index++ )
//			MapHandler.AddMap( GameIndex, RecordIndex, li_Avail.GetItemAtIndex(Index) );

		li_Active.LoadFrom(li_Avail);
		li_Avail.Clear();

		return true;

	case b_Remove.Caption:
		return RemoveMap();

	case b_RemoveAll.Caption:
		if ( lb_Active.ItemCount()==0 )
			return true;

//		for ( Index = 0; Index < li_Active.ItemCount; Index++ )
//			MapHandler.RemoveMap( GameIndex, RecordIndex, li_Active.GetItemAtIndex(Index) );

		li_Avail.LoadFrom(li_Active,false);
		li_Active.Clear();

		return true;

	case b_MoveUp.Caption:
		if ( !li_Active.IsValid() )
			return true;

		Index = li_Active.Index;
		Str = GetMapURL(li_Active, -1);
		if (index>0)
		{
			li_Active.Swap(index,index-1);
			li_Active.SetIndex(Index - 1);
		}

//		MapHandler.ShiftMap(GameIndex, RecordIndex, Str, -1);

		return true;

	case b_MoveDown.Caption:
		if ( !li_Active.IsValid() )
			return true;

		Index = li_Active.Index;
		Str = GetMapURL(li_Active, -1);

		if (index<lb_Active.ItemCount()-1)
		{
			li_Active.Swap(index,index+1);
			li_Active.SetIndex(Index + 1);
		}

//		MapHandler.ShiftMap(GameIndex, RecordIndex, Str, 1);

		return true;
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

	if ( li_Avail.ItemCount > 0 )
		EnableComponent(b_AddAll);
	else DisableComponent(b_AddAll);

	if ( li_Active.ItemCount > 0 )
	{
		EnableComponent(b_RemoveAll);
		if ( li_Active.IsValid() )
		{
			if ( li_Active.Index == 0 )
				DisableComponent(b_MoveUp);
			else
			{
				EnableComponent(b_MoveUp);
				if ( li_Active.Index == li_Active.ItemCount -1 )
					DisableComponent(b_MoveDown);
				else EnableComponent(b_MoveDown);
			}
		}
		else
		{
			DisableComponent(b_MoveUp);
			DisableComponent(b_MoveDown);
		}
	}
	else
	{
		DisableComponent(b_RemoveAll);
		DisableComponent(b_MoveUp);
		DisableComponent(b_MoveDown);
	}
}

// Remove any additional text from the map's name
// Used for getting just the mapname
static function string StripMapName( string FullMapName )
{
	local int pos;

	pos = InStr(FullMapName, " ");
	if ( pos != -1 )
		FullMapName = Left(FullMapName, pos);

	pos = InStr(FullMapName, "?");
	if ( pos != -1 )
		FullMapName = Left(FullMapName, pos);

	return FullMapName;
}

// Remove the additional text, and append the extra string data from the list
// Used when passing in a URL for the selected map
static function string GetMapURL( GUIList List, int Index )
{
	local int pos;
	local string s;

	if ( Index == -1 )
		Index = List.Index;

	s = List.GetItemAtIndex(Index);
	pos = InStr(s, " ");

	// extra text in the mapname - get additional parameters from extra info
	if ( pos != -1 )
		s = Left(s, pos) $ List.GetExtraAtIndex(Index);

	return s;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=InactiveBackground
         bFillClient=True
         Caption="Inactive Maps"
         BottomPadding=0.110000
         WinTop=0.030053
         WinLeft=0.013880
         WinWidth=0.483107
         WinHeight=0.965313
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=InactiveBackground.InternalPreDraw
     End Object
     sb_Avail=GUISectionBackground'xVoting.MatchSetupMaps.InactiveBackground'

     Begin Object Class=GUISectionBackground Name=ActiveBackground
         bFillClient=True
         Caption="Active Maps"
         BottomPadding=0.215000
         WinTop=0.030053
         WinLeft=0.511243
         WinWidth=0.474194
         WinHeight=0.965313
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=ActiveBackground.InternalPreDraw
     End Object
     sb_Active=GUISectionBackground'xVoting.MatchSetupMaps.ActiveBackground'

     Begin Object Class=GUIListBox Name=InactiveList
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=InactiveList.InternalOnCreateComponent
         WinTop=0.138078
         WinLeft=0.113794
         WinWidth=0.380394
         WinHeight=0.662671
         TabOrder=0
     End Object
     lb_Avail=GUIListBox'xVoting.MatchSetupMaps.InactiveList'

     Begin Object Class=GUIListBox Name=ActiveList
         bVisibleWhenEmpty=True
         OnCreateComponent=ActiveList.InternalOnCreateComponent
         WinTop=0.108021
         WinLeft=0.605861
         WinWidth=0.368359
         WinHeight=0.662671
         TabOrder=1
     End Object
     lb_Active=GUIListBox'xVoting.MatchSetupMaps.ActiveList'

     Begin Object Class=GUIButton Name=AddButton
         Caption="Add"
         Hint="Add the selected maps to your map list"
         WinTop=0.902198
         WinLeft=0.263743
         WinWidth=0.203807
         WinHeight=0.079184
         TabOrder=6
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=MatchSetupMaps.ModifyMapList
         OnKeyEvent=AddButton.InternalOnKeyEvent
     End Object
     b_Add=GUIButton'xVoting.MatchSetupMaps.AddButton'

     Begin Object Class=GUIButton Name=AddAllButton
         Caption="Add All"
         Hint="Add all maps to your map list"
         WinTop=0.902198
         WinLeft=0.045006
         WinWidth=0.190232
         WinHeight=0.079184
         TabOrder=5
         OnClickSound=CS_Up
         OnClick=MatchSetupMaps.ModifyMapList
         OnKeyEvent=AddAllButton.InternalOnKeyEvent
     End Object
     b_AddAll=GUIButton'xVoting.MatchSetupMaps.AddAllButton'

     Begin Object Class=GUIButton Name=RemoveButton
         Caption="Remove"
         AutoSizePadding=(HorzPerc=0.500000)
         Hint="Remove the selected maps from your map list"
         WinTop=0.902198
         WinLeft=0.543747
         WinWidth=0.191554
         WinHeight=0.079184
         TabOrder=10
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=MatchSetupMaps.ModifyMapList
         OnKeyEvent=RemoveButton.InternalOnKeyEvent
     End Object
     b_Remove=GUIButton'xVoting.MatchSetupMaps.RemoveButton'

     Begin Object Class=GUIButton Name=RemoveAllButton
         Caption="Remove All"
         Hint="Remove all maps from your map list"
         WinTop=0.902198
         WinLeft=0.772577
         WinWidth=0.191554
         WinHeight=0.079184
         TabOrder=11
         OnClickSound=CS_Down
         OnClick=MatchSetupMaps.ModifyMapList
         OnKeyEvent=RemoveAllButton.InternalOnKeyEvent
     End Object
     b_RemoveAll=GUIButton'xVoting.MatchSetupMaps.RemoveAllButton'

     Begin Object Class=GUIButton Name=MoveUpButton
         Caption="Up"
         Hint="Move this map higher up in the list"
         WinTop=0.815376
         WinLeft=0.772577
         WinWidth=0.191554
         WinHeight=0.079184
         TabOrder=9
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=MatchSetupMaps.ModifyMapList
         OnKeyEvent=MoveUpButton.InternalOnKeyEvent
     End Object
     b_MoveUp=GUIButton'xVoting.MatchSetupMaps.MoveUpButton'

     Begin Object Class=GUIButton Name=MoveDownButton
         Caption="Down"
         Hint="Move this map lower down in the list"
         WinTop=0.815376
         WinLeft=0.543747
         WinWidth=0.191554
         WinHeight=0.079184
         TabOrder=8
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=MatchSetupMaps.ModifyMapList
         OnKeyEvent=MoveDownButton.InternalOnKeyEvent
     End Object
     b_MoveDown=GUIButton'xVoting.MatchSetupMaps.MoveDownButton'

     OnLogOut=MatchSetupMaps.LoggedOut
     PanelCaption="Maplist"
}
