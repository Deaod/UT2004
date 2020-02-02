//====================================================================
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListPageBuddy extends UT2K4Browser_ServerListPageMS;

// Actual list of buddies
var() config float			BuddySplitterPosition;
var() config array<String> 	Buddies;
var() config string			BuddyListBoxClass;

var GUISplitter					sp_Buddy;
var UT2K4Browser_BuddyListBox 	lb_Buddy;
var UT2K4Browser_BuddyList 		li_Buddy;

var localized string AddBuddyCaption, AddBuddyLabel;
var localized string RemoveBuddyCaption;
var localized string BuddyNameCaption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);
	lb_Buddy.SetAnchor(Self);
	li_Buddy = UT2K4Browser_BuddyList(lb_Buddy.List);
	li_Buddy.OnChange = BuddyListChanged;
	li_Buddy.OnRightClick = InternalOnRightClick;

	lb_Buddy.TabOrder = 0;
	lb_Server.TabOrder = 1;
	lb_Rules.TabOrder = 2;
	lb_Players.TabOrder = 3;

	for ( i = 0; i < Buddies.Length; i++ )
		li_Buddy.AddedItem();
}

event Opened( GUIComponent Sender )
{
	Super.Opened(Sender);

	Controller.AddBuddy = AddBuddy;
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if (bShow && bInit)
	{
		sp_Buddy.SplitterUpdatePositions();
		bInit = False;
	}
}

function Refresh()
{
	local int i;

	Super.Refresh();

	// Construct query containing all buddy names
	for(i=0; i<Buddies.Length; i++)
		AddQueryTerm("buddy", Buddies[i], QT_Equals);

	// Run query
	Browser.Uplink().StartQuery(CTM_Query);

	SetFooterCaption(StartQueryString);
	KillTimer(); // Stop it going back to ready from a previous timer!
}

function BuddyListChanged(GUIComponent Sender)
{
	// Add code here to highlight server for this buddy
}

function AddBuddy(optional string NewBuddy)
{
	if ( Controller.OpenMenu(Controller.RequestDataMenu, AddBuddyLabel, BuddyNameCaption) )
	{
		Controller.ActivePage.SetDataString(NewBuddy);
		Controller.ActivePage.OnClose = BuddyPageClosed;
	}
}

function BuddyPageClosed( bool bCancelled )
{
	local string s;

	if ( bCancelled )
		return;

	s = Controller.ActivePage.GetDataString();
	if ( s != "" )
	{
		if ( FindBuddyIndex(s) != -1 )
			return;

		Buddies[Buddies.Length] = s;
		li_Buddy.AddedItem();
		SaveConfig();
	}
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUISplitter(NewComp) != None)
	{
		// This splitter already has a panel
		if (GUISplitter(Sender).Panels[0] != None)
		{
			// This splitter is the main splitter
			if (UT2K4Browser_ServerListPageBuddy(Sender.MenuOwner) != None)
			{
				sp_Buddy = GUISplitter(NewComp);
				sp_Buddy.DefaultPanels[0] = "GUI2K4.UT2K4Browser_ServerListBox";
				sp_Buddy.DefaultPanels[1] = "XInterface.GUISplitter";
				sp_Buddy.WinTop=0;
				sp_Buddy.WinLeft=0;
				sp_Buddy.WinWidth=1.0;
				sp_Buddy.WinHeight=1.0;
				sp_Buddy.bNeverFocus=True;
				sp_Buddy.bAcceptsInput=True;
				sp_Buddy.RenderWeight=0;
				sp_Buddy.OnCreateComponent=InternalOnCreateComponent;
				sp_Buddy.OnLoadIni=InternalOnLoadIni;
				sp_Buddy.OnReleaseSplitter=InternalReleaseSplitter;
				sp_Buddy.SplitOrientation=SPLIT_Vertical;
			}

			// This is the second panel of sp_Buddy splitter
			else Super.InternalOnCreateComponent(NewComp, Sender);
		}

		else
			Super.InternalOnCreateComponent(NewComp, Sender);
	}

	else if (UT2K4Browser_BuddyListBox(NewComp) != None)
	{
		lb_Buddy = UT2K4Browser_BuddyListBox(NewComp);
	}

	else Super.InternalOnCreateComponent(NewComp, Sender);
}

function InternalOnLoadIni(GUIComponent Sender, string S)
{
	if (Sender == sp_Buddy)
		sp_Buddy.SplitPosition = BuddySplitterPosition;

	else Super.InternalOnLoadIni(Sender, S);
}

function InternalReleaseSplitter(GUIComponent Sender, float NewPos)
{
	if (Sender == sp_Buddy)
	{
		BuddySplitterPosition = NewPos;
		SaveConfig();
	}

	else Super.InternalReleaseSplitter(Sender, NewPos);
}

function int FindBuddyIndex( string BuddyName )
{
	local int i;

	for ( i = 0; i < Buddies.Length; i++ )
		if ( Buddies[i] ~= BuddyName )
			return i;

	return -1;
}

function ContextSelect( GUIContextMenu Sender, int Index )
{
	if ( !NotifyContextSelect(Sender, Index) )
	{
		switch ( Index )
		{
		case 0: AddBuddy(); break;
		case 1:
			if ( li_Buddy.IsValid() )
			{
				Buddies.Remove(li_Buddy.Index, 1);
				li_Buddy.RemovedCurrent();
				SaveConfig();
			}

			break;
		}
	}
}

defaultproperties
{
     BuddySplitterPosition=0.597582
     BuddyListBoxClass="GUI2K4.UT2K4Browser_BuddyListBox"
     AddBuddyCaption="ADD BUDDY"
     AddBuddyLabel="Add Buddy"
     RemoveBuddyCaption="REMOVE BUDDY"
     BuddyNameCaption="Buddy Name: "
     Begin Object Class=GUISplitter Name=HorzSplitter
         SplitOrientation=SPLIT_Horizontal
         DefaultPanels(0)="GUI2K4.UT2K4Browser_BuddyListBox"
         DefaultPanels(1)="XInterface.GUISplitter"
         OnReleaseSplitter=UT2k4Browser_ServerListPageBuddy.InternalReleaseSplitter
         OnCreateComponent=UT2k4Browser_ServerListPageBuddy.InternalOnCreateComponent
         IniOption="@Internal"
         WinHeight=1.000000
         RenderWeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         OnLoadINI=UT2k4Browser_ServerListPageBuddy.InternalOnLoadINI
     End Object
     sp_Main=GUISplitter'GUI2K4.UT2k4Browser_ServerListPageBuddy.HorzSplitter'

     MainSplitterPosition=0.184326
     DetailSplitterPosition=0.319135
     HeaderColumnSizes(0)=(ColumnSizes=(0.096562,0.493471,0.206944,0.102535,0.150000))
     HeaderColumnSizes(1)=(ColumnSizes=(0.498144,0.500000))
     HeaderColumnSizes(2)=(ColumnSizes=(0.473428,0.185665,0.226824,0.220000))
     PanelCaption="Buddy Browser"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Add Buddy"
         ContextItems(1)="Remove Buddy"
         OnSelect=UT2k4Browser_ServerListPageBuddy.ContextSelect
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.UT2k4Browser_ServerListPageBuddy.RCMenu'

}
