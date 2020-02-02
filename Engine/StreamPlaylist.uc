//==============================================================================
//	Created on: 10/12/2003
//	A user-configured list of streaming music files.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamPlaylist extends StreamBase
	PerObjectConfig
	Config(UPlaylists);

var() protected config int           Current;
var() protected config array<string> Playlist;
var() protected string               Title;

var() protected config bool          bNeedSave;
var() editinline editconst noexport private   editconstarray transient array<int>    RandomPool;
var() editinline editconst noexport protected StreamInterface                        FileManager;
var() editinline editconst noexport protected editconstarray           array<Stream> Songs;

delegate OnPlaylistChanged();

function bool InitializePlaylist( StreamInterface InManager )
{
	if ( InManager == None || IsInitialized() )
		return false;

	FileManager = InManager;
	LoadPlaylist();
	return true;
}

function bool LoadPlaylist()
{
	local int i;

	ClearPlaylist();
	for ( i = 0; i < Playlist.Length; i++ )
	{
		if ( !FileManager.ValidFile(Playlist[i]) )
		{
			log("Removing file from playlist '"$GetTitle()$"' - file not found",'MusicPlayer');
			Playlist.Remove(i--,1);
			continue;
		}

		AddSong(Playlist[i]);
	}

	ResetRandomPool();
	bNeedSave = False;
	return true;
}

function Stream CreateStream( string FileName )
{
	if ( FileName == "" )
		return None;

	return FileManager.CreateStream( FileName );
}

function int AddSong( string SongFileName, optional bool bSkipNotification )
{
	local Stream NewStream;
	local EFileType Type;
	local int i;

	if ( SongFileName == "" )
		return -1;

	Type = ConvertToFileType(SongFileName);
	if ( Type == FILE_Stream )
	{
		NewStream = CreateStream(SongFileName);
		if ( NewStream == None )
			return -1;

		i = AddStream(GetPlaylistLength(), NewStream, bSkipNotification);
		bNeedSave = bNeedSave || ValidStreamIndex(i);

		return i;
	}

	return -1;
}

function int AddStream( int Index, Stream NewStream, optional bool bSkipNotification )
{
	local int i;
	local string Str;

	if ( NewStream == None )
		return -1;

	Str = NewStream.GetFileName();
	if ( Str == "" )
		return -1;

	i = FindIndexByName( Str );
	if ( !ValidStreamIndex(i) )
	{
		if ( !ValidStreamIndex(Index) )
			Index = GetPlaylistLength();

		Songs.Insert( Index, 1 );
		Songs[Index] = NewStream;
		RandomPool[RandomPool.Length] = Index;

		if ( !bSkipNotification )
			OnPlaylistChanged();
		return Index;
	}

	return i;
}

function int InsertSong( int idx, string Path, optional bool bSkipNotification )
{
	local Stream NewStream;
	local EFileType Type;
	local int i;

	if ( !ValidStreamIndex(idx) )
		return AddSong(Path,bSkipNotification);

	if ( Path == "" )
		return -1;

	Type = ConvertToFileType(Path);
	if ( Type == FILE_Stream )
	{
		NewStream = CreateStream(Path);
		if ( NewStream == None )
			return -1;

		i = AddStream(idx, NewStream, bSkipNotification);
		bNeedSave = bNeedSave || ValidStreamIndex(i);
		return i;
	}

	return -1;

}

function bool RemoveSong( string SongFileName, optional bool bSkipNotification )
{
	return RemoveSongAt(FindIndexByName(SongFileName), bSkipNotification);
}

function bool RemoveSongAt( int idx, optional bool bSkipNotification )
{
	local int i;

	if ( !ValidStreamIndex(idx) )
		return false;

	Songs.Remove(idx,1);

	// Remove the last index from the random pool
	for ( i = 0; i < RandomPool.Length; i++ )
		if ( RandomPool[i] == Songs.Length )
		{
			RandomPool.Remove(i,1);
			break;
		}

	// If this was the current song, attempt to set the current to the previous song, so that the playlist will
	// select the next song correctly
	if ( idx == Current && !SetCurrent(idx-1) )
		SetCurrent(0);

	bNeedSave = True;

	if ( !bSkipNotification )
		OnPlaylistChanged();
	return true;
}

function string NextSong( bool bMayRepeat )
{
	local int i;

	i = GetCurrent() + 1;
	if ( !ValidStreamIndex(i) && bMayRepeat )
		i = 0;

	if ( SetCurrent(i) )
		return Songs[Current].GetPath();

	return "";
}

function string PrevSong( bool bMayRepeat )
{
	local int i;

	i = GetCurrent() - 1;
	if ( !ValidStreamIndex(i) && bMayRepeat )
		i = GetPlaylistLength() - 1;

	if ( SetCurrent(i) )
		return Songs[Current].GetPath();

	return "";
}

function ReplaceWith( StreamPlaylist Other )
{
	if ( Other == None )
		return;

	FileManager = Other.FileManager;
	Other.GetSongs(Songs);
	ResetRandomPool();

	SetCurrent( Other.GetCurrent() );
	bNeedSave = True;
}

function bool ClearPlaylist()
{
	bNeedSave = bNeedSave || Songs.Length > 0;
	Songs.Remove( 0, Songs.Length );
	RandomPool.Remove(0, RandomPool.Length);

	return true;
}

