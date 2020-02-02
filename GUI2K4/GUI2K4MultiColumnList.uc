class GUI2K4MultiColumnList extends GUIMultiColumnList;

delegate string OnGetSortString(GUIComponent Sender, int item, int column);

function string InternalGetSortString( int i )
{
	return OnGetSortString(self, i, SortColumn);
}

defaultproperties
{
     GetSortString=GUI2K4MultiColumnList.InternalGetSortString
}
