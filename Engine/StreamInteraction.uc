//==============================================================================
//	Created on: 10/12/2003
//	Relays player input to the appropriate handlers on behalf of the streaming music system
//  Relays notification of streaming music events to the appropriate handlers
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamInteraction extends Interaction
	Native
	Config(User);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() config float FadeInSeconds;
var() config float FadeOutSeconds;

var() config string PlaylistManagerType;
var() editconst noexport editinline StreamPlaylistManager   PlaylistManager;
var() editconst noexport editinline StreamInterface         FileManager;

var() editconst noexport protected int CurrentSongHandle;
var() editconst noexport protected float CurrentSongPosition, LastPlayTime, CurrentSongDuration;
var() editconst noexport protected string CurrentSong;
var() editconst noexport Stream CurrentStreamAttachment;

var() config    bool bAutoStart;             // Whether to automatically start the stream player when the game is started
var() config    bool bDisplayTrackChanges;   // When new song begins, display the track name on the HUD for a few seconds
var() transient editconst noexport protected bool bRestartTrack;          // Used to restart stream after level change
var() transient editconst noexport protected bool bTrackWaiting;          // Used to switch tracks

delegate OnStreamChanged( string NewStreamFileName );
delegate OnStreamingStopped();
delegate OnAdjustVolume( float NewVolume );

const INVALIDSONGHANDLE = 0;

// =====================================================================================================================
// =====================================================================================================================
//  Initialization
// =====================================================================================================================
// =====================================================================================================================

event Initialized()
{
	Super.Initialized();

	ClearSongInfo();

	FileManager = CreateFileManager();
	PlaylistManager = CreatePlaylistManager();
	if ( PlaylistManager != None )
		PlaylistManager.Initialize( FileManager );

	if ( bAutoStart )
		QueueNextSong();
}

function StreamInterface CreateFileManager()
{
	return new class'Engine.StreamInterface';
}

function StreamPlaylistManager CreatePlaylistManager()
{
	local class<StreamPlaylistManager> PlaylistManagerClass;

	if ( PlaylistManagerType != "" )
		PlaylistManagerClass = class<StreamPlaylistManager>(DynamicLoadObject(PlaylistManagerType,class'Class'));

	if ( PlaylistManagerClass == None )
		PlaylistManagerClass = class'Engine.StreamPlaylistManager';

	return new PlaylistManagerClass;
}

function QueueNextSong()
{
	bTrackWaiting = True;
}

event Tick( float DeltaTime )
{
	if ( bTrackWaiting )
		NextSong();

	else if ( bRestartTrack )
	{
		bRestartTrack = False;
		PlayStream(CurrentSong, CurrentSongPosition);
	}

	else if ( !IsPaused() && CurrentSongHandle != INVALIDSONGHANDLE )
		CurrentSongPosition += (DeltaTime / ViewportOwner.Actor.Level.TimeDilation);
}

// =====================================================================================================================
// =====================================================================================================================
//  Notification / Events
// =====================================================================================================================
// =====================================================================================================================

native final function bool IsPaused( optional int SongHandle );

function SetStreamAttachment( Stream StreamObj )
{
	local StreamTag sTag;

	CurrentStreamAttachment = StreamObj;
	if ( CurrentStreamAttachment != None )
	{
		sTag = CurrentStreamAttachment.GetTag();
		if ( sTag != None )
			CurrentSongDuration = float(sTag.Duration.FieldValue) / 1000.0;
	}
}

