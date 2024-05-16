USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANNULLA_PUBBLICAZIONE_TED_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ANNULLA_PUBBLICAZIONE_TED_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int )
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
	set @TYPE_TO = 'ANNULLA_PUBBLICAZIONE_TED'

	select @newId = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = @TYPE_TO and StatoFunzionale <> 'Annullato'

	IF @newId is null
	BEGIN

		set @Bando = @idDoc

		select @idRichiesta = isnull(max(id),0) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'PUBBLICA_GARA_TED', 'RETTIFICA_GARA_TED'  ) and StatoFunzionale = 'InAttesaPubTed' 

		IF @idRichiesta = 0
			set @Errore = 'Per effettuare la cancellazione della richiesta di pubblicazione è necessaria una richiesta nello stato di In attesa di pubblicazione TED'
		
		-- se non sono presenti errori
		IF @Errore = ''
		BEGIN

			INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda ,LinkedDoc, Titolo )
				select  @IdUser, @TYPE_TO , @IdUser ,Azienda,@idDoc, 'Cancella Richiesta Pubblicazione'
					from ctl_doc with(nolock)
					where id=@idDoc		

			set @newId = SCOPE_IDENTITY()

			insert into Document_TED_GARA( idHeader, id_gara, TED_PUB_NO_DOC_EXT )
					select @newid, id_gara, TED_PUB_NO_DOC_EXT
						from Document_TED_GARA with(nolock)
						where idheader = @idRichiesta

		END

	END


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
