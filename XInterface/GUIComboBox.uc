// ====================================================================
//  Class: UT2K4UI.GUIComboBox
//
//  A Combination of an EditBox, a Down Arrow Button and a ListBox
//
//  Written by Michel Comeau
//  Updated by Ron Prestenback
//  (c) 2002, 2003 Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIComboBox extends GUIMultiComponent
    Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()   bool        bReadOnly;
var()   bool        bValueReadOnly;
var()   bool        bIgnoreChangeWhenTyping;  // If not read-only, only accept OnChange when Enter is pressed
var()   bool        bShowListOnFocus;
var()   int         MaxVisibleItems;

var() editconst     int     Index;
var() editconst     string  TextStr;
var() editconst GUIList     List;

var Automated   GUIEditBox             Edit;
var Automated   GUIScrollButtonBase    MyShowListBtn;
var Automated   GUIListBox             MyListBox;

delegate OnShowList();	// Called when the list is shown
delegate OnHideList();	// Called when the list is hidden

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

    List              = MyListBox.List;
    List.OnChange     = ItemChanged;
    List.bHotTrack    = true;
    List.bHotTrackSound = false;
    List.OnClickSound = CS_Click;
    List.OnClick      = InternalListClick;
    List.OnInvalidate = InternalOnInvalidate;
    List.TextAlign    = TXTA_Left;
    MyListBox.Hide();

    Edit.OnChange           = TextChanged;
    Edit.OnMousePressed     = InternalEditPressed;
    Edit.INIOption          = INIOption;
    Edit.INIDefault         = INIDefault;
    Edit.bReadOnly          = bReadOnly;

    List.OnDeActivate = InternalListDeActivate;

    MyShowListBtn.OnClick = ShowListBox;
    MyShowListBtn.FocusInstead = List;
    SetHint(Hint);

}

function SetHint(string NewHint)
{
    Super.SetHint(NewHint);

	MyShowListBtn.SetHint(NewHint);
	Edit.SetHint(NewHint);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputKey iKey;

	if ( State == 3 )
	{
		iKey = EInputKey(Key);
	    if (iKey == IK_Down && Controller.ShiftPressed)
	    {
	        ShowListBox(Self);
	        return true;
	    }

	    if ( iKey == IK_Enter && !bReadOnly && !bValueReadOnly && bIgnoreChangeWhenTyping && TextStr != Edit.GetText() )
	    {
			TextStr = Edit.TextStr;
		    OnChange(self);
		}
	}

    return false;
}


function InternalListDeActivate()
{
	if ( bDebugging )
		log(Name@"ListDeactivate Edit.bPendingFocus: "$Edit.bPendingFocus);

    if (!Edit.bPendingFocus)
    	HideListBox();
}

function InternalOnInvalidate(GUIComponent Who)
{
	if ( bDebugging )
		log(Name@"Invalidate Who:"$Who);

    if ( Who != Controller.ActivePage )
        return;

    Edit.SetFocus(None);
    HideListBox();
}

function InternalEditPressed(GUIComponent Sender, bool bRepeat)
{
	if ( bDebugging )
		log(Name@"EditPressed MyListBox.bVisible:"@MyListBox.bVisible);

    if ( Edit.bReadOnly && !bRepeat )
    {
        if ( !MyListBox.bVisible )
        {
            Controller.bIgnoreNextRelease = true;
            ShowListBox(Self);
        }
        else
            HideListBox();
    }

    return;
}

function bool InternalListClick(GUIComponent Sender)
{
	if ( bDebugging )
		log(Name@"ListClick");

	if ( !bValueReadOnly )
    	List.InternalOnClick(Sender);

    Edit.SetFocus(none);
    HideListBox();
    return true;
}

function string InternalOnSaveIni(GUIComponent Sender)
{
    return OnSaveIni(Sender);
}

function InternalOnLoadIni(GUIComponent Sender, string S)
{
    OnLoadIni(Sender, S);
}

function HideListBox()
{
	if ( bDebugging )
		log(Name@"HideListBox");

	OnHideList();

	if ( Controller != None )
		MyShowListBtn.Graphic = Controller.ImageList[7];

    MyListBox.Hide();
    List.SilentSetIndex( List.FindIndex(TextStr) );
}

event SetVisibility(bool bIsVisible)
{
	local bool bTemp;

    Super(GUIComponent).SetVisibility(bIsVisible);

	bTemp = bDebugging;
	bDebugging = False;

    HideListBox();
    MyShowListBtn.SetVisibility(bIsVisible);
    Edit.SetVisibility(bIsVisible);

    bDebugging = bTemp;
}


function bool ShowListBox(GUIComponent Sender)
{
	if ( bDebugging )
		log(Name@"ShowListBox MyListBox.bVisible:"$MyListBox.bVisible);

	OnShowList();

    MyListBox.SetVisibility(!MyListBox.bVisible);
	if (MyListBox.bVisible)
		MyShowListBtn.Graphic = Controller.ImageList[2];
    else
	    MyShowListBtn.Graphic = Controller.ImageList[7];

    if (MyListBox.bVisible)
    {
        List.SetFocus(none);
        List.SetTopItem(List.Index);
    }

    return true;
}

function ItemChanged(GUIComponent Sender)
{
    Index = List.Index;
    SetText(List.Get());
    if ( !bReadOnly && !bValueReadOnly && bIgnoreChangeWhenTyping )
    {
    	TextStr = Edit.TextStr;
    	OnChange(Self);
    }
}

