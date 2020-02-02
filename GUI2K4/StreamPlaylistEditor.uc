//==============================================================================
//	Created on: 10/12/2003
//	Graphical User Interface for music playlists & navigating the user's file system
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamPlaylistEditor extends FloatingWindow
	DependsOn(StreamBase);


var() editinline editconst noexport StreamInteraction       Handler;
var() editinline editconst noexport StreamInterface         FileManager;
var() editinline editconst noexport StreamPlaylistManager   PlaylistManager;

var() editinline noexport StreamPlaylist                    CurrentPlaylist;
var() editinline noexport DirectoryTreeList                 li_Directory;

var automated GUISectionBackground                          sb_Main;
var automated DirectoryTreeListBox                          lb_Directory;
var automated GUIButton                                     b_Add, b_Done;
var automated moComboBox                                    co_DriveLetters;

var() localized array<string> GeneralFileItems, GeneralFolderItems, PlaylistItems, NonPlaylistItems, ImportItems;


// =====================================================================================================================
// =====================================================================================================================
//  GUI methods
// =====================================================================================================================
// =====================================================================================================================

final operator(46) array<string> += ( out array<string> A, array<string> B )
{
	local int i, j;

	j = A.Length;
	A.Length = B.Length + j;
	for ( i = 0; i < B.Length; i++ )
		A[j++] = B[i];

	return A;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<string> dl;
	local int i;

	Super.InitComponent(MyController, MyOwner);

	sb_Main.ManageComponent(lb_Directory);

	if ( !SetFileManager() )
		Warn("Error setting FileManager!");

	li_Directory = lb_Directory.List;
	li_Directory.FileManager = FileManager;
	li_Directory.OnChange = UpdateCurrentPath;
	li_Directory.OnDblClick = InternalOnDblClick;
	li_Directory.bDropSource=True;
	li_Directory.bMultiSelect=True;

	FileManager.GetDriveLetters(dl);
	co_DriveLetters.MyComboBox.bIgnoreChangeWhenTyping = True;
	for (i=0;i<dl.Length;i++)
		co_DriveLetters.AddItem(dl[i] $ FileManager.GetPathSeparator());

	InitializeDirectoryList();
}

function DCOnChange(GUIComponent Sender)
{
	local string s;

	s = co_DriveLetters.GetText();
	li_Directory.ChDir(s);
}

function HandleParameters( String Param1, string Param2 )
{
	t_WindowTitle.SetCaption( WindowName @ "-" @ Param1 );
}

event Closed(GUIComponent Sender, bool bCancelled )
{
	Super.Closed(Sender, bCancelled);
	PlaylistManager.Save();
}

function bool InternalOnKeyEvent( out byte iKey, out byte State, float Delta )
{
	local Interactions.EInputKey Key;

	if ( EInputAction(State) != IST_Release || FocusedControl != lb_Directory )
		return false;

	Key = EInputKey(iKey);
	if ( Key == IK_Backspace || Key == IK_Left || Key == IK_NumPad4 )
	{
		li_Directory.ChDir("..");
		return true;
	}

	if ( Key == IK_Enter || Key == IK_Right || Key == IK_NumPad6 )
	{
		InternalOnDblClick(None);
		return true;
	}

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local array<string> Items;
	local int i, PlaylistIndex, idx;
	local bool bResult;

	switch(Sender)
	{
	case b_Add:
		Items = li_Directory.GetPendingItems(True);
		PlaylistIndex = PlaylistManager.GetCurrentIndex();

		idx = PlaylistManager.GetCurrentPlaylist().GetPlaylistLength();
		for ( i = Items.Length - 1; i >= 0; i-- )
			bResult = PlaylistManager.InsertInPlaylist( PlaylistIndex, idx, Items[i], i > 0 );

		return bResult;

	case b_Done:
		Controller.CloseMenu(False);
		return true;
	}

	return false;
}

function ContextClick( GUIContextMenu Menu, int Index )
{
	local StreamBase.FilePath Path;

	PlaylistManager.ParsePath(li_Directory.Get(True), Path);
//	log("StreamPlaylistEditor.ContextClick Index:"$Index@"Path:"$Path.FullPath,'MusicPlayer');
	switch ( Menu.ContextItems[Index] )
	{
		case GeneralFileItems[0]:	// play selected
			Handler.PlaySong(Path.FullPath,0.0);
			break;

		case PlaylistItems[0]: // remove selected
			PlaylistManager.RemoveFromCurrentPlaylist(Path.FullPath);
			break;

		case GeneralFolderItems[0]:
		case NonPlaylistItems[0]: // Add to playlist
			AddToPlaylist(Path.FullPath);
			break;

		case NonPlaylistItems[1]: // add to playlist and play
			AddToPlaylist(Path.FullPath);
			Handler.PlaySong(Path.FullPath,0.0);
			break;

		case ImportItems[0]:	// Import as new
			PlaylistManager.ImportPlaylist(-1,-1,Path.FullPath);
			break;

		case ImportItems[1]:
			AddToPlaylist(Path.FullPath);
			break;
	}
}

