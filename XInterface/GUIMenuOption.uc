// ====================================================================
//  Class:  UT2K4UI.GUIMultiComponent
//
//  MenuOptions combine a label and any other component in to 1 single
//  control.  The Label is left justified, the control is right.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIMenuOption extends GUIMultiComponent
        Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(Option) editconst  bool   bIgnoreChange;          // Don't want an OnChange event
var(Option)   bool            bValueReadOnly;         // Value of this option cannot be modified by input
var(Option)   bool            bAutoSizeCaption;       // Extend CaptionWidth if caption is too long
var(Option)   bool            bHeightFromComponent;   // Get the Height of this component from the Component
var(Option)   bool            bFlipped;               // Draw the Component to the left of the caption
var(Option)   bool            bSquare;                // Use the Height for the Width
var(Option)   bool            bVerticalLayout;        // Layout controls vertically

var(Option)   eTextAlign      LabelJustification;     // How do we justify the label
var(Option)   eTextAlign      ComponentJustification; // How do we justify the label

var(Option)   float           CaptionWidth;           // How big should the Caption be
var(Option)   float           ComponentWidth;         // How big should the Component be (-1 = 1-CaptionWidth)

var(Option) localized  string Caption;                // Caption for the label
var(Option)   string          ComponentClassName;     // Name of the component to spawn
var(Option)   string          LabelFont;              // Name of the Font for the label
var(Option)   string          LabelStyleName;         // The Style for the label

var(Option)   Color           LabelColor;             // Color for the label
var(Option) editconst noexport        GUILabel        MyLabel;                // Holds the label
var(Option) editconst noexport        GUIComponent    MyComponent;            // Holds the component

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if (bVerticalLayout) StandardHeight *= 2;
    Super.Initcomponent(MyController, MyOwner);

    // Create the two components

    MyLabel = GUILabel(AddComponent("XInterface.GUILabel"));
    if (MyLabel==None)
    {
        log("Failed to create "@self@" due to problems creating GUILabel");
        return;
    }



    if (bFlipped)
    {
        if (LabelJustification==TXTA_Left)
            LabelJustification=TXTA_Right;

        else if (LabelJustification==TXTA_Right)
            LabelJustification=TXTA_Left;

        if (ComponentJustification==TXTA_Left)
            ComponentJustification=TXTA_Right;

        else if (ComponentJustification==TXTA_Right)
            ComponentJustification=TXTA_Left;
    }

    MyLabel.Caption     = Caption;
    if ( LabelStyleName == "" )
    {
    	MyLabel.TextColor = LabelColor;
    	MyLabel.TextFont = LabelFont;
    }
    else MyLabel.Style       = Controller.GetStyle(LabelStyleName,MyLabel.FontScale);
    MyLabel.FontScale   = FontScale;
    MyLabel.TextAlign   = LabelJustification;
    MyLabel.IniOption   = IniOption;
    MyLabel.bNeverScale = True;

    if (ComponentClassName == "")
        return;

    MyComponent = AddComponent(ComponentClassName);
    // Check for errors
    if (MyComponent == None)
    {
        log("Could not create requested menu component"@ComponentClassName);
        return;
    }

	SetHint(Hint);
    MyComponent.IniOption = IniOption;

    if (bHeightFromComponent && !bVerticalLayout)
        WinHeight = MyComponent.WinHeight;
    else
        MyComponent.WinHeight = WinHeight;

    MyComponent.OnChange = InternalOnChange;
    MyComponent.bTabStop = true;
    MyComponent.TabOrder = 1;
    MyComponent.bNeverScale = True;
    MyComponent.bNeverFocus = bNeverFocus;

	SetFriendlyLabel(MyLabel);
    if ( MenuState == MSAT_Disabled )
    {
    	MenuState = MSAT_Blurry;
    	DisableMe();
    }
}

// Used for MultiOptionLists

function SetComponentValue(coerce string NewValue, optional bool bNoChange);
function string GetComponentValue()
{
    return "";
}
// Reset component to default state
function ResetComponent()
{
    SetComponentValue(IniDefault);
}

function SetReadOnly( bool bValue )
{
	bValueReadOnly = bValue;
}

function SetHint(string NewHint)
{
	Super.SetHint(NewHint);

	MyLabel.SetHint(NewHint);
	MyComponent.SetHint(NewHint);
}

function SetCaption(string NewCaption)
{
    Caption = NewCaption;
    MyLabel.Caption = NewCaption;
}

// This is the function that the GUIMultiOptionList will call when this component has been clicked on,
// since it overrides the component's OnClick() delegate
// Return false to prevent the GUIMultiOptionList from passing the OnClick notification upwards
function bool MenuOptionClicked(GUIComponent Sender)
{
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
    if (Controller != None && Controller.bCurMenuInitialized)
    {
		if ( !bIgnoreChange )
			OnChange(Self);
	}

	bIgnoreChange = False;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender);

function CenterMouse()
{
	if ( MyComponent != None )
		MyComponent.CenterMouse();

	else Super.CenterMouse();
}

function SetFriendlyLabel( GUILabel NewLabel )
{
	Super.SetFriendlyLabel(NewLabel);

	if ( MyComponent != None )
		MyComponent.SetFriendlyLabel(NewLabel);
}

defaultproperties
{
     bAutoSizeCaption=True
     ComponentJustification=TXTA_Right
     CaptionWidth=0.500000
     ComponentWidth=-1.000000
     LabelFont="UT2MenuFont"
     LabelStyleName="TextLabel"
     LabelColor=(B=64,A=255)
     PropagateVisibility=True
     OnCreateComponent=GUIMenuOption.InternalOnCreateComponent
     WinTop=0.347656
     WinLeft=0.496094
     WinWidth=0.500000
     WinHeight=0.030000
     bAcceptsInput=True
     Begin Object Class=GUIToolTip Name=GUIMenuOptionToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUIMenuOption.GUIMenuOptionToolTip'

     OnClickSound=CS_Click
     bStandardized=True
     StandardHeight=0.030000
}
