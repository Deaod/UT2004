//==============================================================================
//	Created on: 10/13/2003
//	Base class for streaming music related classes
//  Organizational purposes only
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamBase extends Object
	Abstract
	Native;

enum EFileType
{
	FILE_None,
	FILE_Directory,
	FILE_Log,
	FILE_Ini,
	FILE_Stream,
	FILE_Playlist,
	FILE_Music,
	FILE_Map,
	FILE_Texture,
	FILE_Animation,
	FILE_Static,
	FILE_XML,
	FILE_HTML,
	FILE_Sound,
	FILE_Demo,
	FILE_DivX,
};

enum EStreamPlaylistType
{
	SPT_None,
	SPT_M3U,
	SPT_PLS,
	SPT_B4S,
};

struct FilePath
{
	var string FullPath,
               Directory,	// Always contains trailing path-separator
	           Filename,	// Only contains name (no dots)
			   Extension;   // Only contains extension (no dots)

	var array<string> DirectoryParts;
};

struct ID3Field
{
	var pointer           Reference;
	var string            FieldName;
	var string           FieldValue;
	var byte     		    FieldID;
	var byte                Code[4];
};

// "StringA" * "StringB" = "StringA\StringB" or "StringA/StringB"
native static final operator(40) string *  ( coerce string A, coerce string B );
native static final operator(44) string *= ( out	string A, coerce string B );


// OS-specific hooks
native static final function string GetPathSeparator();
native static final function bool   IsCaseSensitive();

// seperates a file path into a ParsedFilePath struct
static final event string GetPathRoot( out string InPath )
{
	local int i;
	local string root;

	i = InStr(InPath, GetPathSeparator() $ GetPathSeparator()); // would look like:   '//blah/blah/'
	if ( i == -1 )
		i = InStr(InPath, ":" $ GetPathSeparator()); 	// would look like 'c:\blah\blah'

	if ( i != -1 )
	{
		root = Left(InPath, i + 1);
		InPath = Mid(InPath, i + 2);
		// so root should now be either '/' or 'c:'
	}

	return root;
}

static final event bool HasExtension( string Test )
{
	return ParseExtension(Test) != "";
}

static final event bool ParsePath( string InPath, out FilePath ParsedPath )
{
	local int i;

	if ( InPath == "" )
		return false;

	ParsedPath.FullPath = InPath;

	i = RevInStr(InPath, GetPathSeparator());
	if ( i != -1 )
		ParsedPath.Directory = Left(InPath, i+1);

	ParsedPath.DirectoryParts = ParseDirectories(InPath);
	ParsedPath.Extension = ParseExtension(InPath);
	ParsedPath.FileName = InPath;

	return ParsedPath.DirectoryParts.Length > 0 || (ParsedPath.Extension != "" && ParsedPath.FileName != "");
}

static final event string ParseExtension( out string FileNameWithExtension )
{
	local int i;
	local string Ext;

	if ( FileNameWithExtension == "" )
		return "";

	i = RevInStr(FileNameWithExtension, ".");
	if ( i >= 0 )
		Ext = Mid(FileNameWithExtension, i + 1);

	if ( ConvertToFileType(Ext) != FILE_None )
	{
		FileNameWithExtension = Left(FileNameWithExtension,i);
		return Locs(Ext);
	}

	return "";
}

static final event array<string> ParseDirectories( out string InPath )
{
	local array<string> Directories;
	local string root;

	root = GetPathRoot(InPath);
	Split(InPath, GetPathSeparator(), Directories);
	InPath = "";

	// Re-insert the root directory at the beginning of the array
	if ( root != "" )
	{
		Directories.Insert(0,1);
		Directories[0] = root;
	}

	// If the last item was actually a file, remove it from the array and store in the out string
	if ( HasExtension(Directories[Directories.Length - 1]) )
	{
		InPath = Directories[Directories.Length - 1];
		Directories.Length = Directories.Length - 1;
	}

	return Directories;
}

static final function int RevInStr( string src, string match )
{
	local int pos, i;
	local string s;

	if ( src == "" || match == "" )
		return -1;

	s = src;
	i = InStr(s, match);

	do
	{
		pos += i;
		s = Mid(src, pos+1);
		i = InStr(s, match) + 1;
	} until ( i == 0 );

	return pos;
}

static final function string FormatTimeDisplay( coerce float Seconds )
{
	local int i;
	local string TimeString;

	// Get hours
	i = Seconds / 3600;
	if ( i > 0 )
		TimeString = i $ ":";

	i = Seconds / 60;
	if ( TimeString != "" && i < 10 )
		TimeString $= "0";

	TimeString $= i $ ":";

	i = Seconds % 60;
	if ( i < 10 )
		TimeString $= "0";

	TimeString $= i;

	return TimeString;
}

static final event string ConvertToFileExtension( EFileType Type )
{
	switch ( Type )
	{
	case FILE_Log:       return ".log";
	case FILE_Ini:       return ".ini";
	case FILE_Playlist:  return ".m3u;.pls;.b4s";
	case FILE_Music:     return ".umx";
	case FILE_Map:       return ".ut2";
	case FILE_Texture:   return ".utx";
	case FILE_Animation: return ".ukx";
	case FILE_Static:    return ".usx";
	case FILE_XML:       return ".xml";
	case FILE_HTML:      return ".html;.htm";
	case FILE_Sound:     return ".uax";
	case FILE_Demo:      return ".DEMO4";
	case FILE_DivX:      return ".avi";
	case FILE_Stream:
//			return ".ogg";
		return ".mp3;.ogg";
	}

	return "";
}

static final event EFileType ConvertToFileType( string Extension )
{
	local string Ext;

	if ( Extension == "" )
		return FILE_None;

	Ext = ParseExtension(Extension);
	if ( Ext == "" )
		Ext = Extension;

	Ext = Locs(Ext);
	switch ( Ext )
	{
		case "mp3":// return FILE_None;
		case "ogg":	return FILE_Stream;
		case "wav":
		case "umx":	return FILE_Music;
		case "ut2": return FILE_Map;
		case "ukx": return FILE_Animation;
		case "uax": return FILE_Sound;
		case "utx": return FILE_Texture;
		case "dem": return FILE_Demo;
		case "usx": return FILE_Static;
		case "ini": return FILE_Ini;
		case "log": return FILE_Log;
		case "avi": return FILE_DivX;
		case "xml": return FILE_XML;
		case "html":
		case "htm": return FILE_HTML;
		case "m3u":
		case "b4s":
		case "pls": return FILE_Playlist;
	}

	return FILE_None;
}

static function bool CompareNames( string NameA, string NameB )
{
	if ( IsCaseSensitive() )
		return NameA == NameB;

	return NameA ~= NameB;
}

function bool HandleDebugExec( string Command, string Param )
{
//	log(Class.Name$"::HandleDebugExec  Command:"$Command@"Param:"$Param);
	return false;
}

defaultproperties
{
}
