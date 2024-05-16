USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_GARA_CREATE_FROM_MODIFICA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[TEMPLATE_GARA_CREATE_FROM_MODIFICA] ( @iddoc int , @IdUser int  )
AS
BEGIN

	-- QUESTA STORED COPIA IL TEMPLATE_GARA PRENDENDO I DATI DA QUELLO SUL QUALE E' STATO ESEGUITO IL COMANDO
	-- E VIENE LEGATO (CON PREVDOC) ALL'ULTIMO MODELLO DELLA CATENA. 

	SET NOCOUNT ON;

	declare @Id INT
	declare @LastId INT
	declare @out INT
	DECLARE @NewTitolo varchar(4000)
	declare @oldPrevDoc INT
	declare @Errore nvarchar(2000)
	declare @lastPrevDoc int
	declare @tipoDoc varchar(1000)
	declare @azienda int
	declare @jumpcheck varchar(1000)
	declare @body nvarchar(max)
	declare @IdQuest as int


	set @Errore=''
	set @Id = 0
	set @IdQuest = 0
	set @LastId = @idDoc
	set @lastPrevDoc = @idDoc

	-- RESTO NEL CICLO FINCHÈ MANTENGO VERA LA RELAZIONE PREVDOC
	WHILE @lastPrevDoc <> 0
	BEGIN

		SET @lastPrevDoc = 0

		select  @LastId = id,
				@lastPrevDoc = isnull(PrevDoc,0)
			from 
				ctl_doc with(nolock) 
			where prevdoc = @LastId and tipodoc in ( 'TEMPLATE_GARA' ) 
			and deleted = 0 and StatoFunzionale = 'Pubblicato'
				  and LinkedDoc=0
	END

	--- Se esiste già un CONFIG_MODELLI che ha come prevDoc l'idDoc richiesto. Apro quello
	select  @Id=id,
			@tipoDoc = TipoDoc
		from CTL_DOC with(nolock) 
		where PrevDoc = @LastId and TipoDoc in ( 'TEMPLATE_GARA' ) and StatoFunzionale = 'InLavorazione' and Deleted = 0

	IF @Id = 0
	BEGIN

		declare @IdNewDoc int 
		--faccio una copia del documento 
		--exec COPY_Document 'TEMPLATE_GARA',@iddoc,@IdNewDoc output 

		
		
		exec BANDO_GARA_COPIA @iddoc , @IdUser , @IdNewDoc output, 1
		

		--setto sul documento appena creato il precedente
		update CTL_DOC 
			set PrevDoc = @iddoc, StatoFunzionale ='InLavorazione', Deleted=0, Protocollo ='' , DataInvio=null
				,titolo = replace(Titolo,'copia di','')
				, Data= GETDATE()
			where Id = @IdNewDoc

		--se esiste un questionario amminisrativo agganciato lo copio e lo aggancio al nuovo documento di modifica
		--select @IdQuest = ID from CTL_DOC  with (nolock)
		--	where TipoDoc='QUESTIONARIO_AMMINISTRATIVO'
		--		and LinkedDoc =@iddoc

		--if @IdQuest <> 0
		--begin
		--	declare @IdNewQuest as int

		--	exec COPY_Document 'QUESTIONARIO_AMMINISTRATIVO',@IdQuest,@IdNewQuest output 

			--associo il questionario al nuovo doc TEMPLATE_GARA creato
		--	update CTL_DOC set deleted=0, linkeddoc =@IdNewDoc ,Data= GETDATE()  where Id =@IdNewQuest 

		--end

		set @Id = @IdNewDoc
		

	END

	
	if @Errore = ''
	begin

		-- rirorna l'id del doc appena creato o quello del doc in lavorazione
		select @Id as id, @tipoDoc as TYPE_TO, @tipoDoc as JSCRIPT
	
	end
	else
	begin

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	end
	
END




GO
