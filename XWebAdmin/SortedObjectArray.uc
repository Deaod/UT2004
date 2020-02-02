// ====================================================================
//  Class:  xWebAdmin.SortedObjectArray
//  Parent: xWebAdmin.ObjectArray
//
//  Sorted list - sorts by tag
// ====================================================================

class SortedObjectArray extends ObjectArray;

var const bool debug;

function Add(object item, string tag)
{
local int pos;

	if (debug)
	{
		for (pos = 0; pos < AllItems.Length; pos++)
			log(" Member"@pos@AllItems[pos].Tag);
	}

	pos = FindTagId(tag);

	if (pos < 0)
		InsertAt(-pos-1, item, tag);
	else
		InsertAt(pos, item, tag);

	if (debug)
	{
		log("~~Inserting new member at"@pos@tag);
		for (pos = 0; pos < AllItems.Length; pos++)
			log("   Member"@pos@AllItems[pos].Tag);
	}
}

function int FindTagId(string Tag)
{
local int sz, min, max, pos;

    sz = AllItems.Length - 1;
    if (sz < 0 || IsBefore(Tag, AllItems[0].tag))
	{
		if (debug)
			log(tag@"was before first member, so returning -1");
	    return -1;
	}
	if (Tag ~= AllItems[0].Tag)
		return 0;

	if (Tag ~= AllItems[sz].Tag)
		return sz;

	if (sz == 1)
		return -3;
	// Add tag to end of list
    if (!IsBefore(Tag,AllItems[sz].tag))
	{
		if (debug)
			log(tag@"was after last member, so returning"@(-(sz+1))-1);
        return (-(sz+1))-1;
	}

    // Find the position of insertion
    max = sz;
    pos = sz;
    do {
        if (tag ~= AllItems[pos].tag)
            return pos;
        if (IsBefore(Tag,AllItems[pos].tag))
            max = pos;
        else min = pos;

		if (debug)
			log("Min:"$Min@"Max:"$Max@"Pos:"$((Min + Max)/2));

        pos = (min + max)/2;
    } until (max-min < 2);

    // Min = 1 and Max = 2, return 1
    if (pos == 0)
	{
		if (debug)
			log(tag@"wanted to be added at 0, so adding at 1 instead");
		return 1;
	}
	if (debug)
		log(tag@"will be inserted at position"@-pos-2);
    return -pos-2;
}

/*
singular function ToggleSort()
{
	ReverseSort = !ReverseSort;
log("ToggleSort.  ReverseSort is now:"$ReverseSort);
}

*/
function bool IsBefore(string test, string tag)
{
local bool b;
	if (debug)
	{
		b = ((!ReverseSort && test < tag) || (ReverseSort && test > tag));
		log("IsBefore");
		log("  ReverseSort:"$ReverseSort);
		log("  "$Test@"is before"@Tag$":"@b);
		log("");
		return ((!ReverseSort && test < tag) || (ReverseSort && test > tag));
	}

	return Super.IsBefore(test,tag);
}

defaultproperties
{
}
