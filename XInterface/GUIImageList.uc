// GUIImageList is simply a GUIImage that has its current image selected from an array
// It rotates using mouse wheel/arrow keys

class GUIImageList extends GUIImage;
//	Native;

var() editinline array<string> MatNames;
var() array<Material> Materials;
var() editconst int CurIndex;
var() bool bWrap;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	OnKeyEvent=internalKeyEvent;
}

function AddMaterial(string MatName, out Material Mat)
{
local int i;

	if (Mat != None)
	{
		i = Materials.Length;
		Materials[i]=Mat;
		MatNames[i]=MatName;
	}
}

function string GetCurMatName()
{
	if (CurIndex >= 0 && CurIndex < Materials.Length)
		return MatNames[CurIndex];

	return "";
}

function SetIndex(int index)
{
	if (index >= 0 && index < Materials.Length)
	{
		CurIndex = index;
		Image = Materials[index];
	}
	else
	{
		Image = None;
		CurIndex = -1;
	}
}

function bool internalKeyEvent(out byte Key, out byte State, float delta)
{
	if ( State != 3 )
		return false;

	switch ( Key )
	{
	case 0x25:	// Up/Left/MouseWheelUp
	case 0x26:
	case 0x64:
	case 0x68:
	case 0xEC:
		PrevImage();
		return true;

	case 0x27:  // Down/Right/MouseWheelDn
	case 0x28:
	case 0x62:
	case 0x66:
	case 0xED:
		NextImage();
		return true;


	case 0x24:	// Home
	case 0x67:
		FirstImage();
		return true;

	case 0x23:	// End
	case 0x61:
		LastImage();
		return true;
	}

	return false;
}

function PrevImage()
{
	if (CurIndex < 1)
	{
		if (bWrap)
			SetIndex(Materials.Length - 1);
	}
	else
		SetIndex(CurIndex - 1);
}

function NextImage()
{
	if (CurIndex < 0)
		SetIndex(0);
	else if ((CurIndex + 1) >= Materials.Length)
	{
		if (bWrap)
			SetIndex(0);
	}
	else
		SetIndex(CurIndex + 1);
}

function FirstImage()
{
	if (Materials.Length > 0)
		SetIndex(0);
}

function LastImage()
{
	if (Materials.Length > 0)
		SetIndex(Materials.Length - 1);
}

defaultproperties
{
     StyleName="NoBackground"
     bTabStop=True
     bAcceptsInput=True
     bCaptureMouse=True
}
