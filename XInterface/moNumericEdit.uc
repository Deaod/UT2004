// ====================================================================
//  Class:  UT2K4UI.moNumericEdit
//  Parent: UT2K4UI.GUIMenuOption
//
//  <Enter a description here>
// ====================================================================

class moNumericEdit extends GUIMenuOption;

var(Option)		int				MinValue, MaxValue, Step;
var(Option) editconst noexport	GUINumericEdit	MyNumericEdit;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	MyNumericEdit = GUINumericEdit(MyComponent);
	MyNumericEdit.MinValue = MinValue;
	MyNumericEdit.MaxValue = MaxValue;
	MyNumericEdit.Step = Step;

	MyNumericEdit.CalcMaxLen();
	MyNumericEdit.OnChange = InternalOnChange;
	MyNumericEdit.SetReadOnly(bValueReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	if ( bNoChange )
		bIgnoreChange = True;

	SetValue(NewValue);
	bIgnoreChange = False;
}

function string GetComponentValue()
{
	return string(GetValue());
}

function SetValue(coerce int V)
{
	MyNumericEdit.SetValue(v);
}

function int GetValue()
{
	return int(MyNumericEdit.Value);
}

function Setup(coerce int NewMin, coerce int NewMax, coerce int NewStep)
{
	MinValue = NewMin;
	MaxValue = NewMax;
	Step     = NewStep;

	MyNumericEdit.MinValue = MinValue;
	MyNumericEdit.MaxValue = MaxValue;
	MyNumericEdit.Step     = Step;

	MyNumericEdit.MyEditBox.bIncludeSign = NewMin < 0;
	MyNumericEdit.CalcMaxLen();

	SetValue( Clamp(GetValue(), NewMin, NewMax) );
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MyNumericEdit.SetReadOnly(b);
}

defaultproperties
{
     MinValue=-9999
     MaxValue=9999
     Step=1
     ComponentClassName="XInterface.GUINumericEdit"
}
