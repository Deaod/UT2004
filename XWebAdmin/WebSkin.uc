//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WebSkin extends Object
	abstract
	notplaceable;

var string SubPath;
var localized string DisplayName;		// Name to use in skin select box
var string SkinCSS;			// CSS file associated with this skin
var string DefaultBGColor;	// Color for webadmin backgrounds

// Array containing any pages you'd like to handle a query for
var array<string>	SpecialQuery;

function Init(UTServerAdmin WebAdmin)
{
	WebAdmin.SkinPath = "/" $ SubPath;
	WebAdmin.SiteBG = DefaultBGColor;
	WebAdmin.SiteCSSFile = SkinCSS;
}

// Add additional values to WebResponse object
// Return true to cancel normal handling of query
// Return false to allow UTServerAdmin to continue processing query
function bool HandleSpecialQuery(WebRequest Request, WebResponse Response) { return false; }

// Hook for overriding VariableMap values before tokens in .htm or .inc files are replaced with values
// Return false to allow query processing to continue
function string HandleWebInclude(WebResponse Response, string filename) { return ""; }
function bool HandleHTM(WebResponse Response, string filename) { return false; }
function bool HandleMessagePage(WebResponse Response, string Title, string Message) { return false; }
function bool HandleFrameMessage(WebResponse Response, string Message, bool bIsError) { return false; }

defaultproperties
{
     DisplayName="SomeSkin"
     SkinCSS="ut2003.css"
     DefaultBGColor="#243954"
}
