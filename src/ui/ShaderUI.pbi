XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "UI.pbi"


; XIncludeFile "Command.pbi"

; -----------------------------------------
; Shader Module Declaration
; -----------------------------------------
DeclareModule ShaderUI
  UseModule UI

  Structure ShaderUI_t Extends UI_t
    panel.i
    vertex.i
    frag.i
    save_btn.i
    saveas_btn.i
    load_btn.i
    *shader.Program::Program_t
  EndStructure
  
  Interface IShaderUI Extends IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s,*shader.Shader::Shader_t)
  Declare Delete(*ui.ShaderUI_t)
  Declare Init(*ui.ShaderUI_t)
  Declare OnEvent(*ui.ShaderUI_t,event.i)
  Declare Term(*ui.ShaderUI_t)
  Declare SetContent(*ui.ShaderUI_t,*shader.Shader::Shader_t)
  DataSection 
    DummyVT: 
    Data.i @Init()
    Data.i @OnEvent()
    Data.i @Term()
  EndDataSection 
  
EndDeclareModule

; -----------------------------------------
; ShaderUI Module Implementation
; -----------------------------------------
Module ShaderUI

  ; New
  ;-------------------------------
  Procedure New(*parent.View::View_t,name.s,*shader.Shader::Shader_t)
    Protected *ui.ShaderUI_t = AllocateMemory(SizeOf(ShaderUI_t))
    
    Protected x = *parent\x
    Protected y = *parent\y
    Protected w = *parent\width
    Protected h = *parent\height
    
    InitializeStructure(*ui,ShaderUI_t)
    *ui\shader = *shader
    *ui\name = name
    *ui\top = *parent
    
    Protected w2 = w-20
    *ui\container = FrameGadget(#PB_Any,x,y,w,h,"Shaders")
    *ui\save_btn = ButtonGadget(#PB_Any,x+10,y+25,w2/3,20,"Save")
    *ui\saveas_btn = ButtonGadget(#PB_Any,10+x+w2/3,y+25,w2/3,20,"Save As")
    *ui\load_btn = ButtonGadget(#PB_Any,10+x+2*w2/3,y+25,w2/3,20,"Load")
    *ui\panel = PanelGadget(#PB_Any,x+5,y+55,w-10,h-55)
    SetGadgetColor(*ui\panel,#PB_Gadget_BackColor,RGB(240,240,240))
    AddGadgetItem(*ui\panel,-1,"Vertex Shader")
    *ui\vertex = EditorGadget(#PB_Any,0,0,GadgetWidth(*ui\panel),GadgetHeight(*ui\panel)-25)
    
    SetGadgetColor(*ui\vertex,#PB_Gadget_BackColor,RGB(20,20,20))
    SetGadgetColor(*ui\vertex,#PB_Gadget_FrontColor,RGB(100,255,160))
    
    AddGadgetItem(*ui\panel,-1,"Fragment Shader")
    *ui\frag = EditorGadget(#PB_Any,0,0,GadgetWidth(*ui\panel),GadgetHeight(*ui\panel)-25)
    SetGadgetColor(*ui\frag,#PB_Gadget_BackColor,RGB(20,20,20))
    SetGadgetColor(*ui\frag,#PB_Gadget_FrontColor,RGB(100,255,160))
    
    SetGadgetState(*ui\panel,1)
    If *ui\shader
;       SetGadgetText(*ui\vertex,*ui\shader\s_vert)
;       SetGadgetText(*ui\frag,*ui\shader\s_frag)
    EndIf
    

    CloseGadgetList()
    
    *ui\width = w
    *ui\height = h
    *ui\VT = ?DummyVT
   
    
    ProcedureReturn *ui
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*ui.ShaderUI_t)
    ClearStructure(*ui,ShaderUI_t)
    FreeMemory(*ui)
  EndProcedure

 
  
  ; Init
  ;-------------------------------
  Procedure Init(*ui.ShaderUI_t)
    Debug "ShaderUI Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*ui.ShaderUI_t,event.i)
    Protected path.s
    Protected file.i
    Protected str.s
    Protected nb.i
    Protected i.i
    Protected window.i = EventWindow()
    Select event
      Case #PB_Event_SizeWindow
        Debug "EVENT SIZE WINDOW"
        Protected x,y,w,h
        x = GadgetX(*ui\container)
        y = GadgetY(*ui\container)
        w = GadgetWidth(*ui\container)
        h = GadgetHeight(*ui\container)
        Protected w2 = w-20
        ResizeGadget(*ui\save_btn,x+10,y+25,w2/3,25)    
        ResizeGadget(*ui\saveas_btn,x+w2/3+10,y+25,w2/3,25) 
        ResizeGadget(*ui\load_btn,x+2*w2/3+10,y+25,w2/3,25) 
        ResizeGadget(*ui\panel,x+5,y+55,w-10,h-55)
        ResizeGadget(*ui\vertex,0,0,GadgetWidth(*ui\panel),GadgetHeight(*ui\panel)-25)
        ResizeGadget(*ui\frag,0,0,GadgetWidth(*ui\panel),GadgetHeight(*ui\panel)-25)
      Case #PB_Event_Gadget
        Protected g = EventGadget()
        Select g
          Case *ui\vertex
            
            Select EventType()
              Case #PB_EventType_Change
                *ui\shader\vert\s =  GetGadgetText(*ui\vertex)
                CompilerIf #PB_Compiler_Unicode
                   *ui\shader\pgm = Program::Create("shader",Shader::DeCodeUnicodeShader(*ui\shader\vert\s),"",Shader::DeCodeUnicodeShader(*ui\shader\frag\s),#True)
                CompilerElse
                   *ui\shader\pgm = Program::Create("shader",*ui\shader\vert\s,"",*ui\shader\frag\s,#True)
                CompilerEndIf
               
            EndSelect
            
          Case *ui\frag

            Select EventType()
              Case #PB_EventType_Change
                *ui\shader\frag\s = GetGadgetText(*ui\frag)
                CompilerIf #PB_Compiler_Unicode
                  *ui\shader\pgm = Program::Create("shader", Shader::DeCodeUnicodeShader(*ui\shader\vert\s),"",Shader::DeCodeUnicodeShader(*ui\shader\frag\s),#True)
                CompilerElse
                  *ui\shader\pgm = Program::Create("shader", *ui\shader\vert\s,"",*ui\shader\frag\s,#True)
                CompilerEndIf
                
            EndSelect
            
          Case *ui\save_btn
            If *ui\shader\frag\path = ""
              *ui\shader\frag\path = SaveFileRequester("Save File","","*.glsl",0)
            EndIf
            
            file = CreateFile(#PB_Any,*ui\shader\frag\path)
            FileSeek(file,0)
            If file
              nb = CountString(*ui\shader\frag\s,Chr(10))
              For i=1 To nb
                WriteString(file,StringField(*ui\shader\frag\s,i,Chr(10)))
              Next
              CloseFile(file)
            Else
              MessageRequester("CAN'T OPEN FILE",*ui\shader\frag\path)
            EndIf
            
          Case *ui\saveas_btn
            *ui\shader\frag\path = SaveFileRequester("Save File","","*.glsl",0)
            
            file = CreateFile(#PB_Any,*ui\shader\frag\path)
            
            If file
              nb = CountString(*ui\shader\frag\s,Chr(10))

              For i=1 To nb
                WriteString(file,StringField(*ui\shader\frag\s,i,Chr(10)))
              Next
              CloseFile(file)
            Else
              MessageRequester("CAN'T OPEN FILE",*ui\shader\frag\path)
            EndIf
              
            
          Case *ui\load_btn
            path = OpenFileRequester("Select Shader File","","*.glsl",0)
            Define state = GetGadgetState(*ui\panel)
            If Not path = ""
              file = ReadFile(#PB_Any,path,#PB_Ascii) 
              str.s
              While Not Eof(file)
                str + ReadString(file)+Chr(10)
              Wend  
              
              Select state
                  Case 0:
                    *ui\shader\vert\s = str
                    *ui\shader\vert\path = path
                    SetGadgetText(*ui\vertex, str)
                    PostEvent(#PB_Event_Gadget, window, *ui\vertex, #PB_EventType_Change)
                  Case 1:
                    *ui\shader\frag\s = str
                    *ui\shader\frag\path = path
                    SetGadgetText(*ui\frag, str)
                    PostEvent(#PB_Event_Gadget, window, *ui\frag, #PB_EventType_Change)
                  Case 2:
                    *ui\shader\geom\s = str
                    *ui\shader\geom\path = path
                    ;SetGadgetText(*ui\shader\geom, str)  
                EndSelect
                
              CloseFile(file)
              
;               PostEvent(#PB_Event_Gadget,EventWindow(),*ui\frag,#PB_EventType_Change)
            EndIf
            
            
            
          
        EndSelect
        
    EndSelect
    
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*ui.ShaderUI_t)
    Debug "ShaderUI Term Called!!!"
  EndProcedure
  
  ; Set Content
  ;-------------------------------
  Procedure SetContent(*ui.ShaderUI_t,*shader.Shader::Shader_t)
    *ui\shader = *shader
    SetGadgetText(*ui\vertex,*ui\shader\vert\s)
    SetGadgetText(*ui\frag,*ui\shader\frag\s)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 121
; FirstLine = 77
; Folding = --
; EnableXP