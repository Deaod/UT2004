class MotionBlur extends CameraEffect
	native
	noexport
	editinlinenew
	collapsecategories;

var() byte	BlurAlpha;

var const pointer	RenderTargets[2];
var const float		LastFrameTime;

defaultproperties
{
     BlurAlpha=128
}
