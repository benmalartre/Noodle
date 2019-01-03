XIncludeFile "../libs/MySQL.pbi"

;   Debug "Info:    " + PeekS(mysql_get_client_info(), -1, #PB_UTF8)
;   Debug "Version: " + Str(mysql_get_client_version())
;   Debug Hex(mysql_get_parameters())
;   
;   *hDB = mysql_init(#Null)
;
;   If *hDB     
;     If mysql_real_connect(*hDB,"127.0.0.1","root","password","",3306,"NULL",#Null)
;       mysql_autocommit(*hDB,#True)
;       Debug "Connected!"
;       Debug mysql_get_server_version(*hDB)
;
;       
;       Debug "Server:"
;       Debug PeekS(mysql_get_server_info(*hDB), -1, #PB_UTF8)
;       Debug "Connection:"
;       Debug PeekS(mysql_get_host_info(*hDB), -1, #PB_UTF8)
;       Debug "Protocolgeneration:"
;       Debug Str(mysql_get_proto_info(*hDB))
;       
;       If mysql_select_db(*hDB,"test") <> 1
;         Debug "* DB Selected"
;         
;         If mysql_query(*hDB,"SHOW TABLES") <> 1
;           Debug "* Query made..."
;           ; get next INSERT ID
;           id = mysql_insert_id(*hDB)
;           If id
;             Debug "id>"+Str(id)
;           EndIf
;           ; get query info
;           *info = mysql_info(*hDB)
;           If *info
;             Debug PeekS(*info, -1, #PB_UTF8)
;           EndIf
;           
;           ; do we have a Result ?
;           If mysql_field_count(*hDB)
;             *result = mysql_store_result(*hDB)
;             
;             If *result
;               Debug "* Got Result!"
;               nRows.l = mysql_num_rows(*result)
;               Debug "Num Rows: " + Str(nRows.l)
;               
;               For i = 0 To nRows.l - 1
;                 *row.MYSQL_ROW = mysql_fetch_row(*result)
;                 If *row
;                     Rows.s = ""
;                     For j = 0 To mysql_num_fields(*result) - 1
;                         Rows + PeekS_Utf8(*row\field[j]) + ", ";PeekS_Utf8() does a peeks in utf8 mode, but if *row\field[j] is null (field is empty) it returns an empty string.
;                     Next
;                   Debug Rows
;                   Debug "rows>"+Rows
;                 EndIf
;               Next
;               
;               mysql_free_result(*result)
;             EndIf
;             
;           EndIf
;           
;         Else
;           Debug PeekS(mysql_error(*hDB), -1, #PB_UTF8)
;         EndIf
;         
;       Else
;         Debug Str(mysql_errno(*hDB))
;         Debug "Database Error!"
;         Debug PeekS(mysql_error(*hDB), -1, #PB_UTF8)
;       EndIf
;     
;     Else ; No Connect, Error!
;       Debug "Error: "
;       Debug PeekS(mysql_error(*hDB), -1, #PB_UTF8)
;     EndIf
;     
;     mysql_close(*hDB)
;     
;   EndIf


; TEST CODE
UseModule MySQL


server$ = "localhost"      ; ip serveur mamp
user$ = "root"               ; nom utilisateur, root par défaut
pass$ = "root"               ; mot de passe, vide par défaut
namedb$  = "benmalartre"        ; nom de la base de données
portsql = 0 
pipe$ = "" 
conf = 0 
objetdb= mysql_init(0)

; connexion
If mysql_real_connect(objetdb, server$, user$, pass$, namedb$, portsql, pipe$, conf)=0 
  Debug "FAIL CONNECT TO SQL DB"
End
EndIf 
Debug "SERVER VERSION : "+Str(mysql_get_server_version(objetdb))

; requete sql 
SQL$ = "SELECT * FROM cv" ;ca c'est la requete 

resultat = mysql_query(objetdb,SQL$) ; exécution de la requête
; c'est l'adresse du résultat qui est mis dans la variable resultat
resultat = mysql_store_result(objetdb) ;stocke le résultat dans un
; objet qui sera manipulé ensuite. Renvoie 0 si la requête n'a rien donné!
;If resultat=0
; Debug "La requête a échoué !"
; End
;End If 

nblignes = mysql_num_rows(resultat) ;retourne le nombre de lignes
nbchamps = mysql_num_fields(resultat); nombre champs par ligne 

Debug "lignes "+Str(nblignes) 
Debug "colonnes "+Str(nbchamps)

For i=1 To nblignes

ligne = mysql_fetch_row(resultat); donne l'adresse du debut
; d'une ligne de résultats

For boucle = 0 To nbchamps-1 ;le premier champ est le 0, le second le 1...

pointeur=PeekI(ligne+8*(boucle));donne l'adresse du champ à lire 
;cette adresse est stockée sur 4 octets (soit 32 bits) donc entier Long
;donc commande PeekL et incrémentation de 4 à chaque passage.

If pointeur>0 
valeur.s=PeekS(pointeur, -1, #PB_Ascii) ; met le contenu du champ dans
; la variable chaîne 'valeur'
; C'est une chaîne, donc PeekS
Else 
valeur="NULL"
EndIf 

Debug valeur 
Next boucle
Next i
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 105
; FirstLine = 66
; EnableXP