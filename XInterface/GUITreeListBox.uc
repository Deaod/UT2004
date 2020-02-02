// ====================================================================
//  Class:  GUITreeListBox
//
//  Written by Bruce Bickar
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class GUITreeListBox extends GUIListBoxBase native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var	GUITreeList List;

function InitBaseList(GUIListBase LocalList)
{
	if ((List == None || List != LocalList) && GUITreeList(LocalList) != None)
		List = GUITreeList(LocalList);

	List.OnClick=InternalOnClick;
	List.OnClickSound=CS_Click;
	List.OnChange=InternalOnChange;
	List.OnDblClick = InternalDblClick;

	Super.InitBaseList(LocalList);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	if (DefaultListClass != "")
	{
		List = GUITreeList(AddComponent(DefaultListClass));
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

function InternalOnChange(GUIComponent Sender)
{
	if (Controller != None && Controller.bCurMenuInitialized)
		OnChange(Self);
}

function bool InternalDblClick( GUIComponent Sender )
{
	List.InternalDblClick(Sender);
	OnDblClick(Self);
	return True;
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
     DefaultListClass="XInterface.GUITreeList"
     Begin Object Class=GUITreeScrollBar Name=TreeScrollbar
         bVisible=False
         OnPreDraw=TreeScrollbar.GripPreDraw
     End Object
     MyScrollBar=GUITreeScrollBar'XInterface.GUITreeListBox.TreeScrollbar'

}
