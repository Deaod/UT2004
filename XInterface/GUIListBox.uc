// ====================================================================
//  Class:  UT2K4UI.GUIListBox
//
//  The GUIListBoxBase is a wrapper for a GUIList and it's ScrollBar
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class GUIListBox extends GUIListBoxBase
	native;

var	GUIList List;	// For Quick Access;

function InitBaseList(GUIListBase LocalList)
{
	if ((List == None || List != LocalList) && GUIList(LocalList) != None)
		List = GUIList(LocalList);

	List.OnClick=InternalOnClick;
	List.OnClickSound=CS_Click;
	List.OnDblClick=InternalOnDblClick;
	List.OnChange=InternalOnChange;

	Super.InitBaseList(LocalList);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	if (DefaultListClass != "")
	{
		List = GUIList(AddComponent(DefaultListClass));
		if (List == None)
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
}

function bool InternalOnClick(GUIComponent Sender)
{
	List.InternalOnClick(Sender);
	OnClick(Self);
	return true;
}

function bool InternalOnDblClick(GUIComponent Sender)
{
//	List.InternalOnDblClick(Sender);
//	OnDblClick(Self);
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

function bool MyOpen(GUIContextMenu Menu)
{
	return HandleContextMenuOpen(self, Menu, Menu.MenuOwner);
}

function bool MyClose(GUIContextMenu Sender)
{
	return HandleContextMenuClose(Sender);
}

defaultproperties
{
     DefaultListClass="XInterface.GUIList"
}
