//==============================================================================
//	Base class for all server browser multi-column listboxes
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class ServerBrowserMCListBox extends GUIMultiColumnListBox;

var UT2K4Browser_ServerListPageBase tp_Anchor;

function SetAnchor(UT2K4Browser_ServerListPageBase AnchorPage)
{
	tp_Anchor = AnchorPage;
	ServerBrowserMCList(List).SetAnchor(AnchorPage);
}

function bool InternalOnOpen(GUIContextMenu Menu)
{
	return HandleContextMenuOpen(List, Menu, Menu.MenuOwner);
}

function bool InternalOnClose(GUIContextMenu Sender)
{
	return HandleContextMenuClose(Sender);
}

defaultproperties
{
     bVisibleWhenEmpty=True
     IniOption="@Internal"
     StyleName="ServerBrowserGrid"
}
