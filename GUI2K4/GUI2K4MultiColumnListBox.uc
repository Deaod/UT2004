class GUI2K4MultiColumnListBox extends GUIMultiColumnListBox;

delegate string OnGetSortString(GUIComponent Sender, int item, int column);

function InitBaseList(GUIListBase LocalList)
{
	Super.InitBaseList(LocalList);
	GUI2K4MultiColumnList(List).OnGetSortString = InternalOnGetSortString;
}

function string InternalOnGetSortString(GUIComponent Sender, int item, int column)
{
	return OnGetSortString(self, item, column);
}

defaultproperties
{
     DefaultListClass="GUI2K4.GUI2K4MultiColumnList"
}
