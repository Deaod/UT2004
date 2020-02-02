// ====================================================================
//  GUITabControl - This control has a number of tabs
//
//  Written by Joe Wilcox
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
//
//  Updated by Ron Prestenback
// ====================================================================

class GUITabControl extends GUIMultiComponent
    Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()   bool                bFillSpace;    // Tab buttons should be resized if cumulative width is smaller than WinWidth
var()   bool                bDockPanels;   // If true, associated panels will dock vertically with this control
var()   bool                bDrawTabAbove; // If true, tabs are drawn above the tab panels

var()   bool                bFillBackground;
var()   color               FillColor;

var()   float               FadeInTime;
var()   float               TabHeight;

var()   string              BackgroundStyleName;
var()   Material            BackgroundImage;

var() editconst noexport   array<GUITabButton> TabStack;
var() editconst noexport   GUITabButton        ActiveTab, PendingTab;
var() editconst noexport   GUIStyles           BackgroundStyle;
var() editconst noexport   GUIBorder           MyFooter;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    if (BackgroundStyleName != "")
        BackgroundStyle = Controller.GetStyle(BackgroundStyleName,FontScale);

    OnKeyEvent = InternalOnKeyEvent;
}

event Opened( GUIComponent Sender )
{
	local int i;

	Super.Opened(Sender);
	for ( i = 0; i < TabStack.Length; i++ )
	{
		if ( TabStack[i] != None )
			TabStack[i].Opened(Self);
	}

	if ( !bInit && bVisible && ActiveTab != None && ActiveTab.MyPanel != None )
		ActivateTab(ActiveTab, True);

	bInit = false;
}

event Closed( GUIComponent Sender, bool bCancelled )
{
	local int i;

	Super.Closed(Sender,bCancelled);

	for ( i = 0; i < TabStack.Length; i++ )
		if ( TabStack[i] != None )
			TabStack[i].Closed(Sender,bCancelled);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local int i,aTabIndex, StartIndex;

    if ( (FocusedControl!=None) || (TabStack.Length<=0) )
        return false;

    if (ActiveTab == None)
        return false;

    for(i=0;i<TabStack.Length;i++)
    {
        if (TabStack[i]==ActiveTab)
        {
            aTabIndex = i;
            break;
        }
    }

    if ( Key==0x25 && State == 1 )  // Left
    {
        StartIndex = aTabIndex;
        while (true)
        {
            if (aTabIndex==0)
                aTabIndex=TabStack.Length-1;
            else
                aTabIndex--;

			// Send false for bFocusPanel to ActivateTab here to continue using left/right
            if (aTabIndex == StartIndex || ActivateTab(TabStack[aTabIndex], False))
                break;
        }
        return true;

    }

    if ( Key==0x27 && State == 1 )  // Right
    {
        StartIndex = aTabIndex;
        while (true)
        {
            aTabIndex++;
            if (aTabIndex==TabStack.Length)
                aTabIndex=0;

 			// Send false for bFocusPanel to ActivateTab here to continue using left/right
           if (StartIndex == aTabIndex || ActivateTab(TabStack[aTabIndex], False))
                break;
        }
        return true;
    }

    return false;
}

function GUITabPanel AddTabItem( GUITabItem Item )
{
	return AddTab( Item.Caption, Item.ClassName, ,Item.Hint );
}

