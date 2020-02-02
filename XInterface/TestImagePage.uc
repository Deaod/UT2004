class TestImagePage extends TestPageBase;

#exec OBJ LOAD FILE=InterfaceContent.utx

var automated GUIImage i_Test;
var automated moComboBox co_Style, co_Align, co_Select, co_Render;
var automated GUINumericEdit nu_Width, nu_Height, nu_PortionX1, nu_PortionX2, nu_PortionY1, nu_PortionY2;
var automated GUIButton b_Add;
var automated GUILabel l_ImageSize;

var config array<string> Images;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	Background = Controller.DefaultPens[1];
}

function bool InternalOnClick( GUIComponent Sender )
{
	local string S;
	local Material M;

	if ( Sender == b_Add )
	{
		S = co_Select.GetText();
		if ( co_Select.FindIndex(s) == -1 )
		{
			M = LoadTexture(S);
			if ( M != None )
			{
				co_Select.AddItem(S);
				Images[Images.Length] = S;
				SaveConfig();

				SetNewImage(S);
			}
		}
	}
	return true;
}

function InternalOnOpen()
{
	local int i;

	// Prepare the ComboBoxes
	co_Style.AddItem("Normal");
	co_Style.AddItem("Stretched");
	co_Style.AddItem("Scaled");
	co_Style.AddItem("Bound");
	co_Style.AddItem("Justified");
	co_Style.AddItem("PartialScaled");

	co_Align.AddItem("TopLeft");
	co_Align.AddItem("Center");
	co_Align.AddItem("BottomRight");

	co_Render.AddItem("None");
	co_Render.AddItem("Normal");
	co_Render.AddItem("Masked");
	co_Render.AddItem("Translucent");
	co_Render.AddItem("Modulated");
	co_Render.AddItem("Alpha");
	co_Render.AddItem("Additive");
	co_Render.AddItem("Subtractive");
	co_Render.AddItem("Particle");
	co_Render.AddItem("AlphaZ");

	for ( i = 0; i < Images.Length; i++ )
		co_Select.AddItem(Images[i]);

	SetNewImage(co_Select.MyComboBox.List.Get(True));
	co_Render.SetIndex(1);
	co_Style.SetIndex(0);
	co_Align.SetIndex(0);
	nu_PortionX1.SetValue(-1);
	nu_PortionY1.SetValue(-1);
	nu_PortionX2.SetValue(-1);
	nu_PortionY2.SetValue(-1);
}

function InternalOnRendered(Canvas C)
{
	if ( i_Test.bPositioned )
	{
		nu_Width.Value = string(i_Test.ActualWidth());
		nu_Height.Value = string(i_Test.ActualHeight());

		OnRendered=None;
	}
}

function OnNewImgStyle(GUIComponent Sender)
{
local string NewImgStyle;

	NewImgStyle = co_Style.GetText();
	switch ( NewImgStyle )
	{
	case "Normal":
		i_Test.ImageStyle = ISTY_Normal;
		break;

	case "Stretched":
		i_Test.ImageStyle = ISTY_Stretched;
		break;

	case "Scaled":
		i_Test.ImageStyle = ISTY_Scaled;
		break;

	case "Bound":
		i_Test.ImageStyle = ISTY_Bound;
		break;

	case "Justified":
		i_Test.ImageStyle = ISTY_Justified;
		break;

	case "PartialScaled":
		i_Test.ImageStyle = ISTY_PartialScaled;
		break;
	}
}

function InternalOnChange( GUIComponent Sender )
{
	if ( Sender == co_Render )
	{
		switch (co_Render.GetText())
		{
		case "None":
			i_Test.ImageRenderStyle = MSTY_None;
			break;

		case "Normal":
			i_Test.ImageRenderStyle = MSTY_Normal;
			break;

		case "Masked":
			i_Test.ImageRenderStyle = MSTY_Masked;
			break;

		case "Translucent":
			i_Test.ImageRenderStyle = MSTY_Translucent;
			break;

		case "Modulated":
			i_Test.ImageRenderStyle = MSTY_Modulated;
			break;

		case "Alpha":
			i_Test.ImageRenderStyle = MSTY_Alpha;
			break;

		case "Additive":
			i_Test.ImageRenderStyle = MSTY_Additive;
			break;

		case "Subtractive":
			i_Test.ImageRenderStyle = MSTY_Subtractive;
			break;

		case "Particle":
			i_Test.ImageRenderStyle = MSTY_Particle;
			break;

		case "AlphaZ":
			i_Test.ImageRenderStyle = MSTY_AlphaZ;
			break;
		}
	}
}

