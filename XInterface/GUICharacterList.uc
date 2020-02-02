// ====================================================================
//  Class:  UT2K4UI.GUICharacterList
//  Parent: UT2K4UI.GUIHorzList
//
//  <Enter a description here>
// ====================================================================

class GUICharacterList extends GUICircularList
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() array<xUtil.PlayerRecord> PlayerList;
var() bool					  bLocked;
var() Material				  DefaultPortrait;	// Image used for unused entries
var() array<xUtil.PlayerRecord> SelectedElements;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	InitList();
}

function InitList()
{
	local int i;
	local array<xUtil.PlayerRecord> AllPlayerList;

	class'xUtil'.static.GetPlayerList(AllPlayerList);

	// Filter out 'duplicate' characters - only used in single player
	for(i=0; i<AllPlayerList.Length; i++)
	{
		if(AllPlayerList[i].Menu != "DUP")
			PlayerList[PlayerList.Length] = AllPlayerList[i];
	}

	ItemCount = PlayerList.Length;
}

// Accessor function for the items.

function string SelectedText()
{
	if ( (Index >=0) && (Index <ItemCount) )
		return PlayerList[Index].DefaultName;

	return "";
}

function bool ValidIndex(int i)
{
	return i >= 0 && i < PlayerList.Length;
}

function Add(string NewItem, optional Object obj)
{
	return;	// GUICharacterLists can not be modifed at runtime
}

function Remove(int i, optional int Count)
{
	return;	// GUICharacterLists can not be modifed at runtime
}

function Clear()
{
	return;	// GUICharacterLists can not be modifed at runtime
}

function Find(string Text, optional bool bExact)
{
	local int i;
	for (i=0;i<ItemCount;i++)
	{
		if (bExact)
		{
			if (Text == PlayerList[i].DefaultName)
			{
				Index = i;
				Top = i;
				OnChange(self);
				return;
			}
		}
		else
		{
			if (Text ~= PlayerList[i].DefaultName)
			{
				Index = i;
				Top = i;
				OnChange(self);
				return;
			}
		}
	}
}

function material GetPortrait()
{
	return PlayerList[Index].Portrait;
}

function Material GetPortraitAt(int i)
{
	if (ValidIndex(i))
		return PlayerList[i].Portrait;

	return None;
}

function string GetName()
{
	return PlayerList[Index].DefaultName;
}

function string GetNameAt(int i)
{
	if (ValidIndex(i))
		return PlayerList[i].DefaultName;

	return "";
}

function string GetGender()
{
	return PlayerList[Index].Sex;
}

function string GetGenderAt(int i)
{
	if ( ValidIndex(i) )
		return PlayerList[i].Sex;

	return "";
}
function xUtil.PlayerRecord GetRecord()
{
	return PlayerList[Index];
}

function xUtil.PlayerRecord GetRecordAt(int i)
{
	local xUtil.PlayerRecord Rec;

	if (ValidIndex(i))
		Rec = PlayerList[i];

	return Rec;
}

function string GetDecoText()
{
	return GetDecoTextAt(Index);
}

function string GetDecoTextAt(int AtIndex)
{
	local string S;

	if (ValidIndex(AtIndex))
		S = PlayerList[AtIndex].TextName;

	return S;
}

function sound GetSound()
{
	local sound NameSound;
	local string SoundName;

	SoundName = "AnnouncerNames." $ Repl(PlayerList[Index].DefaultName, ".", "_");
/*	// Use the player name, with periods replaced with underscores, as sound name
	DefName = PlayerList[Index].DefaultName;

	PeriodPos = InStr(DefName, ".");
	while(PeriodPos != -1)
	{
		DefName = Left(DefName, PeriodPos)$"_"$Mid(DefName, PeriodPos+1);
		PeriodPos = InStr(DefName, ".");
	}

	SoundName = "AnnouncerNames."$DefName;	// TODO Is this still applicable?
*/
	NameSound = sound(DynamicLoadObject(SoundName, class'Sound'));

	if(NameSound == None)
		Log("Could not find player name sound for: "$PlayerList[Index].DefaultName);

	return NameSound;
}

function Sound GetSoundAt(int i)
{
	local sound NameSound;
	local string SoundName;

	if (ValidIndex(i))
	{
		SoundName = "AnnouncerNames." $ Repl(PlayerList[i].DefaultName, ".", "_");
		NameSound = Sound(DynamicLoadObject(SoundName, class'Sound'));

		if (NameSound == None)
			log("Could not find player name sound for:"@PlayerList[i].DefaultName);
	}

	return NameSound;
}

function ScrollRight()
{
	MoveRight();
}

function ScrollLeft()
{
	MoveLeft();
}

function bool MoveLeft()
{
	if (bLocked)
	{
		if ( Index > 0 )
		{
			Index--;
			OnChange(Self);
		}
		return true;
	}
	else return Super.MoveLeft();
}

function bool MoveRight()
{
	if (bLocked)
	{
		if (Index<ItemsPerPage-1)
		{
			Index++;
			OnChange(Self);
		}

		return true;
	}
	else return Super.MoveRight();
}

function End()
{
	if (bLocked)
	{
		Index = ItemsPerPage-1;
		OnChange(Self);
	}
	else
		Super.End();
}

function ClearPendingElements()
{
	Super.ClearPendingElements();
	if ( SelectedItems.Length == 0 )
		SelectedElements.Remove(0, SelectedElements.Length);
}

function array<xUtil.PlayerRecord> GetPendingElements( optional bool bGuarantee )
{
	local int i;

	if ( (DropState == DRP_Source && Controller.DropSource == Self) || bGuarantee )
	{
		if ( SelectedElements.Length == 0 )
		{
			for (i = 0; i < SelectedItems.Length; i++)
				if (ValidIndex(SelectedItems[i]))
					SelectedElements[SelectedElements.Length] = PlayerList[SelectedItems[i]];
					
			if ( SelectedElements.Length == 0 && IsValid() )
				SelectedElements[0] = PlayerList[Index];
		}
		
		return SelectedElements;
	}
}

function bool InternalOnBeginDrag(GUIComponent Sender)
{
	if ( Super.InternalOnBeginDrag(Sender) )
	{
		SelectedElements = GetPendingElements();
		return true;
	}

	return false;
}

// Called on the drop source when when an Item has been dropped.  bAccepted tells it whether
// the operation was successful or not.
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
	// Pending items were dropped somewhere - list cannot be modified at runtime
	if (bAccepted && Accepting != None)
		bRepeatClick = False;

	// If the drag-n-drop wasn't accepted, set bRepeatClick to True so that ClearPendingElements()
	// won't clear the SelectedItems array - we may want to retry to drag-n-drop
	if (Accepting == None)
		bRepeatClick = True;

	SetOutlineAlpha(255);
	if ( bNotify )
		CheckLinkedObjects(Self);
}

// Cannot add to CharacterList at runtime
function bool InternalOnDragDrop(GUIComponent Sender)
{
	InternalOnMouseRelease(Sender);
	return false;
}

defaultproperties
{
}
