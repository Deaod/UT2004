//==============================================================================
//	Menu Option component for GUISliders
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class moSlider extends GUIMenuOption;

var(Option) float              MaxValue, MinValue, Value;
var(Option) bool		       bIntSlider;
var(Option) string		       SliderStyleName, SliderCaptionStyleName, SliderBarStyleName;
var(Option) noexport editconst GUISlider	MySlider;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	SetReadOnly(bValueReadOnly);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUISlider(NewComp) != None)
	{
		MySlider = GUISlider(NewComp);
		MySlider.MinValue = MinValue;
		MySlider.MaxValue = MaxValue;
		MySlider.bIntSlider = bIntSlider;
		MySlider.StyleName = SliderStyleName;
		MySlider.CaptionStyleName = SliderCaptionStyleName;
		MySlider.BarStyleName = SliderBarStyleName;
	}
	Super.InternalOnCreateComponent(NewComp, Sender);
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

function Adjust(float Amount)
{
	if (MySlider != None)
		MySlider.Adjust(Amount);
}

function SetValue(coerce float NewV)
{
	if (MySlider != None)
		Value = MySlider.SetValue(NewV);
}

function float GetValue()
{
	if (MySlider != None)
		return MySlider.Value;

	return 0.0;
}

function Setup(coerce float MinV, coerce float MaxV, optional bool bInt)
{
	MinValue = MinV;
	MaxValue = MaxV;
	bIntSlider = bInt;

	if (MySlider != None)
	{
		MySlider.MinValue = MinValue;
		MySlider.MaxValue = MaxValue;
		MySlider.bIntSlider = bIntSlider;
	}
}

function InternalOnChange(GUIComponent Sender)
{
	Value = MySlider.Value;
	Super.InternalOnChange(Sender);
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MySlider.SetReadOnly(b);
}

defaultproperties
{
     SliderStyleName="SliderKnob"
     SliderCaptionStyleName="SliderCaption"
     SliderBarStyleName="SliderBar"
     ComponentClassName="XInterface.GUISlider"
}
