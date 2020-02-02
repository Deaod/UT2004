// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class GUIVertImageListBox extends GUIListBoxBase;

var		GUIVertImageList List;

var() 	eCellStyle CellStyle;

var() 	float	ImageScale;					// Scale value for the images

var() 	int		NoVisibleRows;				// How many rows of visible images are there
var() 	int 	NoVisibleCols;				// How many cols of visible images are there

var() int	HorzBorder, VertBorder;			// How much white space

function InitBaseList(GUIListBase LocalList)
{

	List = GUIVertImageList(LocalList);
    List.CellStyle = CellStyle;
    List.ImageScale = ImageScale;
    List.NoVisibleRows = NoVisibleRows;
    List.NoVisibleCols = NoVisibleCols;
    List.HorzBorder = HorzBorder;
    List.VertBorder = VertBorder;

	LocalList.OnClick=InternalOnClick;
	LocalList.OnClickSound=CS_Click;
	LocalList.OnChange=InternalOnChange;

    MyScrollBar.SetVisibility(true);
    MyScrollBar.Step = List.NoVisibleCols;


	Super.InitBaseList(LocalList);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	if (DefaultListClass != "")
	{
		MyList = GUIListBase(AddComponent(DefaultListClass));
		if (MyList == None)
		{
        	log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
            return;
        }

	}

	if (MyList == None)
	{
		Warn("Could not initialize list!");
		return;
	}
    InitBaseList(MyList);
}

function bool InternalOnClick(GUIComponent Sender)
{
	List.InternalOnClick(Sender);
    OnClick(Sender);
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
	if (Controller != None && Controller.bCurMenuInitialized)
		OnChange(Self);
}

function int ItemCount()
{
	return List.ItemCount;
}

function AddImage(material Image, optional int Item)
{
	List.Add(Image, Item);
}

function bool MyOpen(GUIContextMenu Menu, GUIComponent ContextMenuOwner)
{
	return HandleContextMenuOpen(self, Menu, ContextMenuOwner);
}

function bool MyClose(GUIContextMenu Sender)
{
	return HandleContextMenuClose(Sender);
}

function Clear()
{
	List.Clear();
}

defaultproperties
{
     ImageScale=1.000000
     HorzBorder=2
     VertBorder=2
     DefaultListClass="XInterface.GUIVertImageList"
}
