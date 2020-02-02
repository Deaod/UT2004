class GUIMultiColumnListHeader extends GUIComponent
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() GUIMultiColumnList MyList;
var() editconst const int SizingCol;
var() editconst const int ClickingCol;

var	GUIStyles	BarStyle;
var string		BarStyleName;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local eFontScale x;
	Super.InitComponent(MyController, MyOwner);

    if (BarStyleName!="")
    	BarStyle = Controller.GetStyle(BarStyleName,x);

}

defaultproperties
{
     SizingCol=-1
     ClickingCol=-1
     BarStyleName="SectionHeaderBar"
     StyleName="SectionHeaderTop"
     bAcceptsInput=True
}
