USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANNULLA_DELTA_TED_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANNULLA_DELTA_TED_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @Bando as int
	declare @Body nvarchar( max )
	declare @idRichiesta int = 0
	declare @TYPE_TO varchar(200)

	set @Errore=''	
	
	
	---CERCO UNA RICHIESTA IN CORSO CREATA DA QUEL DOCUMENTO
	select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'ANNULLA_DELTA_TED' ) and StatoFunzionale <> 'Annullato'

	set @TYPE_TO = 'ANNULLA_DELTA_TED'


	if @newId is null
	begin

		set @Bando = @idDoc

		select @idRichiesta = isnull(id,0) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale in( 'Inviato' ,'Invio_con_errori')

		-- deve esistere un documento di richiesta nello stato di iniviato o inviato con errori ( l'inviato con errori ci fa capire che almeno la gara è stata inviata per il guue )
		if @idRichiesta = 0
			set @Errore = 'Per effettuare la cancellazione occorre che prima sia stata eseguita una Richiesta invio dati GUUE'
		
		-- se non sono presenti errori
		if @Errore = ''
		begin
			
				-- CREO IL DOCUMENTO
				INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,LinkedDoc, Titolo )
					select  @IdUser, @TYPE_TO , @IdUser ,Azienda,@idDoc, 'Cancella Informazione GUUE'
						from ctl_doc with(nolock)
						where id=@idDoc		

				set @newId = SCOPE_IDENTITY()

				-- inserisco i dati base della gara
				insert into Document_TED_GARA( idHeader, id_gara )
						select @newid, id_gara
							from Document_TED_GARA with(nolock)
							where idheader = @idRichiesta

				insert into Document_TED_LOTTI( idHeader, CIG, AzioneProposta )
								select @newid, cig, 'TED - Cancellazione'
									from Document_TED_LOTTI with(nolock)
									where idheader = @idRichiesta and StatoRichiestaLOTTO = 'Elaborato' and AzioneProposta <> 'TED - Cancellazione'

		
				--EXEC INSERT_SERVICE_REQUEST 'TED', 'cancellaDeltaGara', @IdUser, @newid
				--EXEC INSERT_SERVICE_REQUEST 'TED', 'cancellaDeltaLotto', @IdUser, @newid

				--update CTL_DOC
				--	set StatoFunzionale = 'InvioInCorso',
				--		Deleted = 0
				--where id = @newid

				----annullo eventuali altri documenti di invio dati ted e di annullamento
				--update CTL_DOC
				--		set StatoFunzionale = 'Annullato'
				--	where LinkedDoc = @Bando and TipoDoc in ( 'DELTA_TED', 'ANNULLA_DELTA_TED' ) and id <> @newid

		end

	end


	if  ISNULL(@newId,0) <> 0
	begin

		select @newId as id, @TYPE_TO as TYPE_TO
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
