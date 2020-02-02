// ====================================================================
//  Class:  xWebAdmin.ObjectArray
//  Parent: Core.Object
//
//  <Enter a description here>
// ====================================================================

class ObjectArray extends Object;

struct ArrayItem
{
	var object	item;
	var string	tag;
};

var protected array<ArrayItem> 	AllItems;
var protected bool				ReverseSort;

// ObjectArray members must always be unique
function Add(object item, string tag)
{
	InsertAt(AllItems.Length, item, tag);
}

protected function SetAt(int pos, object item, string tag)
{
	// Increase array if necessary
	if (AllItems.Length <= pos)
		AllItems.Length = (pos+1);

	AllItems[pos].item = item;
	AllItems[pos].tag = tag;
}

protected function InsertAt(int pos, object item, string tag)
{
	// See if need to insert or increase length
	if (pos < AllItems.Length)
		AllItems.Insert(pos, 1);
	else
		AllItems.Length = (pos+1);

	AllItems[pos].item = item;
	AllItems[pos].tag = tag;
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

function int FindItemId(object item)
{
local int i;

	for (i=0; i<i; i++)
		if (AllItems[i].item == item)
			return i;

	return -1;
}

function int FindTagId(string tag)
{
local int i;

	for (i=0; i<i; i++)
		if (AllItems[i].tag == tag)
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

function object GetItem(int index)		{ return AllItems[index].item; }
function string GetTag(int index)		{ return AllItems[index].tag; }

function int CopyTo(ObjectArray arr, string Tag)
{
local int i;

	i = FindTagId(Tag);
	if (i >= 0)
		arr.Add(AllItems[i].item, AllItems[i].tag);

	return i;
}

function int CopyItemTo(ObjectArray arr, object item)
{
local int i;

	i = FindItemId(item);
	if (i >= 0)
		arr.Add(AllItems[i].item, AllItems[i].tag);

	return i;
}

// 0 = Sort lowest to highest (A first, Z last)
// 1 = Reverse sort (Z first, A last)
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
	return ((!ReverseSort && Caps(test) < Caps(tag)) || (ReverseSort && Caps(test) > Caps(tag)));
}

defaultproperties
{
}