function TextChanged(GUIComponent Sender)
{
	if ( bValueReadOnly )
		Edit.TextStr = TextStr;
	else if ( bReadOnly || !bIgnoreChangeWhenTyping )
	{
		TextStr = Edit.TextStr;
	    OnChange(self);
	}
}

function SetText(string NewText, optional bool bListItemsOnly)
{
	local int i;

	i = List.FindIndex(NewText);
	if ( (bReadOnly || bListItemsOnly) && i < 0 )
		return;

	Edit.SetText(NewText);
	TextStr = Edit.TextStr;
}

function SetExtra(string NewExtra, optional bool bListItemsOnly)
{
	local int i;

	i = FindExtra(NewExtra);
	if (( bReadOnly || bListItemsOnly ) && i < 0 )
		return;

	Edit.SetText( List.GetItemAtIndex(i) );
}

function string Get()
{
	return Edit.GetText();
}

function string GetText()
{
    return Get();
}

function object GetObject()
{
    local string temp;

    temp = List.Get();

    if ( temp~=Edit.GetText() )
        return List.GetObject();

	return none;
}

function string GetExtra()
{
    local string temp;

    temp = List.Get();

    if ( temp~=Edit.GetText() )
        return List.GetExtra();

	return "";
}

function SetIndex(int I)
{
    List.SetIndex(i);
}

function int GetIndex()
{
    return List.Index;
}

function AddItem(string Item, Optional object Extra, Optional string Str)
{
    List.Add(Item,Extra,Str);
}

function RemoveItem(int Item, optional int Count)
{
    List.Remove(Item, Count);
}

function string GetItem(int index)
{
    return List.GetItemAtIndex(index);
}

function object GetItemObject(int index)
{
    return List.GetObjectAtIndex(index);
}

function string find(string Text, optional bool bExact, optional bool bExtra)
{
    return List.Find(Text,bExact, bExtra);
}

function int FindExtra(string Text, optional bool bExact)
{
    return List.FindExtra(Text, bExact);
}

function int FindIndex(string Test, optional bool bExact, optional bool bExtra, optional Object Obj)
{
    return List.FindIndex(Test, bExact, bExtra, Obj);
}

function int ItemCount()
{
    return List.ItemCount;
}

function ReadOnly(bool b)
{
    Edit.bReadOnly = b;
}

function InternalOnMousePressed(GUIComponent Sender, bool bRepeat)
{
    if (!bRepeat)
    {
    	if ( bDebugging )
    		log(Name@"MousePressed");

        ShowListBox(Sender);
    }
}

function Clear()
{
	List.Clear();
	if ( bReadOnly )
		Edit.SetText("");

	// Set my values directly, in case component's state prevented OnChange() events from being passed upwards
	TextStr = "";
	Index = -1;
}

function CenterMouse()
{
	if ( MyShowListBtn != None )
		MyShowListBtn.CenterMouse();

	else Super.CenterMouse();
}

function SetFriendlyLabel( GUILabel NewLabel )
{
	Super.SetFriendlyLabel(NewLabel);

	if ( Edit != None )
		Edit.SetFriendlyLabel(NewLabel);

	if ( MyShowListBtn != None )
		MyShowListBtn.SetFriendlyLabel(NewLabel);

	if ( MyListBox != None )
		MyListBox.SetFriendlyLabel(NewLabel);
}

function LoseFocus(GUIComponent Sender)
{
	if ( bDebugging )
		log(Name@"LoseFocus  Sender:"$Sender);

	Super.LoseFocus(Sender);
}

function bool FocusFirst( GUIComponent Sender )
{
	if ( Edit != None )
	{
		HideListBox();
		Edit.SetFocus(None);
		return true;
	}

	if ( bAcceptsInput )
	{
		Super(GUIComponent).SetFocus(None);
		return true;
	}

	return false;
}

function bool FocusLast( GUIComponent Sender )
{
	if ( Edit != None )
	{
		HideListBox();
		Edit.SetFocus(None);
		return true;
	}

	if ( bAcceptsInput )
	{
		Super(GUIComponent).SetFocus(None);
		return true;
	}

	return false;
}

defaultproperties
{
     MaxVisibleItems=8
     Index=-1
     Begin Object Class=GUIEditBox Name=EditBox1
         bNeverScale=True
         OnActivate=EditBox1.InternalActivate
         OnDeActivate=EditBox1.InternalDeactivate
         OnKeyType=EditBox1.InternalOnKeyType
         OnKeyEvent=EditBox1.InternalOnKeyEvent
     End Object
     Edit=GUIEditBox'XInterface.GUIComboBox.EditBox1'

     Begin Object Class=GUIComboButton Name=ShowList
         RenderWeight=0.600000
         bNeverScale=True
         OnKeyEvent=ShowList.InternalOnKeyEvent
     End Object
     MyShowListBtn=GUIComboButton'XInterface.GUIComboBox.ShowList'

     Begin Object Class=GUIListBox Name=ListBox1
         OnCreateComponent=ListBox1.InternalOnCreateComponent
         StyleName="ComboListBox"
         RenderWeight=0.700000
         bTabStop=False
         bVisible=False
         bNeverScale=True
     End Object
     MyListBox=GUIListBox'XInterface.GUIComboBox.ListBox1'

     PropagateVisibility=True
     WinHeight=0.060000
     bAcceptsInput=True
     Begin Object Class=GUIToolTip Name=GUIComboBoxToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUIComboBox.GUIComboBoxToolTip'

     OnKeyEvent=GUIComboBox.InternalOnKeyEvent
}
