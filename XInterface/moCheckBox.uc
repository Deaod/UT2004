// ====================================================================
//  Class:  XInterface.moCheckBox
//  Combines a label and check box button.
// ====================================================================

class moCheckBox extends GUIMenuOption;

var(Option)                     string             CheckStyleName;
var(Option) noexport editconst GUICheckBoxButton   MyCheckBox;
var(Option) noexport editconst deprecated bool     bChecked;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local GUIStyles S;
    Super.Initcomponent(MyController, MyOwner);

    MyCheckBox = GUICheckBoxButton(MyComponent);
    MyCheckBox.OnChange = ButtonChecked;
    MyCheckBox.OnClick = InternalClick;

    S = Controller.GetStyle(CheckStyleName,MyCheckBox.FontScale);
    if ( S != none )
        MyCheckBox.Graphic = S.Images[0];
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	if ( bNoChange )
		bIgnoreChange = True;

    Checked(NewValue);
    bIgnoreChange = False;
}

function string GetComponentValue()
{
    return string(IsChecked());
}

function ResetComponent()
{
    MyCheckBox.SetChecked(False);
}

function bool IsChecked()
{
    return MyCheckBox.bChecked;
}

function bool Checked(coerce bool C)
{
    MyCheckBox.SetChecked(C);
    return true;
}

function ButtonChecked(GUIComponent Sender)
{
    if ( Sender == MyCheckBox )
        InternalOnChange(Self);
}

private function bool InternalClick(GUIComponent Sender)
{
	if ( bValueReadOnly )
		return true;

	return MyCheckBox.InternalOnClick(Sender);
}

defaultproperties
{
     bSquare=True
     CaptionWidth=0.800000
     ComponentClassName="XInterface.GUICheckBoxButton"
}
