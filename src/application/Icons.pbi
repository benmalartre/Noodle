XIncludeFile "../core/Icons.pbi"

UsePNGImageEncoder()


CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Global iconFolder.s = "C:/Users/graph/Documents/bmal/src/Amnesie/icons/"
CompilerElseIf #PB_Compiler_OS  = #PB_OS_MacOS
  Global iconFolder.s = "/Users/benmalartre/Documents/RnD/amnesie/icons/"
CompilerEndIf


#RESOLUTION = 64
Define window = OpenWindow(#PB_Any, 0,0,800,800,"Icons")
Define  canvas = CanvasGadget(#PB_Any, 0,0,800,800)
  
Global iconCounter = 0


Procedure DrawIcon(func.Icon::DrawIconImpl)
  Define currentX = (iconCounter % 8) * 100
  Define currentY = (iconCounter / 8) * 100
  iconCounter + 1
  ResetCoordinates()
  TranslateCoordinates(currentX, currentY)
  func()
EndProcedure

Procedure CopyFolder(srcFolder.S, dstFolder.s)
  DeleteDirectory(dstFolder, "*", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
  CreateDirectory(dstFolder)
  
  Define dir.i = ExamineDirectory(#PB_Any, srcFolder, "*")
  While NextDirectoryEntry(dir)
    If DirectoryEntryType(dir) = #PB_DirectoryEntry_File
      Define filename.s = DirectoryEntryName(dir)
      CopyFile(srcFolder + filename, dstFolder + filename)
    EndIf
  Wend  
  FinishDirectory(dir)
EndProcedure

StartVectorDrawing(CanvasVectorOutput(canvas))
DrawIcon(Icon::@LoopIcon())
DrawIcon(Icon::@PlayForwardIcon())
DrawIcon(Icon::@PlayBackwardIcon())
DrawIcon(Icon::@StopIcon())
DrawIcon(Icon::@PreviousFrameIcon())
DrawIcon(Icon::@NextFrameIcon())
DrawIcon(Icon::@FirstFrameIcon())
DrawIcon(Icon::@LastFrameIcon())
DrawIcon(Icon::@VisibleIcon())
DrawIcon(Icon::@InvisibleIcon())
DrawIcon(Icon::@TranslateIcon())
DrawIcon(Icon::@RotateIcon())
DrawIcon(Icon::@ScaleIcon())
DrawIcon(Icon::@BrushIcon())
DrawIcon(Icon::@PenIcon())
DrawIcon(Icon::@SelectIcon())
DrawIcon(Icon::@SplitVIcon())
DrawIcon(Icon::@SplitHIcon())
DrawIcon(Icon::@LockedIcon())
DrawIcon(Icon::@UnlockedIcon())
DrawIcon(Icon::@OpIcon())
DrawIcon(Icon::@TrashIcon())
DrawIcon(Icon::@StageIcon())
DrawIcon(Icon::@LayerIcon())
DrawIcon(Icon::@FolderIcon())
DrawIcon(Icon::@FileIcon())
DrawIcon(Icon::@HomeIcon())
DrawIcon(Icon::@BackIcon())
DrawIcon(Icon::@WarningIcon())
DrawIcon(Icon::@ErrorIcon())
DrawIcon(Icon::@SaveIcon())
DrawIcon(Icon::@OpenIcon())
DrawIcon(Icon::@ExpendedIcon())
DrawIcon(Icon::@ConnectedIcon())
DrawIcon(Icon::@CollapsedIcon())
DrawIcon(Icon::@ArrowLeftIcon())
DrawIcon(Icon::@ArrowRightIcon())
DrawIcon(Icon::@ArrowUpIcon())
DrawIcon(Icon::@ArrowDownIcon())
StopVectorDrawing()

Procedure SaveIconAsImage(icon.i, suffix.s, fill.i=Icon::#FILL_COLOR_DEFAULT, 
                          stroke.i=Icon::#STROKE_COLOR_DEFAULT, thickness=Icon::#STROKE_WIDTH)
  Define image.i = CreateImage(#PB_Any, #RESOLUTION, #RESOLUTION, 32)
  
  StartDrawing(ImageOutput(image))
  DrawingMode(#PB_2DDrawing_AlphaChannel)
  Box(0,0,#RESOLUTION, #RESOLUTION, RGBA(0,0,0,0))
  StopDrawing()

  StartVectorDrawing(ImageVectorOutput(image))
 
  ResetCoordinates()
  ScaleCoordinates(#RESOLUTION / 100, #RESOLUTION / 100)
  Select icon
    Case Icon::#ICON_VISIBLE
      Icon::VisibleIcon(fill, stroke, thickness)  
    Case Icon::#ICON_INVISIBLE
      Icon::InvisibleIcon(fill, stroke, thickness) 
    Case Icon::#ICON_PLAYFORWARD
      Icon::PlayForwardIcon(fill, stroke, thickness) 
    Case Icon::#ICON_PLAYBACKWARD
      Icon::PlayBackwardIcon(fill, stroke, thickness) 
    Case Icon::#ICON_STOP
      Icon::StopIcon(fill, stroke, thickness) 
    Case Icon::#ICON_PREVIOUSFRAME
      Icon::PreviousFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_NEXTFRAME
      Icon::NextFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_FIRSTFRAME
      Icon::FirstFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_LASTFRAME
      Icon::LastFrameIcon(fill, stroke, thickness) 
    Case Icon::#ICON_LOOP
      Icon::LoopIcon(fill, stroke, thickness) 
    Case Icon::#ICON_TRANSLATE
      Icon::TranslateIcon(fill, stroke, thickness) 
    Case Icon::#ICON_ROTATE
      Icon::RotateIcon(fill, stroke, thickness) 
    Case Icon::#ICON_SCALE
      Icon::ScaleIcon(fill, stroke, thickness) 
     Case Icon::#ICON_BRUSH
       Icon::BrushIcon(fill, stroke, thickness) 
     Case Icon::#ICON_PEN
       Icon::PenIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SELECT
       Icon::SelectIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SPLITH
       Icon::SplitHIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SPLITV
       Icon::SplitVIcon(fill, stroke, thickness) 
     Case Icon::#ICON_LOCKED
       Icon::LockedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_UNLOCKED
       Icon::LockedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_OP
       Icon::OpIcon(fill, stroke, thickness) 
     Case Icon::#ICON_TRASH
       Icon::TrashIcon(fill, stroke, thickness) 
     Case Icon::#ICON_STAGE
       Icon::StageIcon(fill, stroke, thickness)
     Case Icon::#ICON_LAYER
       Icon::LayerIcon(fill, stroke, thickness) 
     Case Icon::#ICON_FOLDER
       Icon::FolderIcon(fill, stroke, thickness) 
     Case Icon::#ICON_FILE
       Icon::FileIcon(fill, stroke, thickness) 
     Case Icon::#ICON_SAVE
       Icon::SaveIcon(fill, stroke, thickness) 
     Case Icon::#ICON_OPEN
       Icon::OpenIcon(fill, stroke, thickness) 
     Case Icon::#ICON_HOME
       Icon::HomeIcon(fill, stroke, thickness) 
     Case Icon::#ICON_BACK
       Icon::BackIcon(fill, stroke, thickness) 
     Case Icon::#ICON_WARNING
       Icon::WarningIcon(fill, stroke, thickness) 
     Case Icon::#ICON_ERROR
       Icon::ErrorIcon(fill, stroke, thickness) 
     Case Icon::#ICON_EXPENDED
       Icon::ExpendedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_CONNECTED
       Icon::ConnectedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_COLLAPSED
       Icon::CollapsedIcon(fill, stroke, thickness) 
     Case Icon::#ICON_ARROWLEFT
       Icon::ArrowLeftIcon(fill, stroke, thickness) 
     Case Icon::#ICON_ARROWRIGHT
       Icon::ArrowRightIcon(fill, stroke, thickness) 
     Case Icon::#ICON_ARROWUP
       Icon::ArrowUpIcon(fill, stroke, thickness) 
     Case Icon::#ICON_ARROWDOWN
       Icon::ArrowDownIcon(fill, stroke, thickness) 
  EndSelect
  
  StopVectorDrawing()
  SaveImage(image, iconFolder+Icon::IconName(icon)+"_"+suffix+".png", #PB_ImagePlugin_PNG, #False, 32)
  FreeImage(image)
EndProcedure

For i=0 To Icon::#ICON_LAST - 1
  SaveIconAsImage(i, "default", Icon::#FILL_COLOR_DEFAULT, Icon::#STROKE_COLOR_DEFAULT)
  SaveIconAsImage(i, "selected", Icon::#FILL_COLOR_SELECTED, Icon::#STROKE_COLOR_SELECTED)
  SaveIconAsImage(i, "disabled", Icon::#FILL_COLOR_DISABLED, Icon::#STROKE_COLOR_DISABLED)
Next


CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_MacOS
    Define dstFolder.s = "/Users/benmalartre/Documents/RnD/amnesie/build/src/icons/"
    CopyFolder(iconFolder, dstFolder)
  CompilerCase #PB_OS_Windows
    Define dstFolder.s = "C:/Users/graph/Documents/bmal/src/Jivaro/build/src/Release/icons/"
    CopyFolder(iconFolder, dstFolder)
CompilerEndSelect



  
Repeat
  event = WaitWindowEvent()
  
Until event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 172
; FirstLine = 36
; Folding = -
; EnableXP