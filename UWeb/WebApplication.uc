class WebApplication extends Object;

// Set by the webserver
var LevelInfo Level;
var WebServer WebServer;
var string Path;

function Init();

// This is a dummy function which should never be called
// Here for backwards compatibility
final function Cleanup();

function CleanupApp()
{
	if (Level != None)
		Level = None;

	if (WebServer != None)
		WebServer = None;
}

function bool PreQuery(WebRequest Request, WebResponse Response) { return true; }
function Query(WebRequest Request, WebResponse Response);
function PostQuery(WebRequest Request, WebResponse Response);

defaultproperties
{
}
