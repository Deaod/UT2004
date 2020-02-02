// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class GUISectionBackground extends GUIImage
	Native;

var(Style) editconst noexport GUIStyles	CaptionStyle; // must have a CaptionStyle to be drawn
var(Style)	string	 	CaptionStyleName;
var(Style)  int			AltCaptionOffset[4];
var(Style)  eTextAlign	AltCaptionAlign;
var(Style)	bool		bAltCaption;
var()       bool        bRemapStack;                // When components are added to the alignment stack, they are inserted based on their tab order
var()       bool        bFillClient;                // Adjust WinHeight of components so that they fill the client area


var() editinlinenotify noexport array<GUIComponent> AlignStack;
var() material HeaderTop,HeaderBar,HeaderBase;		// Top, Bar and base

var() localized string	  Caption;
var() float               ColPadding,               // Padding between columns
                          LeftPadding,
                          RightPadding,
						  TopPadding,
						  BottomPadding;            // range is 0 - 1.0
var() float               ImageOffset[4];
var() int                 NumColumns;               // Number of columns to divide the managed components into
var() int	              MaxPerColumn;             // Applicable only when NumColumns > 0

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

    if (CaptionStyleName!="")
    	CaptionStyle = Controller.GetStyle(CaptionStyleName,FontScale);

}

event SetVisibility(bool bIsVisible)
{
	local int i;

	Super.SetVisibility(bIsVisible);

    for (i=0;i<AlignStack.Length;i++)
    	AlignStack[i].SetVisibility(bIsVisible);
}


// Components that are manage by the section background are auto aligned and placed
function bool ManageComponent(GUIComponent Component)
{
	local int i;

	if ( Component == None )
		return false;

	i = FindComponentIndex(Component);
	if ( i == -1 )
	{
		if ( bRemapStack )
		{
		    for (i=0;i<AlignStack.Length;i++)
		    {
		    	if (AlignStack[i].TabOrder > Component.TabOrder)
			        break;
		    }
		}
		else i = AlignStack.Length;

	    AlignStack.Insert(i, 1);
		AlignStack[i]=Component;

		return true;
	}

    return false;
}

function bool UnmanageComponent( GUIComponent Comp )
{
	local int i;

	i = FindComponentIndex(Comp);
	if ( i != -1 && i >= 0 && i < AlignStack.Length )
	{
		AlignStack.Remove(i,1);
		return true;
	}

	return false;
}

function int FindComponentIndex( GUIComponent Comp )
{
	local int i;

	if ( Comp == None )
		return -1;

	for ( i = 0; i < AlignStack.Length; i++ )
		if ( AlignStack[i] == Comp )
			return i;

	return -1;
}

function Reset()
{
	AlignStack.Remove( 0, AlignStack.Length );
	bInit = true;
}

function bool InternalPreDraw(Canvas C)
{
	local float AL, AT, AW, AH, LPad, RPad, TPad, BPad;

	if ( AlignStack.Length == 0 )
		return false;

	AL = ActualLeft();
	AT = ActualTop();
	AW = ActualWidth();
	AH = ActualHeight();

	LPad = (LeftPadding   * AW) + ImageOffset[0];
	TPad = (TopPadding    * AH) + ImageOffset[1];
	RPad = (RightPadding  * AW) + ImageOffset[2];
	BPad = (BottomPadding * AH) + ImageOffset[3];

	if ( Style != none )
	{
		LPad += BorderOffsets[0];
		TPad += BorderOffsets[1];
		RPad += BorderOffsets[2];
		BPad += BorderOffsets[3];
	}

	AutoPosition( AlignStack,
		AL, AT, AL + AW, AT + AH,
		LPad, TPad, RPad, BPad,
		NumColumns, ColPadding );

	return false;
}

event ResolutionChanged(int ResX, int ResY)
{
	Super.ResolutionChanged(ResX, ResY);
	bInit = True;
}

function SetPosition( float NewLeft, float NewTop, float NewWidth, float NewHeight, optional bool bRelative )
{
	Super.SetPosition(NewLeft,NewTop,NewWidth,NewHeight,bRelative);
	bInit = true;
}

defaultproperties
{
     CaptionStyleName="TextLabel"
     bRemapStack=True
     HeaderTop=Texture'2K4Menus.NewControls.ComboTickFocused'
     HeaderBar=Texture'2K4Menus.NewControls.NewSliderBar'
     HeaderBase=Texture'2K4Menus.NewControls.Display98'
     ColPadding=0.050000
     LeftPadding=0.050000
     RightPadding=0.050000
     ImageOffset(0)=16.000000
     ImageOffset(1)=44.000000
     ImageOffset(2)=16.000000
     ImageOffset(3)=18.000000
     NumColumns=1
     FontScale=FNS_Small
     RenderWeight=0.090000
     OnPreDraw=GUISectionBackground.InternalPreDraw
}
