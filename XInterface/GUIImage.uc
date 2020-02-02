/* ====================================================================
  Class:  UT2K4UI.GUIImage

  GUIImage - A graphic image used by the menu system.  It encapsulates
  Material.

  Written by Joe Wilcox
  (c) 2002, Epic Games, Inc.  All Rights Reserved
  Notes about draw styles:

  Some things to know about using ISTY_Stretched -
  If X1, X2, Y1, and Y2 are all -1, draws normally.
  If specify values for any of those (i.e. you are drawing only a portion of another texture),
  the image is scaled instead of streched.  In effect, it is the same as ISTY_Scaled, with one exception:
  If using ImageAlign other than IMGA_Left, then position calculation is done based from the
  original material's size with ISTY_Stretched, whereas it is done with size of the GUIImage with
  ISTY_Scaled.

  ImageAlign is ignored if ImageStyle is ISTY_Bound.
 ===================================================================*/

class GUIImage extends GUIComponent
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


var() Material Image;				// The Material to Render
var() Material			DropShadow;			// The Materinal used for a drop shadow
var() color				ImageColor;			// What color should we set
var() eImgStyle			ImageStyle;			// How should the image be displayed
var() EMenuRenderStyle	ImageRenderStyle;	// How should we display this image
var() eImgAlign			ImageAlign;			// If ISTY_Justified, how should image be aligned
var() int				X1,Y1,X2,Y2;		// If set, it will pull a subimage from inside the image
var() int				DropShadowX;		// Offset for a drop shadow
var() int				DropShadowY;		// Offset for a drop shadow

var() float             BorderOffsets[4];	// How thick is the border (in percentage)
// Only used for ISTY_PartialScaled
// Essentially, ISTY_PartialScaled means the material is stretched if the bounds are larger than the material
// and scaled if the bounds are smaller than the material

// X3 and Y3 are used to specify how far into each side (must be symmetric) of the image
// will be stretched *instead of* scaled if the material is smaller than the bounds
// This is mainly used for textures which contain combinations of gradients and detailed borders or bevels,
// where the gradient should be scaled to maintain color distribution, but the border needs to maintain a
// minimum size.  Also used to preserve "bevelled" appearance of materials (editbox)
var() float             X3, Y3;

event string AdditionalDebugString()
{
	return " IS:"$GetEnum(enum'EImgStyle', ImageStyle);
}

defaultproperties
{
     ImageColor=(B=255,G=255,R=255,A=255)
     ImageRenderStyle=MSTY_Alpha
     X1=-1
     Y1=-1
     X2=-1
     Y2=-1
     X3=-1.000000
     Y3=-1.000000
     RenderWeight=0.100000
}
