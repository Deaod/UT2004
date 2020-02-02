//==============================================================================
//	Created on: 10/14/2003
//	Manages custom playlists
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamPlaylistManager extends StreamBase
	Config(UPlaylists);

var() editconst protected config int                            CurrentPlaylist;	// Index of current playlist
var() editinline editconst noexport StreamInterface             FileManager;
var() editinline editconstarray protected array<StreamPlaylist> Playlists;
var() protected bool                                            bDisableNotification;
var() transient noexport protected bool                         bDirty;

var() protected config bool           bShuffle, bShuffleAll, bRepeat, bRepeatAll;
var() localized string                DefaultPlaylistName;

struct PlaylistParser
{
	var() EStreamPlaylistType Type;
	var() string              ParserClass;
};

var() config array<PlaylistParser> ParserType;
var() editconst noexport editinline editconstarray array<PlaylistParserBase>    Parsers;

// =====================================================================================================================
// =====================================================================================================================
// Initialization
// =====================================================================================================================
// =====================================================================================================================

delegate ChangedActivePlaylist( StreamPlaylist NewPlaylist );

function Initialize( StreamInterface InFileManager )
{
	FileManager = InFileManager;
	InitializePlaylists();
	InitializeParsers();
}

protected function InitializePlaylists()
{
	local array<string> PlaylistNames;
	local StreamPlaylist NewList;
	local int i;

	PlaylistNames = GetPerObjectNames("UPlaylists", "StreamPlaylist");
	for  ( i = 0; i < PlaylistNames.Length; i++ )
	{
		if ( PlaylistNames[i] == "" )
			continue;

		NewList = CreatePlaylist(PlaylistNames[i]);
		AppendPlaylist(NewList);
	}

	if ( Playlists.Length == 0 )
		CreateDefaultPlaylist();

	else if ( !ActivatePlaylist(CurrentPlaylist) )
		ActivatePlaylist(0);
}

protected function InitializeParsers()
{
	local int i, j;
	local class<PlaylistParserBase> ParseClass;

	for ( i = 0; i < ParserType.Length; i++ )
	{
		if ( ParserType[i].ParserClass != "" )
		{
			ParseClass = class<PlaylistParserBase>(DynamicLoadObject(ParserType[i].ParserClass, class'Class'));
			if ( ParseClass != None )
			{
				j = Parsers.Length;
				Parsers[j] = new(Self) ParseClass;
				Parsers[j].SetType(ParserType[i].Type);
			}
		}
	}
}

protected function StreamPlaylist CreateDefaultPlaylist()
{
	local int i;
	local string Nothing;

	Nothing = DefaultPlaylistName;
	i = AddPlaylist(Nothing);
	if ( ValidIndex(i) && ActivatePlaylist(i) )
		return Playlists[CurrentPlaylist];

	return None;
}

// =====================================================================================================================
// =====================================================================================================================
// Playlist Management
// =====================================================================================================================
// =====================================================================================================================

function bool ActivatePlaylist( int ListIndex, optional bool bNoFail )
{
	if ( !ValidIndex(ListIndex) )
	{
		if ( bNoFail )
			return False;

//		log("Wasn't a valid index:"$ListIndex,'MusicPlayer');
		if ( GetRepeatAll() )
		{
			if ( ListIndex < 0 )
				ListIndex = Playlists.Length - 1;
			else if ( ListIndex >= Playlists.Length )
				ListIndex = 0;

			if ( !ValidIndex(ListIndex) )
				return false;
		}

		else return false;
	}

	bDirty = bDirty || ListIndex != CurrentPlaylist;
	Playlists[ListIndex].InitializePlaylist(FileManager);
	CurrentPlaylist = ListIndex;

	if ( !bDisableNotification )
		ChangedActivePlaylist(Playlists[ListIndex]);

	return true;
}

function int AddPlaylist( out string NewPlaylistName )
{
	local string Str;
	local int i;

	if ( NewPlaylistName == "" )
		NewPlaylistName = DefaultPlaylistName;

	Str = NewPlaylistName;
	while ( ValidName(NewPlaylistName) )
		NewPlaylistName = Str $ i++;

	return AppendPlaylist( CreatePlaylist(NewPlaylistName) );
}

protected function int AppendPlaylist( StreamPlaylist Playlist )
{
	local int i;

	if ( Playlist == None )
		return -1;

	i = FindPlaylistIndex(Playlist);
	if ( i == -1 )
		i = Playlists.Length;

//	log("Appending new playlist...playlist number "$i);
	Playlists[i] = Playlist;
	bDirty = True;
	return i;
}

