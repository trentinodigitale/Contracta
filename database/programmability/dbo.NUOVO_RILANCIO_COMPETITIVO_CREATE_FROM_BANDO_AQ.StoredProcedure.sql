USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[NUOVO_RILANCIO_COMPETITIVO_CREATE_FROM_BANDO_AQ]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[NUOVO_RILANCIO_COMPETITIVO_CREATE_FROM_BANDO_AQ] 
	( @idRow int  , @idUser int )
AS
BEGIN
	
	declare @IdDoc as int
	declare @id int
	declare @GG_OffIndicativa as int
	declare @Azienda as int

	declare @idx int
	declare @Modello varchar(500)
	declare @CodiceModello varchar(500)
	declare @MOD_BandoSempl varchar(500)
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	set @Id = 0

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--recupero id del bando_sda e id azienda
	select @IdDoc= @idRow

	-- cerca una versione precedente del documento
	select @Id = id from CTL_DOC where LinkedDoc = @IdDoc and TipoDoc = 'NUOVO_RILANCIO_COMPETITIVO_TESTATA' and deleted = 0 and StatoDoc = 'Saved' and idpfu=@idUser
	


	-- se non viene trovato allora si crea il nuovo documento
	--if isnull(@Id , 0 ) = 0 
	if @Errore=''
	begin

		declare @identifIniziativa varchar(500)

		set @identifIniziativa = NULL
		select @Azienda = pfuidazi from profiliutente with(Nolock) where idpfu = @IdUser
		select @identifIniziativa = IdentificativoIniziativa from Document_Bando with(Nolock) where idHeader = @IdDoc


		-- se l'utente che sta creando la convenzione non è dell'agenzia
		--if not exists ( select idpfu from profiliutente with(Nolock) where idpfu = @IdUser and pfuIdAzi = 35152001 )
		--begin

		--	set @identifIniziativa = '9999'

		--end


		
		-- genero la testata del documento
		insert into CTL_DOC (
				 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
					ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale, Versione )
					
			select  @idUser as IdPfu ,  'NUOVO_RILANCIO_COMPETITIVO' , 'Saved' , 'Senza Titolo' , d.Body , @Azienda ,   '' as StrutturaAziendale
					, d.Protocollo  ,  '' as Fascicolo  ,  Id  ,'InLavorazione' 
					, '2'
				from CTL_DOC d
					inner join document_Bando b on d.id = b.idheader
					where Id = @IdDoc

		set @Id = @@identity
		


		---- inserico i dati base del bando
		insert into Document_Bando (
					idHeader, TipoBando,ProceduraGara, TipoBandoGara , TipoAppaltoGara, EvidenzaPubblica, IdentificativoIniziativa , Divisione_lotti)
			select  @Id    ,  '' /*TipoBando*/,ProceduraGara, 3,TipoAppaltoGara, '0',@identifIniziativa , 2 as Divisione_lotti
				from document_bando f 
					where f.idHeader = @IdDoc

		-- inserisoc il record nella document_protocollo
		insert into Document_dati_protocollo ( idHeader)
			values (  @Id )


		-- inserisce i lotti 
		insert into document_microlotti_dettagli ( [IdHeader],[TipoDoc],[StatoRiga],[NumeroLotto],[Descrizione],[CIG],[NoteLotto],[EsitoRiga] ) 
			select @Id as [IdHeader],'NUOVO_RILANCIO_COMPETITIVO' as TipoDoc,[StatoRiga],[NumeroLotto],[Descrizione],[CIG],[NoteLotto],[EsitoRiga] 
				from document_microlotti_dettagli 
				where idheader = @IdDoc and tipodoc = 'BANDO_GARA' and voce = 0 
				order by NumeroLotto
				

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
