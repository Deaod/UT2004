//==============================================================================
//	Created on: 10/21/2003
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class DirectoryTreeListBox extends GUIListBoxBase;

var DirectoryTreeList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	if (DefaultListClass != "")
	{
		List = DirectoryTreeList(AddComponent(DefaultListClass));
		if (List == None)
		{
        	log(Name$".InitComponent - Could not create default list ["$DefaultListClass$"]");
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

function InitBaseList(GUIListBase LocalList)
{
	if ((List == None || List != LocalList) && GUIList(LocalList) != None)
		List = DirectoryTreeList(LocalList);

	List.OnClick=InternalOnClick;
	List.OnClickSound=CS_Click;
	List.OnDblClick=InternalOnDblClick;
	List.OnChange=InternalOnChange;

	Super.InitBaseList(LocalList);
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

function bool MyOpen(GUIContextMenu Menu, GUIComponent ContextMenuOwner)
{
	return HandleContextMenuOpen(self, Menu, ContextMenuOwner);
}

function bool MyClose(GUIContextMenu Sender)
{
	return HandleContextMenuClose(Sender);
}

defaultproperties
{
     DefaultListClass="GUI2K4.DirectoryTreeList"
}
