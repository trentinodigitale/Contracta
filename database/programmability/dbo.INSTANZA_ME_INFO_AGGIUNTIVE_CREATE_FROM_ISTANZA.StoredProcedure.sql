USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INSTANZA_ME_INFO_AGGIUNTIVE_CREATE_FROM_ISTANZA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[INSTANZA_ME_INFO_AGGIUNTIVE_CREATE_FROM_ISTANZA] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	--declare @idDoc as int
	--set @idDoc=155065

	declare @Errore as nvarchar(MAX)
	declare @id as int
	declare @id_modello as int
	declare @DES_Order as int
	declare @classe_modello nvarchar(MAX) 
	declare @OPEN_DOC as int
	declare @tipodoc varchar(1000)
	declare @stato_funz_istanza varchar(1000)
	declare @classi nvarchar(MAX) 
	declare @sez_valide nvarchar(MAX) 
	declare @sez_da_rimuovere nvarchar(MAX) 
	declare @out as int
	declare @ELENCO_PATH_CLASSI_MODELLO nvarchar(MAX) 
	set @ELENCO_PATH_CLASSI_MODELLO=''
	declare @ELENCO_CLASSI_MODELLO nvarchar(MAX) 
	set @ELENCO_CLASSI_MODELLO = ''
	set @id=0
	set @OPEN_DOC=0
	set @Errore=''
	set @DES_Order=10
	
	set @tipodoc = 'INSTANZA_ME_INFO_AGGIUNTIVE_' + cast(@iddoc as varchar(10))

	select @stato_funz_istanza=StatoFunzionale from ctl_doc where id=@idDoc

	--Verifica la presenza di un documento ISTANZA_ME_INFO_AGGIUNTIVE% il cui linkeddoc è quello dell'istanza
	select @id=id 
		from ctl_doc
	where LinkedDoc=@idDoc and TipoDoc=@tipodoc and Deleted=0

	--se l'istanza non è in lavorazione ed ha trovato il documento lo apre
	if @id > 0 and @stato_funz_istanza <> 'InLavorazione'
	begin
		set @OPEN_DOC=1		
	end	

	

	if @stato_funz_istanza = 'InLavorazione'
	BEGIN
		--RECUPERO LE CLASSI SELEZIONATE SULL'ISTANZA
		select @classi=value from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID in ('DISPLAY_CLASSI','DISPLAY_ABILITAZIONI') and DZT_Name='ClasseIscriz'
		--print 	@classi
		 --INVOCO QUESTA STORED CHE MI DA IL PATH DELLE CLASSI CHE HANNO ASSOCIATO UN MODELLO
		declare @t table (name nvarchar(MAX))
		insert @t (name)
		exec SP_CAN_INSERT_INFO_ADD_ISTANZA @iddoc , @classi , @out output
	
		--NELLA VARIABILE HO ELENCO DEI PATH DELLE CLASSI CHE RICHIEDONO INFO AGGIUNTIVE SUL QUALE VIENE FATTO UN SORT E UNA DISTINCT
		select @ELENCO_PATH_CLASSI_MODELLO=name from  @t

		
		set @ELENCO_CLASSI_MODELLO ='###'
	
		select   @ELENCO_CLASSI_MODELLO = @ELENCO_CLASSI_MODELLO + C.DMV_Cod  + '###' 
			from dbo.split(@ELENCO_PATH_CLASSI_MODELLO,'###')
		inner join ClasseIscriz C on C.DMV_Father=items
		order by items

		--print @ELENCO_CLASSI_MODELLO

	END
	


	--se non lo trova e l'istanza è in lavorazione lo crea
	IF @id = 0 and @stato_funz_istanza = 'InLavorazione'
	BEGIN

		insert into ctl_doc (IdPfu,Titolo,LinkedDoc,TipoDoc)
		select @IdUser,'Informazioni Aggiuntive',@idDoc,@tipodoc

		set @id=SCOPE_IDENTITY()

		--mi inserisco in un campo sentinella per il documento contentente il path delle classi INFO_ADD del modello che lo richiedono
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
		select @id,'SENTINELLA_PATH_CLASSI_INFO_ADD','PATH_CLASSI',0,@ELENCO_CLASSI_MODELLO
		
		

		insert into CTL_Documents ( DOC_ID, DOC_DescML, DOC_Table, DOC_FieldID, DOC_LFN_GroupFunction, DOC_ProgIdCustomizer, DOC_Help, DOC_Param, DOC_Module, DOC_DocPermission, DOC_PosPermission ) 
			select @tipodoc as DOC_ID, DOC_DescML, DOC_Table, DOC_FieldID, DOC_LFN_GroupFunction, DOC_ProgIdCustomizer, DOC_Help, DOC_Param, DOC_Module, DOC_DocPermission, DOC_PosPermission  
			from LIB_Documents where DOC_ID = 'ISTANZA_ME_INFO_AGGIUNTIVE'
	
		insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
			select @tipodoc AS DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module 
				from LIB_DocumentSections   where DSE_DOC_ID = 'ISTANZA_ME_INFO_AGGIUNTIVE' and DSE_ID='TESTATA'
	
	END

	IF @id > 0 and @stato_funz_istanza = 'InLavorazione'
	BEGIN

		-- Ciclo sul classi che richiedono le info aggiuntive e se non ci sono sul documento le aggiungo
			declare CurRow Cursor static for 
			select 
				distinct CT.id as id_modello ,CV.Value as classe_modello
				from dbo.Split(@ELENCO_CLASSI_MODELLO,'###')
					inner join ctl_doc CT on CT.TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and ct.StatoFunzionale in ('Pubblicato') and ct.Deleted=0
					inner join CTL_DOC_Value CV on CV.IdHeader=CT.id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz' and value like '%###'+items+'###%'
	
			open CurRow

			FETCH NEXT FROM CurRow 	INTO @id_modello , @classe_modello
				WHILE @@FETCH_STATUS = 0
			BEGIN
					--CONTROLLO SE PER IL MODELLO IN QUESTIONE ESISTE LA SEZIONE SUL DOCUMENTO
					IF NOT EXISTS ( 
									Select * 
										from CTL_DocumentSections 
											inner join CTL_DOC on id=@id_modello
											inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
										where DES_Table= 'Document_MicroLotti_Dettagli'  and  DSE_DOC_ID = @tipodoc and DSE_ID=MOD_ID
								   )
					BEGIN
						select @DES_Order=max(DES_Order) + 10 from CTL_DocumentSections where DSE_DOC_ID=@tipodoc

						insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
								select  @tipodoc as DSE_DOC_ID, DSE_ID + '_' +  CAST(@DES_Order as varchar(10)) as DSE_ID ,DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, @DES_Order as DES_Order, DES_Module 
									from LIB_DocumentSections   where DSE_DOC_ID = 'ISTANZA_ME_INFO_AGGIUNTIVE' and DSE_ID='CLASSE'
						

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							select @id ,'CLASSE'+ '_' + CAST(@DES_Order as varchar(10)) , 0 , 'ClasseIscriz' , @classe_modello as Value 
							from ctl_doc
								inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
							where ctl_doc.id=@id_modello

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							select @id ,'CLASSE'+ '_' + CAST(@DES_Order as varchar(10)) , 0 , 'Body' , Body as Value 
							from ctl_doc
								inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
							where ctl_doc.id=@id_modello



						
						set @DES_Order=@DES_Order + 10

					   insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
							select  @tipodoc as DSE_DOC_ID, MOD_ID as DSE_ID, MOD_ID , MOD_ID as DSE_MOD_ID , '' as DES_LFN_GroupFunction, 0 as DES_PosPermission,
									'Document_MicroLotti_Dettagli' as DES_Table, 'idHeader' as DES_FieldIdDoc, 'id' as DES_FieldIdRow, 'Tipodoc=''' +MOD_ID + '_' + cast(@iddoc as varchar(10)) + ' '' ' as DES_TableFilter, 'CtlDocument.Sec_Caption' as  DES_ProgID,
									'VIEW=&FIELD_OWNER=&HEIGHT=&WIN=no&READONLYCONDITION=&STATE_FIELD=&OBLIG_FIELD=&VIEW_FROM=&SEC_FIELD=YES&FROM_USER_FIELD=&READONLY=&FILTER_ROW=TipoDoc='''+ MOD_ID + '_' + cast(@iddoc as varchar(10))+'''&DYNAMIC_MODEL_SAVE=yes&DYNAMIC_MODEL=yes' as DSE_PARAM
									, @DES_Order as DES_Order, 'INFO_ADD' as DES_Module 
							from ctl_doc
								inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
							where ctl_doc.id=@id_modello

						insert into Document_MicroLotti_Dettagli (idheader,tipodoc)
						select @id , MOD_ID + '_' + cast(@iddoc as varchar(10))
						from ctl_doc
								inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
							where ctl_doc.id=@id_modello

             
						--MODELLO VIS	
						insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
						select @id,MOD_ID,MOD_ID
						from ctl_doc
								inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
							where ctl_doc.id=@id_modello
						--MODELLO SAVE DINAMICO
						insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
						select @id,MOD_ID + '_SAVE',MOD_ID
						from ctl_doc
								inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'
							where ctl_doc.id=@id_modello

						--set @DES_Order=@DES_Order + 10
					END
					

			FETCH NEXT FROM CurRow 	INTO @id_modello , @classe_modello
				END 
			CLOSE CurRow
			DEALLOCATE CurRow	

	END


	----se l'istanza è in lavorazione e lo trova verifica che sia coerente con le classi presenti sull'istanza e le sezioni del documento altrimenti lo è lo adegua
	IF  @id > 0 and @stato_funz_istanza = 'InLavorazione'
	BEGIN
		--VERIFICO SE CI SONO DEI CAMBIAMENTI ED EVENTUALMENTE ADEGUARE
		IF NOT EXISTS ( select * from CTL_DOC_Value where IdHeader=@id and DSE_ID='SENTINELLA_PATH_CLASSI_INFO_ADD' and DZT_Name='PATH_CLASSI' and value=@ELENCO_CLASSI_MODELLO)
		BEGIN

			select mod_id into #temp_sez_valide from 
			dbo.Split(@ELENCO_CLASSI_MODELLO,'###')
					inner join ctl_doc CT on CT.TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and ct.StatoFunzionale in ('Pubblicato') and ct.Deleted=0
					inner join CTL_DOC_Value CV on CV.IdHeader=CT.id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz' and value like '%###'+items+'###%'					
					inner join CTL_Models on MOD_ID='INFO_ADD_'+titolo+'_MOD_Modello'

			
			declare CurRow Cursor static for 
				--sono le sezioni da rimuovere, passo per il cursore per eliminare anche la sezione della classe
				select DSE_ID as sez_da_rimuovere
						from CTL_DocumentSections where DSE_DOC_ID=@tipodoc and DES_Table='Document_MicroLotti_Dettagli' 
					and dse_id not in (select mod_id from #temp_sez_valide)					
			open CurRow

			FETCH NEXT FROM CurRow 	INTO @sez_da_rimuovere
				WHILE @@FETCH_STATUS = 0
				BEGIN
					select @DES_Order=DES_Order-10 from CTL_DocumentSections where DSE_ID=@sez_da_rimuovere and DSE_DOC_ID=@tipodoc

					delete from CTL_DocumentSections where DSE_ID=@sez_da_rimuovere and DSE_DOC_ID=@tipodoc
					---@DES_Order visto che la section della classe ha come DSE_ID CLASSE_@desorder-10
					delete from CTL_DocumentSections where DSE_ID='CLASSE_' + CAST(@DES_Order as varchar(20)) and DSE_DOC_ID=@tipodoc


			FETCH NEXT FROM CurRow 	INTO @sez_da_rimuovere
				END 

			CLOSE CurRow
			DEALLOCATE CurRow	
	
		drop table #temp_sez_valide


		--mi inserisco in un campo sentinella per il documento contentente il path delle classi INFO_ADD del modello che lo richiedono
		
		delete from CTL_DOC_Value where IdHeader=@id and DSE_ID = 'SENTINELLA_PATH_CLASSI_INFO_ADD' and DZT_Name='PATH_CLASSI'

		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
			select @id,'SENTINELLA_PATH_CLASSI_INFO_ADD','PATH_CLASSI',0,@ELENCO_CLASSI_MODELLO

		END
	END
	
	---SE PER IL DOCUMENTO APPENA CREATO, ESISTE IN PRECEDENZA UN INFO_ADD PER QUELLE CLASSI PROVA A RECUPERARE I DATI
	IF EXISTS ( select * from ctl_doc where id=@idDoc and ISNULL(prevDoc,0) > 0 )
	BEGIN
		declare @id_prev int
		declare @id_prev_ok int
		declare @iddest as int
		declare @idfrom as int
		set @id_prev=0
		set @id_prev_ok=0
		declare @modello_INFO as nvarchar(1000)

		select @id_prev=PrevDoc from ctl_doc where id=@idDoc  
		--RECUPERO IL PREV_DOC con INFO_ADD SE LO TROVO
		while ( @id_prev_ok = 0 and @id_prev > 0 )
		BEGIN
			select @id_prev=ISNULL(C.PrevDoc,0),@id_prev_ok=ISNULL(C2.LinkedDoc,0)
				from ctl_doc C 
					left join ctl_doc C2 on C2.tipodoc='INSTANZA_ME_INFO_AGGIUNTIVE_' + CAST(@id_prev as varchar(20))  and C2.deleted = 0 and c2.StatoFunzionale='Inviato' and c2.LinkedDoc=@id_prev
				where C.id=@id_prev
		END
		
--		INFO_ADD_Macchinari_Industriali_1_MOD_Modello_85531
		if @id_prev_ok > 0
		begin
			DECLARE cur1 CURSOR STATIC FOR
			select 
					distinct 'INFO_ADD_' + Ct.Titolo + '_MOD_Modello_' as modello_INFO  
						from dbo.Split(@ELENCO_CLASSI_MODELLO,'###')
							inner join ctl_doc CT on CT.TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and ct.StatoFunzionale in ('Pubblicato') and ct.Deleted=0
							inner join CTL_DOC_Value CV on CV.IdHeader=CT.id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz' and value like '%###'+items+'###%'
			OPEN cur1 
			FETCH NEXT FROM cur1 INTO @modello_INFO	
			WHILE @@FETCH_STATUS = 0   
			BEGIN	
				
				select @iddest=id from Document_MicroLotti_Dettagli where IdHeader=@id and TipoDoc=@modello_INFO+cast(@idDoc as varchar(100))
				select @idfrom=id from Document_MicroLotti_Dettagli where IdHeader=(select id from ctl_doc where tipodoc='INSTANZA_ME_INFO_AGGIUNTIVE_' + CAST(@id_prev_ok as varchar(20)) and LinkedDoc=@id_prev_ok and deleted = 0  ) and TipoDoc=@modello_INFO+cast(@id_prev_ok as varchar(100))
				
				
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idfrom  , @iddest , ',Id,IdHeader,TipoDoc,EsitoRiga,Statoriga, '			 


				FETCH NEXT FROM cur1 INTO @modello_INFO
			END
			
			
			CLOSE cur1
			DEALLOCATE cur1
		end




		
	END




	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id , @tipodoc as TYPE_TO
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end


END














GO