// Called when the current song is over
function StreamFinished( int Handle, EStreamFinishReason Reason )
{
	Super.StreamFinished( Handle, Reason );

	PlaylistManager.Save();

	log("StreamFinished() Handle:"$Handle@"Reason:"$GetEnum(enum'EStreamFinishReason',Reason),'MusicPlayer');
	if ( Handle == CurrentSongHandle && CurrentSongHandle != INVALIDSONGHANDLE )
	{
		log("CurrentSongPosition:"$class'StreamBase'.static.FormatTimeDisplay(CurrentSongPosition)@"Total song time:"$class'StreamBase'.static.FormatTimeDisplay(GetStreamDuration()));
		CurrentSongPosition = 0.0;
		CurrentSongHandle = INVALIDSONGHANDLE;
		SetStreamAttachment(None);
		OnStreamingStopped();
		QueueNextSong();
	}
	else log(Name@"StreamFinished Invalid Song Handle",'MusicPlayer');
}

event NotifyLevelChange()
{
//	log("Last Position before level change was:"$CurrentSongPosition);
	if ( CurrentSongHandle != INVALIDSONGHANDLE && CurrentSong != "" )
		bRestartTrack = True;
}

// =====================================================================================================================
// =====================================================================================================================
//   Commands
// =====================================================================================================================
// =====================================================================================================================

exec function string GetCurrentStream()
{
	HasPlayer();
	log("CurrentSongHandle:"$CurrentSongHandle@"CurrentSong:"$CurrentSong@"IsPaused:"$IsPaused());

	return CurrentSong;
}

function int CurrentHandle()
{
	return CurrentSongHandle;
}

exec function NextSong( optional bool bForce )
{
	if ( !HasPlayer() )
		return; //!! Might cause player to get stuck

	bTrackWaiting = False;
	PlayStream( PlaylistManager.NextSong(bForce) );
}

exec function PrevSong( optional bool bForce )
{
	if ( !HasPlayer() )
		return;

	bTrackWaiting = False;

	// Unless we're still in the first three seconds of the song,
	// restart the current track
	if ( CurrentSongPosition > 3.0 )
		PlayStream( CurrentSong );

	else PlayStream( PlaylistManager.PrevSong(bForce) );
}

exec function PauseSong()
{
	if ( !HasPlayer() )
		return;

	if ( CurrentSongHandle != INVALIDSONGHANDLE )
		PC().PauseStream(CurrentSongHandle);
}

exec function PlaySong( string SongName, float InitialTime )
{
	if ( !HasPlayer() )
		return;

//	log("PlaySong SongName:"$SongName@"InitialTime:"$InitialTime);
	PlayStream(SongName, InitialTime);
}

exec function StopSong()
{
	if ( !HasPlayer() )
		return;

	if ( CurrentSongHandle != INVALIDSONGHANDLE )
		PC().StopStream(CurrentSongHandle, FadeOutSeconds);

	// Re-enable music playback
	PC().AllowMusicPlayback(True);
	ClearSongInfo();
}

exec function SetMusicVolume( float NewVolume )
{
	if ( HasPlayer() )
	{
		PC().AdjustVolume( CurrentSongHandle, FClamp(NewVolume, 0.0, 1.0) );
		OnAdjustVolume(NewVolume);
	}
}

exec function SeekStream( float Seconds )
{
	Seek(Seconds);
}
// =====================================================================================================================
// =====================================================================================================================
//  Stream Manipulation
// =====================================================================================================================
// =====================================================================================================================
function bool Seek( float SeekSeconds )
{
//	log("StreamInternaction CurrentHandle:"$CurrentSongHandle@"CurrentPosition:"$CurrentSongPosition@"seeking to "$SeekSeconds);
	// Current decoder doesn't support seeking, so just return false
	return False;
	if ( CurrentSongHandle != INVALIDSONGHANDLE )
	{
		if ( PC().SeekStream(CurrentSongHandle, SeekSeconds) > 0 )
		{
			CurrentSongPosition = SeekSeconds;
			return true;
		}
	}

	return false;
}

