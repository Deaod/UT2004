//==============================================================================
//	Created on: 10/21/2003
//	File System Object
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamDirectoryNode extends StreamBase
	within DirectoryTreeList;

var() StreamDirectoryNode        Parent;
var() editconst editinline array<StreamDirectoryNode> Children;
var() editconst editinline array<string>              Contents;

var()           private int    NodeRenderCost, ChildRenderCost;
var() editconst private string MyPath;
var() editconst private string DirectoryName;
var()           private bool   bExpanded;
var() private bool   bInitialized;

function InitializeNode()
{
	if ( Initialized() )
		return;

	Clear();
	bInitialized = True;

	// Maybe root
	if ( Parent == None || MyPath == "" || MyPath == ".." )
		return;

	if ( bSimpleFileBrowsing )
		AddChild("..").InitializeNode();

	RefreshNodeContents();
}

function RefreshNodeContents()
{
	local int i;
	local array<string> Directories, Files;

	if ( FileManager == None )
	{
		log("Cannot refresh node '"$MyPath$"' contents - File Manager not set.",'MusicPlayer');
		return;
	}

	if ( HasChildren() )
	{
		for ( i = Children.Length - 1; i >= 0; i-- )
			if ( Children[i].GetPath() != ".." )
				Children.Remove(i,1);
	}

	Contents.Remove(0, Contents.Length);

	FileManager.GetDirectoryContents( Directories, MyPath, FILE_Directory );
	for ( i = 0; i < Directories.Length; i++ )
		AddChild(Directories[i]);

	FileManager.GetDirectoryContents( Files, MyPath, FILE_Stream );
	FileManager.GetDirectoryContents( Files, MyPath, FILE_Playlist );
	for ( i = 0; i < Files.Length; i++ )
		AddContent(Files[i]);

	UpdateCost();
}

function Clear( optional bool bPropagate )
{
	local int i;

//	log(GetName()@"Clear");
	if ( HasChildren() && bPropagate )
	{
		for ( i = 0; i < Children.Length; i++ )
			Children[i].Clear(bPropagate);
	}

	Children.Remove(0, Children.Length);
	Contents.Remove(0, Contents.Length);
	UpdateCost();

	bInitialized = False;
}

function string GetIndent()
{
	local string Indent;

	if ( bSimpleFileBrowsing )
		return "";

	if ( Parent != None )
		Indent = Parent.GetIndent() $ " ";

	return Indent;
}

function string GetNodePrefix( bool bNoPrefix )
{
	if ( bNoPrefix )
		return "";

	if ( IsEmpty() )
		return GetIndent() $ ". ";

	if ( !IsOpen() )
		return GetIndent() $ "+ ";

	return GetIndent() $ "- ";
}

function string NodeText( int VisibleIndex, optional bool bNoPrefix )
{
	local StreamDirectoryNode Node;

	if ( !IsOpen() )
		return GetNodePrefix(bNoPrefix) $ DirectoryName;

	Node = FindVisibleNode(VisibleIndex);
	if ( Node == Self )
	{
		if ( VisibleIndex >= 0 && VisibleIndex < Contents.Length )
			return Contents[VisibleIndex];

		return GetNodePrefix(bNoPrefix) $ DirectoryName;
	}

	return Node.NodeText(VisibleIndex,bNoPrefix);
}

function StreamDirectoryNode FindVisibleNode( out int idx )
{
	local int count, i;

	if ( !IsOpen() )
		return Self;

	InitializeNode();
	if ( idx > 0 )
	{
		count = Children[0].Cost();
		if ( HasChildren() )
		{
			while ( count <= idx && ++i < Children.Length )
				count += Children[i].Cost();
		}

		if ( i == Children.Length || !HasChildren() )
		{
			idx -= count;
			return Self;
		}

		idx = count - idx;
	}

	return Children[i].FindVisibleNode( idx );
}

function int FindVisibleNodeIndex( string Path )
{
	local int i, VisibleIndex;
	local string MyComponent;

	if ( Path == "" )
		return 1;

	InitializeNode();
	MyComponent = StripPathComponent(Path);
	if ( MyComponent == "" )
		MyComponent = Path;

	VisibleIndex = 1;
	for ( i = 0; i < Children.Length; i++ )
	{
		if ( CompareNames(MyComponent, Children[i].GetName()) )
			return VisibleIndex + Children[i].FindVisibleNodeIndex(Path);

		VisibleIndex += Children[i].Cost();
	}

	for ( i = 0; i < Contents.Length; i++ )
	{
		if ( CompareNames(MyComponent, Contents[i]) )
			break;

		VisibleIndex++;
	}

	return VisibleIndex;
}

function int Cost()
{
	return NodeRenderCost + ChildRenderCost;
}