function GUITabPanel AddTab(string InCaption, string PanelClass, optional GUITabPanel ExistingPanel, optional string InHint, optional bool bForceActive)
{
    local class<GUITabPanel> NewPanelClass;

    local GUITabButton NewTabButton;
    local GUITabPanel  NewTabPanel;

    local int i;

    // Make sure this doesn't exist first
    for (i=0;i<TabStack.Length;i++)
    {
        if (TabStack[i].Caption ~= InCaption)
        {
            log("A tab with the caption"@InCaption@"already exists.");
            return none;
        }
    }

    if (ExistingPanel==None)
        NewPanelClass = class<GUITabPanel>(Controller.AddComponentClass(PanelClass));

    if ( (ExistingPanel!=None) || (NewPanelClass != None) )
    {
        if (ExistingPanel != None)
            NewTabPanel = GUITabPanel(AppendComponent(ExistingPanel,True));
        else if (NewPanelClass != None)
            NewTabPanel = GUITabPanel(AddComponent(PanelClass,True));

        if (NewTabPanel == None)
        {
            log("Could not create panel for"@NewPanelClass);
            return None;
        }

        if (NewTabPanel.MyButton != None)
            NewTabButton = NewTabPanel.MyButton;
        else
        {
            NewTabButton = new class'GUITabButton';
            if (NewTabButton==None)
            {
                log("Could not create tab for"@NewPanelClass);
                return None;
            }

            NewTabButton.InitComponent(Controller, Self);
            NewTabButton.Opened(Self);
            NewTabPanel.MyButton = NewTabButton;
            if (!bDrawTabAbove)
            {
                NewTabPanel.MyButton.bBoundToParent = False;
                NewTabPanel.MyButton.Style = Controller.GetStyle("FlippedTabButton",NewTabPanel.FontScale);
            }
        }

        NewTabPanel.MyButton.Hint           = Eval(InHint != "", InHint, NewTabPanel.Hint);
        NewTabPanel.MyButton.Caption        = Eval(InCaption != "", InCaption, NewTabPanel.PanelCaption);
        NewTabPanel.MyButton.OnClick        = InternalTabClick;
        NewTabPanel.MyButton.MyPanel        = NewTabPanel;
        NewTabPanel.MyButton.FocusInstead   = self;
        NewTabPanel.MyButton.bNeverFocus    = true;

        NewTabPanel.InitPanel();

        // Add the tab to controls
        TabStack[TabStack.Length] = NewTabPanel.MyButton;
        if ( (TabStack.Length==1 && bVisible) || (bForceActive) )
            ActivateTab(NewTabPanel.MyButton,true);
        else NewTabPanel.Hide();

        return NewTabPanel;

    }

    return none;
}

function GUITabPanel InsertTab(int Pos, string Caption, string PanelClass, optional GUITabPanel ExistingPanel, optional string InHint, optional bool bForceActive)
{
    local class<GUITabPanel> NewPanelClass;
    local GUITabPanel NewTabPanel;
    local GUITabButton NewTabButton;

    if (ExistingPanel == None)
        NewPanelClass = class<GUITabPanel>(Controller.AddComponentClass(PanelClass));

    if ( ExistingPanel != None || NewPanelClass != None)
    {
        if (ExistingPanel != None)
            NewTabPanel = GUITabPanel(AppendComponent(ExistingPanel,True));
        else if (NewPanelClass != None)
            NewTabPanel = GUITabPanel(AddComponent(PanelClass,True));

        if (NewTabPanel == None)
        {
            log("Could not create panel for"@NewPanelClass);
            return None;
        }

        if (NewTabPanel.MyButton != None)
            NewTabButton = NewTabPanel.MyButton;

        else
        {
            NewTabButton = new class'GUITabButton';
            if (NewTabButton==None)
            {
                log("Could not create tab for"@NewPanelClass);
                return None;
            }

            NewTabButton.InitComponent(Controller, Self);
            NewTabButton.Opened(Self);
            NewTabPanel.MyButton = NewTabButton;
        }


        NewTabPanel.MyButton.Caption = Caption;
        NewTabPanel.MyButton.Hint = InHint;
        NewTabPanel.MyButton.OnClick = InternalTabClick;
        NewTabPanel.MyButton.MyPanel = NewTabPanel;
        NewTabPanel.MyButton.FocusInstead = self;
        NewTabPanel.MyButton.bNeverFocus = true;
        NewTabPanel.InitPanel();

        TabStack.Insert(Pos, 1);
        TabStack[Pos] = NewTabPanel.MyButton;
        if (TabStack.Length==1 || bForceActive)
            ActivateTab(NewTabPanel.MyButton,true);
        else NewTabPanel.Hide();

        return NewTabPanel;
    }

    return None;
}