// Assigned to li_Directory.OnChange
function UpdateCurrentPath( GUIComponent Sender )
{
	if ( Sender == li_Directory )
		co_DriveLetters.SetText(FileManager.GetCurrentDirectory());
}

function bool InternalOnDblClick(GUIComponent Sender)
{
	local string s;

	s = li_Directory.Get();

//	log("InternalOnDblClick Item:"$s@"Path:"$li_Directory.GetPath(),'MusicPlayer');

	if ( PlaylistManager.HasExtension(s) )
		AddToPlaylist( li_Directory.Get(True) );
	else
		li_Directory.ChDir( li_Directory.GetPath() );

	return true;
}

function bool AddPreDraw( Canvas C )
{
	if ( !bCaptureMouse || bMoving )
		return false;

	b_Add.WinTop = b_Add.RelativeTop( lb_Directory.ActualTop() );
	return true;
}

function bool ClosePreDraw( Canvas C )
{
	if ( !bCaptureMouse || bMoving )
		return false;

	b_Done.WinTop = b_Done.RelativeTop((lb_Directory.ActualTop() + lb_Directory.ActualHeight()) - b_Done.ActualHeight());
	return true;
}

function bool InternalRightClick( GUIComponent Sender )
{
	if ( Controller == None || Controller.ActiveControl != li_Directory )
		return false;

	return true;
}

function bool ContextOpen( GUIContextMenu Menu )
{
	local string Selected;
	local StreamBase.FilePath Path;

	Selected = li_Directory.Get( True );
	if ( PlaylistManager.ParsePath(Selected, Path) )
	{
		if ( Path.FullPath != "" )
		{
			if ( Path.Extension != "" ) // file
			{
				Menu.ContextItems = GeneralFileItems;
				if ( Path.Extension == "m3u" || Path.Extension == "b4u" || Path.Extension == "pls" )
					Menu.ContextItems += ImportItems;
				else if ( CurrentPlaylist.FindIndexByPath(Path.FullPath) != -1 )
					Menu.ContextItems += PlaylistItems;
				else Menu.ContextItems += NonPlaylistItems;
			}
			else	// folder
				Menu.ContextItems = GeneralFolderItems;
		}
		return true;
	}

	return false;
}

// =====================================================================================================================
// =====================================================================================================================
//  Initialization
// =====================================================================================================================
// =====================================================================================================================

function bool SetFileManager()
{
	if ( FileManager != None )
	{
		if ( PlaylistManager == None && !SetPlaylistManager() )
			return false;

		return true;
	}

	if ( PlaylistManager == None && !SetPlaylistManager() )
		return false;

	FileManager = Handler.FileManager;
	return FileManager != None;
}

function bool SetPlaylistManager()
{
	if ( PlaylistManager != None )
	{
		if ( Handler == None && !SetHandler() )
			return false;

		return true;
	}

	if ( Handler == None && !SetHandler() )
		return false;

	PlaylistManager = Handler.PlaylistManager;
	CurrentPlaylist = PlaylistManager.GetCurrentPlaylist();
	return true;
}

function bool SetHandler()
{
	local int i;

	if ( Controller == None || Controller.ViewportOwner == None )
		return false;

	for ( i = 0; i < Controller.ViewportOwner.LocalInteractions.Length; i++ )
	{
		if ( StreamInteraction(Controller.ViewportOwner.LocalInteractions[i]) != None )
		{
			Handler = StreamInteraction(Controller.ViewportOwner.LocalInteractions[i]);
//			Handler.Editor = Self;
			return true;
		}
	}


	log("StreamPlayer.SetHandler() - no StreamInteractions found!",'MusicPlayer');
	return false;
}

function InitializeDirectoryList()
{
	local int i;
	local array<string> Drives;

	if ( !FileManager.GetDriveLetters( Drives ) )
	{
		Warn("FileManager returned no valid drives!");
		return;
	}

//	log("FileManager returned the following drives:"@JoinArray(Drives, ",", True),'MusicPlayer' );

	li_Directory.bNotify = False;
	li_Directory.Clear();
	for ( i = 0; i < Drives.Length; i++ )
		li_Directory.AddNode( None, Drives[i] );
	li_Directory.bNotify = True;

	li_Directory.ChDir( FileManager.GetCurrentDirectory() );
}

function bool AddToPlaylist( string FileName )
{
	return PlaylistManager.AddToPlaylist(-1, FileName);
}

function bool HandleDebugExec( string Command, string Param )
{
	return li_Directory.HandleDebugExec(Command,Param);
}

