//==============================================================================
//	Base class for tab panels which access playinfo information
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4PlayInfoPanel extends UT2K4TabPanel
	abstract;

var() int                               NumColumns;
var array<PlayInfo.PlayInfoData>        InfoRules;
var automated	GUIMultiOptionListBox   lb_Rules;
var				GUIMultiOptionList      li_Rules;
var() config bool                       bVerticalLayout;
var() editconst noexport PlayInfo       GamePI;
var() noexport bool                     bRefresh, bUpdate;
var() localized string                  EditText;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	lb_Rules.NumColumns = NumColumns;
	Super.InitComponent(MyC, MyO);

	li_Rules = lb_Rules.List;
	li_Rules.OnCreateComponent = InternalOnCreateComponent;
    li_Rules.bHotTrack = True;
}

function bool CanShowPanel()
{
	if (GamePI == None)
		return false;

	return Super.CanShowPanel();
}

// Called from the owning page when GameType has been changed or PlayInfo settings have been reloaded
function Refresh()
{
	GamePI.GetSettings(MyButton.Caption, InfoRules);
	ClearRules();
	LoadRules();
}

// This function is used to initialize the GUIMultiOptionList with the settings in PlayInfo
function LoadRules()
{
	if (bUpdate)
		UpdateRules();
}

// This function updates the values of the menu options of the GUIMultiOptionList
// with the correct values from PlayInfo
function UpdateRules()
{
	local int i, j;

    for (i = 0; i < li_Rules.Elements.Length; i++)
    {
        if ( GUIListSpacer(li_Rules.Elements[i]) != None )
            continue;

        j = li_Rules.Elements[i].Tag;

        // The index got corrupted - dump the contents of the our list to see what's going on
        // then crash the game to get our attention :>
        if (InfoRules[j].DisplayName != li_Rules.Elements[i].Caption)
            DumplistElements(i, j);

        Assert(InfoRules[j].DisplayName == li_Rules.Elements[i].Caption);

        li_Rules.Elements[i].SetHint(InfoRules[j].Description);

    // Update the value of the GUIMenuOption with the actual value in PlayInfo
        if (j < InfoRules.Length)
        	li_Rules.Elements[i].SetComponentValue(InfoRules[j].Value, True);

        // Assign the TabOrder so that user can tab properly between list elements
        li_Rules.Elements[i].TabOrder = i;
    }

	bRefresh = False;
	bUpdate = False;
}

function DumpListElements(int BadListIndex, int BadPlayInfoIndex)
{
    local int i;

    log("** DumpListElements **");
    log("Element["$BadListIndex$"] caption:"$li_Rules.Elements[BadListIndex].Caption@"Setting["$BadPlayInfoIndex$"] caption:"$GamePI.Settings[BadPlayInfoIndex].DisplayName);
    for (i = 0; i < li_Rules.Elements.Length; i++)
    {
        log(i$")"@li_Rules.Elements[i].Caption@li_Rules.Elements[i].Tag);
    }

    GamePI.Dump();
}

