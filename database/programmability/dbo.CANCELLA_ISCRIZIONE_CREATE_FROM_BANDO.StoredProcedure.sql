USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CANCELLA_ISCRIZIONE_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CANCELLA_ISCRIZIONE_CREATE_FROM_BANDO]	( @idDoc int , @IdUser int )
 AS
 BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @cessato INT
	declare @Errore as nvarchar(2000)
	declare @rup int
	declare @riferimento int
	declare @jumpcheck varchar(500)
	declare @note nvarchar(1000)

	set @Errore = ''

	Select  @rup = dc.idPfu,
			@cessato =  isnull(azi.aziDeleted,0)
		from CTL_DOC_Destinatari CD with(nolock)
				inner join Aziende azi with(nolock) ON azi.IdAzi = CD.IdAzi
				inner join Document_Bando_Commissione DC with(nolock) on CD.idHeader=DC.idHeader and DC.RuoloCommissione='15550'	
		where CD.idrow=@idDoc

	--CONTROLLO CHE UTENTE CHE RIMUOVE L'ABILITAZIONE SIA IL RUP oppure UTENTE RIFERIMENTO ISTANZE
	--	OPPURE LASCIO PASSARE SE L'AZIENDA E' CESSATA
	--IF @IdUser <> @rup and @IdUser <> @riferimento and @cessato = 0
	if 
		-- azienda non cessata
		@cessato = 0 
		
		-- non sei il rup
		and @IdUser <> @rup  
		
		-- non sei un riferimento per le istanze
		and @IdUser  not in ( select DR.idPfu
									from CTL_DOC_Destinatari CD with(nolock)
											inner join Document_Bando_Riferimenti DR with(nolock) on CD.idHeader=DR.idHeader and DR.RuoloRiferimenti='Istanze'
									where CD.idrow=@idDoc
							)
	BEGIN
		set @Errore='Operazione non consentita. Solo il responsabile del Procedimento oppure l''utente di riferimento per le istanze puo'' rimuovere l''abilitazione'				
	END	

	---CONTROLLO CHE L'AZIENDA RISULTA ANCORA ISCRITTA
	IF @errore=''
	BEGIN

		IF NOT EXISTS (Select idrow from CTL_DOC_Destinatari CD with(nolock) where CD.idrow=@idDoc and StatoIscrizione in ( 'Iscritto' ,'Sospeso'))
		BEGIN	
			set @Errore='Operazione non consentita. Lo stato iscrizione del Fornitore deve essere "Iscritto"'	
		END

	END

	--CERCO UN DOCUMENTO GIA' CREATO IN PRECEDENZA PER UTENTE RELATIVO A QUELLA ISCRIZIONE	
	IF @errore=''
	BEGIN

		select @id=c.id 
			from ctl_doc C with(nolock)
					inner join CTL_DOC_Destinatari CD with(nolock) on CD.idrow=@iddoc and CD.idHeader=C.LinkedDoc and CD.IdAzi=C.Destinatario_Azi 
			where C.tipodoc='CANCELLA_ISCRIZIONE' and c.idpfu=@IdUser and c.Deleted=0 and c.StatoFunzionale <> 'Pubblicato'

	END

	--CONTROLLO SE IL DOCUMENTO APPENA TROVATO E RELATIVO AD ISCRIZIONE ANCORA VALIDA ALTRIMENTI RIMUOVO IL DOCUMENTO APPENA TROVATO E DO UN MESSAGGIO
	IF @errore='' and @id > 0
	begin
		IF NOT EXISTS (Select * from CTL_DOC_Destinatari CD with(nolock) where CD.idrow=@idDoc and StatoIscrizione in ( 'Iscritto' ,'Sospeso') )
		BEGIN	
			update ctl_doc set deleted=1 where id=@id
			set @Errore='Operazione non consentita. Lo stato iscrizione del Fornitore deve essere "Iscritto"'	
		END		
	end

	if @id is  null
	begin

		IF @cessato = 1
		BEGIN
			set @jumpcheck = '1'
			set @note = 'L''abilitazione dell''impresa viene eliminata a seguito di cessazione della stessa'
		END
		ELSE
		BEGIN
			set @jumpcheck = ''
			set @note = ''
		END

		Insert into ctl_doc (IdPfu,titolo,Fascicolo,Destinatario_Azi,ProtocolloRiferimento,TipoDoc,LinkedDoc, JumpCheck,Note)
			Select @IdUser,'Cancella Iscrizione',C.Fascicolo,IdAzi,C.Protocollo,'CANCELLA_ISCRIZIONE',C.id, @jumpcheck, @note
			from CTL_DOC_Destinatari with(nolock)
				inner join CTL_DOC C with(nolock) on C.id=idHeader
			where idrow=@idDoc

		set @id = SCOPE_IDENTITY()	

	end
	else
	begin

		IF @cessato = 1
		BEGIN

			update ctl_doc
					set JumpCheck = '1',
						note = 'L''abilitazione dell''impresa viene eliminata a seguito di cessazione della stessa'
				where Id = @id

		END
		

	end

	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id, '' as Errore
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END










GO