function bool RemovePlaylist( string PlaylistName )
{
	local int i;

//	log("Removing playlist "$PlaylistName);
	i = FindNameIndex(PlaylistName);
	if ( i != -1 )
		return RemovePlaylistAt(i);

	return false;
}

function bool RemovePlaylistAt( int Index )
{
	local bool bWasActive;

	if ( !ValidIndex(Index) )
		return false;

//	log("Removing playlist at "$index);
	bWasActive = CurrentPlaylist == Index;

	// Check if this is the active playlist - if so, set the default active
	Playlists[Index].ClearConfig();
	Playlists.Remove(Index,1);

	if ( bWasActive )
		ActivatePlaylist(0);

	return true;
}

function bool RenamePlaylist( int Index, out string NewName )
{
	local StreamPlaylist Temp;
	local string Str;
	local int i;

//	log("RenamePlaylist() Index:"$Index@"CurrentName:"$Playlists[Index].GetTitle()@"NewName:"$NewName);
	if ( !ValidIndex(Index) || NewName == "" )
		return false;

	Str = NewName;
	while ( ValidName(NewName) )
		NewName = Str $ i++;

	Temp = CreatePlaylist(NewName);
	if ( Temp == None )
		return false;

	Temp.ReplaceWith(Playlists[Index]);
	Playlists[Index].ClearConfig();

	Playlists[Index] = Temp;
	Playlists[Index].Save();

	if ( !bDisableNotification )
		ChangedActivePlaylist(Playlists[Index]);

	return true;
}

function bool AddToPlaylist( int PlaylistIndex, string Path, optional bool bSkipNotification )
{
	if ( !ValidIndex(PlaylistIndex) )
	{
		if ( !ValidIndex(CurrentPlaylist) )
			return false;

		PlaylistIndex = CurrentPlaylist;
	}

	return InsertInPlaylist( PlaylistIndex, -1, Path, bSkipNotification );
}

function bool InsertInPlaylist( int PlaylistIndex, int InsertPosition, string Path, optional bool bSkipNotification )
{
	local EFileType Type;
	local bool bResult;

	if ( !ValidIndex(PlaylistIndex) )
		return false;

	Type = ConvertToFileType(Path);
	Playlists[PlaylistIndex].InitializePlaylist(FileManager);

//	log("PlaylistManager.AddToPlaylist() PlaylistIndex:"$PlaylistIndex@"InsertPosition:"$InsertPosition@"Path:"$Path@" Type:"$GetEnum(enum'EFileType',Type)@"Path:"$Path);
	switch ( Type )
	{
	case FILE_None:     // directory
		bDisableNotification = True;
		bResult = AddDirectory( PlaylistIndex, InsertPosition, Path, True );
		bDisableNotification = False;

		if ( bResult && !bSkipNotification )
			Playlists[PlaylistIndex].OnPlaylistChanged();

		return bResult;

	case FILE_Playlist: // importing a playlist
		bDisableNotification = True;
		bResult = ImportPlaylist(PlaylistIndex, InsertPosition, Path);
		bDisableNotification = False;

		if ( bResult && !bSkipNotification )
			Playlists[PlaylistIndex].OnPlaylistChanged();

		return bResult;

	case FILE_Stream:   // adding a song
		return Playlists[PlaylistIndex].InsertSong(InsertPosition, Path, bDisableNotification || bSkipNotification) != -1;
	}

	return false;
}

function bool RemoveFromCurrentPlaylist( string Path, optional bool bSkipNotification )
{
//	log("RemoveFromCurrentPlaylist CurrentPlaylist:"$CurrentPlaylist@"Path:"$Path);
	if ( ValidIndex(CurrentPlaylist) )
		return Playlists[CurrentPlaylist].RemoveSong(Path, bSkipNotification);

	return false;
}

function bool ClearCurrentPlaylist()
{
	if ( !ValidIndex(CurrentPlaylist) )
		return false;

	return Playlists[CurrentPlaylist].ClearPlaylist();
}

function EStreamPlaylistType GetPlaylistType( string Path )
{
	local string Ext;

	Ext = ParseExtension(Path);
	switch ( Locs(Ext) )
	{
	case "m3u": return SPT_M3U;
	case "b4s": return SPT_B4S;
	case "pls": return SPT_PLS;
	}

 return SPT_None;
}