function UpdateCost( optional bool bFullUpdate )
{
	local int i;

	NodeRenderCost = 0;
	ChildRenderCost = 0;

	if ( !IsOpen() )
		NodeRenderCost = 1;

	else
	{
		if ( !bSimpleFileBrowsing )
			NodeRenderCost = 1;

		for ( i = 0; i < Children.Length; i++ )
		{
			if ( bFullUpdate )
				Children[i].UpdateCost( bFullUpdate );

			ChildRenderCost += Children[i].Cost();
		}

		NodeRenderCost += Contents.Length;
	}
}

function Toggle()
{
	if ( IsOpen() )
		Collapse();

	else Expand();
}

function Expand( optional bool bFullUpdate )
{
	InitializeNode();

	bExpanded = True;
	UpdateCost(bFullUpdate);
}

function Collapse( optional bool bFullUpdate )
{
	InitializeNode();

	bExpanded = False;
	UpdateCost(bFullUpdate);
}

function bool ChangeDirectory( string Path, out StreamDirectoryNode Node, optional bool bRefreshContents )
{
	local int i;
	local string MyComponent;

	InitializeNode();

//	log(GetName()@"ChangeDirectory to '"$Path$"'",'MusicPlayer');
	if ( Path == "" || Path == "." )
	{
		if ( bRefreshContents && Initialized() )
			RefreshNodeContents();

		if ( IsEmpty() )
		{
			Node = None;
			return false;
		}

		Expand();
		Node = Self;
		return true;
	}

	if ( Path == ".." )
	{
		if ( Parent == None )
		{
			Expand();
			Node = Self;
			return true;
		}

		Collapse();
		return Parent.ChangeDirectory("",Node,bRefreshContents);
	}

	MyComponent = StripPathComponent(Path);
	if ( MyComponent == "" )
	{
		MyComponent = Path;
		Path = "";
	}

	i = FindChildIndex(MyComponent);
	if ( Valid(i) )
	{
		if ( Children[i].ChangeDirectory(Path, Node, bRefreshContents) )
		{
			Collapse();
			return true;
		}
	}

	Node = None;
	return false;
}

function bool ExpandPath( string Path )
{
	local int i, idx;
	local string s;

	InitializeNode();
	if ( Path == "" )
	{
		Expand();
		return true;
	}

	s = StripPathComponent(Path);
	if ( s == "" )
		s = Path;

	if ( s != "" )
	{
		idx = FindChildIndex(s);
		if ( Valid(idx) )
		{
			for ( i = 0; i < Children.Length; i++ )
			{
				if ( Children[i] != Children[idx] )
					Children[i].Collapse();
			}

			if ( Path != "" )
				Children[idx].ExpandPath(Path);
		}

		Expand();
		return true;
	}

	return false;
}

function StreamDirectoryNode AddChild( string ChildName )
{
	local int i;
	local string s;
	local StreamDirectoryNode Child;

	if ( ChildName == "" )
		return None;

	InitializeNode();

//	log(DirectoryName@"adding directory:"@ChildName,'MusicPlayer');
	while ( i < Children.Length )
	{
		s = Children[i].GetName();
		if ( CompareNames(s, ChildName) )
			return Children[i];

		if ( ChildName < s )
			break;

		i++;
	}

	Child = CreateChild(ChildName);
	if ( Child == None )
	{
		log(GetName()@"failed to successfully create child '"$ChildName$"'",'MusicPlayer');
		return None;
	}

	Children.Insert( i, 1 );
	Children[i] = Child;
	UpdateCost();

	return Child;
}

function bool AddContent( string ContentName )
{
	local int i;
	local string s;

	if ( ContentName == "" )
		return false;

	InitializeNode();

	s = StripPathComponent(ContentName);
	if ( s != "" )
	{
		i = FindChildIndex(s);
		if ( Valid(i) )
			return Children[i].AddContent(ContentName);

		return false;
	}

	i = FindFileIndex(ContentName);
	if ( i == -1 )
		Contents[Contents.Length] = ContentName;

	return true;
}

function bool RemoveChild( StreamDirectoryNode Child )
{
	local int i;

	if ( Child == None )
		return false;

	InitializeNode();
	i = FindChildIndex(Child.GetName());
	return RemoveChildAt(i);
}

function bool RemoveChildAt( int i )
{
	if ( Valid(i) )
	{
		Children.Remove(i,1);
		UpdateCost(True);
		return true;
	}

	return false;
}

function bool RemoveContent( string Path )
{
	local string s;
	local int i;

	InitializeNode();

	s = StripPathComponent(Path);
	if ( s != "" )
	{
		i = FindChildIndex(s);
		if ( Valid(i) )
			return Children[i].RemoveContent(Path);

		return false;
	}

	i = FindFileIndex(Path);
	return RemoveContentAt(i);
}

function bool RemoveContentAt( int i )
{
	if ( ValidFile(i) )
	{
		Contents.Remove(i,1);
		UpdateCost(True);
		return true;
	}

	return false;
}