function GUITabPanel ReplaceTab(GUITabButton Which, string Caption, string PanelClass, optional GUITabPanel ExistingPanel, optional string InHint, optional bool bForceActive)
{
    local class<GUITabPanel> NewPanelClass;

    local GUITabPanel  NewTabPanel, OldTabPanel;

    if (ExistingPanel==None)
        NewPanelClass = class<GUITabPanel>(Controller.AddComponentClass(PanelClass));

    if ( (ExistingPanel!=None) || (NewPanelClass != None) )
    {

        OldTabPanel = Which.MyPanel;

        if (ExistingPanel==None)
            NewTabPanel = GUITabPanel(AddComponent(PanelClass, True));
        else
            NewTabPanel = GUITabPanel(AppendComponent(ExistingPanel, True));

        if (NewTabPanel==None)
        {
            log("Could not create panel"@NewPanelClass);
            return none;
        }

        Which.Caption           = Caption;
        Which.Hint              = InHint;
        Which.MyPanel           = NewTabPanel;
        NewTabPanel.MyButton    = Which;

        // Init new panel
        NewTabPanel.InitPanel();

        // Make sure to notify old tab - so use ActivateTab
        if ( bForceActive )
            ActivateTab(NewTabPanel.MyButton, True);
        else NewTabPanel.Hide();

        // Notify old panel
        RemoveComponent(OldTabPanel);
        OldTabPanel.Free();

        return NewTabPanel;

    }

    return none;
}

function RemoveTab(optional string Caption, optional GUITabButton who)
{
    local int i;
    local bool bActive;
    local GUITabPanel OldPanel;

    if ( (caption=="") && (Who==None) )
        return;

    if (Who==None)
        i = TabIndex(Caption);
    else i = TabIndex(Who.Caption);

    if (i < 0)
        return;

    OldPanel = TabStack[i].MyPanel;
    bActive = TabStack[i] == ActiveTab;
    TabStack[i].OnClick = None;
    TabStack[i].Free();
    TabStack.Remove(i, 1);

    RemoveComponent(OldPanel,True);
    OldPanel.Free();

    if (bActive)
        LostActiveTab();
}

function bool LostActiveTab()
{
    local int i;

    if (!Controller.bCurMenuInitialized)
        return false;

    for (i = 0; i < TabStack.Length; i++)
        if (ActivateTab(TabStack[i],true))
            return true;

    return false;
}

event MakeTabActive(GUITabButton Who)
{
	if (ActiveTab!=None)
    	ActiveTab.ChangeActiveState(false,false);

	PendingTab = None;
    ActiveTab = Who;
    OnChange(Who);
}

function bool ActivateTab(GUITabButton Who, bool bFocusPanel)
{

    if (Who == none || PendingTab != None || !Who.CanShowPanel())     // null or not selectable
        return false;

	Who.bForceFlash = False;
    if (Who==ActiveTab) // Same Tab, just accept
    {
        if ( ActiveTab.ChangeActiveState(True, bFocusPanel) )
	        return true;

	    return false;
    }

    PendingTab = Who;
    if ( PendingTab.ChangeActiveState(True, bFocusPanel) )
    {
	    if (PendingTab.MyPanel.FadeInTime==0.0 || TabStack.Length<2)
	    	MakeTabActive(Who);

	    else
	    {
	    	FadeInTime = PendingTab.MyPanel.FadeInTime;
	        if (!Controller.bQuietMenu)
		        PlayerOwner().PlayOwnedSound(Controller.FadeSound,SLOT_Interface,1.0);
	    }

	    return true;
	}

	PendingTab = None;
    return false;
}

function bool ActivateTabByName(string tabname, bool bFocusPanel)
{
    local int i;

    i = TabIndex(TabName);
    if (i < 0 || i >= TabStack.Length) return false;
    return ActivateTab(TabStack[i], bFocusPanel);
}

function bool ActivateTabByPanel( GUITabPanel Panel, bool bFocusPanel )
{
	local int i;

	if ( Panel == None || !Panel.CanShowPanel() )
		return false;

	for ( i = 0; i < TabStack.Length; i++ )
		if ( TabStack[i] != None && TabStack[i].MyPanel == Panel )
			return ActivateTab(TabStack[i], bFocusPanel);

	return false;
}

function bool InternalTabClick(GUIComponent Sender)
{
    local GUITabButton But;

    But = GUITabButton(Sender);
    if (But==None)
        return false;

    ActivateTab(But,true);
    return true;
}

