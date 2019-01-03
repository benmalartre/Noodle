; ------------------------------- 
; Petit exemple sur le SQL avec libmysql. 
; c'est pompé sur l'exemple de Poshu, mais en
; vachement simplifié pour les bleus-bites comme moi

; Pour les fonctions MySql, allez voir ce site:
; http://doc.domainepublic.net/mysql/doc. ... tions.html
; plus clair que http://dev.mysql.com/doc/refman/5.0/fr/ ... tions.html

; Il faut déjà avoir créé une base mysql, bien sûr !

Define mysqldll.s = "E:\Projects\RnD\Noodle\libs\x64\windows\libmysql.dll" 

If FileSize(mysqldll) = -1
  MessageRequester("Error", "no file", 0)
  End
ElseIf OpenLibrary(0,mysqldll)
Else
  MessageRequester("Error", "lib mysql damaged", 0)
  End
EndIf

PrototypeC PFNMYSQLINIT(*mysql)
PrototypeC PFNMYSQLREALCONNECT( *mysql, host.p-ascii, user.p-ascii, passwd.p-ascii, db.p-ascii, port.l, unix_socket.p-ascii, client_flag)
PrototypeC PFNMYSQLQUERY( *mysql, query.p-ascii)

Define mysql_lib.i = OpenLibrary( #PB_Any ,mysqldll )

Global mysql_init.PFNMYSQLINIT = GetFunction(mysql_lib, "mysql_init")
Global mysql_real_connect.PFNMYSQLREALCONNECT = GetFunction(mysql_lib, "mysql_real_connect")
Global mysql_query.PFNMYSQLQUERY = GetFunction(mysql_lib, "mysql_query")

ExamineLibraryFunctions(mysql_lib)
While NextLibraryFunction()
  Debug LibraryFunctionName()
Wend


Debug mysql_init

serveur$ = "localhost" ; ip serveur easyphp
user$ ="root" ; nom utilisateur, root par défaut
pass$ ="root" ; mot de passe, vide par défaut
nomdb$="benmalartre" ; nom de la base de données
portsql =0 
pipe$ ="" 
conconf =0 
objetdb= mysql_init(0)

;se connecter à la base de donnée 
If mysql_real_connect(objetdb, serveur$, user$, pass$, nomdb$, portsql, pipe$, conconf)=0 
Debug "echec connexion"
End
EndIf 


;chopper des données: 

SQL$ = "SELECT * FROM users" ;ca c'est la requete 

resultat=mysql_query(objetdb,SQL$) ; exécution de la requête
; c'est l'adresse du résultat qui est mis dans la variable resultat
resultat=CallFunction(mysql_lib,"mysql_store_result",objetdb) ;stocke le résultat dans un
; objet qui sera manipulé ensuite. Renvoie 0 si la requête n'a rien donné!
;If resultat=0
; Debug "La requête a échoué !"
; End
;End If 

nblignes=CallFunction(mysql_lib,"mysql_num_rows",resultat) ;retourne le nombre de lignes
nbchamps=CallFunction(mysql_lib,"mysql_num_fields",resultat); nombre champs par ligne 

Debug "lignes "+Str(nblignes) 
Debug "colonnes "+Str(nbchamps)

For i=1 To nblignes

ligne=CallFunction(mysql_lib,"mysql_fetch_row",resultat); donne l'adresse du debut
; d'une ligne de résultats

For boucle = 0 To nbchamps-1 ;le premier champ est le 0, le second le 1...

pointeur=PeekL(ligne+4*(boucle));donne l'adresse du champ à lire 
;cette adresse est stockée sur 4 octets (soit 32 bits) donc entier Long
;donc commande PeekL et incrémentation de 4 à chaque passage.

If pointeur>0 
valeur.s=PeekS(pointeur) ; met le contenu du champ dans
; la variable chaîne 'valeur'
; C'est une chaîne, donc PeekS
Else 
valeur="NULL"
EndIf 

Debug valeur 
Next boucle
Next i
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 77
; FirstLine = 36
; EnableXP