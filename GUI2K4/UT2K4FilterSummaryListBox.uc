//==============================================================================
//	Listbox for a filter summary list
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4FilterSummaryListBox extends GUIMultiColumnListBox;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	HeaderColumnPerc = UT2K4FilterSummaryPanel(MyO).HeaderColumnPerc;
	Super.InitComponent(MyC, MyO);
}

defaultproperties
{
     DefaultListClass="GUI2K4.UT2K4FilterSummaryList"
     StyleName="ServerBrowserGrid"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Remove this rule"
         ContextItems(1)="Edit this rule"
         ContextItems(2)="-"
         ContextItems(3)="Apply changes"
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.UT2K4FilterSummaryListBox.RCMenu'

}