function OnNewImgAlign(GUIComponent Sender)
{
local string NewImgAlign;

	NewImgAlign = co_Align.GetText();
	if (NewImgAlign == "TopLeft")
		i_Test.ImageAlign = IMGA_TopLeft;
	else if (NewImgAlign == "Center")
		i_Test.ImageAlign = IMGA_Center;
	else if (NewImgAlign == "BottomRight")
		i_Test.ImageAlign = IMGA_BottomRight;
}

function OnNewImgSelect(GUIComponent Sender)
{
	local string S;

	s = co_Select.GetText();
	if ( co_Select.FindIndex(s) != -1 )
		SetNewImage(s);
}

function SetNewImage(string ImageName)
{
	i_Test.Image = LoadTexture(ImageName);
	if ( i_Test.Image != None )
		l_ImageSize.Caption =  i_Test.Image.MaterialUSize() $ "x" $ i_Test.Image.MaterialVSize();
}

function Material LoadTexture(string TextureFullName)
{
	return Material(DynamicLoadObject(TextureFullName, class'Material'));
}

function ResizeImage(GUIComponent Sender)
{
	if ( Sender == nu_Width )
		i_Test.WinWidth = i_Test.RelativeWidth(int(nu_Width.Value));

	else i_Test.WinHeight = i_Test.RelativeHeight(int(nu_Height.Value));
}

function ChangePortion(GUIComponent Sender)
{
	switch ( Sender )
	{
	case nu_PortionX1:
		i_Test.X1 = int(GUINumericEdit(Sender).Value);
		break;
	case nu_PortionX2:
		i_Test.X2 = int(GUINumericEdit(Sender).Value);
		break;
	case nu_PortionY1:
		i_Test.Y1 = int(GUINumericEdit(Sender).Value);
		break;
	case nu_PortionY2:
		i_Test.Y2 = int(GUINumericEdit(Sender).Value);
		break;
	}
}

