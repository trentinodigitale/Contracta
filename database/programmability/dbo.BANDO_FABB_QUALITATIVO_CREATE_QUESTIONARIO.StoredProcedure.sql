USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_FABB_QUALITATIVO_CREATE_QUESTIONARIO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[BANDO_FABB_QUALITATIVO_CREATE_QUESTIONARIO] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;


	declare @KeyRiga			varchar(1000)
	declare @Domanda_Sezione	varchar(1000)
	declare @Domanda_Elenco		varchar(1000)
	declare @Descrizione		varchar(1000)
	declare @NomeModello		varchar(1000)
	declare @Domanda_Tipologia	varchar(100)
	declare @Titolo				varchar(1000)
	declare @ModelloSave		varchar(1000)
	declare @NoteCompilazione   nvarchar(max)
	declare @TitoloDomanda		nvarchar(max)
	declare @NomeModelloIndice varchar(50)
	declare @NomeSezione		varchar(100)
		
	declare @ListaSezioni		varchar(max)
	declare @GUID varchar(1000)

	-- verifico se il teplate del bando è cambiato
	if exists( select b.idrow   -- ci sono valori che prima non c'erano
					from CTL_DOC_VALUE b
						left outer join CTL_DOC_VALUE c on  c.DSE_ID = 'VALORI_COPY' and b.IdHeader = c.IdHeader and b.DZT_Name = c.DZT_Name and b.Row = c.Row and b.Value = c.Value 
					where b.idheader = @idDoc and b.DSE_ID = 'VALORI' and c.IdRow is null
						)
		or 
		exists( select b.idrow  -- c'erano valori che ora non cisono
					from CTL_DOC_VALUE b
						left outer join CTL_DOC_VALUE c on  c.DSE_ID = 'VALORI' and b.IdHeader = c.IdHeader and b.DZT_Name = c.DZT_Name and b.Row = c.Row and b.Value = c.Value 
					where b.idheader = @idDoc and b.DSE_ID = 'VALORI_COPY' and c.IdRow is null
			)
	begin
		
		select @GUID = cast( guid as varchar(1000))  from CTL_DOC where id = @idDoc
		set @GUID = REPLACE( @GUID , '-' , '_' )
		-- cancella la vecchia copia e la ricreo
		delete from CTL_DOC_Value where IdHeader = @idDoc and DSE_ID = 'VALORI_COPY' 
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			select IdHeader, 'VALORI_COPY'  as DSE_ID, Row, DZT_Name, Value 
				from CTL_DOC_Value where IdHeader = @idDoc and DSE_ID = 'VALORI' order by IdRow


		declare @DocName varchar(50)
		set @DocName = 'QUESTIONARIO_' + REPLACE( @GUID , '-' , '_' )
		update document_bando set TipoBando = @DocName where idHeader = @idDoc



		-- cancello un eventuale documento presistente
		-- e la sua persistenza
		delete from CTL_Documents where DOC_ID = @DocName
		delete from CTL_DocumentSections where DSE_DOC_ID = @DocName
		update CTL_DOC set deleted = 1 where Tipodoc = @DocName


		--------------------------------------------------------------------
		--copio la parte iniziale del documento da un documento di partenza
		--------------------------------------------------------------------
		insert into CTL_Documents ( DOC_ID, DOC_DescML, DOC_Table, DOC_FieldID, DOC_LFN_GroupFunction, DOC_ProgIdCustomizer, DOC_Help, DOC_Param, DOC_Module, DOC_DocPermission, DOC_PosPermission ) 
			select @DocName as DOC_ID, DOC_DescML, DOC_Table, DOC_FieldID, DOC_LFN_GroupFunction, DOC_ProgIdCustomizer, DOC_Help, DOC_Param, DOC_Module, DOC_DocPermission, DOC_PosPermission  
				from LIB_Documents where DOC_ID = 'QUESTIONARIO_BASE'
		
		insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
			select @DocName AS DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module 
				from LIB_DocumentSections   where DSE_DOC_ID = 'QUESTIONARIO_BASE'

		-- creo i modelli specicifici per il salvataggio delle sezioni base
		set @ModelloSave = @DocName + '_TESTATA_SAVE'
		exec CopiaModello @ModelloSave , 'QUESTIONARIO_BASE_TESTATA_SAVE' , 'FABBISOGNI_QUALITATIVI'
		
		set @ModelloSave = @DocName + '_TESTATA_SUB_QUESTIONARI_SAVE'
		exec CopiaModello @ModelloSave , 'QUESTIONARIO_BASE_TESTATA_SUB_QUESTIONARI_SAVE' , 'FABBISOGNI_QUALITATIVI'

		-- creo una copia del modello per la definizione dei sub questionari e lo sostituisco sulla sezione per filtrare solo le sezioni relative alla richiesta
		set @ModelloSave = @DocName + '_SUB_QUESTIONARI'
		exec CopiaModello @ModelloSave , 'QUESTIONARIO_BASE_SUB_QUESTIONARI' , 'FABBISOGNI_QUALITATIVI'
		insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
			values ( @ModelloSave, 'Sezioni_Questionario', 'Filter' , 'SQL_WHERE= DMV_Father = ''' + cast( @idDoc as varchar(20)) + ''''  , 'FABBISOGNI_QUALITATIVI' )
		update CTL_DocumentSections set DSE_MOD_ID = @ModelloSave where DSE_DOC_ID = @DocName and DSE_ID = 'SUB_QUESTIONARI'


		-- CREO IL DOCUMENTO DI RIFERIMENTO
		insert into CTL_DOC ( LinkedDoc , Titolo , Tipodoc , StatoFunzionale , JumpCheck )
			values ( @idDoc , 'Esempio Questionario' , @DocName , 'Chiuso' , 'TEMPLATE' )

		declare @idTemplate  int
		declare @idModello   int
		declare @Row		 varchar(20)

		set @idTemplate = @@identity

		-- conservo sul documento l'id del template
		update CTL_Doc set iddoc = @idTemplate where id = @idDoc


		set @ListaSezioni = ''

		-- Ciclo sul template sezioni VALORI
		declare CurRow Cursor static for 
			select  K.Value as KeyRiga , T.Value as Domanda_Sezione , Q.Value as Domanda_Elenco , D.Value AS Descrizione , cast( T.Row  as varchar(20))
				from CTL_DOC_VALUE T
					INNER JOIN CTL_DOC_VALUE Q on T.IdHeader = Q.idheader and T.DSE_ID = Q.DSE_ID and T.Row = Q.Row and  Q.DZT_Name = 'Domanda_Elenco' 
					INNER JOIN CTL_DOC_VALUE D on T.IdHeader = D.idheader and T.DSE_ID = D.DSE_ID and T.Row = D.Row and  D.DZT_Name = 'Descrizione' 
					INNER JOIN CTL_DOC_VALUE K on T.IdHeader = K.idheader and T.DSE_ID = K.DSE_ID and T.Row = K.Row and  K.DZT_Name = 'KeyRiga' 
				where T.IdHeader = @idDoc and T.DSE_ID = 'VALORI' and T.DZT_Name = 'Domanda_Sezione'
				order by t.Row
	
		open CurRow

		-- ciclo sulle righe dei criteri di ricerca
		FETCH NEXT FROM CurRow 	INTO @KeyRiga , @Domanda_Sezione , @Domanda_Elenco , @Descrizione , @Row
		WHILE @@FETCH_STATUS = 0
		BEGIN


			-- se la riga è una sezione 
			if @Domanda_Sezione = 'sezione'
			begin
				-- aggiungo la sezione con il modello per le sezioni e preparo i valori con la descrizione richiesta

				--set @NomeSezione = 'SEZ_' + @GUID + '_' + replace( @KeyRiga , ' ' , '' ) + '_SEZIONE'
				set @NomeSezione = 'SEZ_' + @Row + '_' + '_SEZIONE'


				insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
					select  @DocName as DSE_DOC_ID, @NomeSezione as DSE_ID, @Descrizione , 'QUESTIONARIO_DOMANDA_INDICE_SEZIONE' as DSE_MOD_ID , '' as DES_LFN_GroupFunction, 0 as DES_PosPermission,
							'CTL_DOC_VALUE' as DES_Table, 'idHeader' as DES_FieldIdDoc, 'idRow' as DES_FieldIdRow, '' as DES_TableFilter, 'CtlDocument.Sec_Caption' as  DES_ProgID,
							'WIN=no&WRITE_VERTICAL=yes&FROM_USER_FIELD=&SEC_FIELD=yes&DYNAMIC_MODEL=READONLY=yes' as DSE_Param
							, 100 as DES_Order, 'FABBISOGNI_QUALITATIVI' as DES_Module 

				-- si aggiungono i valori per la rappresentazione
				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idTemplate ,@NomeSezione , 0 , 'Descrizione' , @Descrizione as Value 

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idTemplate , @NomeSezione , 0 , 'KeyRiga' , @KeyRiga as Value 

				set @ListaSezioni = @ListaSezioni + @NomeSezione + ','

			end


			-- se la riga è una domanda
			if @Domanda_Sezione = 'domanda'
			begin
				
				set @NomeModello = 'QUESTIONARIO_DOMANDA_' + @Domanda_Elenco 
				select @Domanda_Tipologia = Value , @Titolo = Titolo , @idModello = id  , @NoteCompilazione = isnull( cast( Note  as  nvarchar(max)) , ''), @TitoloDomanda = Body
					from CTL_DOC_VALUE 
					inner join CTL_DOC on id = idheader 
					where guid  = replace( @Domanda_Elenco , '_' , '-' )  and  DSE_ID = 'TIPOLOGIA' and DZT_Name = 'Domanda_Tipologia'

				set @NoteCompilazione = rtrim( @NoteCompilazione )

				--print '@NoteCompilazione ' + @NoteCompilazione
				--print '@Domanda_Tipologia ' + @Domanda_Tipologia 
				--print '@Titolo ' + @Titolo 
				--print '@Domanda_Elenco ' + @Domanda_Elenco

				-- si definisce il modello per la sezione di indice
				if  @NoteCompilazione = '' and  @Domanda_Tipologia = 'Singola'
					set @NomeModelloIndice = 'QUESTIONARIO_DOMANDA_INDICE_CAPTION'

				if  @NoteCompilazione <> '' and  @Domanda_Tipologia = 'Singola' 
					set @NomeModelloIndice = 'QUESTIONARIO_DOMANDA_INDICE_CAPTION_NOTE'

				if  @NoteCompilazione = '' and  @Domanda_Tipologia <> 'Singola' 
					set @NomeModelloIndice = 'QUESTIONARIO_DOMANDA_INDICE_DETAIL'

				if  @NoteCompilazione <> '' and  @Domanda_Tipologia <> 'Singola' 
					set @NomeModelloIndice = 'QUESTIONARIO_DOMANDA_INDICE_DETAIL_NOTE'

				insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
					select  @DocName as DSE_DOC_ID, 'SEZ_' + @Row + '_NOTA' as DSE_ID, @Titolo , @NomeModelloIndice as DSE_MOD_ID , '' as DES_LFN_GroupFunction, 0 as DES_PosPermission,
							'CTL_DOC_VALUE' as DES_Table, 'idHeader' as DES_FieldIdDoc, 'idRow' as DES_FieldIdRow, '' as DES_TableFilter, 'CtlDocument.Sec_Caption' as  DES_ProgID,
							'WIN=no&WRITE_VERTICAL=yes&FROM_USER_FIELD=&SEC_FIELD=yes&DYNAMIC_MODEL=READONLY=yes' as DSE_Param
							, 100 as DES_Order, 'FABBISOGNI_QUALITATIVI' as DES_Module 

				-- si aggiungono i valori per la rappresentazione
				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idTemplate , 'SEZ_' + @Row + '_NOTA', 0 , 'Descrizione' , @TitoloDomanda as Value 

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idTemplate , 'SEZ_' + @Row + '_NOTA', 0 , 'KeyRiga' , @KeyRiga as Value 

				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idTemplate , 'SEZ_' + @Row + '_NOTA', 0 , 'Note' , @NoteCompilazione as Value 

				--si aggiunge la sezione alla lista 
				set @ListaSezioni = @ListaSezioni + 'SEZ_' + @Row + '_NOTA' + ','

				

				 
				-- aggiungo la sezione con il modello della domanda
				if @Domanda_Tipologia = 'Singola'
				begin

					insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
						select  @DocName as DSE_DOC_ID, 'SEZ_' + @Row as DSE_ID, @Titolo , @NomeModello as DSE_MOD_ID , '' as DES_LFN_GroupFunction, 0 as DES_PosPermission,
							 'CTL_DOC_VALUE' as DES_Table, 'idHeader' as DES_FieldIdDoc, 'idRow' as DES_FieldIdRow, '' as DES_TableFilter, 'CtlDocument.Sec_Caption' as  DES_ProgID,
							  'WIN=no&WRITE_VERTICAL=yes&FROM_USER_FIELD=&SEC_FIELD=yes&DYNAMIC_MODEL=' as DSE_Param
							  , 100 as DES_Order, 'FABBISOGNI_QUALITATIVI' as DES_Module 
					
					-- creo il modello per il salvataggio
					set @ModelloSave = @DocName + '_' + 'SEZ_' + @Row + '_SAVE'  
					exec CopiaModelloCTL  @ModelloSave , @NomeModello , 'FABBISOGNI_QUALITATIVI'

				end
				else -- domada a più righe
				begin

					insert into CTL_DocumentSections ( DSE_DOC_ID, DSE_ID, DSE_DescML, DSE_MOD_ID, DES_LFN_GroupFunction, DES_PosPermission, DES_Table, DES_FieldIdDoc, DES_FieldIdRow, DES_TableFilter, DES_ProgID, DSE_Param, DES_Order, DES_Module )
						select  @DocName as DSE_DOC_ID, 'SEZ_' + @Row as DSE_ID, @Titolo , @NomeModello as DSE_MOD_ID , '' as DES_LFN_GroupFunction, 0 as DES_PosPermission,
							 'CTL_DOC_VALUE' as DES_Table, 'idHeader' as DES_FieldIdDoc, 'idRow' as DES_FieldIdRow, '' as DES_TableFilter, 'CtlDocument.Sec_Dettagli' as  DES_ProgID,
							  'READONLY=no&WRITE_VERTICAL=yes&AREA_ADD=no&HEIGHT=100%&HEIGHT_ADD=165&CAPTIONGRID=&EDITABLE=YES&SEC_FIELD=yes' as DSE_Param
							  , 100 as DES_Order, 'FABBISOGNI_QUALITATIVI' as DES_Module 

					-- se la domanda prevedeva le righe predispongo la meoria per le righe
					insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
						select @idTemplate , 'SEZ_' + @Row , Row , 'Descrizione' , Value 
							from CTL_DOC_Value 
							where idheader = @idModello and DSE_ID = 'RIGHE' and DZT_Name = 'Descrizione'
							order by Row

				end


				
			end

			--si aggiunge la sezione alla lista 
			set @ListaSezioni = @ListaSezioni + 'SEZ_' + @Row + ','


			FETCH NEXT FROM CurRow 	INTO @KeyRiga , @Domanda_Sezione , @Domanda_Elenco , @Descrizione , @Row
		END 
		CLOSE CurRow
		DEALLOCATE CurRow	


		-- si avvalora il folder del questionario con tutte le sezioni generate
		update CTL_Documents set DOC_Param = replace( DOC_Param , '<SEZIONI_TEMPLATE>'  , @ListaSezioni ) where DOC_ID = @DocName
		
	end




END







GO
