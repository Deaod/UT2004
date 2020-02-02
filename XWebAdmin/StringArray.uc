// ====================================================================
//  Class:  XAdmin.StringArray
//  Parent: Core.Object
//
//  <Enter a description here>
// ====================================================================

class StringArray extends Object;

struct ArrayItem
{
	var string	item;
	var string	tag;
};

var protected array<ArrayItem> AllItems;
var protected bool ReverseSort;

function int Add(coerce string item, coerce string tag, optional bool bUnique)
{
local int pos;

	if (bUnique)
	{
		pos = FindTagId(tag);
		if (pos >= 0)
			return pos;
	}
	return InsertAt(AllItems.Length, item, tag);
}

protected function int SetAt(int pos, coerce string item, coerce string tag)
{
	// Increase array if necessary
	if (AllItems.Length <= pos)
		AllItems.Length = (pos+1);

	AllItems[pos].item = item;
	AllItems[pos].tag = tag;

	return pos;
}

protected function int InsertAt(int pos, coerce string item, coerce string tag)
{
	// See if need to insert or increase length
	if (pos < AllItems.Length)
		AllItems.Insert(pos, 1);
	else
		AllItems.Length = (pos+1);

	AllItems[pos].item = item;
	AllItems[pos].tag = tag;

	return pos;
}

// User Prepare if you know the number of items that will be inserted
function SetSize(int NewSize)
{
	// HACK: This is to pre-allocate the space in the FArray
	//       It should prevent a bunch of Realloc()
	AllItems.Length = NewSize;
	AllItems.Length = 0;
}

function Reset()
{
	AllItems.Length = 0;
}

function int Count()
{
	return AllItems.Length;
}

function int FindItemId(coerce string item, optional bool bLog)
{
local int i;

	for (i=0; i<AllItems.Length; i++)
		if (AllItems[i].item ~= item)
			return i;

	return -1;
}

function int FindTagId(coerce string tag)
{
local int i;

	for (i=0; i<AllItems.Length; i++)
		if (AllItems[i].tag ~= tag)
			return i;

	return -1;
}

function bool Remove(int index)
{
	if (index < 0 || index >= AllItems.Length)
		return false;

	AllItems.Remove(index, 1);
	return true;
}

function string GetItem(int index)		{ return AllItems[index].item; }
function string GetTag(int index)		{ return AllItems[index].tag; }

function int CopyFrom(StringArray arr, coerce string Tag)
{
local int id;

	id = arr.FindTagId(Tag);
	if (id >= 0 && id < arr.Count())
		id = Add(arr.GetItem(id), arr.GetTag(id));

	return id;
}

function int MoveFrom(StringArray arr, coerce string Tag)
{
	return MoveFromId(arr, arr.FindTagId(Tag));
}

function int MoveFromId(StringArray arr, int id)
{
local int newid;

	if (id >= 0 && id < arr.Count())
	{
		newid = Add(arr.GetItem(id), arr.GetTag(id));
		arr.Remove(id);
		return newid;
	}
	return -1;
}

function int CopyFromId(StringArray arr, int id)
{
	if (id >= 0 && id < arr.Count())
		return Add(arr.GetItem(id), arr.GetTag(id));

	return -1;
}

function ShiftStrict(int id, out int Count)
{
	if (Count == 0 || id<0 || id >= AllItems.Length)
		return;

	if (Count < 0)
	{
		// Move items toward 0
		if (id + Count < 0)
			Count = -id;
		InsertAt(id + Count, AllItems[id].item, AllItems[id].Tag);
		Remove(id+1);
	}
	else
	{
		if ((id + Count + 1) >= AllItems.Length)
			Count = AllItems.Length - id - 1;

		InsertAt(id + Count + 1, AllItems[id].item, AllItems[id].Tag);
		Remove(id);
	}
}

// 0 = Sort lowest to highest (A first, Z last)
// 1 = Reverse sort (Z first, A last)
// Thread safe
singular function SetSortOrder(bool Order)
{
	ReverseSort = Order;
}

singular function ToggleSort()
{
	ReverseSort = !ReverseSort;
}

function bool IsBefore(string test, string tag)
{
	local bool bResult;

	bResult = Strcmp(Test,Tag,,True) < 0;
	if ( ReverseSort )
		return !bResult;
	else return bResult;
}

/*
function int CopyTo(ObjectArray arr, string Tag)
{
local int i;

	i = FindTagId(Tag);
	if (i >= 0 && id < arr.Count())
		arr.Add(AllItems[i].item, AllItems[i].tag);

	return i;
}

function int CopyItemTo(ObjectArray arr, string item)
{
local int i;

	i = FindItemId(item);
	if (i >= 0 && id < arr.Count())
		arr.Add(AllItems[i].item, AllItems[i].tag);

	return i;
}
 */

defaultproperties
{
}
