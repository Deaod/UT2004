// ====================================================================
//  Class:  UT2K4UI.GUIListBoxBase
//
//  The GUIListBoxBase is a wrapper for a GUIList and it's ScrollBar
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIListBoxBase extends GUIMultiComponent
        Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Styles
var()           string              SelectedStyleName;      // For propagating selected style to the list
var()           string              SectionStyleName;       // For propagating section style to the list
var()           string              OutlineStyleName;       // For propagating outline styles to the list

var()           string              DefaultListClass;
var automated GUIScrollBarBase      MyScrollBar;
var() editconst                     GUIListBase         MyList;
var()           bool                bVisibleWhenEmpty;      // List box is visible when empty.
var()           bool                bSorted;
var()           bool                bInitializeList;		// Propagated to list

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local bool bTemp;

    // Delay propagation until InitBaseList
    bTemp = PropagateVisibility;
    PropagateVisibility = False;

    Super.InitComponent(MyController, MyOwner);

    PropagateVisibility = bTemp;
}

function InitBaseList(GUIListBase LocalList)
{
    MyList = LocalList;

	LocalList.bNeverScale = True;
    LocalList.StyleName = StyleName;
    LocalList.bVisibleWhenEmpty = bVisibleWhenEmpty;
    LocalList.MyScrollBar = MyScrollBar;
    LocalList.bInitializeList = bInitializeList;
    LocalList.bSorted = bSorted;
    LocalList.FontScale = FontScale;

    MyScrollBar.bTabStop = false;
    MyScrollBar.SetList(LocalList);

    SetVisibility(bVisible);
    SetHint(Hint);
}

function SetHint(string NewHint)
{
    local int i;

    Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
        Controls[i].SetHint(NewHint);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIListBase(NewComp) != None)
    {
	    GUIListBase(NewComp).bInitializeList = bInitializeList;
        if (StyleName != "")
            NewComp.StyleName = StyleName;
        if (SelectedStyleName != "")
            GUIListBase(NewComp).SelectedStyleName = SelectedStyleName;
        if (SectionStyleName != "")
            GUIListBase(NewComp).SectionStyleName = SectionStyleName;
        if (OutlineStyleName != "")
            GUIListBase(NewComp).OutlineStyleName = OutlineStyleName;
    }
}

function SetFriendlyLabel( GUILabel NewLabel )
{
	Super.SetFriendlyLabel(NewLabel);

	if ( MyList != None )
		MyList.SetFriendlyLabel(NewLabel);

	if ( MyScrollBar != None )
		MyScrollBar.SetFriendlyLabel(NewLabel);
}

defaultproperties
{
     SectionStyleName="ListSection"
     Begin Object Class=GUIVertScrollBar Name=TheScrollbar
         bVisible=False
         OnPreDraw=TheScrollbar.GripPreDraw
     End Object
     MyScrollBar=GUIVertScrollBar'XInterface.GUIListBoxBase.TheScrollbar'

     bInitializeList=True
     PropagateVisibility=True
     OnCreateComponent=GUIListBoxBase.InternalOnCreateComponent
     FontScale=FNS_Small
     StyleName="NoBackground"
     bAcceptsInput=True
     Begin Object Class=GUIToolTip Name=GUIListBoxBaseToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUIListBoxBase.GUIListBoxBaseToolTip'

}
