// ====================================================================
//  Class:  Engine.FileLog
//  Parent: Engine.Info
//
//  Creates a log device.
//	Important notes about this class since version 2225:
//	- the log file is always closed when destroyed
//	- open log files have the extention .tmp and change to .log when
//		closed
//	- old .tmp files will be overwritten
//	- limited freedom in file extentions, allowed extentions:
//		log, txt, html, htm
// ====================================================================

class FileLog extends Info
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Internal
var pointer LogAr; // FArchive*

// File Names
var const string LogFileName;
var const string TempFileName;

// File Manipulation
native final function OpenLog(string FName, optional string FExt, optional bool bOverwrite); // no extention in FName
native final function CloseLog();
native final function Logf( string LogString );

defaultproperties
{
}
