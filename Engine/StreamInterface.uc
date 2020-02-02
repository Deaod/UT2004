//==============================================================================
//	Created on: 10/12/2003
//	Handles file & directory manipulation for streaming music files.
//  Could support arbitrary filetypes with very little modification
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamInterface extends StreamBase
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var private globalconfig string CurrentDirectory;

// Directory Interface
native final private function string  GetBaseDirectory();
native final         function bool    GetDriveLetters( out array<string> Letters );
native final         function bool    GetDirectoryContents( out array<string> Contents, optional string DirectoryName, optional EFileType FileType );

native final         function string  CreateDirectory( string DirectoryName );
native final         function bool    RemoveDirectory( string DirectoryName );
native final         function bool    ValidDirectory( optional string DirectoryPath );

// ID3 Tags


// File manipulation
native final          function Stream    CreateStream( string FileName, optional bool bStrict ); // specify bStrict to indicate it isn't allowed to include relative paths when searching
native final          function bool      ValidFile( string FileName );
native final          function bool      LoadPlaylist( string FileName, out array<string> Lines, optional bool bStrict );

function string GetCurrentDirectory()
{
	if ( CurrentDirectory == "" || !ValidDirectory(CurrentDirectory) )
		ChangeDirectory(GetBaseDirectory());

	return CurrentDirectory;
}

function ChangeDirectory( string DirectoryName )
{
	local bool bSave;

	bSave = DirectoryName != CurrentDirectory;
	CurrentDirectory = DirectoryName;
	if ( bSave )
		SaveConfig();
}

function bool HandleDebugExec( string Command, string Param )
{
	local string str;
	local array<string> test;
	local int i;

	if ( Super.HandleDebugExec(Command, Param) )
		return true;

	switch ( Locs(Command) )
	{
	case "getbase": log(GetBaseDirectory());return true;
	case "getcurrent": log(GetCurrentDirectory());return true;
	case "validfilename": log(ValidFile(Param));return true;
	case "dir":
		GetDirectoryContents(test,param);
		log("directory list for"@param);
		for ( i = 0; i < test.Length;i++)
			log("   >"@test[i]);

		return true;

	case "chdir":
		str = GetCurrentDirectory();
		ChangeDirectory(param);
		log("old:"$str@"new:"$GetCurrentDirectory());
		return true;
	}

	return false;
}

defaultproperties
{
}