// TODO hook up non-recursive
function bool AddDirectory( int PlaylistIndex, int InsertPosition, string Path, bool bRecurseDirectories )
{
	local int i;
	local bool bValue;
	local array<string> Results;

	// First, check for any directories
	if ( bRecurseDirectories )
	{
		if ( FileManager.GetDirectoryContents(Results,Path,FILE_Directory) )
		{
			for ( i = Results.Length - 1; i >= 0; i-- )
				bValue = AddDirectory(PlaylistIndex,InsertPosition, Path $ Results[i] $ GetPathSeparator(), True) || bValue;
		}
	}

	Results.Remove(0, Results.Length);
	if ( FileManager.GetDirectoryContents(Results,Path,FILE_Stream) )
	{
		if ( !Playlists[PlaylistIndex].ValidStreamIndex(InsertPosition) )
			InsertPosition = Playlists[PlaylistIndex].GetPlaylistLength();

		for ( i = Results.Length - 1; i >= 0; i-- )
			bValue = Playlists[PlaylistIndex].InsertSong(InsertPosition, Path $ Results[i], bDisableNotification) != -1 || bValue;
	}

	return bValue;
}

function bool ImportPlaylist( int PlaylistIndex, int InsertPosition, string Path )
{
	local int i;
	local EStreamPlaylistType Type;

//	log("ImportPlaylist() PlaylistIndex:"$PlaylistIndex@"InsertPosition:"$InsertPosition@"Path:"$Path);

	Type = GetPlaylistType(Path);
	for ( i = 0; i < Parsers.Length; i++ )
		if ( Parsers[i].GetType() == Type )
			return Parsers[i].Import(PlaylistIndex, InsertPosition, Path);

	return false;
}

// Returns the next song in the playlist
function string NextSong( optional bool bForce )
{
	local StreamPlaylist List;
	local Stream S;
	local string Str;

	if ( GetShuffleAll() || GetShuffle() )
		return GetRandomSong();

	List = GetCurrentPlaylist();
	if ( List == None )
	{
		log("PlaylistManager.NextSong() - no playlists found!",'MusicPlayer');
		return "";
	}

	if ( GetRepeat() )
	{
		S = List.GetCurrentStream();
		if ( S != None )
			return S.GetPath();
	}
	else
	{
		Str = List.NextSong( bForce || GetRepeat() );
		if ( Str == "" && GetRepeatAll() && ActivatePlaylist(CurrentPlaylist+1) )
			Str = Playlists[CurrentPlaylist].NextSong(bForce);

		if ( Str != "" )
			return Str;
	}

//	log("PlaylistManager.NextSong() - last song reached.",'MusicPlayer');
	return "";
}

function string PrevSong( optional bool bForce )
{
	local StreamPlaylist List;
	local Stream S;
	local string str;

	if ( GetShuffleAll() || GetShuffle() )
		return GetRandomSong();

	List = GetCurrentPlaylist();
	if ( List == None )
	{
		log("PlaylistManager.PrevSong() - no playlists found!",'MusicPlayer');
		return "";
	}

	if ( GetRepeat() )
	{
		S = List.GetCurrentStream();
		if ( S != None )
			return S.GetPath();
	}

	else
	{
		Str = List.PrevSong( bForce || GetRepeat() );
		if ( Str == "" && GetRepeatAll() && ActivatePlaylist(CurrentPlaylist-1) )
			Str = Playlists[CurrentPlaylist].PrevSong(bForce);

		if ( Str != "" )
			return Str;
	}
//	log("PlaylistManager.PrevSong() - last song reached.",'MusicPlayer');
	return "";
}

function string GetRandomSong()
{
	local StreamPlaylist List;

	if ( GetShuffle() )
		List = GetCurrentPlaylist();

	else if ( GetShuffleAll() )
		List = GetRandomPlayList();

	if ( List != None )
		return List.GetRandomSong();

	return "";
}

// =====================================================================================================================
// =====================================================================================================================
// Playlist Query
// =====================================================================================================================
// =====================================================================================================================

function int GetCurrentIndex()
{
	if ( ValidIndex(CurrentPlaylist) )
		return CurrentPlaylist;

	return -1;
}

function StreamPlaylist GetCurrentPlaylist()
{
	if ( ValidIndex(CurrentPlaylist) )
		return Playlists[CurrentPlaylist];

	if ( ActivatePlaylist(0) )
		return Playlists[0];

	return CreateDefaultPlaylist();
}

function StreamPlaylist GetRandomPlaylist()
{
	local int i, idx;

	if ( Playlists.Length == 0 )
		return None;

	idx = Rand(Playlists.Length - 1);
	while ( ++i < 10 )
	{
		if ( ActivatePlaylist(idx) )
			return Playlists[CurrentPlaylist];

		idx = Rand(Playlists.Length - 1);
	}

	return None;
}

