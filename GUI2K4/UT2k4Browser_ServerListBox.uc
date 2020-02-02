//====================================================================
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListBox extends ServerBrowserMCListBox;

var() config string OpenIPPage;

var bool bIconClick;
var float IconCounter;

var array<string> ContextItems;	// hack for localization
var int JOINIDX, SPECIDX, REPINGIDX, REFRESHIDX, FILTERIDX, TEMPLATEIDX, CLEARFILTERIDX, ADDFAVIDX, OPENIPIDX, COPYIDX;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super(GUIListBoxBase).InitComponent(MyController, MyOwner);
	ContextItems = ContextMenu.ContextItems;
}

function SetToolTipText( string NewToolTipText )
{
}

function bool PreDrawHint( Canvas C )
{
	local UT2K4Browser_ServersList L;
	local int IconW, i;
    local float XL, YL, MaxWidth, TotalHeight;
	local GUIStyles S;

	L = UT2K4Browser_ServersList(List);
	if ( L == None || Controller == None || !MousingOverIcons() || ToolTip == None || ToolTip.Style == None )
		return true;

	if ( ToolTip.bResetPosition || ToolTip.bTrackMouse )
	{
		S = ToolTip.Style;

		// Figure out the dimensions of the bounding box
		for ( i = 0; i < L.Icons.Length; i++ )
		{
			// Get the width of the icon
			IconW = L.Icons[i].MaterialUSize();
			S.TextSize(C, L.MenuState, L.IconDescriptions[i], XL, YL, L.FontScale);

			// Add a little space between the icon and the description
			XL += (IconW + 0.2 * float(IconW));
			if ( XL > MaxWidth )
				MaxWidth = XL;

			// If the height of the icon is larger than the height of the text, use the height of the icon instead
			YL = Max( YL, L.Icons[i].MaterialVSize() );
			TotalHeight += YL;
		}

		TotalHeight += S.BorderOffsets[1] + S.BorderOffsets[3];

		ToolTip.WinWidth = MaxWidth + S.BorderOffsets[0] + S.BorderOffsets[2];
		ToolTip.WinHeight = TotalHeight;
		ToolTip.WinTop = ToolTip.GetTop(C);
		ToolTip.WinLeft = ToolTip.GetLeft(C);
		ToolTip.bResetPosition = false;
	}

	return true;
}

function bool DrawHint( Canvas C )
{
	local GUIStyles S;
	local UT2K4Browser_ServersList L;
	local plane NormMod;

	local int i, IconW, IconH;
    local float X, Y, XL, YL;

	L = UT2K4Browser_ServersList(List);
	if ( L == None || Controller == None || !MousingOverIcons() || ToolTip == None || ToolTip.Style == None )
		return true;

	S = ToolTip.Style;

	X = ToolTip.WinLeft;
	Y = ToolTip.WinTop;
	XL = ToolTip.WinWidth;
	YL = ToolTip.WinHeight;

	// Draw the drop-shadow...a little off-center
	NormMod = C.ColorModulate;
	C.ColorModulate.W = 0.3; C.ColorModulate.X = 0.2; C.ColorModulate.Y = 0.2; C.ColorModulate.Z = 0.2;
	S.Draw(C, MSAT_Blurry, X + 2, Y + 2, XL, YL);

	// Restore the canvas modulation to previous value
	C.ColorModulate = NormMod;

	// Draw the background image
	S.Draw(C, MSAT_Blurry, X, Y, XL, YL);

	X += S.BorderOffsets[0];
	Y += S.BorderOffsets[1];

	for ( i = 0; i < L.Icons.Length; i++ )
	{
		// Figure out the width of the icon
		IconW = L.Icons[i].MaterialUSize();
		IconH = L.Icons[i].MaterialVSize();

		S.TextSize( C, L.MenuState, L.IconDescriptions[i], XL, YL, L.FontScale);
		YL = FMax( YL, IconH );


		// Draw the icon
		C.SetPos( X, Y );
		C.DrawTile( L.Icons[i], IconW, YL, 0, 0, IconW, IconH );

		// Draw the description

		S.DrawText(C, L.MenuState, X + IconW + 0.2 * float(IconW), Y, XL, YL, TXTA_Left, L.IconDescriptions[i], L.FontScale);
		Y += YL;
	}
	return true;
}


function bool MousingOverIcons()
{
    local float IconRight, IconLeft, IconWidth;

	if ( List == None || Controller == None )
		return false;

    List.GetCellLeftWidth( 0, IconLeft, IconWidth );
    IconRight = IconLeft + IconWidth;

    return Controller.MouseX >= IconLeft && Controller.MouseX <= IconRight;
}

function bool InternalOnOpen(GUIContextMenu Sender)
{
	Sender.ContextItems.Remove(0, Sender.ContextItems.Length);
	if ( List.IsValid() )
	{
		Sender.ContextItems = ContextItems;
		if ( class'LevelInfo'.static.IsDemoBuild() )
			RemoveFilterOptions(Sender);
	}
	else
	{
		Sender.ContextItems[0] = ContextItems[ADDFAVIDX];
		Sender.ContextItems[1] = ContextItems[OPENIPIDX];
	}

	return True;
}

function RemoveFilterOptions( GUIContextMenu Menu )
{
	local int i;

	for ( i = 0; i < Menu.ContextItems.Length; i++ )
		if ( Menu.ContextItems[i] == ContextItems[FILTERIDX] )
		{
			Menu.ContextItems.Remove(i,4);
			break;
		}
}

