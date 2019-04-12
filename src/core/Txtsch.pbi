EnableExplicit

DeclareModule Txtsch
  #MAX_THREADS = 64
  Structure Hit_t
    gID.i               ; global ID    (in file)
    lID.i               ; line ID      (in file)
    cID.i               ; character ID (in line)
    line.s              ; content of the line
  EndStructure
  
  Structure File_t
    file.i
    name.s
    folder.s
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

Module Txtsch
  
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
      Define regex.i = CreateRegularExpression(#PB_Any, pattern)
      If regex
        If MatchRegularExpression(regex, file)
          FreeRegularExpression(regex)
          ProcedureReturn #True
        EndIf
        FreeRegularExpression(regex)
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
  
  Procedure GetNumLines(*file.File_t, *datas)
    Define *buffer.Byte = *datas
    ReadData(*file\file, *buffer, Lof(*file\file))
    Define numLines.i = 0
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
      Define i.i, c.c, cid=0, gid = 0

      If *file\file
        Define length = Lof(*file\file)         
        If Not length : ProcedureReturn : EndIf
        
        ; acquire file in memory
        Define *datas = AllocateMemory(length)    
        Define bytes = ReadData(*file\file, *datas, length) 
        
        ; split up the token string into a character array
        Define nc = Len(token)
        Dim tokens.c(nc)
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
                *file\hits()\lID = lid
                *file\hits()\cID = cid
                *file\hits()\gID = 666
                *file\hits()\line = line
              EndIf
              lid + 1
            Wend
            
            
          Case 1
            FileSeek(*file\file, 0)
            While Not gid = (length-1)
              c = PeekA(*datas + gid)
              gid + 1
              cid + 1
              
              If c = 10                 ; new line 
                lid + 1
                sid = 0
                cid = 0
              ElseIf c = tokens(sid)    ; we've got a match
                sid + 1
              Else                      ; else reset counter
                sid = 0
              EndIf
              If sid = nc-1             ; we've found our complete token
                AddElement(*file\hits())
                *file\hits()\lID = lid
                *file\hits()\gID = gid - nc
                *file\hits()\cID = cid - nc
                *file\hits()\line = GetOneLine(*file, gid - sid )
                FileSeek(*file\file, gid)
                sid = 0
                lid + 1
              EndIf
              
            Wend  
            
          Case 2
            
        EndSelect
        
        ; clean up
        CloseFile(*file\file)
        FreeArray(tokens())
        FreeMemory(*datas)
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
      
      
      If currentThread = #MAX_THREADS - 1 : currentThread = 0 : EndIf
      
      For i = currentThread To #MAX_THREADS - 1
        If Not IsThread(threads(i))
          Define *datas.SearchOneFile_t = AllocateMemory(SizeOf(SearchOneFile_t))
          *datas\file = *queue()
          *datas\mode = mode
          *datas\token = token
      
          threads(i) = CreateThread(@SearchOneFileThread(), *datas)
          DeleteElement(*queue())
          Break
        EndIf
      Next
    Wend
  EndProcedure
  
  
  Procedure Search(*search.Search_t, token.s, mode.i=0)
    ForEach *search\files()
      SearchOneFile(*search\files(), token, mode)
    Next
  EndProcedure
  
  
EndModule



; TEST CODE
Define folder.s = "E:/Projects/RnD/Alembic/booze"
Define pattern.s = ".h;.cpp"
Define token.s =  "BOOZE_TYPE"
Define numHitsThreaded.i = 0

Define search.Txtsch::Search_t
InitializeStructure(search, Txtsch::Search_t)
Txtsch::FilesFromFolder(search, folder, pattern, #True)

Define searchThreaded.Txtsch::Search_t
InitializeStructure(searchThreaded, Txtsch::Search_t)
Txtsch::FilesFromFolder(searchThreaded, folder, pattern, #True)
Define numFiles = ListSize(searchThreaded\files())
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

; Define numHits = 0
; ForEach search\files()
;   If ListSize(search\files()\hits())
;     With search\files()
;       ForEach \hits()
;         AddGadgetItem(gadget,-1, "LINE : "+Str(\hits()\lineID)+": "+\hits()\line+" IN "+\folder+"/"+\name)
;         numHits + 1
;       Next
;     EndWith
;     
;   EndIf
; Next


MessageRequester("SEARCH", "SINGLE THREAD : "+StrD((E1-T1)*0.001)+" : "+Str(numHits)+Chr(10)+Chr(10)+
                           "MULTI THREAD  : "+StrD((E2-T2)*0.001)+" : "+Str(numHitsThreaded)+Chr(10)+
                           "NUM FILES : "+Str(numFiles))



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 183
; FirstLine = 128
; Folding = ---
; EnableXP