//==============================================================================
//	Created on: 10/21/2003
//	Special list for directory structures
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class DirectoryTreeList extends GUIVertList;

var() editconst StreamInterface FileManager;
var() editconst StreamDirectoryNode Root;
var() editconst StreamDirectoryNode Current;

var() config bool bSimpleFileBrowsing;


function InitComponent(GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent(MyController, MyOwner);

	CreateRoot();
	SetCurrent(Root);
}

function CreateRoot()
{
	if ( Root != None )
		return;

	Root = new(Self) class'StreamDirectoryNode';
	Root.SetName("root");
	Root.InitializeNode();
}

function SetCurrent( StreamDirectoryNode Node )
{
	local string Path;

	if ( Node == None )
		Node = Root;

	Current = Node;
	Path = Current.GetPath();
	if ( Path == "" )
		Path = "*";

	if ( FileManager != None )
		FileManager.ChangeDirectory(Path);
}

function bool InternalOnClick(GUIComponent Sender)
{
	return Super.InternalOnClick(Sender);

}

function InternalOnDrawItem(Canvas C, int Item, float X, float Y, float XL, float YL, bool bIsSelected, bool bIsPending)
{
	local string Text;
	local bool bIsDrop;

	Text = VisibleNodeText(Item);
	bIsDrop = Top + Item == DropIndex;

	if (bIsSelected || (bIsPending && !bIsDrop))
	{
		if (SelectedStyle!=None)
		{
			if (SelectedStyle.Images[MenuState] != None)
				SelectedStyle.Draw(C,MenuState, X, Y, XL, YL);
			else
			{
				C.SetPos(X, Y);
				C.DrawTile(Controller.DefaultPens[0], XL, YL,0,0,32,32);
			}
		}
		else
		{
			// Display the selection
			if ( (MenuState==MSAT_Focused)  || (MenuState==MSAT_Pressed) )
			{
				C.SetPos( X, Y );
				if (SelectedImage==None)
					C.DrawTile(Controller.DefaultPens[0], XL, YL,0,0,32,32);
				else
				{
					C.SetDrawColor(SelectedBKColor.R, SelectedBKColor.G, SelectedBKColor.B, SelectedBKColor.A);
					C.DrawTileStretched(SelectedImage, XL, YL);
				}
			}
		}
	}

	if (bIsPending && OutlineStyle != None )
	{
		if ( OutlineStyle.Images[MenuState] != None )
		{
			if ( bIsDrop )
				OutlineStyle.Draw(C, MenuState, X+1, Y+1, XL - 2, YL-2);
			else
			{
				OutlineStyle.Draw(C, MenuState, X, Y, XL, YL);
				if (DropState == DRP_Source)
					OutlineStyle.Draw(C, MenuState, Controller.MouseX - MouseOffset[0], Controller.MouseY - MouseOffset[1] + Y - ClientBounds[1], MouseOffset[2] + MouseOffset[0], ItemHeight);
			}
		}
	}

	if ( bIsSelected && SelectedStyle != None )
		SelectedStyle.DrawText( C, MenuState, X, Y, XL, YL, TXTA_Left, Text, FontScale );

	else Style.DrawText( C, MenuState, X, Y, XL, YL, TXTA_Left, Text, FontScale );
}

function int FindVisibleItemIndex( string Path )
{
	return Current.FindVisibleNodeIndex(Path);
}

function string Get( optional bool bFullPath )
{
	local string Path, File;

	if ( IsValid() )
	{
		if ( bFullPath )
		{
			File = Current.NodeText(Index,True);
			Path = Current.GetPath();
			if ( Path == "" || File == "." || File == ".." )
				return "";

			return Path $ File;
		}

		return Current.NodeText(Index,True);
	}

	return "";
}

// Specify true for bGuarantee to receive the selected item if there are no "pending" items
function array<string> GetPendingItems(optional bool bGuarantee)
{
	local int i;
	local array<string> Items;
	local string str;

	if ( (DropState == DRP_Source && Controller.DropSource == Self) || bGuarantee )
	{
		for ( i = 0; i < SelectedItems.Length; i++ )
			if ( IsValidIndex(SelectedItems[i]) )
			{
				str = GetItemAtIndex(SelectedItems[i]);
				if ( str != "" )
					Items[Items.Length] = str;
			}

		if ( Items.Length == 0 && IsValid() )
		{
			str = GetItemAtIndex(Index);
			if ( str != "" )
				Items[0] = str;
		}
	}

	return Items;
}

function string GetItemAtIndex( int idx )
{
	local string Path, File;
	local StreamDirectoryNode Node;

	if ( IsValidIndex(idx) )
	{
	    Node = VisibleNode(idx);
		File = Node.NodeText(idx,True);
		Path = Node.GetPath();
//		log("GetItemIndex idx:"$idx@"Path:"$Path@"File:"$File);
	    if ( Path == "" || File == "." || File == ".." )
			return "";

		if ( class'StreamBase'.static.HasExtension(File) )
	        return Path $ File;
	    else return Path;
	}

	return "";
}

function string GetCurrentNode()
{
	return Current.GetName();
}

function string GetCurrentNodePath()
{
	return Current.GetPath();
}

function string GetPath()
{
	return GetPathAt(Index);
}

function string GetPathAt( int idx )
{
	local StreamDirectoryNode Node;

	if ( IsValidIndex(idx) )
	{
		Node = VisibleNode(idx);
		if ( Node != None )
			return Node.GetPath();
	}

	return "";
}

