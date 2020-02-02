// ====================================================================
//  Class:  UT2K4UI.GUISlider
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
//  Sliders will not be drawn if both MinValue & MaxValue are both 0
// ====================================================================

class GUISlider extends GUIComponent
        Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()   float       MinValue, MaxValue;
var()   float       Value;
var()   float       MarkerWidth;
var()   bool        bIntSlider;
var()	bool		bShowMarker;
var()	bool		bShowCaption;
var()   bool        bDrawPercentSign;
var()   bool        bReadOnly;
var()   bool        bShowValueTooltip;   // Show the current value as a tooltip while dragging
var()	material 	FillImage;

var()   string      CaptionStyleName, BarStyleName;
var     GUIStyles   CaptionStyle;
var     GUIStyles   BarStyle;


// Return true to prevent caption from being drawn
delegate bool OnPreDrawCaption( out float X, out float Y, out float XL, out float YL, out ETextAlign Justification );

delegate string OnDrawCaption()
{
    if (bIntSlider)
        return "("$int(Value)$ Eval(bDrawPercentSign, " %", "") $ ")";

	return "("$Value$Eval(bDrawPercentSign, " %", "") $ ")";
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

    CaptionStyle = Controller.GetStyle(CaptionStyleName,FontScale);
    BarStyle = Controller.GetStyle(BarStyleName,FontScale);

}

function bool InternalCapturedMouseMove(float deltaX, float deltaY)
{
    local float Perc;

	if ( bReadOnly )
		return true;

    if ( (Controller.MouseX >= Bounds[0]) && (Controller.MouseX<=Bounds[2]) )
    {
        Perc = FClamp( ((Controller.MouseX - (ActualLeft() + (MarkerWidth/2))) / (ActualWidth()-MarkerWidth)), 0.0, 1.0 );
        Value = ((MaxValue - MinValue) * Perc) + MinValue;
        if (bIntSlider)
            Value = round(Value);
    }
    else if (Controller.MouseX < Bounds[0])
        Value = MinValue;
    else if (Controller.MouseX > Bounds[2])
        Value = MaxValue;

    Value = FClamp(Value,MinValue,MaxValue);

    if ( bShowValueTooltip )
    	ToolTip.SetTip( GetValueString() );

    return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( bReadOnly )
		return false;

    if ( (Key==0x25) && (State==1) )    // Left
    {
        if (bIntSlider)
            Adjust(-1);
        else
            Adjust(-0.01);
        return true;
    }

    if ( (Key==0x27) && (State==1) ) // Right
    {
        if (bIntSlider)
            Adjust(1);
        else
            Adjust(0.01);
        return true;
    }


    return false;
}

function float SetValue(float NewValue)
{
	Value = FClamp(NewValue, MinValue, MaxValue);

    if (bIntSlider)
        Value = Round(Value);

    return Value;
}

function Adjust(float amount)
{
    local float Perc;
    Perc = (Value-MinValue) / (MaxValue-MinValue);
    Perc += amount;
    Perc = FClamp(Perc,0.0,1.0);
    Value = FClamp( ((MaxValue - MinValue) * Perc) + MinValue, MinValue, MaxValue );
    OnChange(self);
}

function bool InternalOnClick(GUIComponent Sender)
{
    if ( bShowValueToolTip )
    	RevertTooltipToNormal();

    OnChange(self);
    return true;
}

function InternalOnMousePressed(GUIComponent Sender,bool RepeatClick)
{
	if ( bShowValueTooltip )
		ModifyTooltipForDragging();

    InternalCapturedMouseMove(0,0);
}

function InternalOnMouseRelease(GUIComponent Sender)
{
    InternalCapturedMouseMove(0,0);
}

function SetReadOnly(bool b)
{
	bReadOnly = b;
}

event float GetMarkerPosition()
{
	local float Perc;

	Perc = (Value - MinValue) / (MaxValue - MinValue);
	return ActualLeft() + ((ActualWidth() - MarkerWidth) * Perc);
}

function CenterMouse()
{
	if ( PlayerOwner() != None )
		PlayerOwner().ConsoleCommand( "SETMOUSE" @ GetMarkerPosition() @ (ActualTop() + ActualHeight() / 2) );
}

function string GetValueString()
{
	local string ValueStr;

	if ( bIntSlider )
		ValueStr = string( int(Value) );
	else ValueStr = string(Value);
	if ( bDrawPercentSign )
		ValueStr @= "%";

	return ValueStr;
}

function ModifyTooltipForDragging()
{
	ToolTip.bTrackMouse = True;
	ToolTip.bTrackInput = False;
	ToolTip.bMultiLine  = False;
	ToolTip.HideToolTip = HideToolTip;
	ToolTip.LeaveArea =   ToolTipLeaveArea;
	SetTooltipText( GetValueString() );
	ShowToolTip();
}

function RevertTooltipToNormal()
{
	ToolTip.bTrackMouse = ToolTip.default.bTrackMouse;
	ToolTip.bTrackInput = ToolTip.default.bTrackInput;
	ToolTip.bMultiLine  = ToolTip.default.bMultiLine;
	ToolTip.HideToolTip = None;
	ToolTip.LeaveArea   = None;
	ToolTip.LeaveArea();
	SetTooltipText( Hint );
}

function ShowToolTip()
{
	Controller.MouseOver = ToolTip.InternalEnterArea();
	ToolTip.SetVisibility(True);
}

function HideToolTip()
{
	if ( MenuState != MSAT_Pressed )
	{
		log("HideToolTip  MenuState:"$GetEnum(enum'EMenuState', MenuState));
		ToolTip.SetVisibility(False);
	}
}

function bool ToolTipLeaveArea()
{
	return False;
}

defaultproperties
{
     MaxValue=100.000000
     bShowMarker=True
     bShowValueTooltip=True
     FillImage=Texture'2K4Menus.NewControls.SliderFillBlurry'
     CaptionStyleName="SliderCaption"
     BarStyleName="SliderBar"
     StyleName="SliderKnob"
     WinHeight=0.030000
     bTabStop=True
     bAcceptsInput=True
     bCaptureMouse=True
     bRequireReleaseClick=True
     Begin Object Class=GUIToolTip Name=GUISliderToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUISlider.GUISliderToolTip'

     OnClickSound=CS_Click
     OnClick=GUISlider.InternalOnClick
     OnMousePressed=GUISlider.InternalOnMousePressed
     OnMouseRelease=GUISlider.InternalOnMouseRelease
     OnKeyEvent=GUISlider.InternalOnKeyEvent
     OnCapturedMouseMove=GUISlider.InternalCapturedMouseMove
}
