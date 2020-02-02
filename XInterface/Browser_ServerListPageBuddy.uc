class Browser_ServerListPageBuddy extends Browser_ServerListPageMS;

// Actual list of buddies
var() config array<String> Buddies;

var GUISplitter		  MainSplit;
var GUISplitter		  BudSplit;
var Browser_BuddyList MyBuddyList;
var localized string AddBuddyCaption;
var localized string RemoveBuddyCaption;

var bool BuddyInitialized;

function InitComponent(GUIController C, GUIComponent O)
{
	Super.InitComponent(C, O);

	if( !BuddyInitialized )
	{
		MainSplit = GUISplitter(Controls[0]);

		// Set one half of the buddy splitter to be the servers panel
		BudSplit.Controls[1] = MainSplit.Controls[0];

		// Set the buddy splitter as one half of the main splitter
		MainSplit.Controls[0] = BudSplit;

		// Init the budsplit
		BudSplit.InitComponent(C, MainSplit);
	}

	MyBuddyList = Browser_BuddyList( GUIMultiColumnListBox(GUIPanel(BudSplit.Controls[0]).Controls[0]).Controls[0] );
	MyBuddyList.MyBuddyPage = self;
	MyBuddyList.ItemCount = Buddies.Length;

	// Change server list spacing a bit
	MyServersList.InitColumnPerc[0]=0.1;
	MyServersList.InitColumnPerc[1]=0.25;
	MyServersList.InitColumnPerc[2]=0.15;
	MyServersList.InitColumnPerc[3]=0.125;
	MyServersList.InitColumnPerc[4]=0.125;

	// This page has a REFRESH LIST button
	GUIButton(GUIPanel(Controls[1]).Controls[6]).OnClick=MyRefreshClick;
	GUIButton(GUIPanel(Controls[1]).Controls[6]).Caption=RefreshCaption;
	GUIButton(GUIPanel(Controls[1]).Controls[6]).bVisible=true;

	// take over the "Add Favorite" button for "Add Buddy".
	GUIButton(GUIPanel(Controls[1]).Controls[7]).OnClick=AddBuddyClick;
	GUIButton(GUIPanel(Controls[1]).Controls[7]).Caption=AddBuddyCaption;

	// add "Remove Buddy" button
	GUIButton(GUIPanel(Controls[1]).Controls[4]).OnClick=RemoveBuddyClick;
	GUIButton(GUIPanel(Controls[1]).Controls[4]).Caption=RemoveBuddyCaption;

	StatusBar.WinWidth=0.6;

	BuddyInitialized = True;
}

function bool MyRefreshClick(GUIComponent Sender)
{
	Super.MyRefreshClick(Sender);
	return true;
}

function RefreshList()
{
	local int i;
	local MasterServerClient.QueryData QD;

	MyServersList.Clear();

	// Construct query containing all buddy names
	i = Buddies.Length;
	MSC.Query.Length = i;

	for(i=0; i<Buddies.Length; i++)
	{
		QD.Key			= "buddy";
		QD.Value		= Buddies[i];
		QD.QueryType	= QT_Equals;
		MSC.Query[i] = QD;
	}

	// Run query
	MSC.StartQuery(CTM_Query);

	StatusBar.SetCaption(StartQueryString);
	SetTimer(0, false); // Stop it going back to ready from a previous timer!
}

// Add a new buddy to your list
function bool AddBuddyClick(GUIComponent Sender)
{
	if ( Controller.OpenMenu("xinterface.Browser_AddBuddy") )
		Browser_AddBuddy(Controller.TopPage()).MyBuddyPage = self;

	return true;
}

// Remove current buddy from your list
function bool RemoveBuddyClick(GUIComponent Sender)
{
	if(MyBuddyList.Index < 0 || MyBuddyList.Index >= Buddies.Length)
		return true;

	Buddies.Remove(MyBuddyList.Index, 1);

	MyBuddyList.ItemCount = Buddies.Length;

	SaveConfig();
	return true;
}

defaultproperties
{
     Begin Object Class=GUISplitter Name=BuddySplitter
         SplitOrientation=SPLIT_Horizontal
         SplitPosition=0.250000
         Background=Texture'Engine.DefaultTexture'
         Begin Object Class=GUIPanel Name=BuddyPanel
             Begin Object Class=GUIMultiColumnListBox Name=BuddyListBox
                 bVisibleWhenEmpty=True
                 Begin Object Class=Browser_BuddyList Name=TheBuddyList
                     OnPreDraw=TheBuddyList.InternalOnPreDraw
                     OnClick=TheBuddyList.InternalOnClick
                     OnRightClick=TheBuddyList.InternalOnRightClick
                     OnMousePressed=TheBuddyList.InternalOnMousePressed
                     OnMouseRelease=TheBuddyList.InternalOnMouseRelease
                     OnKeyEvent=TheBuddyList.InternalOnKeyEvent
                     OnBeginDrag=TheBuddyList.InternalOnBeginDrag
                     OnEndDrag=TheBuddyList.InternalOnEndDrag
                     OnDragDrop=TheBuddyList.InternalOnDragDrop
                     OnDragEnter=TheBuddyList.InternalOnDragEnter
                     OnDragLeave=TheBuddyList.InternalOnDragLeave
                     OnDragOver=TheBuddyList.InternalOnDragOver
                 End Object
                 Controls(0)=Browser_BuddyList'XInterface.Browser_ServerListPageBuddy.TheBuddyList'

                 OnCreateComponent=BuddyListBox.InternalOnCreateComponent
                 StyleName="ServerBrowserGrid"
                 WinHeight=1.000000
             End Object
             Controls(0)=GUIMultiColumnListBox'XInterface.Browser_ServerListPageBuddy.BuddyListBox'

         End Object
         Controls(0)=GUIPanel'XInterface.Browser_ServerListPageBuddy.BuddyPanel'

         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     BudSplit=GUISplitter'XInterface.Browser_ServerListPageBuddy.BuddySplitter'

     AddBuddyCaption="ADD BUDDY"
     RemoveBuddyCaption="REMOVE BUDDY"
}