function string GetRandomSong()
{
	local int idx;
	local Stream RandomStream;

	if ( RandomPool.Length == 0 )
		ResetRandomPool();

	if ( RandomPool.Length > 0 )
	{
		idx = Rand(RandomPool.Length - 1);
		if ( ValidStreamIndex(RandomPool[idx]) )
		{
			RandomStream = Songs[RandomPool[idx]];
			RandomPool.Remove(idx,1);
			return RandomStream.GetPath();
		}
	}

	return "";
}

function ResetRandomPool()
{
	local int i;

	RandomPool.Length = Songs.Length;
	for ( i = 0; i < Songs.Length; i++ )
		RandomPool[i] = i;
}

function bool SetTitle( string NewTitle )
{
	if ( NewTitle == "" )
		return false;

	Title = NewTitle;
	OnPlaylistChanged();
	Save();

	return true;
}

function bool SetCurrent( int Index )
{
	if ( !ValidStreamIndex(Index) )
		return false;

	Current = Index;
	bNeedSave = True;
	return true;
}

// DOES NOT perform notification!!
function bool SetSongs( array<Stream> NewSongs )
{
	Songs = NewSongs;
	ResetRandomPool();
	bNeedSave = True;
	return true;
}

// =====================================================================================================================
// =====================================================================================================================
// Query
// =====================================================================================================================
// =====================================================================================================================

function bool IsInitialized()
{
	return FileManager != None;
}

function string GetTitle()
{
	return Title;
}

function int GetCurrent()
{
	return Current;
}

function GetSongs( out array<Stream> SongArray )
{
	SongArray = Songs;
}

function Stream GetCurrentStream()
{
	return GetStreamAt(GetCurrent());
}

function Stream GetStream( string StreamName )
{
	local int i;

	i = FindIndexByName(StreamName);
	return GetStreamAt(i);
}

function Stream GetStreamAt( int Index )
{
	if (ValidStreamIndex(Index) )
		return Songs[Index];

	return None;
}

function int GetPlaylistLength()
{
	return Songs.Length;
}

function int FindIndexByName( string Test )
{
	local FilePath APath;

	if ( ParsePath(Test, APath) )
	{
		if ( APath.Extension != "" )
		{
			if ( APath.Directory != "" )
				return FindIndexByPath(APath.FullPath);
			else if ( APath.FileName != "" )
				return FindIndexByFullName( APath.FileName $ "." $ APath.Extension );
		}
		else return FindIndexByFileName(APath.FileName);
	}

	return -1;
}

function int FindIndexByPath( string Test )
{
	local int i;

	if ( Test == "" )
		return -1;

	for ( i = 0; i < Songs.Length; i++ )
		if ( Songs[i].GetPath() ~= Test )
			return i;

	return -1;
}

function int FindIndexByFullName( string Test )
{
	local int i, num;

	if ( Test == "" )
		return -1;

	num = GetPlaylistLength();
	for ( i = 0; i < num; i++ )
	{
		if ( Songs[i].GetFullName() ~= Test )
			return i;
	}

	return -1;
}

function int FindIndexByFileName( string Test )
{
	local int i, num;

	if ( Test == "" )
		return -1;

	num = GetPlaylistLength();
	for ( i = 0; i < num; i++ )
	{
		if ( Songs[i].GetFileName() ~= Test )
			return i;
	}

	return -1;
}

function bool ValidStreamName( string FileName )
{
	if ( FileName == "" )
		return false;

	return ValidStreamIndex( FindIndexByName(FileName) );
}

function bool ValidStreamIndex( int Index )
{
	return Index >= 0 && Index < Songs.Length;
}

// =====================================================================================================================
// =====================================================================================================================
//  Debug
// =====================================================================================================================
// =====================================================================================================================

function DebugInfo()
{
	local int i;

	log("   Playlist '"$GetTitle()$"', Length:"$GetPlaylistLength(),'MusicPlayer');
	for ( i = 0; i < GetPlaylistLength(); i++ )
		log("    "$i$")"@Songs[i].GetSongTitle(),'MusicPlayer');
}

function bool HandleDebugExec(string Command, string Param)
{
	local int i;

	if ( Super.HandleDebugExec(Command,Param) )
		return true;

	switch ( Locs(Command))
	{
	case "addsong":
		AddSong(Param);
		return true;

	case "dumptags":
		for ( i = 0; i < Songs.Length; i++ )
			Songs[i].DumpTags();
		return true;

	case "scripttags":
		for ( i = 0; i < Songs.Length; i++ )
			Songs[i].DumpScriptTag();

	case "showsongs":
		log("Playlist"@GetTitle()@"has"@Songs.Length@"songs",'MusicPlayer');
		for ( i = 0; i < Songs.Length; i++ )
			log("  "$i$")"@Songs[i].GetPath(),'MusicPlayer');

		return true;
	}

	return false;
}

function Save()
{
	local int i;

	if ( !bNeedSave )
		return;

	Playlist.Remove(0, Playlist.Length);
	for ( i = 0; i < Songs.Length; i++ )
		if ( Songs[i] != None )
			Playlist[i] = Songs[i].GetPath();

	bNeedSave = False;
	SaveConfig();
}

defaultproperties
{
     bNeedSave=True
}
