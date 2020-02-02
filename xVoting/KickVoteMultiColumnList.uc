// ====================================================================
//  Class:  xVoting.KickVoteMultiColumnList
//
//	Multi-Column list box used to display players.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class KickVoteMultiColumnList extends GUIMultiColumnList;

var VotingReplicationInfo VRI;
var array<VotingHandler.KickVoteScore> KickVoteData;
var array<string> PlayerName;
var int PrevSortColumn;
//------------------------------------------------------------------------------------------------
function LoadPlayerList(VotingReplicationInfo LoadVRI)
{
    local GameReplicationInfo GRI;
    local int i,x;

	if( LoadVRI == none )
		return;
	else
		VRI = LoadVRI;

    GRI = PlayerOwner().GameReplicationInfo;

    KickVoteData.Remove(0,KickVoteData.Length);
    for(i=0; i<GRI.PRIArray.Length; i++)
    {
        if(!( (GRI.PRIArray[i].PlayerName ~= "WebAdmin" || GRI.PRIArray[i].PlayerName ~= "DemoRecSpectator") &&
            GRI.PRIArray[i].bIsSpectator &&
            GRI.PRIArray[i].bOnlySpectator &&
            GRI.PRIArray[i].bOutOfLives)  // dont show web admin or DemoRec spectators
            &&
            !GRI.PRIArray[i].bBot &&  // dont show bots
            !GRI.PRIArray[i].bAdmin)  // Dont show admins they can't be kicked anyway
        {
            KickVoteData.Insert(KickVoteData.Length,1);
            PlayerName.Insert(KickVoteData.Length-1,1);
			PlayerName[KickVoteData.Length-1] = GRI.PRIArray[i].PlayerName;
            KickVoteData[KickVoteData.Length-1].PlayerID = GRI.PRIArray[i].PlayerID;
            if( GRI.PRIArray[i].Team != none)
                KickVoteData[KickVoteData.Length-1].Team = GRI.PRIArray[i].Team.TeamIndex;
            else
                KickVoteData[KickVoteData.Length-1].Team = 255;

            KickVoteData[KickVoteData.Length-1].KickVoteCount = 0;
			// find and retrieve the vote count from VRI
			for( x=0; x<VRI.KickVoteCount.Length; x++ )
			{
				if( KickVoteData[KickVoteData.Length-1].PlayerID == VRI.KickVoteCount[x].PlayerID )
				{
					KickVoteData[KickVoteData.Length-1].KickVoteCount = VRI.KickVoteCount[x].KickVoteCount;
					break;
				}
			}
            AddedItem();
        }
    }
    setTimer(4, true); // check for updates to player list every 4 seconds
	OnDrawItem  = DrawItem;
}
//------------------------------------------------------------------------------------------------
function UpdatedVoteCount(int PlayerID, int VoteCount)
{
	local int i;

	for( i=0; i<KickVoteData.Length; i++ )
	{
		if( KickVoteData[i].PlayerID == PlayerID )
		{
			KickVoteData[i].KickVoteCount = VoteCount;
            UpdatedItem(i);
			break;
		}
	}
	OnSortChanged();
}
//------------------------------------------------------------------------------------------------
function Clear()
{
    KickVoteData.Remove(0,KickVoteData.Length);
    ItemCount = 0;
    Super.Clear();
}
//------------------------------------------------------------------------------------------------
function int GetSelectedPlayerID()
{
	if( Index > -1 )
		return KickVoteData[SortData[Index].SortItem].PlayerID;
	else
		return -1;
}
//------------------------------------------------------------------------------------------------
function string GetSelectedPlayerName()
{
    if( Index > -1 )
    	return PlayerName[Index];
    else
		return "";
}
//------------------------------------------------------------------------------------------------
function int GetSelectedTeam()
{
	return KickVoteData[SortData[Index].SortItem].Team;
}
//------------------------------------------------------------------------------------------------
function timer()
{
    local GameReplicationInfo GRI;
    local int i,x,TeamIndex;
    local int PlayerID;
    local bool bFound;

    Super.timer();

    GRI = PlayerOwner().GameReplicationInfo;

    // Add new players to list
    for(i=0; i<GRI.PRIArray.Length; i++)
    {
        PlayerID = GRI.PRIArray[i].PlayerID;
        if( GRI.PRIArray[i].Team != none)
            TeamIndex = GRI.PRIArray[i].Team.TeamIndex;
        else
            TeamIndex =  255;

        if(!( (GRI.PRIArray[i].PlayerName ~= "WebAdmin" || GRI.PRIArray[i].PlayerName ~= "DemoRecSpectator") &&
            GRI.PRIArray[i].bIsSpectator &&
            GRI.PRIArray[i].bOnlySpectator &&
            GRI.PRIArray[i].bOutOfLives)  // dont show web admin or DemoRec spectators
            &&
            !GRI.PRIArray[i].bBot &&  // dont show bots
            !GRI.PRIArray[i].bAdmin)  // Dont show admins they can't be kicked anyway
        {
            bFound = false;
            for(x=0;x < KickVoteData.Length; x++)
            {
                if( KickVoteData[x].PlayerID == PlayerID )
                {
                    bFound = true;
                    // check for name change
                    if( PlayerName[x] != GRI.PRIArray[i].PlayerName )
                    	PlayerName[x] = GRI.PRIArray[i].PlayerName;
                    break;
                }
            }

            if(!bFound)
            {
            	KickVoteData.Insert(KickVoteData.Length,1);
	            PlayerName.Insert(KickVoteData.Length-1,1);
				PlayerName[KickVoteData.Length-1] = GRI.PRIArray[i].PlayerName;
                KickVoteData[KickVoteData.Length-1].PlayerID = PlayerID;
                KickVoteData[KickVoteData.Length-1].Team = TeamIndex;
                KickVoteData[KickVoteData.Length-1].KickVoteCount = 0;
				// find and retrieve the vote count from VRI
				for( x=0; x<VRI.KickVoteCount.Length; x++ )
				{
					if( KickVoteData[KickVoteData.Length-1].PlayerID == VRI.KickVoteCount[x].PlayerID )
					{
						KickVoteData[KickVoteData.Length-1].KickVoteCount = VRI.KickVoteCount[x].KickVoteCount;
						break;
					}
				}
                AddedItem();
            }
        }
    }

    // Remove missing players from list
    for(i=0;i < KickVoteData.Length; i++)
    {
        PlayerID = KickVoteData[i].PlayerID;
        bFound = false;
        for(x=0; x<GRI.PRIArray.Length; x++)
        {
            if( PlayerID == GRI.PRIArray[x].PlayerID )
            {
                bFound = true;
                break;
            }
        }

        if(!bFound)
        {
        	PlayerName.Remove(i,1);
            KickVoteData.Remove(i,1);
            for( x=0; x<SortData.Length; x++ )
            {
            	if( SortData[x].SortItem == i )
            	{
					SortData.Remove(x,1);
					InvSortData.Remove(x,1);
					break;
				}
			}
			ItemCount--;
			OnSortChanged();
        }
    }
}
//------------------------------------------------------------------------------------------------
function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local string TeamName;
    local GUIStyles DrawStyle;

	if( i >= SortData.Length || SortData[i].SortItem >= KickVoteData.Length )
		return;

    // Draw the selection border
    if( bSelected )
    {
        SelectedStyle.Draw(Canvas,MenuState, X, Y-2, W, H+2 );
        DrawStyle = SelectedStyle;
    }
    else
    	DrawStyle = Style;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		PlayerName[SortData[i].SortItem], FontScale );

	if( PlayerOwner().GameReplicationInfo.bTeamGame && (KickVoteData[SortData[i].SortItem].Team < 4)  )
	    TeamName = class'Engine.TeamInfo'.default.ColorNames[KickVoteData[SortData[i].SortItem].Team];
	else
		TeamName = "";

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		TeamName, FontScale );

    GetCellLeftWidth( 2, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(KickVoteData[SortData[i].SortItem].PlayerID), FontScale );

    GetCellLeftWidth( 3, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(KickVoteData[SortData[i].SortItem].KickVoteCount), FontScale );
}
//------------------------------------------------------------------------------------------------
function string GetSortString( int i )
{
	local string ColumnData[4];

	ColumnData[0] = left(Caps(PlayerName[i]),20);
	ColumnData[1] = left(Caps(KickVoteData[i].Team),5);
	ColumnData[2] = right("0000" $ KickVoteData[i].PlayerID,4);
	ColumnData[3] = right("0000" $ KickVoteData[i].KickVoteCount,4);

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

defaultproperties
{
     ColumnHeadings(0)="Player Name"
     ColumnHeadings(1)="Team"
     ColumnHeadings(2)="ID"
     ColumnHeadings(3)="Votes"
     InitColumnPerc(0)=0.550000
     InitColumnPerc(1)=0.150000
     InitColumnPerc(2)=0.150000
     InitColumnPerc(3)=0.150000
     ColumnHeadingHints(0)="Player Name"
     ColumnHeadingHints(1)="Player's Team"
     ColumnHeadingHints(2)="Player's ID number"
     ColumnHeadingHints(3)="Number of kick votes registered against this player."
     SortColumn=2
     SortDescending=True
     SelectedStyleName="BrowserListSelection"
     StyleName="ServerBrowserGrid"
}