function PlayStream( string FileName, optional int SeekSeconds )
{
	local int LastSongHandle;

	if ( FileName != "" )
	{
		if ( FileName == CurrentSong && IsPaused() && SeekSeconds == 0.0 )
		{
			PauseSong();
			return;
		}

		// Current decoder doesn't support seeking - reset this value unless decoder is changed
		SeekSeconds = 0;
		LastSongHandle = CurrentSongHandle;

		if ( SeekSeconds > 0.0 && CurrentSong == FileName )
			CurrentSongHandle = PC().PlayStream(FileName, True);
		else CurrentSongHandle = PC().PlayStream(FileName, True);

		if ( CurrentSongHandle == INVALIDSONGHANDLE )
			log("StreamInteraction::PlaySong() Invalid song name:"@FileName,'MusicPlayer');
		else
		{
			KillMusic();
			CurrentSongPosition = SeekSeconds;
			CurrentSongDuration = 0.0;

			if ( LastSongHandle != INVALIDSONGHANDLE )
			{
				if ( SeekSeconds > 0.0 && CurrentSong == Filename )
					PC().StopStream(LastSongHandle);
				else PC().StopStream(LastSongHandle, FadeOutSeconds);
			}

			CurrentSong = Filename;

			// TODO : better render to hud
			if ( bDisplayTrackChanges )
				PC().ClientMessage( "Now playing '"$CurrentSong$"' Handle:"$CurrentSongHandle);

			OnStreamChanged(CurrentSong);
		}
	}
	else
	{
		if ( CurrentSongHandle == INVALIDSONGHANDLE )
		{
			PC().AllowMusicPlayback(True);
			ClearSongInfo();
		}
	}
}

function float GetStreamPosition()
{
	return CurrentSongPosition;
}

function float GetStreamVolume()
{
	if ( HasPlayer() )
		return float(PC().ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"));

	return 0.8;
}

function float GetStreamDuration()
{
	if ( !IsPlaying() )
		return 0.0;

	if ( CurrentSongDuration == 0.0 )
		CurrentSongDuration = float(PC().ConsoleCommand("GETDURATION"@CurrentSongHandle));

	return CurrentSongDuration;
}

// =====================================================================================================================
// =====================================================================================================================
//  Utility / Internal
// =====================================================================================================================
// =====================================================================================================================

// Call SongNext() when Tick() is called

function bool IsPlaying()
{
	return CurrentSongHandle != INVALIDSONGHANDLE;
}

function bool HasPlayer()
{
	if ( ViewportOwner == None )
	{
		log("StreamInteraction::HasPlayer() - No ViewportOwner!",'MusicPlayer');
		return false;
	}

	if ( ViewportOwner.Actor == None )
	{
		log("StreamInteraction::HasPlayer() - No PlayerController!",'MusicPlayer');
		return false;
	}

	return true;
}

function ClearSongInfo()
{
	// Clear all transients
	SetStreamAttachment(None);
	CurrentSong = "";
	CurrentSongHandle = INVALIDSONGHANDLE;
	CurrentSongPosition = 0.0;
	CurrentSongDuration = 0.0;
}

// Kill any level/background music currently playing, and disable music
protected function KillMusic()
{
	if ( !HasPlayer() )
		return;

	PC().StopAllMusic();
	PC().AllowMusicPlayback(false);
}

protected function PlayerController PC()
{
	if ( HasPlayer() )
		return ViewportOwner.Actor;

	return None;
}

exec function streamdebug( string Command, string Param )
{
	if ( Command ~= "getstats" )
	{
		log(" CurrentSong '"$CurrentSong$"' Handle:"$CurrentSongHandle@"Pos:"$CurrentSongPosition@"Duration:"$CurrentSongDuration);
		return;
	}
	if ( FileManager.HandleDebugExec(Command,Param) )
		return;

	if ( PlaylistManager.HandleDebugExec( Command, Param) )
		return;

//	if ( Editor != None )
//		Editor.HandleDebugExec(Command,Param);
}

defaultproperties
{
     FadeInSeconds=0.500000
     FadeOutSeconds=0.500000
     bRequiresTick=True
}