function StreamPlaylist GetPlaylistAt( int idx )
{
	if ( !ValidIndex(idx) )
		return None;

	return Playlists[idx];
}

function int GetPlaylistCount()
{
	return Playlists.Length;
}

// Current playlist interaction

function bool ValidIndex( int Index )
{
	return Index >= 0 && Index < Playlists.Length;
}

function int FindNameIndex( string PlaylistName )
{
	local int i;

	if ( PlaylistName == "" )
		return -1;

	for ( i = 0; i < Playlists.Length; i++ )
		if ( Playlists[i].GetTitle() ~= PlaylistName )
			return i;

	return -1;
}

function int FindPlaylistIndex( StreamPlaylist Playlist )
{
	local int i;

	if ( Playlist == None )
		return -1;

	for ( i = 0; i < Playlists.Length; i++ )
		if ( Playlists[i] == Playlist )
			return i;

	return -1;
}

function bool ValidName( string Test )
{
	local int i;

	for ( i = 0; i < Playlists.Length; i++ )
		if ( Test ~= Playlists[i].GetTitle() )
			return true;

	return false;
}

function bool GetShuffle()
{
	return bShuffle;
}

function bool GetShuffleAll()
{
	return bShuffleAll;
}

function bool GetRepeat()
{
	return bRepeat;
}

function bool GetRepeatAll()
{
	return bRepeatAll;
}

// =====================================================================================================================
// =====================================================================================================================
//   Internal
// =====================================================================================================================
// =====================================================================================================================

function SetShuffle( bool bEnable )
{
	bDirty = bDirty || bEnable != bShuffle;
	bShuffle = bEnable;

	if ( bEnable && bShuffleAll )
		SetShuffleAll(False);
}

function SetShuffleAll( bool bEnable )
{
	bDirty = bDirty || bEnable != bShuffleAll;
	bShuffleAll = bEnable;
	if ( bEnable && bShuffle )
		SetShuffle( False );
}

function SetRepeat( bool bEnable )
{
	bDirty = bDirty || bEnable != bRepeat;
	bRepeat = bEnable;

	if ( bEnable && bRepeatAll )
		SetRepeatAll(False);
}

function SetRepeatAll( bool bEnable )
{
	bDirty = bDirty || bEnable != bRepeatAll;
	bRepeatAll = bEnable;

	if ( bEnable && bRepeat )
		SetRepeat(False);
}

protected function StreamPlaylist CreatePlaylist(string PlaylistName)
{
	local StreamPlaylist List;

	if ( PlaylistName == "" )
		return None;

	List = new(None, Repl(PlaylistName, " ", Chr(27))) class'StreamPlaylist';
	if ( List != None )
	{
		List.SetTitle( Repl(PlaylistName, Chr(27), " ") );
		List.Save();
	}

	return List;
}

function bool HandleDebugExec( string Command, string Param )
{
	local int i;
	local bool result;

	if ( Super.HandleDebugExec(Command,Param) )
		return true;

	switch ( Locs(command) )
	{

	case "activate":
		if ( Playlists.Length > 0 )
			ActivatePlaylist(0);
		else ActivatePlaylist(int(Param));

		log("Active Playlist:"$Playlists[CurrentPlaylist].GetTitle()@"Tracks:"$Playlists[CurrentPlaylist].GetPlaylistLength(),'MusicPlayer');
		break;

	case "lists":
		log(" === All existing playlists === ",'MusicPlayer');
		for ( i = 0; i < Playlists.Length; i++ )
			log(" Playlist"@i@" '"$Playlists[i].GetTitle(),'MusicPlayer');
	}

	for (i = 0; i < Playlists.Length; i++ )
		result = Playlists[i].HandleDebugExec(Command,Param) || result;

	return result;
}

function Save()
{
	local int i;

	for ( i = 0; i < Playlists.Length; i++ )
		Playlists[i].Save();

	if ( !bDirty )
		return;

	SaveConfig();
	bDirty = False;
}

function string GetCurrentTitle()
{
	return Playlists[GetCurrentIndex()].GetTitle();
}

defaultproperties
{
     bRepeatAll=True
     DefaultPlaylistName="New Playlist"
     ParserType(0)=(Type=SPT_B4S,ParserClass="Engine.B4SParser")
     ParserType(1)=(Type=SPT_M3U,ParserClass="Engine.M3UParser")
     ParserType(2)=(Type=SPT_PLS,ParserClass="Engine.PLSParser")
}