function InternalOnClick(GUIContextMenu Sender, int Index)
{
    local int i, idx;
    local bool bWasSuccess;
    local UT2K4Browser_ServersList L;

    L = UT2K4Browser_ServersList(List);
    if (Sender != None)
    {
    	if ( Sender.ContextItems[Index] == "-" )
    		Index++;

    	if ( NotifyContextSelect(Sender, Index) )
    		return;

        switch ( Sender.ContextItems[Index] )
        {
            case ContextItems[JOINIDX]:	// Join
                L.Connect(False);
                break;

            case ContextItems[SPECIDX]:	// Spectate
                L.Connect(True);
                break;

            case ContextItems[REPINGIDX]:	// Refresh Server Info
                idx = List.CurrentListId();
                tp_Anchor.PingServer(idx, PC_Clicked, L.Servers[idx]);
                break;

            case ContextItems[REFRESHIDX]:	// Refresh list
            	tp_Anchor.RefreshClicked();
            	break;

            case ContextItems[FILTERIDX]:	// Configure Filters
                tp_Anchor.FilterClicked();
                break;

            case ContextItems[TEMPLATEIDX]:	// Create Template
                idx = List.CurrentListId();

                if (idx >= 0 && Controller.OpenMenu(Controller.FilterMenu))
                    FilterPageBase(Controller.ActivePage).CreateTemplateFilter(L.Servers[idx].ServerName, L.Servers[idx].ServerInfo);

                break;

            case ContextItems[CLEARFILTERIDX]:	// Deactivate All Filters
                for (i = 0; i < tp_Anchor.FilterMaster.AllFilters.Length; i++)
                    if (tp_Anchor.FilterMaster.ActivateFilter(i, false))
                        bWasSuccess = True;

                if (bWasSuccess)
                {
                    tp_Anchor.FilterMaster.SaveFilters();
                    tp_Anchor.Refresh();
                }

                break;


            case ContextItems[ADDFAVIDX]:	// Add To Favorite
            	if ( L.IsValid() )
	                L.AddFavorite(tp_Anchor.Browser);
	            else if ( Controller.OpenMenu(Controller.EditFavoriteMenu) )
	            	Controller.ActivePage.OnClose = AddFavClosed;
                break;

            case ContextItems[COPYIDX]:
            	L.CopyServerToClipboard();
            	break;

            case ContextItems[OPENIPIDX]:	// Open IP
            	if ( L.IsValid() )
            		Controller.OpenMenu( OpenIPPage, L.Get() );
            	else
	            	Controller.OpenMenu( OpenIPPage );
            	break;
        }
    }
}

function AddFavClosed( bool bCancelled )
{
	tp_Anchor.Browser.OnAddFavorite(EditFavoritePage(Controller.ActivePage).Server);
}

function SetAnchor(UT2K4Browser_ServerListPageBase AnchorPage)
{
    Super.SetAnchor(AnchorPage);

    MyScrollBar.MyGripButton.OnMousePressed = tp_Anchor.MousePressed;
    MyScrollBar.MyGripButton.OnMouseRelease = tp_Anchor.MouseReleased;
}

function InitBaseList(GUIListBase LocalList)
{
    local GUIMultiColumnList L;

    L = GUIMultiColumnList(LocalList);

    if (L == None || List == LocalList)
        return;

    if (List != None)
    {
        List.SetTimer(0.0, False);
        RemoveComponent(List,true);
        AppendComponent(L,false);
        List = L;
    }
    else
    {
        List = L;
        AppendComponent(L,false);
    }

    Header.MyList = List;
    Super(GUIListBoxBase).InitBaseList(LocalList);
}

defaultproperties
{
     OpenIPPage="GUI2K4.UT2K4Browser_OpenIP"
     SPECIDX=1
     REPINGIDX=3
     REFRESHIDX=4
     FILTERIDX=6
     TEMPLATEIDX=7
     CLEARFILTERIDX=8
     ADDFAVIDX=10
     OPENIPIDX=12
     COPYIDX=11
     DefaultListClass="GUI2K4.UT2K4Browser_ServersList"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Join Server"
         ContextItems(1)="Join As Spectator"
         ContextItems(2)="-"
         ContextItems(3)="Refresh Server Info"
         ContextItems(4)="Refresh List"
         ContextItems(5)="-"
         ContextItems(6)="Configure Filters"
         ContextItems(7)="Create Template"
         ContextItems(8)="Deactivate All Filters"
         ContextItems(9)="-"
         ContextItems(10)="Add To Favorites"
         ContextItems(11)="Copy server address"
         ContextItems(12)="Open IP"
         OnOpen=UT2k4Browser_ServerListBox.InternalOnOpen
         OnClose=UT2k4Browser_ServerListBox.InternalOnClose
         OnSelect=UT2k4Browser_ServerListBox.InternalOnClick
         StyleName="ServerListContextMenu"
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.UT2k4Browser_ServerListBox.RCMenu'

     Begin Object Class=GUIToolTip Name=ServerListToolTip
         ExpirationSeconds=8.000000
         OnPreDraw=UT2k4Browser_ServerListBox.PreDrawHint
         OnDraw=UT2k4Browser_ServerListBox.DrawHint
     End Object
     ToolTip=GUIToolTip'GUI2K4.UT2k4Browser_ServerListBox.ServerListToolTip'

}
