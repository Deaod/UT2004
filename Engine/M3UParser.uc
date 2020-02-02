//==============================================================================
//  Created on: 10/27/2003
//  Specialized parser for WinAmp PLS playlists
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class M3UParser extends PlaylistParserBase;

var FilePath ParsedPath;

function bool Import( int PlaylistIndex, int InsertPosition, string Path )
{
	if ( FileManager.LoadPlaylist(Path, Lines) && ParsePath(Path, ParsedPath) )
	{
		ImportedPlaylist( PlaylistIndex, InsertPosition );
		return true;
	}

	return false;
}

function ParseLines()
{
	local int i;
	local string Str;

	Super.ParseLines();
	if ( Lines.Length == 0 )
		return;

	for ( i = 0; i < Lines.Length; i++ )
	{
		if ( Left(Lines[i],1) == "#" || Lines[i] == "" )
			continue;

		Str = Lines[i];
		if ( Left(Str,1) == GetPathSeparator() )
			Str = Mid(Str,1);

		Paths[Paths.Length] = MatchPath(Str);
	}
}

function string MatchPath( string Str )
{
	local int i;
	local array<string> Parts;
	local string Result;

//	log(Name@"MatchPath matching '"$ParsedPath.Directory$"' against '"$Str$"'");
	Split(Str, GetPathSeparator(), Parts);
	for ( i = 0; i < ParsedPath.DirectoryParts.Length; i++ )
	{
//		log(Name@"MatchPath ParsedPath.Directories["$i$"] '"$ParsedPath.DirectoryParts[i]$"'  Parts[0] '"$Parts[0]$"'");
		if ( CompareNames(ParsedPath.DirectoryParts[i],Parts[0]) )
			break;

		if ( Result != "" )
			Result $= GetPathSeparator();

		Result $= ParsedPath.DirectoryParts[i];
	}

	// however, if no matches were found, then clear the string
	if ( i == ParsedPath.DirectoryParts.Length )
		Result = "";

	for ( i = 0; i < Parts.Length; i++ )
	{
		if ( Result != "" )
			Result $= GetPathSeparator();

		Result $= Parts[i];
	}

//	log("MatchPath - Result:"$Result);
	return Result;
}

defaultproperties
{
}
