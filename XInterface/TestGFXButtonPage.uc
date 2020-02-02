class TestGFXButtonPage extends TestPageBase;

#exec OBJ LOAD FILE=InterfaceContent.utx

var GUIGFXButton Btn;
var GUIComboBox ImgStyle, ImgAlign, ImgSelect;

function MyOnOpen()
{
	Btn = GUIGFXButton(Controls[1]);
	ImgStyle = GUIComboBox(Controls[3]);
	ImgAlign = GUIComboBox(Controls[5]);
	ImgSelect = GUIComboBox(Controls[7]);

	// Prepare the ComboBoxes
	ImgStyle.AddItem("Normal");
	ImgStyle.AddItem("Center");
	ImgStyle.AddItem("Stretched");
	ImgStyle.AddItem("Scaled");
	ImgStyle.AddItem("Bound");

	ImgAlign.AddItem("Blurry");
	ImgAlign.AddItem("Watched");
	ImgAlign.AddItem("Focused");
	ImgAlign.AddItem("Pressed");
	ImgAlign.AddItem("Disabled");

	ImgSelect.AddItem("PlayerPictures.cEgyptFemaleBA");
	ImgSelect.AddItem("InterfaceContent.Menu.bg07");
	ImgSelect.AddItem("PlayerPictures.Galactic");
	ImgSelect.AddItem("InterfaceContent.Menu.CO_Final");
	ImgSelect.AddItem("InterfaceContent.BorderBoxF_Pulse");

	SetNewImage("PlayerPictures.cEgyptFemaleBA");
}

function OnNewImgStyle(GUIComponent Sender)
{
local string NewImgStyle;

	NewImgStyle = ImgStyle.Get();
	if (NewImgStyle == "Normal")
		Btn.Position=ICP_Normal;
	else if (NewImgStyle == "Center")
		Btn.Position=ICP_Center;
	else if (NewImgStyle == "Stretched")
		Btn.Position=ICP_Stretched;
	else if (NewImgStyle == "Scaled")
		Btn.Position=ICP_Scaled;
	else if (NewImgStyle == "Bound")
		Btn.Position=ICP_Bound;
}

function OnNewImgAlign(GUIComponent Sender)
{
local string NewImgAlign;

	NewImgAlign = ImgAlign.Get();
	if (NewImgAlign == "Blurry")
		Btn.MenuState = MSAT_Blurry;
	else if (NewImgAlign == "Watched")
		Btn.MenuState = MSAT_Watched;
	else if (NewImgAlign == "Focused")
		Btn.MenuState = MSAT_Focused;
	else if (NewImgAlign == "Pressed")
		Btn.MenuState = MSAT_Pressed;
	else if (NewImgAlign == "Disabled")
		Btn.MenuState = MSAT_Disabled;
}

function OnNewImgSelect(GUIComponent Sender)
{
	SetNewImage(ImgSelect.Get());
}

function OnNewClientBound(GUIComponent Sender)
{
	Btn.bClientBound=GUICheckBoxButton(Sender).bChecked;	
}

function SetNewImage(string ImageName)
{
	Btn.Graphic=DLOTexture(ImageName);
}

function Material DLOTexture(string TextureFullName)
{
	return Material(DynamicLoadObject(TextureFullName, class'Material'));
}

defaultproperties
{
     OnOpen=TestGFXButtonPage.MyOnOpen
     Begin Object Class=GUIImage Name=Backdrop
         Image=TexPanner'InterfaceContent.Menu.pEmptySlot'
         ImageStyle=ISTY_Bound
         WinTop=0.200000
         WinLeft=0.100000
         WinWidth=0.200000
         WinHeight=0.200000
     End Object
     Controls(0)=GUIImage'XInterface.TestGFXButtonPage.Backdrop'

     Begin Object Class=GUIGFXButton Name=TheButton
         WinTop=0.200000
         WinLeft=0.100000
         WinWidth=0.200000
         WinHeight=0.200000
         OnKeyEvent=TheButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIGFXButton'XInterface.TestGFXButtonPage.TheButton'

     Begin Object Class=GUILabel Name=lblImgStyle
         Caption="Image Style"
         WinTop=0.200000
         WinLeft=0.500000
         WinWidth=0.200000
     End Object
     Controls(2)=GUILabel'XInterface.TestGFXButtonPage.lblImgStyle'

     Begin Object Class=GUIComboBox Name=cboImgStyle
         bReadOnly=True
         WinTop=0.200000
         WinLeft=0.750000
         WinWidth=0.200000
         OnChange=TestGFXButtonPage.OnNewImgStyle
         OnKeyEvent=cboImgStyle.InternalOnKeyEvent
     End Object
     Controls(3)=GUIComboBox'XInterface.TestGFXButtonPage.cboImgStyle'

     Begin Object Class=GUILabel Name=lblImgAlign
         Caption="Menu State"
         WinTop=0.300000
         WinLeft=0.500000
         WinWidth=0.200000
     End Object
     Controls(4)=GUILabel'XInterface.TestGFXButtonPage.lblImgAlign'

     Begin Object Class=GUIComboBox Name=cboImgAlign
         bReadOnly=True
         WinTop=0.300000
         WinLeft=0.750000
         WinWidth=0.200000
         OnChange=TestGFXButtonPage.OnNewImgAlign
         OnKeyEvent=cboImgAlign.InternalOnKeyEvent
     End Object
     Controls(5)=GUIComboBox'XInterface.TestGFXButtonPage.cboImgAlign'

     Begin Object Class=GUILabel Name=lblImgSelect
         Caption="Select Image"
         WinTop=0.400000
         WinLeft=0.500000
         WinWidth=0.200000
     End Object
     Controls(6)=GUILabel'XInterface.TestGFXButtonPage.lblImgSelect'

     Begin Object Class=GUIComboBox Name=cboImgSelect
         bReadOnly=True
         WinTop=0.400000
         WinLeft=0.750000
         WinWidth=0.200000
         OnChange=TestGFXButtonPage.OnNewImgSelect
         OnKeyEvent=cboImgSelect.InternalOnKeyEvent
     End Object
     Controls(7)=GUIComboBox'XInterface.TestGFXButtonPage.cboImgSelect'

     Begin Object Class=GUILabel Name=lblClientBound
         Caption="Client Bound ?"
         WinTop=0.500000
         WinLeft=0.500000
         WinWidth=0.200000
     End Object
     Controls(8)=GUILabel'XInterface.TestGFXButtonPage.lblClientBound'

     Begin Object Class=GUICheckBoxButton Name=cbbClientBound
         WinTop=0.500000
         WinLeft=0.750000
         WinWidth=0.200000
         WinHeight=0.060000
         OnChange=TestGFXButtonPage.OnNewClientBound
         OnKeyEvent=cbbClientBound.InternalOnKeyEvent
     End Object
     Controls(9)=GUICheckBoxButton'XInterface.TestGFXButtonPage.cbbClientBound'

}