// Whoa ...
// Add a new rule to the GUIMultiOptionList
function AddRule(PlayInfo.PlayInfoData NewRule, int Index)
{
    local bool bTemp;
    local string        Width, Op;
    local array<string> Range;
    local moComboBox    co;
    local moFloatEdit   fl;
    local moEditBox     ed;
    local moCheckbox    ch;
    local moNumericEdit nu;
    local moButton      bu;
    local int           i, pos;

    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

    switch (NewRule.RenderType)
    {
        case PIT_Check:
            ch = moCheckbox(li_Rules.AddItem("XInterface.moCheckbox",,NewRule.DisplayName, True));
            if (ch == None)
                break;

            ch.Tag = Index;
            ch.bAutoSizeCaption = True;
            break;

        case PIT_Select:
            co = moCombobox(li_Rules.AddItem("XInterface.moComboBox",,NewRule.DisplayName, True));
            if (co == None)
                break;

            co.ReadOnly(True);
            co.bAutoSizeCaption = True;
            co.Tag = Index;
            co.CaptionWidth=0.5;
            GamePI.SplitStringToArray(Range, NewRule.Data, ";");
            for (i = 0; i+1 < Range.Length; i += 2)
                co.AddItem(Range[i+1],,Range[i]);

            break;

        case PIT_Text:
        	if ( !Divide(NewRule.Data, ";", Width, Op) )
        		Width = NewRule.Data;

            pos = InStr(Width, ",");
            if (pos != -1)
                Width = Left(Width, pos);

            if (Width != "")
                i = int(Width);
            else i = -1;
            GamePI.SplitStringToArray(Range, Op, ":");
            if (Range.Length > 1)
            {
                // Ranged data
                if (InStr(Range[0], ".") != -1)
                {
                    // float edit
                    fl = moFloatEdit(li_Rules.AddItem("XInterface.moFloatEdit",,NewRule.DisplayName, True));
                    if (fl == None) break;
                    fl.Tag = Index;
                    fl.bAutoSizeCaption = True;
                    fl.ComponentWidth = 0.25;
                    if (i != -1)
                        fl.Setup( float(Range[0]), float(Range[1]), fl.MyNumericEdit.Step);
                }

                else
                {
                    nu = moNumericEdit(li_Rules.AddItem("XInterface.moNumericEdit",,NewRule.DisplayName, True));
                    if (nu == None) break;
                    nu.Tag = Index;
                    nu.bAutoSizeCaption = True;
                    nu.ComponentWidth = 0.25;
                    if (i != -1)
                        nu.Setup( int(Range[0]), int(Range[1]), nu.MyNumericEdit.Step);
                }
            }
            else if (NewRule.ArrayDim != -1)
            {
                bu = moButton(li_Rules.AddItem("XInterface.moButton",,NewRule.DisplayName, True));
                if (bu == None) break;
                bu.Tag = Index;
                bu.bAutoSizeCaption = True;
                bu.ComponentWidth = 0.25;
                bu.OnChange = ArrayPropClicked;
            }

            else
            {
                ed = moEditbox(li_Rules.AddItem("XInterface.moEditBox",,NewRule.DisplayName, True));
                if (ed == None) break;
                ed.Tag = Index;
                ed.bAutoSizeCaption = True;
                if (i != -1)
                    ed.MyEditBox.MaxWidth = i;
            }
            break;

        default:
            bu = moButton(li_Rules.AddItem("XInterface.moButton",,NewRule.DisplayName, True));
            if (bu == None) break;
            bu.Tag = Index;
            bu.bAutoSizeCaption = True;
            bu.ComponentWidth = 0.25;
            bu.OnChange = CustomClicked;
    }

    Controller.bCurMenuInitialized = bTemp;
}

function AddGroupHeader(int PlayInfoIndex, bool InitialRow)
{
    local int ModResult, i;
    local GUIMenuOption mo;

    //  If the GUIMultiOptionList has more than one column, add a spacer component
    //  for each column until we are back to the first column
    if ( !li_Rules.bVerticalLayout )
    {
	    ModResult = li_Rules.Elements.Length % lb_Rules.NumColumns;
	    while (ModResult-- > 0)
	        li_Rules.AddItem( "XInterface.GUIListSpacer" );

	    if (!InitialRow)
	        for (i = 0; i < lb_Rules.NumColumns; i++)
	            li_Rules.AddItem( "XInterface.GUIListSpacer" );
	}

    // We are now at the first column - safe to add a header row
    mo = li_Rules.AddItem( "XInterface.GUIListHeader",, InfoRules[PlayInfoIndex].Grouping );
    if ( mo != None )
    	mo.bAutoSizeCaption = True;

	if ( !li_Rules.bVerticalLayout )
	{
	    i = 0;
	    while (++i < lb_Rules.NumColumns)
	    {
		    mo = li_Rules.AddItem( "XInterface.GUIListHeader" );
		    if ( mo != None )
		    	mo.bAutoSizeCaption = True;
		}
	}
}

function ClearRules()
{
	li_Rules.Clear();
}

function InternalOnActivate()
{
	if (bRefresh)
		Refresh();
	else if (bUpdate)
		UpdateRules();
}

function ListBoxCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIMultiOptionList(NewComp) != None)
    {
    	GUIMultiOptionList(NewComp).bVerticalLayout = bVerticalLayout;
        GUIMultiOptionList(NewComp).bDrawSelectionBorder = False;
        GUIMultiOptionList(NewComp).ItemPadding = 0.15;
    }

    if (Sender == lb_Rules)
        lb_Rules.InternalOnCreateComponent(NewComp, Sender);
}

function InternalOnCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
	if (Sender == li_Rules)
	{
		NewComp.ComponentJustification = TXTA_Right;
		NewComp.LabelJustification = TXTA_Left;
	    NewComp.CaptionWidth = 0.65;

	    if (moButton(NewComp) != None)
	    {
	        moButton(NewComp).ButtonStyleName = "SquareButton";
	        moButton(NewComp).ButtonCaption = EditText;
	    }
	}
}

