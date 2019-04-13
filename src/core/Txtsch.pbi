EnableExplicit
;========================================================================================
; Txtsch Module Declaration  ( search text in file content )
;========================================================================================
DeclareModule Txtsch
  #MAX_THREADS = 64
  Structure Hit_t
    lineID.i
    charID.i
    line.s
  EndStructure
  
  Structure File_t
    file.i
    name.s
    folder.s
    *buffer
    bytes.i
    List hits.Hit_t()
  EndStructure
  
  Structure Search_t
    token.s
    List *files.File_t()
  EndStructure
  
  Structure SearchOneFile_t
    *file.File_t
    token.s
    mode.i
  EndStructure

  Declare FilesFromFolder(*search.Search_t, folder.s, pattern.s="*.*", recurse.b=#False)
  Declare SearchOneFile(*file.File_t, token.s, mode.i=0)
  Declare Search(*file.File_t, token.s, mode.i=0)
  Declare ThreadSearch(*search.Search_t, token.s, mode.i=0)
  Declare GetNumHits(*search.Search_t)
EndDeclareModule

;========================================================================================
; Txtsch Module Implementation
;========================================================================================
Module Txtsch
  Procedure.b CheckOnePattern(file.s, pattern.s)
    ProcedureReturn Bool(FindString(file, pattern) > 0)
  EndProcedure
  
  Procedure.b CheckPattern(file.s, patterns.s)
    Define numTickets, numSeparators.i = CountString(patterns, ";")
    If Right(patterns, 1) = ";"
      numTickets = numSeparators
    Else
      numTickets = numSeparators + 1
    EndIf
    
    Define pattern.s
    Define i
    For i=0 To numTickets-1
      pattern = StringField(patterns, i+1,";")
      If CheckOnePattern(file, pattern)
        ProcedureReturn #True
      EndIf
      
    Next
   ProcedureReturn #False
 EndProcedure
 
 Procedure.s GetOneLine(*file.File_t, index.i)
   FileSeek(*file\file, index, #PB_Absolute)
   ProcedureReturn ReadString(*file\file)
 EndProcedure
 
  Procedure NextLine(*file.File_t)
    While ReadCharacter(*file\file) <> 10 : Wend
  EndProcedure
 
  Procedure GetNumHits(*search.Search_t)
    Define numHits = 0
    ForEach *search\files()
      numHits + ListSize(*search\files()\hits())
    Next
    ProcedureReturn numHits
  EndProcedure
  
  Procedure GetBuffer(*file.File_t)
    
  EndProcedure
  
  Procedure GetNumLines(*file.File_t)
    Define numLines.i = 0
    Define *buffer.Byte = *file\buffer
    While *buffer\b <> 0
      If *buffer\b = 10
        numLines+1
      EndIf
      *buffer+1
    Wend
    ProcedureReturn numLines
  EndProcedure

  Procedure FilesFromFolder(*search.Search_t, path.s, pattern.s="*.*", recurse.b=#False)
    Define.i Id
    Id = ExamineDirectory(#PB_Any, path, "*.*")
    
    If Id
      While NextDirectoryEntry(Id)
      
        If DirectoryEntryName(Id) = "."  : Continue : EndIf
        If DirectoryEntryName(Id) = ".." : Continue : EndIf
        
        If DirectoryEntryType(Id) = #PB_DirectoryEntry_File
          If CheckPattern(DirectoryEntryName(Id), pattern)
            AddElement(*search\files())
            *search\files() = AllocateMemory(SizeOf(File_t))
            InitializeStructure(*search\files(), File_t)
            *search\files()\name = DirectoryEntryName(Id)
            *search\files()\folder = path
          EndIf
        Else
          FilesFromFolder(*search, path + "\"+ DirectoryEntryName(Id), pattern, recurse)
        EndIf
      Wend
      FinishDirectory(Id)
    EndIf
  EndProcedure
  
  Procedure SearchOneFile(*file.File_t, token.s, mode.i=0)
    If FileSize(*file\folder+"/"+*file\name)>0
      *file\file = ReadFile(#PB_Any, *file\folder+"/"+*file\name)
  
      Define line.s, lid.i = 0
      Define i.i, c.c, sid.i=0, cid.i = 0, gid = 0

      If *file\file
        Define length = Lof(*file\file)         
        If Not length : ProcedureReturn : EndIf
        
        ; acquire file in memory
        *file\buffer = AllocateMemory(length)    
        *file\bytes = ReadData(*file\file, *file\buffer, length) 
        
        ; split up the token string into a character array
        Define nc = Len(token)
        Dim tokens.c(Len(token))
        For i=0 To nc-1
          tokens(i) = Asc(Mid(token, i+1, 1))
        Next
        
        ; search the file
        Select mode
          Case 0
            FileSeek(*file\file, 0)
            While Not Eof(*file\file)
              line = ReadString(*file\file)
              cid = FindString(line, token)
              If cid
                AddElement(*file\hits())
                *file\hits()\lineID = lid
                *file\hits()\charID = cid
                *file\hits()\line = line
              EndIf
              lid + 1
            Wend
            
            
          Case 1
            FileSeek(*file\file, 0)
            While Not gid = (length-1)
              c = PeekA(*file\buffer + gid)
              If c = 10                 ; new line 
                lid + 1
                cid = 0
                sid = 0
              ElseIf c = tokens(sid)    ; we've got a match
                sid + 1
                cid + 1
              Else                      ; else reset counter
                sid = 0
                cid + 1
              EndIf
              If sid = nc-1             ; we've found our complete token
                AddElement(*file\hits())
                *file\hits()\lineID = lid
                *file\hits()\charID = cid - nc
                *file\hits()\line = GetOneLine(*file, gid - (cid-1) )
                FileSeek(*file\file, gid)
              EndIf
              gid + 1
            Wend  
            
          Case 2
            
        EndSelect
        
        ; clean up
        CloseFile(*file\file)
        FreeMemory(*file\buffer)
        FreeArray(tokens())

      EndIf
    EndIf
    
  EndProcedure
  
  Procedure SearchOneFileThread(*datas.SearchOneFile_t)
    SearchOneFile(*datas\file, *datas\token, *datas\mode)
    FreeMemory(*datas)
  EndProcedure
  
  Procedure ThreadSearch(*search.Search_t, token.s, mode.i=0)
    NewList *queue.File_t()
    CopyList(*search\files(), *queue())
    
    Dim threads.i(#MAX_THREADS)
    Define currentThread.i = 0
    
    While ListSize(*queue())
      
      
      If currentThread >= #MAX_THREADS  : currentThread = 0 : EndIf
      
      For i = currentThread To #MAX_THREADS - 1
        If Not IsThread(threads(i))
          Define *datas.SearchOneFile_t = AllocateMemory(SizeOf(SearchOneFile_t))
          *datas\file = *queue()
          *datas\mode = mode
          *datas\token = token
      
          threads(i) = CreateThread(@SearchOneFileThread(), *datas)
          DeleteElement(*queue())
          currentThread = i+1
          Break
        EndIf
      Next
    Wend
    
    ; wait threads to finish
    Define working.i
    
    Repeat
      working = 0
      For i=0 To #MAX_THREADS-1
        If IsThread(threads(i))
          working + 1
        EndIf
      Next
    Until Not working 
      
  EndProcedure
  
  
  Procedure Search(*search.Search_t, token.s, mode.i=0)
    ForEach *search\files()
      SearchOneFile(*search\files(), token, mode)
    Next
  EndProcedure
  
  
EndModule


; TEST CODE
Define folder.s = "E:\Projects\RnD\Alembic\booze\PureBasic";"C:\Program Files\Autodesk\Maya2018"
Define pattern.s = ".h;.cpp"
Define token.s =  "BOOZE"

Define search.Txtsch::Search_t
InitializeStructure(search, Txtsch::Search_t)
Txtsch::FilesFromFolder(search, folder, pattern, #True)

Define searchThreaded.Txtsch::Search_t
InitializeStructure(searchThreaded, Txtsch::Search_t)
Txtsch::FilesFromFolder(searchThreaded, folder, pattern, #True)

; Define file.Txtsch::File_t
; InitializeStructure(file, Txtsch::File_t)
; file\folder = "E:/Projects/RnD/Alembic/booze"
; file\name = "AlembicAttribute.cpp"
; 
; Txtsch::SearchOneFile(file, "BOOZE", 1)

Define mode = 1
Define T1.q = ElapsedMilliseconds()
Txtsch::Search(search, token, mode)
Define E1.q = ElapsedMilliseconds()
Define numHits = Txtsch::GetNumHits(search)

Define T2.q = ElapsedMilliseconds()
Txtsch::ThreadSearch(searchThreaded, token, mode)
Define E2.q = ElapsedMilliseconds()
Define numHitsThreaded = Txtsch::GetNumHits(searchThreaded)

Define file = CreateFile(#PB_Any, "E:/Projects/RnD/test/search"+Str(mode)+".log")
ForEach search\files()
  If ListSize(search\files()\hits())
    With search\files()
      ForEach \hits()
        WriteStringN(file, \hits()\line+" IN "+\folder+"/"+\name+" : LINE "+Str(\hits()\lineID))
      Next
    EndWith
    
  EndIf
Next


MessageRequester("SEARCH", "SINGLE THREAD : "+StrD((E1-T1)*0.001)+" : "+Str(numHits)+Chr(10)+Chr(10)+
                           "MULTI THREAD  : "+StrD((E2-T2)*0.001)+" : "+Str(numHitsThreaded))



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 264
; FirstLine = 252
; Folding = ---
; EnableXP