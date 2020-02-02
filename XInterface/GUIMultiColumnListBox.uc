//====================================================================
//  Parent: GUIListBoxBase
//   Class: UT2K4UI.GUIMultiColumnListBox
//    Date: 05-01-2003
//
//  Base class for listboxes which use multiple columns for showing data.
//
//  Updated by Ron Prestenback
//	TODO: Update all panels that use this component to save the header column perc's
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class GUIMultiColumnListBox extends GUIListBoxBase
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Automated GUIMultiColumnListHeader 	Header;
var() bool                              bDisplayHeader;
var() editconst GUIMultiColumnList		List;
var() array<float>						HeaderColumnPerc;
var() localized array<string>           ColumnHeadings;

var() bool bFullHeightStyle;

function InitBaseList(GUIListBase LocalList)
{
	if ((List == None || List != LocalList) && GUIMultiColumnList(LocalList) != None)
		List = GUIMultiColumnList(LocalList);

	if ( ColumnHeadings.Length > 0 )
		List.ColumnHeadings = ColumnHeadings;

	Header.MyList = List;
	Super.InitBaseList(LocalList);

}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

    if (DefaultListClass!="")
    {
    	List = GUIMultiColumnList(AddComponent(DefaultListClass));
        if (List==None)
        {
        	log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
            return;
        }
    }

	if (List == None)
	{
		Warn("Could not initialize list!");
		return;
	}

    InitBaseList(List);

	if (bFullHeightStyle)
		List.Style=None;
}

function InternalOnLoadIni(GUIComponent Sender, string S)
{
	local int i;

	if (GUIMultiColumnList(Sender) != None)
	{
		if (HeaderColumnPerc.Length == GUIMultiColumnList(Sender).InitColumnPerc.Length)
			GUIMultiColumnList(Sender).InitColumnPerc = HeaderColumnPerc;

		else
		{
			if (GUIMultiColumnList(Sender).InitColumnPerc.Length == 0)
				GUIMultiColumnList(Sender).InitColumnPerc.Length = HeaderColumnPerc.Length;

			for (i = 0; i < HeaderColumnPerc.Length && i < GUIMultiColumnList(Sender).InitColumnPerc.Length; i++)
				GUIMultiColumnList(Sender).InitColumnPerc[i] = HeaderColumnPerc[i];
		}
	}
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUIMultiColumnList(NewComp) != None)
	{
		GUIMultiColumnList(NewComp).OnColumnSized = InternalOnColumnSized;
		NewComp.IniOption = "@Internal";
		NewComp.OnLoadINI = InternalOnLoadIni;
	}

	Super.InternalOnCreateComponent(NewComp, Sender);
}

function InternalOnColumnSized(int Column)
{
	HeaderColumnPerc[Column] = List.ColumnWidths[Column] / ActualWidth();
}

defaultproperties
{
     Begin Object Class=GUIMultiColumnListHeader Name=MyHeader
     End Object
     Header=GUIMultiColumnListHeader'XInterface.GUIMultiColumnListBox.MyHeader'

     bDisplayHeader=True
     DefaultListClass="Xinterface.GUIMultiColumnList"
}
