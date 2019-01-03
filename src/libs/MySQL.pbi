; ==============================================================================================
; MySQL MODULE DECLARATION
; ==============================================================================================
DeclareModule MySQL
  
  ;- OS Check
  Define mySQLfilename.s
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      mySQLfilename = "../../libs/x64/windows/libmysql.dll"
    CompilerCase #PB_OS_Linux
      mySQLfilename = "../../libs/x64/linux/libmysql.so"
    CompilerCase #PB_OS_MacOS
      mySQLfilename = "../../libs/x64/macos/libmysql.so"
  CompilerEndSelect

  ;- Structures
  Structure MYSQL
  EndStructure
  
  Structure MYSQL_RES
  EndStructure
  
  Structure MYSQL_BIND
  EndStructure
  
  Structure MYSQL_STMT
  EndStructure
  
  Structure MYSQL_ROW
    *field[255]
  EndStructure
  
  Structure MYSQL_FIELD
    name.s
    org_name.s
    table.s
    org_table.s
    db.s
    catalog.s
    def.s
    length.l
    max_length.l
    name_length.l
    org_name_length.l
    table_length.l
    org_table_length.l
    db_length.l
    catalog_length.l
    def_length.l
    flags.l
    decimals.l
    charset_nr.l
    type.l
  EndStructure
  Structure MY_CHARSET_INFO
    number.l
    state.l
    csname.s
    name.s
    Comment.s
    dir.s
    mbminlen.l
    mbmaxlen.l
  EndStructure
  
  ; PROTOTYPES
  PrototypeC PFNMYSQLGETCLIENTINFO()
  PrototypeC PFNMYSQLGETCLIENTVERSION()
  PrototypeC PFNMYSQLERRNO(*mysql.MYSQL)
  PrototypeC PFNMYSQLINIT(*mysql.MYSQL)
  PrototypeC PFNMYSQLREALCONNECT(*mysql.MYSQL,host.p-utf8,user.p-utf8,passwd.p-utf8,db.p-utf8,port.l,unix_socket.p-utf8,client_flag.l)
  PrototypeC PFNMYSQLGETPARAMETERS()
  PrototypeC PFNMYSQLSQLSTATE(*mysql.MYSQL)
  PrototypeC PFNMYSQLERROR(*mysql.MYSQL)
  PrototypeC PFNMYSQLGETSERVERVERSION(*mysql.MYSQL)
  PrototypeC PFNMYSQLGETSERVERINFO(*mysql.MYSQL)
  PrototypeC PFNMYSQLGETHOSTINFO(*mysql.MYSQL)
  PrototypeC PFNMYSQLSELECTDB(*mysql.MYSQL, Databasename.p-utf8)
  PrototypeC PFNMYSQLGETPROTOINFO(*mysql.MYSQL)
  PrototypeC PFNMYSQLINFO(*mysql.MYSQL)
  PrototypeC PFNMYSQLINSERTID(*mysql.MYSQL)
  PrototypeC PFNMYSQLAFFECTEDROWS(*mysql.MYSQL)
  PrototypeC PFNMYSQLAUTOCOMMIT(*mysql.MYSQL,*mode.Byte)
  PrototypeC PFNMYSQLCHARACTERSETNAME(*mysql.MYSQL)
  PrototypeC PFNMYSQLCLOSE(*mysql.MYSQL)
  PrototypeC PFNMYSQLCOMMIT(*mysql.MYSQL)
  PrototypeC PFNMYSQLDEBUG(DebugString.p-utf8)
  PrototypeC PFNMYSQLDISABLEREADSFROMMASTER(*mysql.MYSQL)
  PrototypeC PFNMYSQLDISABLERPLPARSE(*mysql.MYSQL)
  PrototypeC PFNMYSQLDUMPBDEBUGINFO(*mysql.MYSQL)
  PrototypeC PFNMYSQLEMBEDDED()
  PrototypeC PFNMYSQLENABLEREADSFROMMASTER(*mysql.MYSQL)
  PrototypeC PFNMYSQLENABLERPLPARSE(*mysql.MYSQL)
  PrototypeC PFNMYSQLFIELDCOUNT(*mysql.MYSQL)
  PrototypeC PFNMYSQLLIBRARYEND(*mysql.MYSQL)
  PrototypeC PFNMYSQLLISTPROCESSES(*mysql.MYSQL)
  PrototypeC PFNMYSQLMORERESULTS(*mysql.MYSQL)
  PrototypeC PFNMYSQLNEXTRESULT(*mysql.MYSQL)
  PrototypeC PFNMYSQLPING(*mysql.MYSQL)
  PrototypeC PFNMYSQLREADQUERYRESULT(*mysql.MYSQL)
  PrototypeC PFNMYSQLRELOAD(*mysql.MYSQL)
  PrototypeC PFNMYSQLROLLBACK(*mysql.MYSQL)
  PrototypeC PFNMYSQLRPLPARSEENABLED(*mysql.MYSQL)
  PrototypeC PFNMYSQLRPLPROBE(*mysql.MYSQL)
  PrototypeC PFNMYSQLSERVEREND()
  PrototypeC PFNMYSQLTHREADEND()
  PrototypeC PFNMYSQLTHREADINIT()
  PrototypeC PFNMYSQLTHREADSAFE()
  PrototypeC PFNMYSQLSTAT(*mysql.MYSQL)
  PrototypeC PFNMYSQLSTORERESULT(*mysql.MYSQL)
  PrototypeC PFNMYSQLTHREADID(*mysql.MYSQL)
  PrototypeC PFNMYSQLUSERESULT(*mysql.MYSQL)
  PrototypeC PFNMYSQLWARNINGCOUNT(*mysql.MYSQL)
  PrototypeC PFNMYSQLCHANGEUSER(*mysql.MYSQL,user.p-utf8,passwd.p-utf8,db.p-utf8)
  PrototypeC PFNMYSQLDATASEEK(*result.MYSQL_RES,offset.d)
  PrototypeC PFNMYSQLEOF(*result.MYSQL_RES)
  PrototypeC PFNMYSQLESCAPESTRING(strTo.p-utf8,strFrom.p-utf8,length.l)
  PrototypeC PFNMYSQLFETCHFIELD(*result.MYSQL_RES)
  PrototypeC PFNMYSQLFETCHFIELDDIRECT(*result.MYSQL_RES,fieldnr.l)
  PrototypeC PFNMYSQLFETCHFIELDS(*result.MYSQL_RES)
  PrototypeC PFNMYSQLFETCHLENGTHS(*result.MYSQL_RES)
  PrototypeC PFNMYSQLFETCHROW(*result.MYSQL_RES)
  PrototypeC PFNMYSQLFIELDSEEK(*result.MYSQL_RES,offset.l)
  PrototypeC PFNMYSQLFIELDTELL(*result.MYSQL_RES)
  PrototypeC PFNMYSQLFREERESULT(*result.MYSQL_RES)
  PrototypeC PFNMYSQLGETCHARACTERSETINFO(*mysql.MYSQL,*cs.MY_CHARSET_INFO)
  PrototypeC PFNMYSQLHEXSTRING(strTo.p-utf8,strFrom.p-utf8,length.l)
  PrototypeC PFNMYSQLKILL(*mysql.MYSQL,pid.l)
  PrototypeC PFNMYSQLLIBRARYINIT(argc.l,argv.l,Groups.l)
  PrototypeC PFNMYSQLLISTDBS(*mysql.MYSQL,wild.p-utf8)
  PrototypeC PFNMYSQLLISTFIELDS(*mysql.MYSQL,table.p-utf8,wild.p-utf8)
  PrototypeC PFNMYSQLLISTTABLES(*mysql.MYSQL,wild.p-utf8)
  PrototypeC PFNMYSQLMASTERQUERY(*mysql.MYSQL,query.p-utf8,length.l)
  PrototypeC PFNMYSQLNUMFIELDS(*result.MYSQL_RES)
  PrototypeC PFNMYSQLNUMROWS(*result.MYSQL_RES)
  PrototypeC PFNMYSQLOPTIONS(*mysql.MYSQL,option.l,arg.p-utf8)
  PrototypeC PFNMYSQLQUERY(*mysql.MYSQL,query.p-utf8)
  PrototypeC PFNMYSQLREALESCAPESTRING(*mysql.MYSQL,strTo.p-utf8,strFrom.p-utf8,length.l)
  PrototypeC PFNMYSQLREALQUERY(*mysql.MYSQL,query.p-utf8,length.l)
  PrototypeC PFNMYSQLREFRESH(*mysql.MYSQL,Options.l)
  PrototypeC PFNMYSQLROWSEEK(*mysql.MYSQL,offset.l)
  PrototypeC PFNMYSQLROWTELL(*result.MYSQL_RES)
  PrototypeC PFNMYSQLRPLQUERYTYPE(*mysql.MYSQL,type.l)
  PrototypeC PFNMYSQLSENDQUERY(*mysql.MYSQL,query.p-utf8,length.l)
  PrototypeC PFNMYSQLSERVERINIT(argc.l,argv.l,Groups.l)
  PrototypeC PFNMYSQLSETCHARACTERSET(*mysql.MYSQL,csname.p-utf8)
  PrototypeC PFNMYSQLSETSERVEROPTION(*mysql.MYSQL,option.l)
  PrototypeC PFNMYSQLSHUTDOWN(*mysql.MYSQL,shutdown_level.l)
  PrototypeC PFNMYSQLSLAVEQUERY(*mysql.MYSQL,query.p-utf8,length.l)
  PrototypeC PFNMYSQLSSLSET(*mysql.MYSQL,key.p-utf8,cert.p-utf8,ca.p-utf8,capath.p-utf8,cipher.p-utf8)
  
  
  ; IMPORT
  Define mySQLLib = OpenLibrary(#PB_Any, mySQLfilename)
  If mySQLLib
    Global mysql_get_client_info.PFNMYSQLGETCLIENTINFO = GetFunction(mySQLLib, "mysql_get_client_info")
    Global mysql_get_client_version.PFNMYSQLGETCLIENTVERSION = GetFunction(mySQLLib, "mysql_get_client_version")
    Global mysql_errno.PFNMYSQLERRNO = GetFunction(mySQLLib, "mysql_errno")
    Global mysql_init.PFNMYSQLINIT = GetFunction(mySQLLib, "mysql_init")
    Global mysql_real_connect.PFNMYSQLREALCONNECT = GetFunction(mySQLLib, "mysql_real_connect")
    Global mysql_get_parameters.PFNMYSQLGETPARAMETERS = GetFunction(mySQLLib, "mysql_get_parameters")
    Global mysql_sqlstate.PFNMYSQLSQLSTATE = GetFunction(mySQLLib, "mysql_sqlstate")
    Global mysql_error.PFNMYSQLERROR = GetFunction(mySQLLib, "mysql_error")
    Global mysql_get_server_version.PFNMYSQLGETSERVERVERSION = GetFunction(mySQLLib, "mysql_get_server_version")
    Global mysql_get_server_info.PFNMYSQLGETSERVERINFO = GetFunction(mySQLLib, "mysql_get_server_info")
    Global mysql_get_host_info.PFNMYSQLGETHOSTINFO = GetFunction(mySQLLib, "mysql_get_host_info")
    Global mysql_select_db.PFNMYSQLSELECTDB = GetFunction(mySQLLib, "mysql_select_db")
    Global mysql_get_proto_info.PFNMYSQLGETPROTOINFO = GetFunction(mySQLLib, "mysql_get_proto_info")
    Global mysql_info.PFNMYSQLINFO = GetFunction(mySQLLib, "mysql_info")
    Global mysql_insert_id.PFNMYSQLINSERTID = GetFunction(mySQLLib, "mysql_insert_id")
    Global mysql_affected_rows.PFNMYSQLAFFECTEDROWS = GetFunction(mySQLLib, "mysql_affected_rows")
    Global mysql_autocommit.PFNMYSQLAUTOCOMMIT = GetFunction(mySQLLib, "mysql_autocommit")
    Global mysql_character_set_name.PFNMYSQLCHARACTERSETNAME = GetFunction(mySQLLib, "mysql_character_set_name")
    Global mysql_close.PFNMYSQLCLOSE = GetFunction(mySQLLib, "mysql_close")
    Global mysql_commit.PFNMYSQLCOMMIT = GetFunction(mySQLLib, "mysql_commit")
    Global mysql_debug.PFNMYSQLDEBUG = GetFunction(mySQLLib, "mysql_debug")
    Global mysql_disable_reads_from_master.PFNMYSQLDISABLEREADSFROMMASTER = GetFunction(mySQLLib, "mysql_disable_reads_from_master")
    Global mysql_disable_rpl_parse.PFNMYSQLDISABLERPLPARSE = GetFunction(mySQLLib, "mysql_disable_rpl_parse")
    Global mysql_dumPB_debug_info.PFNMYSQLDUMPBDEBUGINFO = GetFunction(mySQLLib, "mysql_dumPB_debug_info")
    Global mysql_embedded.PFNMYSQLEMBEDDED = GetFunction(mySQLLib, "mysql_embedded")
    Global mysql_enable_reads_from_master.PFNMYSQLENABLEREADSFROMMASTER = GetFunction(mySQLLib, "mysql_enable_reads_from_master")
    Global mysql_enable_rpl_parse.PFNMYSQLENABLERPLPARSE = GetFunction(mySQLLib, "mysql_enable_rpl_parse")
    Global mysql_field_count.PFNMYSQLFIELDCOUNT = GetFunction(mySQLLib, "mysql_field_count")
    Global mysql_library_end.PFNMYSQLLIBRARYEND = GetFunction(mySQLLib, "mysql_library_end")
    Global mysql_list_processes.PFNMYSQLLISTPROCESSES = GetFunction(mySQLLib, "mysql_list_processes")
    Global mysql_more_results.PFNMYSQLMORERESULTS = GetFunction(mySQLLib, "mysql_more_results")
    Global mysql_next_result.PFNMYSQLNEXTRESULT = GetFunction(mySQLLib, "mysql_next_result")
    Global mysql_ping.PFNMYSQLPING = GetFunction(mySQLLib, "mysql_ping")
    Global mysql_read_query_result.PFNMYSQLREADQUERYRESULT = GetFunction(mySQLLib, "mysql_read_query_result")
    Global mysql_reload.PFNMYSQLRELOAD = GetFunction(mySQLLib, "mysql_reload")
    Global mysql_rollback.PFNMYSQLROLLBACK = GetFunction(mySQLLib, "mysql_rollback")
    Global mysql_rpl_parse_enabled.PFNMYSQLRPLPARSEENABLED = GetFunction(mySQLLib, "mysql_rpl_parse_enabled")
    Global mysql_rpl_probe.PFNMYSQLRPLPROBE = GetFunction(mySQLLib, "mysql_rpl_probe")
    Global mysql_server_end.PFNMYSQLSERVEREND = GetFunction(mySQLLib, "mysql_server_end")
    Global mysql_thread_end.PFNMYSQLTHREADEND = GetFunction(mySQLLib, "mysql_thread_end")
    Global mysql_thread_init.PFNMYSQLTHREADINIT = GetFunction(mySQLLib, "mysql_thread_init")
    Global mysql_thread_safe.PFNMYSQLTHREADSAFE = GetFunction(mySQLLib, "mysql_thread_safe")
    Global mysql_stat.PFNMYSQLSTAT = GetFunction(mySQLLib, "mysql_stat")
    Global mysql_store_result.PFNMYSQLSTORERESULT = GetFunction(mySQLLib, "mysql_store_result")
    Global mysql_thread_id.PFNMYSQLTHREADID = GetFunction(mySQLLib, "mysql_thread_id")
    Global mysql_use_result.PFNMYSQLUSERESULT = GetFunction(mySQLLib, "mysql_use_result")
    Global mysql_warning_count.PFNMYSQLWARNINGCOUNT = GetFunction(mySQLLib, "mysql_warning_count")
    Global mysql_change_user.PFNMYSQLCHANGEUSER = GetFunction(mySQLLib, "mysql_change_user")
    Global mysql_data_seek.PFNMYSQLDATASEEK = GetFunction(mySQLLib, "mysql_data_seek")
    Global mysql_eof.PFNMYSQLEOF = GetFunction(mySQLLib, "mysql_eof")
    Global mysql_escape_string.PFNMYSQLESCAPESTRING = GetFunction(mySQLLib, "mysql_escape_string")
    Global mysql_fetch_field.PFNMYSQLFETCHFIELD = GetFunction(mySQLLib, "mysql_fetch_field")
    Global mysql_fetch_field_direct.PFNMYSQLFETCHFIELDDIRECT = GetFunction(mySQLLib, "mysql_fetch_field_direct")
    Global mysql_fetch_fields.PFNMYSQLFETCHFIELDS = GetFunction(mySQLLib, "mysql_fetch_fields")
    Global mysql_fetch_lengths.PFNMYSQLFETCHLENGTHS = GetFunction(mySQLLib, "mysql_fetch_lengths")
    Global mysql_fetch_row.PFNMYSQLFETCHROW = GetFunction(mySQLLib, "mysql_fetch_row")
    Global mysql_field_seek.PFNMYSQLFIELDSEEK = GetFunction(mySQLLib, "mysql_field_seek")
    Global mysql_field_tell.PFNMYSQLFIELDTELL = GetFunction(mySQLLib, "mysql_field_tell")
    Global mysql_free_result.PFNMYSQLFREERESULT = GetFunction(mySQLLib, "mysql_free_result")
    Global mysql_get_character_set_info.PFNMYSQLGETCHARACTERSETINFO = GetFunction(mySQLLib, "mysql_get_character_set_info")
    Global mysql_hex_string.PFNMYSQLHEXSTRING = GetFunction(mySQLLib, "mysql_hex_string")
    Global mysql_kill.PFNMYSQLKILL = GetFunction(mySQLLib, "mysql_kill")
    Global mysql_library_init.PFNMYSQLLIBRARYINIT = GetFunction(mySQLLib, "mysql_library_init")
    Global mysql_list_dbs.PFNMYSQLLISTDBS = GetFunction(mySQLLib, "mysql_list_dbs")
    Global mysql_list_fields.PFNMYSQLLISTFIELDS = GetFunction(mySQLLib, "mysql_list_fields")
    Global mysql_list_tables.PFNMYSQLLISTTABLES = GetFunction(mySQLLib, "mysql_list_tables")
    Global mysql_master_query.PFNMYSQLMASTERQUERY = GetFunction(mySQLLib, "mysql_master_query")
    Global mysql_num_fields.PFNMYSQLNUMFIELDS = GetFunction(mySQLLib, "mysql_num_fields")
    Global mysql_num_rows.PFNMYSQLNUMROWS = GetFunction(mySQLLib, "mysql_num_rows")
    Global mysql_options.PFNMYSQLOPTIONS = GetFunction(mySQLLib, "mysql_options")
    Global mysql_query.PFNMYSQLQUERY = GetFunction(mySQLLib, "mysql_query")
    Global mysql_real_escape_string.PFNMYSQLREALESCAPESTRING = GetFunction(mySQLLib, "mysql_real_escape_string")
    Global mysql_real_query.PFNMYSQLREALQUERY = GetFunction(mySQLLib, "mysql_real_query")
    Global mysql_refresh.PFNMYSQLREFRESH = GetFunction(mySQLLib, "mysql_refresh")
    Global mysql_row_seek.PFNMYSQLROWSEEK = GetFunction(mySQLLib, "mysql_row_seek")
    Global mysql_row_tell.PFNMYSQLROWTELL = GetFunction(mySQLLib, "mysql_row_tell")
    Global mysql_rpl_query_type.PFNMYSQLRPLQUERYTYPE = GetFunction(mySQLLib, "mysql_rpl_query_type")
    Global mysql_send_query.PFNMYSQLSENDQUERY = GetFunction(mySQLLib, "mysql_send_query")
    Global mysql_server_init.PFNMYSQLSERVERINIT = GetFunction(mySQLLib, "mysql_server_init")
    Global mysql_set_character_set.PFNMYSQLSETCHARACTERSET = GetFunction(mySQLLib, "mysql_set_character_set")
    Global mysql_set_server_option.PFNMYSQLSETSERVEROPTION = GetFunction(mySQLLib, "mysql_set_server_option")
    Global mysql_shutdown.PFNMYSQLSHUTDOWN = GetFunction(mySQLLib, "mysql_shutdown")
    Global mysql_slave_query.PFNMYSQLSLAVEQUERY = GetFunction(mySQLLib, "mysql_slave_query")
    Global mysql_ssl_set.PFNMYSQLSSLSET = GetFunction(mySQLLib, "mysql_ssl_set")
  Else
    MessageRequester("[MySQL ERROR]", "Can't Load MySQL Library")
  EndIf

  Declare.s PeekS_Utf8(*buffer)

EndDeclareModule


; ==============================================================================================
; MySQL MODULE IMPLEMENTATION
; ==============================================================================================
Module MySQL
  Procedure.s PeekS_Utf8(*buffer)
    If *buffer
      ProcedureReturn PeekS(*buffer, -1, #PB_UTF8)
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
EndModule





; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 250
; FirstLine = 201
; Folding = -
; EnableXP