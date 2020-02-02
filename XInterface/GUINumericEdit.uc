// ====================================================================
//	Class: UT2K4UI. UT2NumericEdit
//
//  A Combination of an EditBox and 2 spinners
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUINumericEdit extends GUIMultiComponent
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Automated GUIEditBox MyEditBox;
var Automated GUISpinnerButton MySpinner;

var()	string				Value;
var()	bool				bLeftJustified;
var()	int					MinValue;
var()	int					MaxValue;
var()	int					Step;
var()   bool                bReadOnly;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if ( MinValue < 0 )
		MyEditBox.bIncludeSign = True;

	Super.InitComponent(MyController, MyOwner);

	MyEditBox.OnChange = EditOnChange;
	MyEditBox.SetText(Value);
	MyEditBox.OnKeyEvent = EditKeyEvent;
	MyEditBox.OnDeActivate = CheckValue;

	CalcMaxLen();

	MyEditBox.INIOption  = INIOption;
	MyEditBox.INIDefault = INIDefault;

	MySpinner.bNeverFocus = True;
	MySpinner.FocusInstead = MyEditBox;
	MySpinner.OnPlusClick = SpinnerPlusClick;
    MySpinner.OnMinusClick = SpinnerMinusClick;

	SetReadOnly(bReadOnly);

    SetHint(Hint);

}

function CalcMaxLen()
{
	local int digitcount,x;

	digitcount=1;
	x=10;
	while (x <= MaxValue)
	{
		digitcount++;
		x*=10;
	}

	MyEditBox.MaxWidth = DigitCount;
}

function SetValue(int V)
{
	if (v<MinValue)
		v=MinValue;

	if (v>MaxValue)
		v=MaxValue;

	MyEditBox.SetText( string(Clamp(V, MinValue, MaxValue)) );
}

function bool SpinnerPlusClick(GUIComponent Sender)
{
	SetValue(int(Value) + Step);
	return true;
}

function bool SpinnerMinusClick(GUIComponent Sender)
{
	SetValue(int(Value) - Step);
	return true;
}

function bool EditKeyEvent(out byte Key, out byte State, float delta)
{
	if ( (key==0xEC) && (State==3) )
	{
		SpinnerPlusClick(none);
		return true;
	}

	if ( (key==0xED) && (State==3) )
	{
		SpinnerMinusClick(none);
		return true;
	}

	return MyEditBox.InternalOnKeyEvent(Key,State,Delta);
}

function EditOnChange(GUIComponent Sender)
{
	Value = string(Clamp(int(MyEditBox.TextStr), MinValue, MaxValue));
    OnChange(Self);
}

function SetHint(string NewHint)
{
	local int i;
	Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetHint(NewHint);
}

function SetReadOnly(bool b)
{
	bReadOnly = b;
	MyEditBox.bReadOnly = b;
	if ( b )
	{
		DisableComponent(MySpinner);
	}
	else
	{
		EnableComponent(MySpinner);
	}
}

function CheckValue()
{
	SetValue(int(Value));
}

function SetFriendlyLabel( GUILabel NewLabel )
{
	Super.SetFriendlyLabel(NewLabel);

	if ( MyEditBox != None )
		MyEditbox.SetFriendlyLabel(NewLabel);

	if ( MySpinner != None )
		MySpinner.SetFriendlyLabel(NewLabel);
}

function ValidateValue()
{
	local int i;

	i = int(MyEditBox.TextStr);
	MyEditBox.TextStr = string(Clamp(i, MinValue, MaxValue));
	MyEditBox.bHasFocus = False;
}

defaultproperties
{
     Begin Object Class=GUIEditBox Name=cMyEditBox
         bIntOnly=True
         bNeverScale=True
         OnActivate=cMyEditBox.InternalActivate
         OnDeActivate=cMyEditBox.InternalDeactivate
         OnKeyType=cMyEditBox.InternalOnKeyType
         OnKeyEvent=cMyEditBox.InternalOnKeyEvent
     End Object
     MyEditBox=GUIEditBox'XInterface.GUINumericEdit.cMyEditBox'

     Begin Object Class=GUISpinnerButton Name=cMySpinner
         bTabStop=False
         bNeverScale=True
         OnClick=cMySpinner.InternalOnClick
         OnKeyEvent=cMySpinner.InternalOnKeyEvent
     End Object
     MySpinner=GUISpinnerButton'XInterface.GUINumericEdit.cMySpinner'

     Value="0"
     MinValue=-9999
     MaxValue=9999
     Step=1
     PropagateVisibility=True
     WinHeight=0.060000
     bAcceptsInput=True
     Begin Object Class=GUIToolTip Name=GUINumericEditToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUINumericEdit.GUINumericEditToolTip'

     OnDeActivate=GUINumericEdit.ValidateValue
}
