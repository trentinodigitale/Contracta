USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RETT_VALORE_ECONOMICO_CREATE_FROM_PDA_RIEPILOGO_LOTTO_ROW]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_RETT_VALORE_ECONOMICO_CREATE_FROM_PDA_RIEPILOGO_LOTTO_ROW] 
	( @idDoc int -- rappresenta l'id della riga del lotto sul doc PDA_OFFERTE
	, @IdUser int  )
AS
BEGIN
	
	SET NOCOUNT ON;

	--declare @idDoc as int
	--declare @IdUser as int

	--set @idDoc = 94304
	--set @IdUser =45094

	declare @Errore as nvarchar(2000)
	declare @Id as int
	declare @idHeaderLottoOfferto as int
	declare @IdPDA as INT
	declare @NumeroLotto as varchar(50)
	declare @aziragionesociale as nvarchar(500)
	declare @IdAziPartecipante as int
	declare @ProtocolloRiferimento as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @Divisione_Lotti as varchar(10)
	declare @IdBando as int
	declare @idRiga int
	declare @Numeroriga int
	declare @Voce int
	declare @Row int 
	declare @FormulaEconomica as nvarchar (4000)
	declare @FieldQuantita				varchar(200)
	declare @Criterio as varchar(100)
	declare @ListaModelliMicrolotti as varchar(500)
	declare @statmentSQL		varchar(max)
	--declare @data_typePrezzo as varchar(100)
	--declare @data_typeQt as varchar(100)
	declare @IdMsgOfferta as int
	declare @Modello varchar(500)
	declare @RigaZero int


	set @RigaZero=1

	set @Errore=''

	select @idHeaderLottoOfferto = idheader , @NumeroLotto=NumeroLotto from document_microlotti_dettagli where id=@idDoc

	select @IdPDA = idheader,@aziragionesociale=aziragionesociale,@IdAziPartecipante=IdAziPartecipante, @IdMsgOfferta=IdMsgFornitore
		 from DOCUMENT_PDA_OFFERTE where idrow=@idHeaderLottoOfferto

	select @IdBando = LinkedDoc , @ProtocolloRiferimento=protocolloriferimento,@Fascicolo=fascicolo,@Divisione_Lotti=Divisione_lotti,
			@Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando 
			 from Document_Bando 
				inner join CTL_DOC on LinkedDoc = idheader
				where id = @IdPDA
	

	if @Divisione_Lotti='0'
	begin
		--controllo se devo includere oppure no la riga 0
		if exists( select * from ctl_doc_value where idheader = @IdBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' ) 
			set @RigaZero = 1 
		else 
			set @RigaZero = 0

	end

	--recupero nome delle colonne prezzo e qt che hanno i valori che possomodificare
	select @FormulaEconomica = FormulaEconomica ,@FieldQuantita = isnull( Quantita , '' ) 
		from Document_Modelli_MicroLotti_Formula 
	where @Criterio = CriterioFormulazioneOfferte
		and @ListaModelliMicrolotti = Codice
	
	--setto modello da usare sulle aree prodotti 
	set @Modello = 'MODELLI_LOTTI_' + @ListaModelliMicrolotti + '_MOD_Offerta'


	--print @Modello

	--recupero la natura delle colonne prezzo e quantità sulla tabella sorgente
	--select @data_typePrezzo=DATA_TYPE from INFORMATION_SCHEMA.COLUMNS where table_name='document_microlotti_dettagli' and COLUMN_NAME=@FormulaEconomica
	--select @data_typeQt=DATA_TYPE from INFORMATION_SCHEMA.COLUMNS where table_name='document_microlotti_dettagli' and COLUMN_NAME=@FieldQuantita

	--controllo che il calcolo economico non sia stato ancora fatto
	if exists( select * from document_microlotti_dettagli where idheader=@IdPDA and statoriga not in ('Valutato','Completo') and numerolotto=@NumeroLotto and voce = 0  )
	begin
		set @Errore = 'rettifica valore non e'' coerente con lo stato del documento' 
	end 

	if @Errore=''
	begin
		--controllo che busta economica sia stata letta
		if exists( select bReadEconomica from PDA_DRILL_MICROLOTTO_LISTA_VIEW where id=@idDoc and bReadEconomica=1)
		begin
			set @Errore = 'busta economica non ancora letta' 
		end
	end

	
	if @Errore=''
	begin
		-- cerco una versione precedente del documento in lavorazione
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RETT_VALORE_ECONOMICO' ) and statofunzionale in (  'InLavorazione' )

		if @id is null
		begin
			
			--se non esiste lo creo
			INSERT into CTL_DOC (
								IdPfu,  TipoDoc, 
								Titolo, Body, Azienda,  
								ProtocolloRiferimento, Fascicolo, LinkedDoc,Versione)
			values
								( 
								@IdUser, 'RETT_VALORE_ECONOMICO',
								left( 'Rettifica Valore Econoimco : ' + @aziRagioneSociale + ' - Lotto ' + @NumeroLotto  , 150 ) , '', @IdAziPartecipante								,  
								@ProtocolloRiferimento, @Fascicolo, @idDoc,'2.0' )
			
			set @id = SCOPE_IDENTITY()	


	
			--ricopio sul documento i valori dell'offerta originale con tipodoc='RETT_VALORE_ECONOMICO_SOURCE'
			declare @IdRowSource INT
			declare @IdRowDest INT
			
			declare CurProgOFF Cursor Static for 
				
				select OD.id from ctl_doc O
					inner join document_microlotti_dettagli OD on O.id=OD.IdHeader and OD.TipoDoc = O.TipoDoc
				where O.tipodoc='OFFERTA' and O.id=@IdMsgOfferta  and isnull(numerolotto,1)=@NumeroLotto --and linkeddoc=@IdBando and statofunzionale='Inviato' and azienda =@IdAziPartecipante and isnull(numerolotto,1)=@NumeroLotto
					  and (
								@RigaZero=1 
							or 
								(@RigaZero=0 and isnull(voce,numeroriga) <> 0 )

							)	

			open CurProgOFF

			FETCH NEXT FROM CurProgOFF 
			INTO @IdRowSource
				WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc)
							select @id , 'RETT_VALORE_ECONOMICO_SOURCE' as TipoDoc
						
						set @IdRowDest = SCOPE_IDENTITY()					

						-- ricopio i valori di tutte le colonne
						exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRowSource  , @IdRowDest , ',Id,IdHeader,TipoDoc,Graduatoria,Sorteggio,Posizione,Aggiudicata,Exequo,StatoRiga,EsitoRiga'			 
					
						FETCH NEXT FROM CurProgOFF 
						INTO @IdRowSource

					END 

			CLOSE CurProgOFF
			DEALLOCATE CurProgOFF



			--ricopio sull'offerta i valori della PDA OFFERTE con tipodoc='RETT_VALORE_ECONOMICO_DEST'
			declare CurProg Cursor Static for 
				
				
				select  id 
					from Document_MicroLotti_Dettagli 
				where 
						IdHeader =  @idHeaderLottoOfferto  and NumeroLotto = @NumeroLotto
						and (
								@RigaZero=1 
							or 
								(@RigaZero=0 and isnull(voce,numeroriga) <> 0 )

							)	
				order by id

			open CurProg

			FETCH NEXT FROM CurProg 
			INTO @IdRowSource
				WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc)
							select @id , 'RETT_VALORE_ECONOMICO_DEST' as TipoDoc
						
						set @IdRowDest = SCOPE_IDENTITY()					

						-- ricopio i valori di tutte le colonne
						exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRowSource  , @IdRowDest , ',Id,IdHeader,TipoDoc,Graduatoria,Sorteggio,Posizione,Aggiudicata,Exequo,StatoRiga,EsitoRiga'			 		 
					
						FETCH NEXT FROM CurProg 
						INTO @IdRowSource
					END 

			CLOSE CurProg
			DEALLOCATE CurProg

			

			--associo il modello alle sezioni
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
				values( @id , 'VALORE_PRODOTTI_SOURCE' , @Modello )
			
			
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
				values( @id , 'VALORE_PRODOTTI_DEST' , @Modello )
			

			--set @Row = 0

			---- riporto i dati dell'offerta sul documento
			--declare crsOf cursor static for 
			--	--if @Divisione_Lotti <> 0 
			--	--begin
			--		select  
			--				id , isnull(NumeroRiga,0) ,  voce 
			--		from Document_MicroLotti_Dettagli d 
			--			where d.IdHeader =  @idHeaderLottoOfferto  and d.NumeroLotto = @NumeroLotto
			--			order by d.id
			--	--end
			--	--else
			--	--begin
			--	--	select  
			--	--			id , NumeroRiga ,  voce
			--	--	from Document_MicroLotti_Dettagli d 
			--	--		where d.IdHeader =  @idHeaderLottoOfferto  and d.NumeroLotto = @NumeroLotto and Voce<>0
			--	--		order by d.id
			--	--end	

			--open crsOf 
			--fetch next from crsOf into  @idRiga , @Numeroriga  , @Voce

			--while @@fetch_status=0 
			--begin 
				
			--	--se non è a lotti non inserisco la voce 0
			--	if ( @Divisione_Lotti <> 0 or ( @Divisione_Lotti = 0 and @Voce<>0 ) )
			--	begin	
				
			--		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--			values(  @id , 'VALORI_PRODOTTI' , @Row, 'idHeaderLotto' , @idRiga )

			--		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--			values(  @id , 'VALORI_PRODOTTI' , @Row, 'NumeroLotto' , @NumeroLotto )

			--		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--			values(  @id , 'VALORI_PRODOTTI' , @Row, 'Voce' , @Voce )

			--		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--			values(  @id , 'VALORI_PRODOTTI' , @Row, 'NumeroRiga' , @Numeroriga )
					

			--		--inserisco il valore iniziale ( @FormulaEconomica )
			--		set @statmentSQL = 'insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			--							select ' +  CAST(@id as varchar) + ', ''VALORI_PRODOTTI'', ' + CAST(@Row as varchar) + ', ''ValoreOfferta'' ,' +  
			--							case @data_typePrezzo 
			--								when 'float' then ' str( ' + @FormulaEconomica + ' ,30,10)'
			--								else @FormulaEconomica
			--							end + ' from Document_MicroLotti_Dettagli where tipodoc=''OFFERTA'' and IdHeader = ' + cast(  @IdMsgOfferta as varchar(20) ) + ' and numerolotto=' + @NumeroLotto + ' and voce = ' + cast(  @Voce as varchar(20) )  + ' and isnull(numeroriga,0)=' + cast(  @Numeroriga as varchar(20) )
					
			--		exec( @statmentSQL )
			--		--print @statmentSQL

			--		--inserisco il nuovo valore ( @FormulaEconomica )
			--		set @statmentSQL = 'insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			--							select ' +  CAST(@id as varchar) + ', ''VALORI_PRODOTTI'', ' + CAST(@Row as varchar) + ', ''CampoNumerico'' ,' +  
			--							case @data_typePrezzo 
			--								when 'float' then ' str( ' + @FormulaEconomica + ' ,30,10)'
			--								else @FormulaEconomica
			--							end + ' from Document_MicroLotti_Dettagli where Id = ' + cast(  @idRiga as varchar(20) ) 
					
			--		--print @statmentSQL
			--		exec( @statmentSQL )
					

			--		--inserisco la quantità iniziale ( @FieldQuantita )
			--		set @statmentSQL = 'insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			--							select ' +  CAST(@id as varchar) + ', ''VALORI_PRODOTTI'', ' + CAST(@Row as varchar) + ', ''Quantita'' ,' +  
			--							case @data_typeQt
			--								when 'float' then ' str( ' + @FieldQuantita + ' ,30,10)'
			--								else @FieldQuantita
			--							end + ' from Document_MicroLotti_Dettagli where tipodoc=''OFFERTA'' and IdHeader = ' + cast(  @IdMsgOfferta as varchar(20) ) + ' and numerolotto=' + @NumeroLotto + ' and voce = ' + cast(  @Voce as varchar(20) )  + ' and isnull(numeroriga,0)=' + cast(  @Numeroriga as varchar(20) )
					
			--		exec( @statmentSQL )
			--		--print @statmentSQL

			--		--inserisco la nuova quantità ( @FieldQuantita )
			--		set @statmentSQL = 'insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			--							select ' +  CAST(@id as varchar) + ', ''VALORI_PRODOTTI'', ' + CAST(@Row as varchar) + ', ''CampoNumerico_1'' ,' +  
			--							case @data_typeQt
			--								when 'float' then ' str( ' + @FieldQuantita + ' ,30,10)'
			--								else @FieldQuantita
			--							end + ' from Document_MicroLotti_Dettagli where Id = ' + cast(  @idRiga as varchar(20) ) 
					
			--		--print @statmentSQL
			--		exec( @statmentSQL )

					
			--		set @Row = @Row + 1 
			--	end 
			--	fetch next from crsOf into  @idRiga , @Numeroriga  , @Voce
			--end 
			--close crsOf 
			--deallocate crsOf


		end

	end
	
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END

















GO
