//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K3Skin extends WebSkin;

function Init(UTServerAdmin WebAdmin)
{
	WebAdmin.SkinPath = "";
	WebAdmin.SiteBG = DefaultBGColor;
	WebAdmin.SiteCSSFile = SkinCSS;
}

defaultproperties
{
     DisplayName="Standard UT2K4"
}
