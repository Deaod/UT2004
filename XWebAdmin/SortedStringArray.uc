// ====================================================================
//  Class:  XAdmin.SortedStringArray
//  Parent: XAdmin.StringArray
//
//  Sorted list - sorts based on tag
// ====================================================================

class SortedStringArray extends StringArray;

function int Add(coerce string item, coerce string tag, optional bool bUnique)
{
local int pos;

	pos = FindTagId(tag);

	if (pos < 0)
		return InsertAt(-pos-1, item, tag);
	else if (bUnique)
		return pos;

	return InsertAt(pos, item, tag);
}

function int FindTagId(coerce string Tag)
{
	local int Last, Min, Max, Pos;

	Last = AllItems.Length - 1;
	if ( Last < 0 || IsBefore(Tag,AllItems[0].Tag) )
		return -1;

	if (Tag ~= AllItems[0].Tag)
		return 0;

	if (Tag ~= AllItems[Last].Tag)
		return Last;

//	if (Last == 0)
//		return -2;

	// Add tag to end of list
    if (!IsBefore(Tag,AllItems[Last].tag))
	    return (-(Last+1))-1;

    // Find the position of insertion
    max = Last;
    pos = Last;
    do {
        if (tag ~= AllItems[pos].tag)
            return pos;
        if (IsBefore(Tag,AllItems[pos].tag))
            max = pos;
        else min = pos;

        pos = (min + max)/2;
    } until (max-min < 2);
    if (pos == 0)
		return -2;

    return -pos-2;
}

defaultproperties
{
}
