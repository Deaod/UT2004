//==============================================================================
//	Combined component containing a button and a label.
//  If MenuClass is assigned, the OnClick delegate will be called when the button is clicked
//  and OnChange will be called once the page is closed
//
//  If MenuClass does not have a value, OnChange will be called when the button is clicked
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class moButton extends GUIMenuOption;

var(Option) string Value;
var(Option) localized string ButtonCaption, MenuTitle;
var(Option) string MenuClass;		// Class for the menu to open when user clicks the button
var(Option) string ButtonStyleName;
var(Option) noexport editconst GUIButton MyButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	MyButton = GUIButton(MyComponent);
	MyButton.OnClick = InternalOnClick;
	MyButton.Caption = ButtonCaption;
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	if ( bNoChange )
		bIgnoreChange = bNoChange;

	SetValue(NewValue);
	bIgnoreChange = False;
}

function string GetComponentValue()
{
	return Value;
}

function SetValue(string NewValue)
{
	if (Value == NewValue)
	{
		bIgnoreChange = False;
		return;
	}

	Value = NewValue;
	InternalOnChange(Self);
}

function ResetComponent()
{
	Value = "";
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == MyButton )
	{
		if ( MenuClass != "" )
		{
			if ( !OnClick(Self) )
				Controller.OpenMenu(MenuClass, MenuTitle, Value);

			Controller.ActivePage.OnClose = PageClosed;
			return true;
		}

		InternalOnChange(Self);
		return true;
	}

	return false;
}

function PageClosed( optional bool bCancelled )
{
	Value = Controller.ActivePage.GetDataString();
	InternalOnChange(Self);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	Super.InternalOnCreateComponent(NewComp, Sender);
	NewComp.StyleName = ButtonStyleName;
}

defaultproperties
{
     ButtonCaption="Edit"
     ButtonStyleName="SquareButton"
     CaptionWidth=0.800000
     ComponentClassName="XInterface.GUIButton"
     StandardHeight=0.040000
}