function bool FloatingPreDraw( Canvas C )
{
	local float AT,bh,bl,bt;
	local bool b;
	// Position All Controls..

	b = super.FloatingPreDraw(C);

	bh = b_Done.ActualHeight();
	bt = ActualTop() + ActualHeight() - 20 - bh;
	bl = ActualLeft() + ActualWidth() - 24 - b_Done.ActualWidth();

	b_Done.WinTop = b_Done.RelativeTop(bt);
	b_Done.WinLeft = b_Done.RelativeLeft(bl);
	bl -= b_Add.ActualWidth()+(ActualWidth()*0.01);
	b_Add.WinLeft = b_Add.RelativeLeft(bl);
	b_Add.WinTop = b_Add.RelativeTop(bt);

	AT = t_WindowTitle.ActualTop() + t_WindowTitle.ActualHeight() + (ActualHeight()*0.01);

	co_DriveLetters.WinLeft = co_DriveLetters.RelativeLeft(ActualLeft() + (ActualWidth()*0.04));
	co_DriveLetters.WinTop = co_DriveLetters.RelativeTop(At);
	co_DriveLetters.WinWidth = co_DriveLetters.RelativeWidth(ActualWidth()*0.92);
	AT += co_DriveLetters.ActualHeight() + (ActualHeight()*0.01);

	sb_Main.WinTop = sb_Main.RelativeTop(AT);
	sb_Main.WinHeight = sb_Main.RelativeHeight(bt - ( ActualHeight() * 0.01 ) - AT);
	sb_Main.WinLeft = sb_Main.RelativeLeft(ActualLeft());
	sb_Main.WinWidth = sb_Main.RelativeWidth(ActualWidth());
	return b;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=MainPanel
         WinTop=0.150000
         WinHeight=0.700000
         RenderWeight=0.200000
         OnPreDraw=MainPanel.InternalPreDraw
     End Object
     sb_Main=AltSectionBackground'GUI2K4.StreamPlaylistEditor.MainPanel'

     Begin Object Class=DirectoryTreeListBox Name=UserDirectory
         bVisibleWhenEmpty=True
         OnCreateComponent=UserDirectory.InternalOnCreateComponent
         WinTop=0.027778
         WinLeft=0.020833
         WinWidth=0.760413
         WinHeight=0.939583
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Directory=DirectoryTreeListBox'GUI2K4.StreamPlaylistEditor.UserDirectory'

     Begin Object Class=GUIButton Name=AddButton
         Caption="Add"
         Hint="Add selected item to playlist.  If selected item is a directory, all songs in the directory will be added to the playlist."
         WinTop=0.041667
         WinLeft=0.822917
         WinWidth=0.145830
         ScalingType=SCALE_X
         OnClick=StreamPlaylistEditor.InternalOnClick
         OnKeyEvent=AddButton.InternalOnKeyEvent
     End Object
     b_Add=GUIButton'GUI2K4.StreamPlaylistEditor.AddButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="CLOSE"
         WinTop=0.844444
         WinLeft=0.822917
         WinWidth=0.156247
         ScalingType=SCALE_X
         OnClick=StreamPlaylistEditor.InternalOnClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     b_Done=GUIButton'GUI2K4.StreamPlaylistEditor.CloseButton'

     Begin Object Class=moComboBox Name=lbDriveLetters
         CaptionWidth=0.300000
         Caption="Directory:"
         OnCreateComponent=lbDriveLetters.InternalOnCreateComponent
         FontScale=FNS_Small
         WinTop=0.100000
         WinLeft=0.100000
         WinWidth=0.900000
         WinHeight=32.000000
         OnChange=StreamPlaylistEditor.DCOnChange
     End Object
     co_DriveLetters=moComboBox'GUI2K4.StreamPlaylistEditor.lbDriveLetters'

     GeneralFileItems(0)="Play selected"
     GeneralFolderItems(0)="Add to playlist"
     PlaylistItems(0)="Remove from playlist"
     NonPlaylistItems(0)="Add to playlist"
     NonPlaylistItems(1)="Add to playlist & play"
     ImportItems(0)="Import to new playlist"
     ImportItems(1)="Import to current playlist"
     WindowName="Adding Songs to "
     MinPageWidth=0.375000
     MinPageHeight=0.227902
     bPersistent=True
     Begin Object Class=GUIContextMenu Name=RCMenu
         OnOpen=StreamPlaylistEditor.ContextOpen
         OnSelect=StreamPlaylistEditor.ContextClick
     End Object
     ContextMenu=GUIContextMenu'GUI2K4.StreamPlaylistEditor.RCMenu'

     OnRightClick=StreamPlaylistEditor.InternalRightClick
     OnKeyEvent=StreamPlaylistEditor.InternalOnKeyEvent
}
