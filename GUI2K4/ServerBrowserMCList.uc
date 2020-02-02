//==============================================================================
//	Base class for server browser multi-column listboxes
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class ServerBrowserMCList extends GUIMultiColumnList;

var UT2K4Browser_ServerListPageBase tp_MyPage;

function SetAnchor(UT2K4Browser_ServerListPageBase Anchor)
{
	tp_MyPage = Anchor;
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending);

defaultproperties
{
     bVisibleWhenEmpty=True
     SelectedStyleName="BrowserListSelection"
     OnDrawItem=ServerBrowserMCList.MyOnDrawItem
     StyleName="ServerBrowserGrid"
     RenderWeight=1.000000
}
