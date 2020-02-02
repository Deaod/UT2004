//=============================================================================
// SubActionFade:
//
// Fades to/from a color
//=============================================================================
class SubActionFade extends MatSubAction
	native;

var(Fade)	color	FadeColor;		// The color to use for the fade
var(Fade)	bool	bFadeOut;		// If TRUE, the screen is fading out (towards the color)

defaultproperties
{
     bFadeOut=True
     Icon=Texture'Engine.SubActionFade'
     Desc="Fade"
}
