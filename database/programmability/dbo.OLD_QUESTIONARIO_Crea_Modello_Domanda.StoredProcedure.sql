USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_QUESTIONARIO_Crea_Modello_Domanda]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD_QUESTIONARIO_Crea_Modello_Domanda]( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Guid varchar(100)
	declare @Natura varchar(100)
	declare @Domanda_Dom_Visual varchar(100)
	declare @TitoloDomanda nvarchar(max)
	declare @Note nvarchar(max)
	declare @Len int	
	declare @Dominio_Altro varchar(20)
	declare @Domanda_Tipologia varchar(20)
	
	declare @NumCaratteri varchar(1000)
	declare @NumDec varchar(1000)
	declare @NomeModello varchar(1000)
	declare @Format varchar(100)


	select @Guid = replace( cast( guid as varchar(100)) , '-' , '_' ) , @TitoloDomanda  = Body , @Note = Note from ctl_doc where id = @idDoc
	

	select @Natura = Value from CTL_DOC_VALUE where  idheader = @idDoc and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'Domanda_Natura' 
	select @Domanda_Dom_Visual = Value from CTL_DOC_VALUE where  idheader = @idDoc and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'Domanda_Dom_Visual' 
	select @Dominio_Altro = Value from CTL_DOC_VALUE where  idheader = @idDoc and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'Dominio_Altro' 
	select @Domanda_Tipologia = Value from CTL_DOC_VALUE where  idheader = @idDoc and DSE_ID = 'TIPOLOGIA' and DZT_Name = 'Domanda_Tipologia' --and value = 'Singola' 

	select @NumDec = Value from CTL_DOC_VALUE where  idheader = @idDoc and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'NumDec' 
	select @NumCaratteri = Value from CTL_DOC_VALUE where  idheader = @idDoc and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'NumCaratteri' 

	set @NomeModello = 'QUESTIONARIO_DOMANDA_' + @Guid 


	-- cancello eventuali modelli creati in precedenza
	delete from CTL_Models where MOD_ID = @NomeModello 
	delete from CTL_ModelAttributes where MA_MOD_ID = @NomeModello 
	delete from CTL_ModelAttributeProperties where  MAP_MA_MOD_ID = @NomeModello 

	-- cancello le vecchie chiavi di ML 
	--delete from LIB_Multilinguismo where  ML_KEY like 'QUESTIONARIO_DOMANDA_TITOLO_' + @Guid + '%' and ML_Module = 'FABBISOGNI_QUALITATIVI'

	set @Format = ''

	-- definisce una lunghezza base per la tipologia dell'attributo
	if @Natura = 'Testo'
	begin
		set @Len = @NumCaratteri--200
		if @Len < 50
			set @Len = 50

	end

	if @Natura = 'Numero'
	begin
		set @Len = @NumCaratteri--10
		set @Format = '###,##0'
		if @NumDec <> '' 
			set @Format = @Format + '.' + REPLICATE( '0',cast(@NumDec as int ))

		if @Len < 5
			set @Len = 5

	end
	if @Natura = 'Dominio'
		set @Len = 10

	if @Natura = 'TextArea'
		set @Len = 200



	
	-- creiamo i modelli in funzioni delle scelte



	-----------------------------------------
	-- si crea la riga del modello
	-----------------------------------------
	if  @Domanda_Tipologia = 'Singola' 
	begin
		-- la tipologia del modello è posizionale
		insert into CTL_Models ( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Param, MOD_Module )
			values( @NomeModello , @NomeModello , @NomeModello , 2 , 'Type=posizionale&DrawMode=1&NumberColumn=1&Path=../../&PathImage=../../CTL_Library/images/Domain/&ML=NO&NO_CLOSURE=yes' , 'FABBISOGNI_QUALITATIVI' )
	end
	else
	begin
		-- la tipologia del modello è una griglia
		insert into CTL_Models ( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Param, MOD_Module  )
			values( @NomeModello , @NomeModello , @NomeModello , 1 , 'Type=griglia&DrawMode=1&NumberColumn=1&Path=../../&PathImage=../../CTL_Library/images/Domain/&ML=NO' , 'FABBISOGNI_QUALITATIVI' )
	end


	-----------------------------------------
	--si creano le righe degli attributi
	-----------------------------------------
	declare @IDX INT
	declare @IDX_F INT
	declare @idRow INT
	declare @Descrizione nvarchar(1000)

	set @IDX = 1
	set @IDX_F = 1
	if @Len is null
		set @Len = 10

	-- nel caso di domande con più righe metto la descrizione della riga
	if  @Domanda_Tipologia <> 'Singola' 
	begin


		insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
			values( @NomeModello , 'Descrizione'  , 'Descrizione'  , @IDX , 10 , @IDX , 'FABBISOGNI_QUALITATIVI' )

		insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
			values ( @NomeModello, 'Descrizione', 'Editable', '0' ,  'FABBISOGNI_QUALITATIVI' )
		
		set @IDX =  @IDX + 1
		
	end


	if @Natura not in ( 'Dominio' ) or ( @Natura = 'Dominio' and @Domanda_Dom_Visual in ( '' , 'List' ) )
	begin

		-- si crea l'attributo se mancante
		exec QUESTIONARIO_Crea_Field @Natura , 1

		-- inserisco la chiave di ML per il campo del modello
		--insert into LIB_Multilinguismo ( ML_KEY, ML_LNG, ML_Description, ML_Context, ML_Module )
		--	select 'QUESTIONARIO_DOMANDA_TITOLO_' + @Guid  as ML_KEY, 'I' as ML_LNG, @TitoloDomanda as ML_Description, 0 as  ML_Context, 'FABBISOGNI_QUALITATIVI' as  ML_Module 


		set @TitoloDomanda = 'Inserire risposta' 
		if @Natura in ( 'Dominio' )
			set @TitoloDomanda = 'Scelta'

		-- modello con un attributo
		insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
			values( @NomeModello , 'DOMANDA_QUESTIONARIO_' + @Natura + '_1' , @TitoloDomanda  , @IDX , @Len , @IDX  , 'FABBISOGNI_QUALITATIVI' )
			--values( @NomeModello , 'DOMANDA_QUESTIONARIO_' + @Natura + '_1' , 'QUESTIONARIO_DOMANDA_TITOLO_' + @Guid  , @IDX , @Len , @IDX  , 'FABBISOGNI_QUALITATIVI' )

		-- per la textarea si mette il numero di righe
		if @Natura = 'TextArea'
		begin
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello,  'DOMANDA_QUESTIONARIO_' + @Natura + '_1', 'Rows', '3' ,  'FABBISOGNI_QUALITATIVI' )
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello,'DOMANDA_QUESTIONARIO_' + @Natura + '_1', 'Width', '700' ,  'FABBISOGNI_QUALITATIVI' )
		end

		-- se è un test si setta la maxlen
		if @Natura = 'Testo' 
		begin
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello, 'DOMANDA_QUESTIONARIO_' + @Natura + '_1', 'MaxLen', @Len ,  'FABBISOGNI_QUALITATIVI' )
		end


		-- se c'è la format si setta 
		if @Natura = 'Numero' and @Format <> '' 
		begin
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello, 'DOMANDA_QUESTIONARIO_' + @Natura + '_1', 'Format', @Format ,  'FABBISOGNI_QUALITATIVI' )
		end


		set @IDX =  @IDX + 1


		-- se è un dominio si filtrano i valori con quelli utili 
		if @Natura = 'Dominio' 
		begin
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello, 'DOMANDA_QUESTIONARIO_' + @Natura + '_1', 'Filter', 'SQL_WHERE=DMV_Father = ''' + @Guid + ''' ' ,  'FABBISOGNI_QUALITATIVI' )
		end

		-- se è spuntato il valore per altro si aggiunge l'attributo per contenerlo
		if @Dominio_Altro = '1' 
		begin
			insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
				values( @NomeModello , 'DOMANDA_QUESTIONARIO_ALTRO_1' , 'Altro'  , @IDX , 200 , @IDX , 'FABBISOGNI_QUALITATIVI' )

			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello, 'DOMANDA_QUESTIONARIO_ALTRO_1', 'Rows', '3' ,  'FABBISOGNI_QUALITATIVI' )
		end

	end
	else
	begin

		-- definisco una larghezza bassa per i check o i radio
		set @Len = 2

		-- modello con tante righe per quanti valori contiene il dominio

		declare CurProg Cursor static for 
			select  Value 
				from CTL_DOC_VALUE 
				where  idheader = @idDoc and DSE_ID = 'VALORI' and DZT_Name = 'Descrizione' 
				order by IdRow

		open CurProg

		FETCH NEXT FROM CurProg  INTO @Descrizione
		WHILE @@FETCH_STATUS = 0
		BEGIN


			-- inserisco la chiave di ML per il campo del modello
			--insert into LIB_Multilinguismo ( ML_KEY, ML_LNG, ML_Description, ML_Context, ML_Module )
			--	select 'QUESTIONARIO_DOMANDA_TITOLO_' + @Guid + '_' + cast( @IDX as varchar(20))  as ML_KEY, 'I' as ML_LNG, @Descrizione as ML_Description, 0 as  ML_Context, 'FABBISOGNI_QUALITATIVI' as  ML_Module 


			-- si crea l'attributo se mancante
			exec QUESTIONARIO_Crea_Field @Domanda_Dom_Visual , @IDX_F


			-- attributo
			insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
				values( @NomeModello , 'DOMANDA_QUESTIONARIO_' + @Domanda_Dom_Visual + '_' + cast( @IDX_F as varchar(20)) , @Descrizione  , @IDX , @Len , @IDX , 'FABBISOGNI_QUALITATIVI' )
				--values( @NomeModello , 'DOMANDA_QUESTIONARIO_' + @Domanda_Dom_Visual + '_' + cast( @IDX_F as varchar(20)) , 'QUESTIONARIO_DOMANDA_TITOLO_' + @Guid  + '_' + cast( @IDX as varchar(20))  , @IDX , @Len , @IDX , 'FABBISOGNI_QUALITATIVI' )

			set @IDX = @IDX + 1
			set @IDX_F = @IDX_F + 1
         
			FETCH NEXT FROM CurProg INTO @Descrizione
		END 
		CLOSE CurProg
		DEALLOCATE CurProg


		
		
		-- se è spuntato il valore per altro si aggiunge l'attributo per contenerlo
		if @Dominio_Altro = '1' 
		begin

			set @IDX_F = 999
			exec QUESTIONARIO_Crea_Field @Domanda_Dom_Visual , @IDX_F

			-- attributo
			insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
				values( @NomeModello , 'DOMANDA_QUESTIONARIO_' + @Domanda_Dom_Visual + '_' + cast( @IDX_F as varchar(20)) , 'Altro'  , @IDX , @Len , @IDX , 'FABBISOGNI_QUALITATIVI' )

			set @IDX = @IDX + 1



			insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
				values( @NomeModello , 'DOMANDA_QUESTIONARIO_ALTRO_1' , 'Altro'  , @IDX , 200 , @IDX , 'FABBISOGNI_QUALITATIVI' )

			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello, 'DOMANDA_QUESTIONARIO_ALTRO_1', 'Rows', '3' ,  'FABBISOGNI_QUALITATIVI' )
			insert into CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				values ( @NomeModello, 'DOMANDA_QUESTIONARIO_ALTRO_1', 'Width', '700' ,  'FABBISOGNI_QUALITATIVI' )
		end

	end


	-- si crea il modello per la parte di Analisi dove si riepilogano i dati inseriti
	declare @ModelloRiepilogo varchar(500)
	set @ModelloRiepilogo = @NomeModello + '_ANALISI'
	exec CopiaModelloCTL @ModelloRiepilogo , @NomeModello  , 'FABBISOGNI_QUALITATIVI'

	-- sul modello appena creato si spostano le colonne per fare posto alla colonna per la ragione sociale
	if  @Domanda_Tipologia <> 'Singola' -- se è presente la descrizione
		update CTL_ModelAttributes set MA_Pos = MA_Pos + 10 , MA_Order = MA_Order + 10 where MA_MOD_ID = @ModelloRiepilogo and MA_Order > 1
	else
		update CTL_ModelAttributes set MA_Pos = MA_Pos + 10 , MA_Order = MA_Order + 10 where MA_MOD_ID = @ModelloRiepilogo 

	insert into CTL_ModelAttributes (  MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module )
		values( @ModelloRiepilogo , 'Aziende' , 'Compilatore'  , 2, 200 , 2, 'FABBISOGNI_QUALITATIVI' )


END
















GO
