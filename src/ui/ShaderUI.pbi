XIncludeFile "../opengl/Shader.pbi"
XIncludeFile "UI.pbi"


; XIncludeFile "Command.pbi"

; -----------------------------------------
; Shader Module Declaration
; -----------------------------------------
DeclareModule ShaderUI

  Structure ShaderUI_t Extends UI::UI_t
    panel.i
    vertex.i
    frag.i
    save_btn.i
    saveas_btn.i
    load_btn.i
    *shader.Program::Program_t
  EndStructure
  
  Interface IShaderUI Extends UI::IUI
  EndInterface

  Declare New(*parent.View::View_t,name.s,*shader.Shader::Shader_t)
  Declare Delete(*Me.ShaderUI_t)
  Declare Init(*Me.ShaderUI_t)
  Declare OnEvent(*Me.ShaderUI_t,event.i)
  Declare Term(*Me.ShaderUI_t)
  Declare SetContent(*Me.ShaderUI_t,*shader.Shader::Shader_t)
  DataSection 
    ShaderUIVT: 
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
    Protected *Me.ShaderUI_t = AllocateMemory(SizeOf(ShaderUI_t))
    
    Protected x = *parent\posX
    Protected y = *parent\posY
    Protected w = *parent\sizX
    Protected h = *parent\sizY
    
    Object::INI(ShaderUI)
    *Me\shader = *shader
    *Me\name = name
    *Me\parent = *parent
    *Me\posX = x
    *Me\posY = y
    *Me\sizX = w
    *Me\sizY = h
    
    Protected w2 = w-20
    *Me\container = FrameGadget(#PB_Any,x,y,w,h,"Shaders")
    *Me\save_btn = ButtonGadget(#PB_Any,x+10,y+25,w2/3,20,"Save")
    *Me\saveas_btn = ButtonGadget(#PB_Any,10+x+w2/3,y+25,w2/3,20,"Save As")
    *Me\load_btn = ButtonGadget(#PB_Any,10+x+2*w2/3,y+25,w2/3,20,"Load")
    *Me\panel = PanelGadget(#PB_Any,x+5,y+55,w-10,h-55)
    SetGadgetColor(*Me\panel,#PB_Gadget_BackColor,RGB(240,240,240))
    AddGadgetItem(*Me\panel,-1,"Vertex Shader")
    *Me\vertex = EditorGadget(#PB_Any,0,0,GadgetWidth(*Me\panel),GadgetHeight(*Me\panel)-25)
    
    SetGadgetColor(*Me\vertex,#PB_Gadget_BackColor,RGB(20,20,20))
    SetGadgetColor(*Me\vertex,#PB_Gadget_FrontColor,RGB(100,255,160))
    
    AddGadgetItem(*Me\panel,-1,"Fragment Shader")
    *Me\frag = EditorGadget(#PB_Any,0,0,GadgetWidth(*Me\panel),GadgetHeight(*Me\panel)-25)
    SetGadgetColor(*Me\frag,#PB_Gadget_BackColor,RGB(20,20,20))
    SetGadgetColor(*Me\frag,#PB_Gadget_FrontColor,RGB(100,255,160))
    
    SetGadgetState(*Me\panel,1)
    If *Me\shader
;       SetGadgetText(*Me\vertex,*Me\shader\s_vert)
;       SetGadgetText(*Me\frag,*Me\shader\s_frag)
    EndIf
    

    CloseGadgetList()

    ProcedureReturn *Me
  EndProcedure
  
  ; Delete
  ;-------------------------------
  Procedure Delete(*Me.ShaderUI_t)
    FreeGadget(*Me\frag)
    FreeGadget(*Me\vertex)
    FreeGadget(*Me\panel)
    FreeGadget(*Me\load_btn)
    FreeGadget(*Me\saveas_btn)
    FreeGadget(*Me\save_btn)
    FreeGadget(*Me\container)
    Object::TERM(ShaderUI)
  EndProcedure

 
  
  ; Init
  ;-------------------------------
  Procedure Init(*Me.ShaderUI_t)
    Debug "ShaderUI Init Called!!!"
  EndProcedure
  
  ; Event
  ;-------------------------------
  Procedure OnEvent(*Me.ShaderUI_t,event.i)
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
        x = GadgetX(*Me\container)
        y = GadgetY(*Me\container)
        w = GadgetWidth(*Me\container)
        h = GadgetHeight(*Me\container)
        Protected w2 = w-20
        ResizeGadget(*Me\save_btn,x+10,y+25,w2/3,25)    
        ResizeGadget(*Me\saveas_btn,x+w2/3+10,y+25,w2/3,25) 
        ResizeGadget(*Me\load_btn,x+2*w2/3+10,y+25,w2/3,25) 
        ResizeGadget(*Me\panel,x+5,y+55,w-10,h-55)
        ResizeGadget(*Me\vertex,0,0,GadgetWidth(*Me\panel),GadgetHeight(*Me\panel)-25)
        ResizeGadget(*Me\frag,0,0,GadgetWidth(*Me\panel),GadgetHeight(*Me\panel)-25)
      Case #PB_Event_Gadget
        Protected g = EventGadget()
        Select g
          Case *Me\vertex
            
            Select EventType()
              Case #PB_EventType_Change
                *Me\shader\vert\s =  GetGadgetText(*Me\vertex)
                CompilerIf #PB_Compiler_Unicode
                   *Me\shader\pgm = Program::Create("shader",Shader::DeCodeUnicodeShader(*Me\shader\vert\s),"",Shader::DeCodeUnicodeShader(*Me\shader\frag\s),#True)
                CompilerElse
                   *Me\shader\pgm = Program::Create("shader",*Me\shader\vert\s,"",*Me\shader\frag\s,#True)
                CompilerEndIf
               
            EndSelect
            
          Case *Me\frag

            Select EventType()
              Case #PB_EventType_Change
                *Me\shader\frag\s = GetGadgetText(*Me\frag)
                CompilerIf #PB_Compiler_Unicode
                  *Me\shader\pgm = Program::Create("shader", Shader::DeCodeUnicodeShader(*Me\shader\vert\s),"",Shader::DeCodeUnicodeShader(*Me\shader\frag\s),#True)
                CompilerElse
                  *Me\shader\pgm = Program::Create("shader", *Me\shader\vert\s,"",*Me\shader\frag\s,#True)
                CompilerEndIf
                
            EndSelect
            
          Case *Me\save_btn
            If *Me\shader\frag\path = ""
              *Me\shader\frag\path = SaveFileRequester("Save File","","*.glsl",0)
            EndIf
            
            file = CreateFile(#PB_Any,*Me\shader\frag\path)
            FileSeek(file,0)
            If file
              nb = CountString(*Me\shader\frag\s,Chr(10))
              For i=1 To nb
                WriteString(file,StringField(*Me\shader\frag\s,i,Chr(10)))
              Next
              CloseFile(file)
            Else
              MessageRequester("CAN'T OPEN FILE",*Me\shader\frag\path)
            EndIf
            
          Case *Me\saveas_btn
            *Me\shader\frag\path = SaveFileRequester("Save File","","*.glsl",0)
            
            file = CreateFile(#PB_Any,*Me\shader\frag\path)
            
            If file
              nb = CountString(*Me\shader\frag\s,Chr(10))

              For i=1 To nb
                WriteString(file,StringField(*Me\shader\frag\s,i,Chr(10)))
              Next
              CloseFile(file)
            Else
              MessageRequester("CAN'T OPEN FILE",*Me\shader\frag\path)
            EndIf
              
            
          Case *Me\load_btn
            path = OpenFileRequester("Select Shader File","","*.glsl",0)
            Define state = GetGadgetState(*Me\panel)
            If Not path = ""
              file = ReadFile(#PB_Any,path,#PB_Ascii) 
              str.s
              While Not Eof(file)
                str + ReadString(file)+Chr(10)
              Wend  
              
              Select state
                  Case 0:
                    *Me\shader\vert\s = str
                    *Me\shader\vert\path = path
                    SetGadgetText(*Me\vertex, str)
                    PostEvent(#PB_Event_Gadget, window, *Me\vertex, #PB_EventType_Change)
                  Case 1:
                    *Me\shader\frag\s = str
                    *Me\shader\frag\path = path
                    SetGadgetText(*Me\frag, str)
                    PostEvent(#PB_Event_Gadget, window, *Me\frag, #PB_EventType_Change)
                  Case 2:
                    *Me\shader\geom\s = str
                    *Me\shader\geom\path = path
                    ;SetGadgetText(*Me\shader\geom, str)  
                EndSelect
                
              CloseFile(file)
              
;               PostEvent(#PB_Event_Gadget,EventWindow(),*Me\frag,#PB_EventType_Change)
            EndIf
            
            
            
          
        EndSelect
        
    EndSelect
    
  EndProcedure
  
  ; Term
  ;-------------------------------
  Procedure Term(*Me.ShaderUI_t)
    Debug "ShaderUI Term Called!!!"
  EndProcedure
  
  ; Set Content
  ;-------------------------------
  Procedure SetContent(*Me.ShaderUI_t,*shader.Shader::Shader_t)
    *Me\shader = *shader
    SetGadgetText(*Me\vertex,*Me\shader\vert\s)
    SetGadgetText(*Me\frag,*Me\shader\frag\s)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 52
; FirstLine = 45
; Folding = --
; EnableXP