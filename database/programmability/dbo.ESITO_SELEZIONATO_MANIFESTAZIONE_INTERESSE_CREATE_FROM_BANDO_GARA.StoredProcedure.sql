USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESITO_SELEZIONATO_MANIFESTAZIONE_INTERESSE_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[ESITO_SELEZIONATO_MANIFESTAZIONE_INTERESSE_CREATE_FROM_BANDO_GARA] ( @idRow int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @IdGara as INT
	declare @IdAziMittente as int
	declare @statoMan varchar(1000)
	declare @Errore as nvarchar(2000)
	declare @ProtocolloOfferta varchar(1000)
	declare @Fascicolo varchar(1000)
	declare @dataScadenza datetime

	set @Errore=''
	set @Id = null

	select @dataScadenza = DataScadenzaOfferta,
		   @statoMan = man.StatoDoc,
		   --@Id = esito.Id,
		   @IdGara = man.LinkedDoc,
		   @ProtocolloOfferta = man.Protocollo,
		   @Fascicolo=man.Fascicolo
	from ctl_doc man with(nolock)
			inner join document_bando gara with(nolock) on gara.idHeader = man.LinkedDoc
			--left join ctl_doc esito with(nolock) on esito.iddoc = man.Id and esito.TipoDoc = 'ESITO_SELEZIONATO_MANIFESTAZIONE_INTERESSE' and esito.Deleted = 0 and esito.StatoFunzionale in ('InLavorazione','Confermato')
	where man.id=@idRow
	
	IF getdate() < @dataScadenza 
	BEGIN
		set  @Errore='Data presentazione manifestazioni di interesse non superata'
	END
	
	IF @Errore = '' and @statoMan <> 'Sended'
	BEGIN
		set  @Errore='Stato documento non corretto per l''operazione richiesta'
	END

	IF @Errore = '' and @id is null
	BEGIN


			--recupero azienda utente collegato
			select @IdAziMittente=pfuidazi from profiliutente with(nolock) where idpfu=@IdUser

			insert into CTL_DOC ( IdPfu, TipoDoc, Body ,Azienda, IdDoc,	ProtocolloRiferimento, Fascicolo, LinkedDoc, StatoFunzionale, StatoDoc,deleted ) 
			values ( @IdUser, 'ESITO_SELEZIONATO_MANIFESTAZIONE_INTERESSE', '', @IdAziMittente , @idRow,@ProtocolloOfferta, @Fascicolo, @IdGara , 'InLavorazione', 'Saved',0 )   

			set @Id = SCOPE_IDENTITY()
		

	END


	if @Errore=''

		-- rirorna l'id del documento
		select @Id as id
	
	else

	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end
	
	
END

GO
