// ====================================================================
//  Class:  xVoting.MapVoteMultiColumnList
//
//	Multi-Column list box used to display maps and game types.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MapVoteMultiColumnList extends GUIMultiColumnList;

var VotingReplicationInfo VRI;
var array<int> MapVoteData;
var int PrevSortColumn;
var GUIStyles SelStyle;
//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

	SelStyle = Controller.GetStyle("SquareButton",FontScale);
}
//------------------------------------------------------------------------------------------------
function LoadList(VotingReplicationInfo LoadVRI, int GameTypeIndex)
{
	local int m,p,l;
	local array<string> PrefixList;

	VRI = LoadVRI;

	Split(VRI.GameConfig[GameTypeIndex].Prefix, ",", PrefixList);
	for( m=0; m<VRI.MapList.Length; m++)
	{
		for( p=0; p<PreFixList.Length; p++)
		{
			if( left(VRI.MapList[m].MapName, len(PrefixList[p])) ~= PrefixList[p] )
			{
				l = MapVoteData.Length;
				MapVoteData.Insert(l,1);
				MapVoteData[l] = m;
				AddedItem();
				break;
			}
		} //p
	} //m
	OnDrawItem  = DrawItem;
}
//------------------------------------------------------------------------------------------------
function Clear()
{
    MapVoteData.Remove(0,MapVoteData.Length);
    ItemCount = 0;
    Super.Clear();
}
//------------------------------------------------------------------------------------------------
function int GetSelectedMapIndex()
{
	return MapVoteData[SortData[Index].SortItem];
}
//------------------------------------------------------------------------------------------------
function string GetSelectedMapName()
{
    if( Index > -1 )
		return VRI.MapList[MapVoteData[SortData[Index].SortItem]].MapName;
	else
		return "";
}
//------------------------------------------------------------------------------------------------
function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local eMenuState MState;
    local GUIStyles DrawStyle;

	if( VRI == none )
		return;

	// Draw the drag-n-drop outline
	if (bPending && OutlineStyle != None && (bDropSource || bDropTarget) )
	{
		if ( OutlineStyle.Images[MenuState] != None )
		{
			OutlineStyle.Draw(Canvas, MenuState, ClientBounds[0], Y, ClientBounds[2] - ClientBounds[0], ItemHeight);
			if (DropState == DRP_Source && i != DropIndex)
				OutlineStyle.Draw(Canvas, MenuState, Controller.MouseX - MouseOffset[0], Controller.MouseY - MouseOffset[1] + Y - ClientBounds[1], MouseOffset[2] + MouseOffset[0], ItemHeight);
		}
	}

    // Draw the selection border
    if( bSelected )
    {
        SelectedStyle.Draw(Canvas,MenuState, X, Y-2, W, H+2 );
        DrawStyle = SelectedStyle;
    }
    else
    	DrawStyle = Style;

    if( !VRI.MapList[MapVoteData[SortData[i].SortItem]].bEnabled )
    	MState = MSAT_Disabled;
    else
    	MState = MenuState;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MState, CellLeft, Y, CellWidth, H, TXTA_Left,
		VRI.MapList[MapVoteData[SortData[i].SortItem]].MapName, FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(VRI.MapList[MapVoteData[SortData[i].SortItem]].PlayCount), FontScale );

    GetCellLeftWidth( 2, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(VRI.MapList[MapVoteData[SortData[i].SortItem]].Sequence), FontScale );
}
//------------------------------------------------------------------------------------------------
function string GetSortString( int i )
{
	local string ColumnData[5];

	ColumnData[0] = left(Caps(VRI.MapList[MapVoteData[i]].MapName),20);
	ColumnData[1] = right("000000" $ VRI.MapList[MapVoteData[i]].PlayCount,6);
	ColumnData[2] = right("000000" $ VRI.MapList[MapVoteData[i]].Sequence,6);

	return ColumnData[SortColumn] $ ColumnData[PrevSortColumn];
}
//------------------------------------------------------------------------------------------------
event OnSortChanged()
{
	Super.OnSortChanged();
	PrevSortColumn = SortColumn;
}
//------------------------------------------------------------------------------------------------
function Free()
{
	VRI = none;
	super.Free();
}
//------------------------------------------------------------------------------------------------
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
	if (bAccepted && Accepting != None)
		OnDblClick(Self);

	SetOutlineAlpha(255);
	if ( bNotify )
		CheckLinkedObjects(Self);
}

defaultproperties
{
     ColumnHeadings(0)="Map Name"
     ColumnHeadings(1)="Played"
     ColumnHeadings(2)="Seq"
     InitColumnPerc(0)=0.600000
     InitColumnPerc(1)=0.200000
     InitColumnPerc(2)=0.200000
     ColumnHeadingHints(0)="Map Name"
     ColumnHeadingHints(1)="Number of times the map has been played."
     ColumnHeadingHints(2)="Sequence, The number of games that have been played since this map was last played."
     SelectedStyleName="BrowserListSelection"
     StyleName="ServerBrowserGrid"
}