function InternalOnChange(GUIComponent Sender)
{
	if (GUIMultiOptionList(Sender) != None)
	{
		if (Controller.bCurMenuInitialized)
			UpdateSetting(GUIMultiOptionList(Sender).Get());
	}

	else if ( GUIMenuOption(Sender) != None && Controller.bCurMenuInitialized )
		UpdateSetting( GUIMenuOption(Sender) );
}

function UpdateSetting(GUIMenuOption Sender)
{
    local int i;
    local int Index;

    if (Sender == None)
        return;

    i = Sender.Tag;
    if (i < 0)
        return;

    if (InfoRules[i].DisplayName != Sender.Caption)
    {
    	if ( Controller.bModAuthor )
		{
		   	log("Corrupt list index detected in component"@Sender.Name,'ModAuthor');
    		DumpListElements( FindComponentIndex(Sender), i );
    	}
    	return;
    }

    Index = GamePI.FindIndex(InfoRules[i].SettingName);
    if (InfoRules[i].DisplayName != Sender.Caption || Index == -1)
    {
    	if ( Controller.bModAuthor )
    	{
	    	log("Invalid setting requested from PlayInfo!",'ModAuthor');
	    	DumpListElements(FindComponentIndex(Sender), i);
	    }
    	return;
    }

    StoreSetting(Index, Sender.GetComponentValue());
}

protected function StoreSetting( int Index, string NewValue )
{
	GamePI.StoreSetting(Index, NewValue);
}

function ArrayPropClicked(GUIComponent Sender)
{
    local int i, Index;
    local GUIArrayPropPage ArrayPage;
    local string ArrayMenu;

    i = Sender.Tag;
    if (i < 0)
        return;

    Index = GamePI.FindIndex(InfoRules[i].SettingName);
	if ( GamePI.Settings[Index].ArrayDim > 1 )
		ArrayMenu = Controller.ArrayPropertyMenu;
	else ArrayMenu = Controller.DynArrayPropertyMenu;

    if (Controller.OpenMenu(ArrayMenu, GamePI.Settings[Index].DisplayName, GamePI.Settings[Index].Value))
    {
        ArrayPage = GUIArrayPropPage(Controller.ActivePage);
        ArrayPage.Item = GamePI.Settings[Index];
        ArrayPage.OnClose = CustomPageClosed;
        ArrayPage.SetOwner(Sender);
    }
}

function CustomClicked(GUIComponent Sender)
{
	local int i, Index;
	local GUICustomPropertyPage Page;
	local string CustomMenu;
	local array<string> Parts;

	i = Sender.Tag;
	if ( i < 0 )
		return;

	Index = GamePI.FindIndex( InfoRules[i].SettingName );
	Split(GamePI.Settings[Index].Data, ";", Parts);
	if ( Parts.Length > 2 )
	{
		CustomMenu = Parts[2];
		if ( Controller.OpenMenu(CustomMenu) )
		{
			Page = GUICustomPropertyPage(Controller.ActivePage);
			Page.Item = GamePI.Settings[Index];
			Page.OnClose = CustomPageClosed;
			Page.SetOwner(Sender);
		}
	}
}

function CustomPageClosed( optional bool bCancelled )
{
	local GUICustomPropertyPage Page;
	local GUIComponent CompOwner;

	Page = GUICustomPropertyPage(Controller.ActivePage);
	if ( Page != None && !bCancelled )
	{
		CompOwner = Page.GetOwner();
		if ( CompOwner != None && moButton(CompOwner) != None )
		{
			moButton(CompOwner).SetComponentValue( Page.GetDataString(), True );
			InternalOnChange(CompOwner);
		}
	}
}

function int FindComponentWithTag(int FindTag)
{
	local int i;

	for ( i = 0; i < li_Rules.Elements.Length; i++ )
	{
		if ( li_Rules.Elements[i].Tag == FindTag )
			return i;
	}

	return -1;
}

function int FindGroupIndex(string Group)
{
    local int i;

    for (i = 0; i < GamePI.Groups.Length; i++)
        if (GamePI.Groups[i] ~= Group)
            return i;

    return -1;
}

function Free()
{
	GamePI = None;
	Super.Free();
}

defaultproperties
{
     NumColumns=1
     Begin Object Class=GUIMultiOptionListBox Name=RuleListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=UT2K4PlayInfoPanel.ListBoxCreateComponent
         WinHeight=0.930009
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4PlayInfoPanel.InternalOnChange
     End Object
     lb_Rules=GUIMultiOptionListBox'GUI2K4.UT2K4PlayInfoPanel.RuleListBox'

     EditText="Edit"
     FadeInTime=0.250000
     OnActivate=UT2K4PlayInfoPanel.InternalOnActivate
}
