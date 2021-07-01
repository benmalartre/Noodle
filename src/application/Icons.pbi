XIncludeFile "../controls/Icon.pbi"

UsePNGImageEncoder()


CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Global iconFolder.s = "C:/Users/graph/Documents/bmal/src/Amnesie/build/icons/ "
CompilerElseIf #PB_Compiler_OS  = #PB_OS_MacOS
  Global iconFolder.s = "/Users/benmalartre/Documents/RnD/amnesie/icons/"
CompilerEndIf


#RESOLUTION = 64
Define window = OpenWindow(#PB_Any, 0,0,800,800,"Icons")
Define  canvas = CanvasGadget(#PB_Any, 0,0,800,800)
  
Global iconCounter = 0


Procedure DrawIcon(func.ControlIcon::DrawIconImpl)
  Define currentX = (iconCounter % 8) * 100
  Define currentY = (iconCounter / 8) * 100
  iconCounter + 1
  ResetCoordinates()
  TranslateCoordinates(currentX, currentY)
  func()
EndProcedure



StartVectorDrawing(CanvasVectorOutput(canvas))
DrawIcon(ControlIcon::@LoopIcon())
DrawIcon(ControlIcon::@PlayForwardIcon())
DrawIcon(ControlIcon::@PlayBackwardIcon())
DrawIcon(ControlIcon::@StopIcon())
DrawIcon(ControlIcon::@PreviousFrameIcon())
DrawIcon(ControlIcon::@NextFrameIcon())
DrawIcon(ControlIcon::@FirstFrameIcon())
DrawIcon(ControlIcon::@LastFrameIcon())
DrawIcon(ControlIcon::@VisibleIcon())
DrawIcon(ControlIcon::@InvisibleIcon())
DrawIcon(ControlIcon::@TranslateIcon())
DrawIcon(ControlIcon::@RotateIcon())
DrawIcon(ControlIcon::@ScaleIcon())
DrawIcon(ControlIcon::@SelectIcon())
DrawIcon(ControlIcon::@SplitVIcon())
DrawIcon(ControlIcon::@SplitHIcon())
DrawIcon(ControlIcon::@LockedIcon())
DrawIcon(ControlIcon::@UnlockedIcon())
DrawIcon(ControlIcon::@OpIcon())
DrawIcon(ControlIcon::@TrashIcon())
DrawIcon(ControlIcon::@LayerIcon())
DrawIcon(ControlIcon::@PenIcon())
DrawIcon(ControlIcon::@FolderIcon())
DrawIcon(ControlIcon::@FileIcon())
DrawIcon(ControlIcon::@HomeIcon())
DrawIcon(ControlIcon::@BackIcon())
DrawIcon(ControlIcon::@WarningIcon())
DrawIcon(ControlIcon::@ErrorIcon())
DrawIcon(ControlIcon::@SaveIcon())
DrawIcon(ControlIcon::@OpenIcon())
StopVectorDrawing()

Procedure SaveIconAsImage(icon.i)
  Define image.i = CreateImage(#PB_Any, #RESOLUTION, #RESOLUTION, 32)
  
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_AlphaChannel)
  Box(0,0,#RESOLUTION, #RESOLUTION, RGBA(0,0,0,0))
  StopDrawing()

  StartVectorDrawing(ImageVectorOutput(image))
  

  ResetCoordinates()
  ScaleCoordinates(#RESOLUTION / 100, #RESOLUTION / 100)
  Select icon
    Case ControlIcon::#ICON_VISIBLE
      ControlIcon::VisibleIcon()  
    Case ControlIcon::#ICON_INVISIBLE
      ControlIcon::InvisibleIcon()
    Case ControlIcon::#ICON_PLAYFORWARD
      ControlIcon::PlayForwardIcon()
    Case ControlIcon::#ICON_PLAYBACKWARD
      ControlIcon::PlayBackwardIcon()
    Case ControlIcon::#ICON_STOP
      ControlIcon::StopIcon()
    Case ControlIcon::#ICON_PREVIOUSFRAME
      ControlIcon::PreviousFrameIcon()
    Case ControlIcon::#ICON_NEXTFRAME
      ControlIcon::NextFrameIcon()
    Case ControlIcon::#ICON_FIRSTFRAME
      ControlIcon::FirstFrameIcon()
    Case ControlIcon::#ICON_LASTFRAME
      ControlIcon::LastFrameIcon()
    Case ControlIcon::#ICON_LOOP
      ControlIcon::LoopIcon()
    Case ControlIcon::#ICON_TRANSLATE
      ControlIcon::TranslateIcon()
    Case ControlIcon::#ICON_ROTATE
      ControlIcon::RotateIcon()
    Case ControlIcon::#ICON_SCALE
      ControlIcon::ScaleIcon()
     Case ControlIcon::#ICON_SELECT
       ControlIcon::SelectIcon()
     Case ControlIcon::#ICON_SPLITH
       ControlIcon::SplitHIcon()
     Case ControlIcon::#ICON_SPLITV
       ControlIcon::SplitVIcon()
     Case ControlIcon::#ICON_LOCKED
       ControlIcon::LockedIcon()
     Case ControlIcon::#ICON_UNLOCKED
       ControlIcon::LockedIcon()
     Case ControlIcon::#ICON_OP
       ControlIcon::OpIcon()
     Case ControlIcon::#ICON_TRASH
       ControlIcon::TrashIcon()
     Case ControlIcon::#ICON_LAYER
       ControlIcon::LayerIcon()
     Case ControlIcon::#ICON_PEN
       ControlIcon::PenIcon()
     Case ControlIcon::#ICON_FOLDER
       ControlIcon::FolderIcon()
     Case ControlIcon::#ICON_FILE
       ControlIcon::FileIcon()
     Case ControlIcon::#ICON_SAVE
       ControlIcon::SaveIcon()
     Case ControlIcon::#ICON_OPEN
       ControlIcon::OpenIcon()
     Case ControlIcon::#ICON_HOME
       ControlIcon::HomeIcon()
     Case ControlIcon::#ICON_BACK
       ControlIcon::BackIcon()
     Case ControlIcon::#ICON_WARNING
       ControlIcon::WarningIcon()
     Case ControlIcon::#ICON_ERROR
       ControlIcon::ErrorIcon()
  EndSelect
  
  StopVectorDrawing()
  SaveImage(image, iconFolder+ControlIcon::IconName(icon)+".png", #PB_ImagePlugin_PNG, #False, 32)
  FreeImage(image)
EndProcedure

For i=0 To ControlIcon::#ICON_LAST - 1
  SaveIconAsImage(i)
Next

  
Repeat
  event = WaitWindowEvent()
  
Until event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 60
; Folding = -
; EnableXP