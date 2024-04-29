

-- unit test clsSetValue

delete from LIB_DocumentProcess where  DPR_DOC_ID = 'REFACTORING_UNITTEST' and DPR_ID = 'clsSetValue' and DPR_ProgID = 'CtlProcess.clsSetValue' and DPR_DescrStep = 'setValue di esempio con parametri query condiction e query update' 
INSERT INTO [LIB_DocumentProcess] ( [DPR_DOC_ID],[DPR_ID],[DPR_ProgID],[DPR_DescrStep],[DPR_Order],[DPR_Param],[DPR_Module]) VALUES (N'REFACTORING_UNITTEST',N'clsSetValue',N'CtlProcess.clsSetValue',N'setValue di esempio con parametri query condiction e query update',N'10',N'QUERY_CONDITION#=#

select ''fittizio'' as esito

#@#QUERY_UPDATE#=#

INSERT INTO _Test(Number)
	VALUES ( 228 )

',N'REFACTORING')

-- unit test clsCheckAndUpd

-- condizione falsa ma non considerata NOT_CONDITION=yes
-- Viene restituito il messaggio
delete from LIB_DocumentProcess where DPR_DOC_ID = 'REFACTORING_UNITTEST' and DPR_ID = 'clsCheckAndUpd' and DPR_ProgID = 'CtlProcess.clsCheckAndUpd' and DPR_DescrStep = 'check and update di prova' 
INSERT INTO [LIB_DocumentProcess] ( [DPR_DOC_ID],[DPR_ID],[DPR_ProgID],[DPR_DescrStep],[DPR_Order],[DPR_Param],[DPR_Module]) VALUES (N'REFACTORING_UNITTEST',N'clsCheckAndUpd',N'CtlProcess.clsCheckAndUpd',N'check and update di prova',N'15',N'QUERY_CONDITION#=#

	-- non blochciamo mai! dopo aver provato l''ok, provare anche il caso di blocca togliendo il top 0
	select top 0 <ID_DOC> as ID
	
#@#MSG#=#Sono un check and update! ciao a tutti. Hello World Salvo e Luca#@#NOT_CONDITION#=#yes',N'REFACTORING')


-- condizione falsa e considerata NOT_CONDITION=no
delete from LIB_DocumentProcess where DPR_DOC_ID = 'REFACTORING_UNITTEST' and DPR_ID = 'clsCheckAndUpd_condfalse' and DPR_ProgID = 'CtlProcess.clsCheckAndUpd' and DPR_DescrStep = 'check and update di prova' 
INSERT INTO [LIB_DocumentProcess] ( [DPR_DOC_ID],[DPR_ID],[DPR_ProgID],[DPR_DescrStep],[DPR_Order],[DPR_Param],[DPR_Module]) 
VALUES (N'REFACTORING_UNITTEST',N'clsCheckAndUpd_condfalse',N'CtlProcess.clsCheckAndUpd',N'check and update di prova',N'15',N'QUERY_CONDITION#=#

	-- non blochciamo mai! dopo aver provato l''ok, provare anche il caso di blocca togliendo il top 0
	select top 0 <ID_DOC> as ID
	
#@#MSG#=#Sono un check and update! ciao a tutti. Hello World Salvo e Luca#@#NOT_CONDITION#=#no',N'REFACTORING')

-- unit test sub process

delete from LIB_DocumentProcess where  DPR_DOC_ID = 'REFACTORING_UNITTEST' and DPR_ID = 'subprocess_clsCheckAndUpd' and DPR_ProgID = 'CtlProcess.clsSetValue' and DPR_DescrStep = 'setValue di esempio con parametri query condiction e query update' 
INSERT INTO [LIB_DocumentProcess] ( [DPR_DOC_ID],[DPR_ID],[DPR_ProgID],[DPR_DescrStep],[DPR_Order],[DPR_Param],[DPR_Module]) 
VALUES (N'REFACTORING_UNITTEST',N'subprocess_clsCheckAndUpd',N'CtlProcess.clsCheckAndUpd',N'check and update di prova',N'15',N'QUERY_CONDITION#=#

	-- non blochciamo mai! dopo aver provato l''ok, provare anche il caso di blocca togliendo il top 0
	select top 0 <ID_DOC> as ID
	
#@#MSG#=#Sono un check and update! ciao a tutti. Hello World Salvo e Luca#@#NOT_CONDITION#=#no',N'REFACTORING')
delete from LIB_DocumentProcess where DPR_DOC_ID = 'REFACTORING_UNITTEST' and DPR_ID = 'clsSubProcess' and DPR_ProgID = 'CtlProcess.clsSubProcess' and DPR_DescrStep = 'test subProcess' 
INSERT INTO [LIB_DocumentProcess] ( [DPR_DOC_ID],[DPR_ID],[DPR_ProgID],[DPR_DescrStep],[DPR_Order],[DPR_Param],[DPR_Module]) 
VALUES (N'REFACTORING_UNITTEST',N'clsSubProcess',N'CtlProcess.clsSubProcess',N'test subProcess',N'20',N'DOC_NAME#=#REFACTORING_UNITTEST#@#PROC_NAME#=#subprocess_clsCheckAndUpd#@#NEW_PROCESS#=#yes#@#QUERY_DOCKEY#=#select <ID_DOC> as DOCKEY#@#QUERY_CONDITION#=#select 1 as DOCKEY',N'REFACTORING')