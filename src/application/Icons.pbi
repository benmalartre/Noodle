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

Procedure SaveIconAsImage(icon.i, suffix.s, fill.i=ControlIcon::#FILL_COLOR_DEFAULT, 
                          stroke.i=ControlIcon::#STROKE_COLOR_DEFAULT, thickness=ControlIcon::#STROKE_WIDTH)
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
      ControlIcon::VisibleIcon(fill, stroke, thickness)  
    Case ControlIcon::#ICON_INVISIBLE
      ControlIcon::InvisibleIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_PLAYFORWARD
      ControlIcon::PlayForwardIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_PLAYBACKWARD
      ControlIcon::PlayBackwardIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_STOP
      ControlIcon::StopIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_PREVIOUSFRAME
      ControlIcon::PreviousFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_NEXTFRAME
      ControlIcon::NextFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_FIRSTFRAME
      ControlIcon::FirstFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_LASTFRAME
      ControlIcon::LastFrameIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_LOOP
      ControlIcon::LoopIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_TRANSLATE
      ControlIcon::TranslateIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_ROTATE
      ControlIcon::RotateIcon(fill, stroke, thickness) 
    Case ControlIcon::#ICON_SCALE
      ControlIcon::ScaleIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SELECT
       ControlIcon::SelectIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SPLITH
       ControlIcon::SplitHIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SPLITV
       ControlIcon::SplitVIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_LOCKED
       ControlIcon::LockedIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_UNLOCKED
       ControlIcon::LockedIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_OP
       ControlIcon::OpIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_TRASH
       ControlIcon::TrashIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_LAYER
       ControlIcon::LayerIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_PEN
       ControlIcon::PenIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_FOLDER
       ControlIcon::FolderIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_FILE
       ControlIcon::FileIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_SAVE
       ControlIcon::SaveIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_OPEN
       ControlIcon::OpenIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_HOME
       ControlIcon::HomeIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_BACK
       ControlIcon::BackIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_WARNING
       ControlIcon::WarningIcon(fill, stroke, thickness) 
     Case ControlIcon::#ICON_ERROR
       ControlIcon::ErrorIcon(fill, stroke, thickness) 
  EndSelect
  
  StopVectorDrawing()
  SaveImage(image, iconFolder+ControlIcon::IconName(icon)+"_"+suffix+".png", #PB_ImagePlugin_PNG, #False, 32)
  Debug "SAVED ICON : " + iconFolder+ControlIcon::IconName(icon)+"_"+suffix+".png"
  FreeImage(image)
EndProcedure

For i=0 To ControlIcon::#ICON_LAST - 1
  SaveIconAsImage(i, "default", ControlIcon::#FILL_COLOR_DEFAULT, ControlIcon::#STROKE_COLOR_DEFAULT)
  SaveIconAsImage(i, "selected", ControlIcon::#FILL_COLOR_SELECTED, ControlIcon::#STROKE_COLOR_SELECTED)
  SaveIconAsImage(i, "disabled", ControlIcon::#FILL_COLOR_DISABLED, ControlIcon::#STROKE_COLOR_DISABLED)
Next

  
Repeat
  event = WaitWindowEvent()
  
Until event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 142
; FirstLine = 118
; Folding = -
; EnableXP