defaultproperties
{
     Begin Object Class=GUIImage Name=TheImage
         ImageRenderStyle=MSTY_Normal
         WinTop=0.115365
         WinLeft=0.088281
         WinWidth=0.600000
         WinHeight=0.976563
         RenderWeight=0.400000
     End Object
     i_Test=GUIImage'XInterface.TestImagePage.TheImage'

     Begin Object Class=moComboBox Name=ImageStyle
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Image Style"
         OnCreateComponent=ImageStyle.InternalOnCreateComponent
         WinTop=0.045000
         WinLeft=0.000000
         WinWidth=0.250000
         WinHeight=0.040000
         TabOrder=4
         OnChange=TestImagePage.OnNewImgStyle
     End Object
     co_Style=moComboBox'XInterface.TestImagePage.ImageStyle'

     Begin Object Class=moComboBox Name=ImageAlign
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Align"
         OnCreateComponent=ImageAlign.InternalOnCreateComponent
         WinTop=0.045000
         WinLeft=0.265625
         WinWidth=0.208984
         WinHeight=0.040000
         TabOrder=5
         OnChange=TestImagePage.OnNewImgAlign
     End Object
     co_Align=moComboBox'XInterface.TestImagePage.ImageAlign'

     Begin Object Class=moComboBox Name=SelectImage
         CaptionWidth=0.100000
         Caption="Select Image"
         OnCreateComponent=SelectImage.InternalOnCreateComponent
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=0.538086
         WinHeight=0.040000
         TabOrder=0
         OnChange=TestImagePage.OnNewImgSelect
     End Object
     co_Select=moComboBox'XInterface.TestImagePage.SelectImage'

     Begin Object Class=moComboBox Name=ImageRenderStyle
         bReadOnly=True
         CaptionWidth=0.100000
         Caption="Render Style"
         OnCreateComponent=ImageRenderStyle.InternalOnCreateComponent
         WinTop=0.045000
         WinLeft=0.480469
         WinWidth=0.326172
         WinHeight=0.040000
         TabOrder=6
         OnChange=TestImagePage.InternalOnChange
     End Object
     co_Render=moComboBox'XInterface.TestImagePage.ImageRenderStyle'

     Begin Object Class=GUINumericEdit Name=ImageWidth
         MinValue=10
         MaxValue=1014
         Step=10
         WinLeft=0.731055
         WinWidth=0.107617
         WinHeight=0.040000
         TabOrder=2
         OnDeActivate=ImageWidth.ValidateValue
         OnChange=TestImagePage.ResizeImage
     End Object
     nu_Width=GUINumericEdit'XInterface.TestImagePage.ImageWidth'

     Begin Object Class=GUINumericEdit Name=ImageHeight
         MinValue=10
         MaxValue=758
         Step=10
         WinLeft=0.838672
         WinWidth=0.069531
         WinHeight=0.040000
         TabOrder=3
         OnDeActivate=ImageHeight.ValidateValue
         OnChange=TestImagePage.ResizeImage
     End Object
     nu_Height=GUINumericEdit'XInterface.TestImagePage.ImageHeight'

     Begin Object Class=GUINumericEdit Name=ImagePortionX1
         MinValue=-1
         MaxValue=1024
         Step=10
         WinTop=0.221354
         WinLeft=0.003516
         WinWidth=0.083203
         WinHeight=0.040000
         TabOrder=7
         OnDeActivate=ImagePortionX1.ValidateValue
         OnChange=TestImagePage.ChangePortion
     End Object
     nu_PortionX1=GUINumericEdit'XInterface.TestImagePage.ImagePortionX1'

     Begin Object Class=GUINumericEdit Name=ImagePortionX2
         MinValue=-1
         MaxValue=1024
         Step=10
         WinTop=0.301354
         WinLeft=0.003516
         WinWidth=0.083203
         WinHeight=0.040000
         TabOrder=9
         OnDeActivate=ImagePortionX2.ValidateValue
         OnChange=TestImagePage.ChangePortion
     End Object
     nu_PortionX2=GUINumericEdit'XInterface.TestImagePage.ImagePortionX2'

     Begin Object Class=GUINumericEdit Name=ImagePortionY1
         MinValue=-1
         MaxValue=1024
         Step=10
         WinTop=0.261354
         WinLeft=0.003516
         WinWidth=0.083203
         WinHeight=0.040000
         TabOrder=8
         OnDeActivate=ImagePortionY1.ValidateValue
         OnChange=TestImagePage.ChangePortion
     End Object
     nu_PortionY1=GUINumericEdit'XInterface.TestImagePage.ImagePortionY1'

     Begin Object Class=GUINumericEdit Name=ImagePortionY2
         MinValue=-1
         MaxValue=1024
         Step=10
         WinTop=0.341354
         WinLeft=0.003516
         WinWidth=0.083203
         WinHeight=0.040000
         TabOrder=10
         OnDeActivate=ImagePortionY2.ValidateValue
         OnChange=TestImagePage.ChangePortion
     End Object
     nu_PortionY2=GUINumericEdit'XInterface.TestImagePage.ImagePortionY2'

     Begin Object Class=GUIButton Name=AddImage
         Caption="Add"
         WinLeft=0.539258
         WinWidth=0.050273
         TabOrder=1
         OnClick=TestImagePage.InternalOnClick
         OnKeyEvent=AddImage.InternalOnKeyEvent
     End Object
     b_Add=GUIButton'XInterface.TestImagePage.AddImage'

     Begin Object Class=GUILabel Name=ImageDims
         FontScale=FNS_Small
         StyleName="TextLabel"
         WinLeft=0.594336
         WinWidth=0.121289
         WinHeight=0.040000
     End Object
     l_ImageSize=GUILabel'XInterface.TestImagePage.ImageDims'

     Images(0)="PlayerPictures.cEgyptFemaleBA"
     Images(1)="InterfaceContent.Menu.bg07"
     Images(2)="2K4Menus.Controls.menuBackground2"
     Images(3)="2K4Menus.Controls.popupBorder_b"
     Images(4)="2K4Menus.Controls.editbox2_b"
     OnOpen=TestImagePage.InternalOnOpen
     OnRendered=TestImagePage.InternalOnRendered
}
