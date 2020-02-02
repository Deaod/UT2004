// ====================================================================
//  Class:  XWebAdmin.xWebQueryHandler
//  Parent: Engine.xAdminBase
//
//  <Enter a description here>
// ====================================================================

class xWebQueryHandler extends xAdminBase
		Within UTServerAdmin;

var string DefaultPage;
var string Title;
var string NeededPrivs;

function bool Init() {return true;}
function bool PreQuery(WebRequest Request, WebResponse Response) { return true; }
function bool Query(WebRequest Request, WebResponse Response)    { return false; }
function bool PostQuery(WebRequest Request, WebResponse Response) { return true; }

// Called at end of match
function Cleanup();

defaultproperties
{
}
