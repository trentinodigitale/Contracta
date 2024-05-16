USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_SORTEGGIO_OFFERTA_CREATE_FROM_SORTEGGIO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_PDA_SORTEGGIO_OFFERTA_CREATE_FROM_SORTEGGIO] 
	( @idDoc int , @IdUser int , @tipoSorteggio varchar(100) = 'AUTO', @idDocSorteggio INT = 0 output  )
AS
BEGIN

	declare @Id as INT
	declare @NumeroLotto varchar(200)
	declare @ML_Note nvarchar (4000)
	declare @idRow int 
	declare @idPda int 
	declare @NewDoc int 
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
	declare @DataScadenza as datetime
	
	Select @IdPfu=IdPfu,
			@Fascicolo=Fascicolo,
			@ProtocolloGenerale=ProtocolloGenerale,
			@DataProtocolloGenerale=DataProtocolloGenerale,
			@ProtocolloRiferimento=ProtocolloRiferimento,
			@Body=Descrizione,@azienda=azienda,
			@StrutturaAziendale=StrutturaAziendale ,
			@NumeroLotto = NumeroLotto,
			@idPda = pda.id
		from CTL_DOC pda 
			inner join Document_MicroLotti_Dettagli m on m.idheader = pda.id
		where m.id=@idDoc

	-- se non esiste crea il documento che riepiloga i sorteggi effettuati
	exec PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO @idPda , @IdUser , @id output 

	set @idRow = @idDoc

	IF ISNULL(@Body ,'') = ''
	BEGIN
		set @Body = 'Sorteggio exequo'
	END

	-- creo il documento di sorteggio
	insert into CTL_DOC (IdPfu,TipoDoc					  ,Titolo					,Fascicolo ,LinkedDoc,Body ,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda    ,Destinatario_Azi ,Data   ,Note,JumpCheck ,PrevDoc) 
		values( @IdPfu,'PDA_SORTEGGIO_OFFERTA', @NumeroLotto ,@Fascicolo,@Id      ,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,0,getDate(),@ML_Note, @tipoSorteggio , @idRow )

	set @NewDoc = SCOPE_IDENTITY()
	set @idDocSorteggio = @NewDoc


	--se sono sulla PDA_CONCORSO setto un modello anonimo per non far vaedere le info dei fornitori
	if exists (select * from ctl_doc where id = @idPda and tipodoc='PDA_CONCORSO')
	begin
		insert into CTL_DOC_SECTION_MODEL
			(IdHeader , dse_id, MOD_Name )
			values
			(@NewDoc , 'DETTAGLI', 'PDA_SORTEGGIO_OFFERTA_DETTAGLI_ANONIMO' )
	end


	declare @IdHeader INT
	declare @IdRow1 INT
	declare @idr INT
	declare CurProg Cursor Static for 
	select @NewDoc as IdHeader , m.id as IdRow1
				from Document_MicroLotti_Dettagli  m
				inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
			where   NumeroLotto = @NumeroLotto
					and m.Exequo = 1
					and o.IdHeader = @idPda

	open CurProg

	FETCH NEXT FROM CurProg INTO @IdHeader,@IdRow1

	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc ,StatoRiga)
			select @IdHeader , 'PDA_SORTEGGIO_OFFERTA' as TipoDoc,'' as StatoRiga

		set @idr = SCOPE_IDENTITY()	
					
		-- ricopio tutti i valori
		exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow1  , @idr , ',Id,IdHeader,TipoDoc,'			 
		
		FETCH NEXT FROM CurProg INTO @IdHeader,@IdRow1

	END 

	CLOSE CurProg
	DEALLOCATE CurProg


	-- ricopio tutti i dati
	-- aggiorno sulle righe dei microlotti del bando i messaggi che si sono aggiudicati i lotti
	declare @SQL varchar(4000)
	set @SQL = '
		select m.id , d.id		
		from Document_MicroLotti_Dettagli  m
				inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = ''PDA_OFFERTE'' 
				inner join Document_MicroLotti_Dettagli d on d.NumeroLotto = m.NumeroLotto 
																and d.Aggiudicata = m.Aggiudicata 
																and d.idheader = ' + cast( @NewDoc as varchar ) + '
																and d.TipoDoc = ''PDA_SORTEGGIO_OFFERTA''
			where   m.NumeroLotto = ' + @NumeroLotto + '
					and m.Exequo = 1
					and o.IdHeader = ' + cast( @idPda as varchar )
	
	exec COPY_DETTAGLI_MICROLOTTI @sql

	-- Se si sta facendo il sorteggio automatico ritorniamo la select con l'id , altrimenti
	-- avvaloriamo soltanto la variabile di output @idDocSorteggio
	IF @tipoSorteggio = 'AUTO'
		select @NewDoc as ID

end




GO
