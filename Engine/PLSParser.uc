//==============================================================================
//  Created on: 10/27/2003
//  Specialized parser for WinAmp PLS playlists
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class PLSParser extends PlaylistParserBase;

function ParseLines()
{
	local int i;

	Super.ParseLines();
	if ( Lines.Length == 0 )
		return;

	for ( i = 0; i < Lines.Length; i++ )
	{
		if ( Left(Lines[i],1) == "[" || Lines[i] == "" )
			continue;

		if ( PlaylistName == "" && Left(Lines[i],InStr(Lines[i], "=")) ~= "PlaylistName" )
		{
			PlaylistName = GetValue(Lines[i], True);
			continue;
		}

		if ( Left(Lines[i],4) ~= "File" )
			Paths[Paths.Length] = GetValue(Lines[i], True);
	}
}

defaultproperties
{
}