function bool ChDir( string Path )
{
	local StreamDirectoryNode Node;

//	log("ChDir:"@Path,'MusicPlayer');

	if ( Current.ChangeDirectory(Path, Node) || Root.ChangeDirectory(Path,Node,True) )
	{
		SetCurrent(Node);
		UpdateItemCount();
		SetTopItem(0);
		SetIndex(-1);

//		log("Current now '"$Current.GetName()$"'",'MusicPlayer');
		return true;
	}

	return false;
}

function bool ExpandNode( string Path )
{
	local StreamDirectoryNode Node;

	if ( Path == "" )
		return false;

	Node = FindNode(Path);
	if ( Node != None )
	{
		Node.Toggle();
//		log("ExpandNode '"$ Path $"' now"@Node.IsOpen(),'MusicPlayer');
		UpdateItemCount(True);
		return true;
	}

	log("ExpandNode() Error: node not found '"$Path$"'",'MusicPlayer');
	return false;
}

private function StreamDirectoryNode VisibleNode( int VisibleItemIndex )
{
/*	local int i, count;

	if ( TreeBase.Length <= 0 )
		return None;

	count = TreeBase[i].Cost();
	while ( count < VisibleItemIndex && ++i < TreeBase.Length )
		count += TreeBase[i].Cost();

	VisibleItemIndex = count - VisibleItemIndex;
*/	return Current.FindVisibleNode(VisibleItemIndex);
}

private function string VisibleNodeText( int VisibleItemIndex )
{
/*	local int i, count;

	if ( TreeBase.Length <= 0 )
		return "";

	count = TreeBase[0].Cost();
	while ( count < VisibleItemIndex && ++i < TreeBase.Length )
		count += TreeBase[i].Cost();

//	log(Name@"VisibleNodeText VisibleItemIndex:"$VisibleItemIndex@"count:"$count@"i:"$i@"TreeBase.Length:"$TreeBase.Length);
	VisibleItemIndex = count - VisibleItemIndex;
*/	return Current.NodeText(VisibleItemIndex);
}

function UpdateItemCount( optional bool bFullUpdate )
{
	Current.UpdateCost( bFullUpdate );
	ItemCount = Current.Cost();
}

function bool AddNode( StreamDirectoryNode Parent, string InName, optional bool bIsFile )
{
//	log(Name@"AddNode Parent "$Parent@"  Name "$InName@"  File "$bIsFile,'MusicPlayer');
	if ( Parent == None )
	{
		if ( Right(InName,1) != ":" && Right(InName,2) != ":\\" )
			return false;

		Parent = Root;
	}

	if ( bIsFile )
		return Parent.AddContent(InName);

	return Parent.AddChild(InName) != None;
}

function bool RemoveNode( StreamDirectoryNode Parent, StreamDirectoryNode Child)
{
	if ( Parent == None )
		Parent = Root;

	return Parent.RemoveChild(Child);
}

function bool RemoveFile( StreamDirectoryNode Parent, string InFileName )
{
	if ( Parent == None )
		Parent = Root;

	return Parent.RemoveContent(InFileName);
}

function StreamDirectoryNode FindNode( string Path )
{
	return Root.FindChildByPath(Path);
}

function MakeVisible(float Perc)
{
	UpdateItemCount();
	Super.SetTopItem( int((ItemCount-ItemsPerPage) * Perc) );
}

function SetTopItem(int Item)
{
//log("GUIListBase::SetTopItem"@Item@"ItemsPerPage:"$ItemsPerPage);
//	UpdateItemCount();
	Super.SetTopItem(Item);
/*
    Top = Item;
    if (Top + ItemsPerPage >= ItemCount)
        Top = ItemCount - ItemsPerPage;

    if (Top<0)
        Top=0;

	if ( bNotify )
	    CheckLinkedObjects(Self);

    OnAdjustTop(Self);
*/
}

function bool IsValid()
{
	UpdateItemCount();
	return Super.IsValid();
}

function bool IsValidIndex( int i )
{
	UpdateItemCount();
	return Super.IsValidIndex(i);
}

function Clear()
{
	Root.Clear( True );
	UpdateItemCount();
	Super.Clear();
}

function bool HandleDebugExec( string Command, string Params )
{
	switch ( Command )
	{
	case "selected":
		log("Selected item:"$Get(),'MusicPlayer');
		return true;

	case "selectedpath":
		log("Selected path:"$GetPath(),'MusicPlayer');
		return true;

	case "visiblenode":
		log("Visible Node"@Params$" '"$VisibleNodeText(int(Params))$"'",'MusicPlayer');
		return true;
	}


	return Current.HandleDebugExec(Command,Params);
}

// Called on the drop source when when an Item has been dropped.  bAccepted tells it whether
// the operation was successful or not.
// This version of OnEndDrag() does not remove the items from the directory list
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
//	log(Name@"InternalOnEndDrag Accepting:"$Accepting@"bAccepted:"$bAccepted,'DebugRon');
	if (bAccepted && Accepting != None)
		bRepeatClick = False;

	// Simulate repeat click if the operation was a failure to prevent InternalOnMouseRelease from clearing
	// the SelectedItems array
	// This way we don't lose the items we clicked on
	if (Accepting == None)
		bRepeatClick = True;

	SetOutlineAlpha(255);
	if ( bNotify )
		CheckLinkedObjects(Self);
}

defaultproperties
{
     bSimpleFileBrowsing=True
     OnDrawItem=DirectoryTreeList.InternalOnDrawItem
     OnEndDrag=DirectoryTreeList.InternalOnEndDrag
}