event bool NextPage()
{
    local int i;

    // If 1 or no tabs in the stack, then query parents
    if (TabStack.Length < 2)
        return Super.NextPage();

    if (ActiveTab == None)
        i = 0;
    else
    {
        i = TabIndex(ActiveTab.Caption) + 1;
        if ( i >= TabStack.Length )
            i = 0;
    }
    return ActivateTab(TabStack[i], true);
}

event bool PrevPage()
{
    local int i;

    if (TabStack.Length < 2)
        return Super.PrevPage();

    if (ActiveTab == None)
        i = TabStack.Length - 1;
    else
    {
        i = TabIndex(ActiveTab.Caption) - 1;
        if ( i < 0 )
            i = TabStack.Length - 1;
    }
    return ActivateTab(TabStack[i], true);
}

event bool NextControl(GUIComponent Sender)
{

    if (Sender != None)
	{
    	Super(GUIComponent).SetFocus(None);
    	return true;
	}
    else
    {
    	if ( Super(GUIComponent).NextControl(Self) )
    		return true;

    	else FocusFirst(None);
    	return true;
    }

    return false;
}

event bool PrevControl(GUIComponent Sender)
{

    if ( Sender != None )
	{
		Super(GUIComponent).SetFocus(None);
		return true;
	}
	else
	{
		if ( Super(GUIComponent).PrevControl(Self) )
			return true;

		else FocusLast(None);
	}

    return false;
}

function int TabIndex(string TabName)
{
    local int i;

    for (i = 0; i < TabStack.Length; i++)
        if (TabStack[i].Caption ~= TabName)
            return i;

    return -1;
}

function GUITabPanel FindPanelClass( class<GUITabPanel> PanelClass )
{
	local int i;

	if ( PanelClass == None )
		return None;

	for ( i = 0; i < TabStack.Length; i++ )
	{
		if ( TabStack[i] != None && TabStack[i].MyPanel != None &&
		     ClassIsChildOf(TabStack[i].MyPanel.Class, PanelClass) )

		return TabStack[i].MyPanel;
	}

	return None;
}

function GUITabPanel BorrowPanel(string Caption)
{
    local int i;

    if (Caption == "")  return None;

    i = TabIndex(Caption);
    if (i < 0) return None;
    return TabStack[i].MyPanel;
}

function SetVisibility(bool bIsVisible)
{
    Super.SetVisibility(bIsVisible);

    if (ActiveTab != None)
        ActiveTab.ChangeActiveState(bIsVisible, False);
}

function InternalOnActivate()
{
    if (ActiveTab == None)
        LostActiveTab();
}

function bool FocusFirst(GUIComponent Sender)
{
	if ( ActiveTab != None && ActiveTab.MyPanel != None && ActiveTab.MyPanel.CanAcceptFocus() && ActiveTab.MyPanel.FocusFirst(None) )
		return true;

	else if (!Super.FocusFirst(Sender))
		Super(GUIComponent).SetFocus(None);

	return true;
}

function bool FocusLast(GUIComponent Sender)
{
	if ( ActiveTab != None && ActiveTab.MyPanel != None && ActiveTab.MyPanel.CanAcceptFocus() && ActiveTab.MyPanel.FocusLast(None) )
		return true;

	else if ( !Super.FocusLast(Sender) )
		Super(GUIComponent).SetFocus(None);

	return true;
}

function CenterMouse()
{
	if ( ActiveTab != None )
		ActiveTab.CenterMouse();

	else Super.CenterMouse();
}

event Free()
{
	local int i;

	for ( i = 0; i < TabStack.Length; i++ )
	{
		if ( TabStack[i] != None )
			TabStack[i].Free();
	}

	Super.Free();
}

function LevelChanged()
{
	local int i;

	for ( i = 0; i < TabStack.Length; i++ )
	{
		if ( TabStack[i] != None )
			TabStack[i].LevelChanged();
	}

	Super.LevelChanged();
}

defaultproperties
{
     bDrawTabAbove=True
     TabHeight=0.080000
     OnActivate=GUITabControl.InternalOnActivate
}