function int FindFileIndex( string FileName )
{
	local int i;

	if ( FileName == "" )
		return -1;

	InitializeNode();

	for ( i = 0; i < Contents.Length; i++ )
		if ( CompareNames(Contents[i], FileName) )
			return i;

	return -1;
}

function bool SetName( string InName )
{
	if ( InName == "" )
		return false;

	DirectoryName = InName;
	return true;
}

function bool SetParent( StreamDirectoryNode InParent )
{
	if ( InParent == None || Parent != None )
		return false;

	Parent = InParent;
	return true;
}

function bool SetPath( string InPath )
{
	if ( MyPath != "" )
		return false;

	if ( DirectoryName == ".." )
	{
		MyPath = DirectoryName;
		return true;
	}

	MyPath = InPath $ DirectoryName $ GetPathSeparator();
	return true;
}

function bool Initialized()
{
	return bInitialized;
}

function bool IsEmpty()
{
	return Initialized() && !HasChildren() && Contents.Length == 0;
}

function bool IsOpen()
{
	return bExpanded;
}

function string GetName()
{
	return DirectoryName;
}

function string GetPath()
{
	return MyPath;
}

function StreamDirectoryNode FindChildByPath( out string Path )
{
	local string ChildName;
	local int i;

	InitializeNode();
	if ( Path == "" )
		return Self;

	ChildName = StripPathComponent(Path);
	if ( ChildName == "" )
		return Self;

	i = FindChildIndex(ChildName);
	if ( Valid(i) )
		return Children[i].FindChildByPath(Path);

	return None;
}

function StreamDirectoryNode FindChild( string ChildName, optional bool bDeepSearch )
{
	local int i;
	local StreamDirectoryNode Node;

	InitializeNode();
	for ( i = 0; i < Children.Length; i++ )
	{
		if ( CompareNames(Children[i].GetName(), ChildName) )
			return Children[i];

		if ( bDeepSearch )
		{
			Node = Children[i].FindChild(ChildName, bDeepSearch);
			if ( Node != None )
				return Node;
		}
	}

	return None;
}

function int FindChildIndex( string ChildName )
{
	local int i;

	if ( ChildName == "" )
		return -1;

	InitializeNode();

//	log(GetName()@"FindChildIndex ChildName '"$ChildName$"'",'MusicPlayer');
	if ( Right(ChildName,1) == GetPathSeparator() )
		ChildName = Left(ChildName, Len(ChildName) - 1);

	for ( i = 0; i < Children.Length; i++ )
		if ( CompareNames(Children[i].GetName(), ChildName) )
			return i;

	return -1;
}


function bool HasChildren()
{
	if ( bSimpleFileBrowsing )
		return Children.Length > 1;

	return Children.Length > 0;
}

function bool Valid( int i )
{
	return i >= 0 && i < Children.Length && Children[i] != None;
}

function bool ValidFile( int i )
{
	return i >= 0 && i < Contents.Length;
}

// =====================================================================================================================
//
//    Internal
//
// =====================================================================================================================

protected function StreamDirectoryNode CreateChild( string ChildName )
{
	local StreamDirectoryNode Child;

	if ( ChildName == "" )
		return None;

	Child = new(Outer) class'GUI2K4.StreamDirectoryNode';
	Assert(Child != None);

	Child.SetParent( Self );
	Child.SetName( ChildName );
	Child.SetPath( MyPath );
	return Child;
}

static function string StripPathComponent( out string Path )
{
	local string s;
	local int i;

	if ( Path == "" )
		return "";

	i = InStr(Path, GetPathSeparator());
	if ( i == -1 )
		return "";

	s = Left(Path,i);
	Path = Mid(Path,i+1);
	return s;
}

function bool HandleDebugExec( string Command, string Param )
{
	local int i;
	local StreamDirectoryNode Node;

	switch ( Command )
	{
	case "cwd":
		log("Current Directory:"$GetPath(),'MusicPlayer');
		return true;

	case "dumpcwd":
		log("Dumping directory contents for"@GetName(),'MusicPlayer');
		for ( i = 0; i < Children.Length; i++ )
			log(" Child "$i@"'"$Children[i].GetName()$"'",'MusicPlayer');
		for ( i = 0; i < Contents.Length; i++ )
			log(" Content "$i@"'"$Contents[i]$"'",'MusicPlayer');

		return true;

	case "cost":
		if ( Param == "" )
			Node = Self;
		else
		{
			Node = FindChild(Param);
			if ( Node == None )
			{
				log("Couldn't find child '"$Param$"' in directory"@GetName(),'MusicPlayer');
				return true;
			}
		}

		log("Cost for directory '"$Node.GetName()$"': "$Node.Cost()@"Open:"$Node.IsOpen()@"Initialized:"$Node.Initialized(),'MusicPlayer');
		return true;
	}

	return false;
}

defaultproperties
{
     NodeRenderCost=1
}
