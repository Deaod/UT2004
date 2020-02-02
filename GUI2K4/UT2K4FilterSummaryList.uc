//==============================================================================
//  Lists active rules for the selected filter
//
//  Created by Ron Prestenback
//  © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4FilterSummaryList extends GUIMultiColumnList
    DependsOn(CustomFilter);

var UT2K4CustomFilterPage   p_Anchor;
var array<CustomFilter.AFilterRule> Rules;

function InternalOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DrawStyle;

    if (bSelected)
    {
        SelectedStyle.Draw(Canvas, MSAT_Pressed, X, Y-2, W, H+2);
        DrawStyle = SelectedStyle;
    }
    else DrawStyle = Style;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, GetRuleItem(i, 0), FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, GetRuleItem(i, 1), FontScale );

    GetCellLeftWidth( 2, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, GetRuleItem(i, 2), FontScale );

    GetCellLeftWidth( 3, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, GetRuleItem(i, 3), FontScale );
}

function AddFilterRule(CustomFilter.AFilterRule NewRule)
{
    Rules[Rules.Length] = NewRule;
    AddedItem();
}

function int RemoveFilterRule(int RuleIndex)
{
    local int i;

    if (ValidIndex(RuleIndex))
    {
        if (RuleIndex == SortData[Index].SortItem)
            return RemoveCurrentRule();

        i = GetListIndex(RuleIndex);

        Rules.Remove(RuleIndex, 1);
        SortData.Remove(i, 1);
        InvSortData.Remove(i, 1);

        ItemCount--;
        OnSortChanged();
    }

    return -1;
}

function int RemoveCurrentRule()
{
    local int OldItem;

    if (Index >= 0)
    {
        OldItem = SortData[Index].SortItem;
        if (ValidIndex(OldItem))
        {
            Rules.Remove(OldItem, 1);
            ItemCount--;
            RemovedCurrent();
            return OldItem;
        }
    }

    return -1;
}

function string GetSortString(int i)
{
    return GetRuleItem(i, SortColumn);
}

function Clear()
{
    if (Rules.Length > 0)
        Rules.Remove(0, Rules.Length);

    Super.Clear();
}

function string GetRuleItem(int RuleIndex, int ItemIndex)
{
    if (ValidIndex(RuleIndex) && ItemIndex >= 0 && ItemIndex < ColumnHeadings.Length)
    {
        switch (ItemIndex)
        {
            case 0: return Rules[RuleIndex].FilterItem.Key;
            case 1: return GetFriendlyName(Rules[RuleIndex].FilterItem.QueryType);
            case 2: return Rules[RuleIndex].FilterItem.Value;
        }
    }

    return "";
}

function bool ValidIndex(int i)
{
    return i >= 0 && i <= Rules.Length;
}

static final function string GetFriendlyName(MasterServerClient.EQueryType QueryType)
{
    switch (QueryType)
    {
        case QT_Equals:             return "Equals";
        case QT_NotEquals:          return "Is Not";
        case QT_LessThan:           return "Lower";
        case QT_LessThanEquals:     return "Or Lower";
        case QT_GreaterThan:        return "Higher";
        case QT_GreaterThanEquals:  return "Or Higher";
        default:                    return "Disabled";
    }

    return "";
}

defaultproperties
{
     ColumnHeadings(0)="Item Name"
     ColumnHeadings(1)="Filter"
     ColumnHeadings(2)="Value"
     SelectedStyleName="BrowserListSelection"
     OnDrawItem=UT2K4FilterSummaryList.InternalOnDrawItem
}
