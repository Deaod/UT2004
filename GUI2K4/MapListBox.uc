//==============================================================================
//	Container for maplists
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class MapListBox extends GUIListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	// TODO Assiging delegate in default properties here causes crash, for some reason
	ContextMenu.OnOpen = MyOpen;
	ContextMenu.OnClose = MyClose;
	ContextMenu.OnSelect = ContextClick;
}

function ContextClick(GUIContextMenu Sender, int Index)
{
	NotifyContextSelect(Sender, Index);
}

function bool MyRealOpen(GUIComponent MenuOwner)
{
	return false;
}

function bool MyOpen(GUIContextMenu Menu)
{
	return HandleContextMenuOpen(List, Menu, Menu.MenuOwner);
}

function bool MyClose(GUIContextMenu Sender)
{
	return HandleContextMenuClose(Sender);
}

defaultproperties
{
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Play This Map"
         ContextItems(1)="Spectate This Map"
         ContextItems(2)="-"
         ContextItems(3)="Add To Maplist"
         ContextItems(4)="Remove From Maplist"
         ContextItems(5)="Filter Maplist"
         StyleName="ServerListContextMenu"
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.MapListBox.RCMenu'

}
