//====================================================================
//  Parent: GUI
//   Class: UT2K4UI.GUIContextMenu
//    Date: 05-01-2003
//
//  Right-click context menu.
//
//  Written by Joe Wilcox
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIContextMenu extends GUIComponent
    native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var localized array<string>   ContextItems;                   // List of menu items
var int             ItemIndex;              // Selected item
var string          SelectionStyleName;     // Name of the Style to use
var GUIStyles       SelectionStyle;         // Holds the style
var int             ItemHeight;

delegate bool OnOpen(GUIContextMenu Sender);  // Return false to prevent menu from appearing
delegate bool OnClose(GUIContextMenu Sender);      // Return false to prevent menu from closing
delegate OnSelect(GUIContextMenu Sender, int ClickIndex);

// Return false to override default behavior
// ( here is where an item is selected & highlighted )
delegate bool OnContextHitTest(float MouseX, float MouseY);

function int AddItem(string NewItem)
{
    local int Index;

    Index = ContextItems.Length;
    ContextItems[Index] = NewItem;
    return Index;
}

function int InsertItem(string NewItem, int Index)
{
    if (Index >= ContextItems.Length)
        return AddItem(NewItem);

    if (Index <0)
        return -1;

    ContextItems.Insert(Index, 1);
    ContextItems[Index] = NewItem;
    return Index;
}

function bool RemoveItemByName(string ItemName)
{
    local int Index;
    for (Index=0;Index<ContextItems.Length;Index++)
        if (ContextItems[Index] ~= ItemName)
        {
            ContextItems.Remove(Index,1);
            return true;
        }

    return false;
}

function bool RemoveItemByIndex(int Index)
{
    if (Index>=0 && Index<ContextItems.Length)
    {
        ContextItems.Remove(Index,1);
        return true;
    }

    return false;
}

function bool ReplaceItem( int Index, string NewItem )
{
	if ( RemoveItemByIndex(Index) )
		return InsertItem(NewItem, Index) > 0;

	return false;

}

defaultproperties
{
     SelectionStyleName="ListSelection"
     FontScale=FNS_Small
     StyleName="ContextMenu"
}
