USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SIMOG_PUBBLICA_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SIMOG_PUBBLICA_CREATE_FROM_BANDO] ( @idDoc int , @idLog int = 0 , @modifica int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @newId INT
	declare @Errore nvarchar(1000)
	declare @tipoDoc varchar(200)
	declare @prevDoc INT
	declare @attach nvarchar(4000)

	set @prevDoc = NULL
	set @attach = ''
	set @tipoDoc = 'SIMOG_PUBBLICA' 

	select @prevDoc = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc =  @tipoDoc

	IF @prevDoc is not null
	BEGIN
		
		update ctl_doc
				set Deleted = 1
			where id = @prevDoc

	END

	INSERT INTO CTL_DOC ( TipoDoc, Azienda ,LinkedDoc, StatoFunzionale, PrevDoc, IdDoc, VersioneLinkedDoc, DataInvio)
		select  @tipoDoc , Azienda, @idDoc, 'Inviato', @prevDoc, @idLog, case when @modifica = 0 then '' else 'RETTIFICA' end, getDate()
			from ctl_doc with(nolock)
			where id=@idDoc		

	set @newId = SCOPE_IDENTITY()

	INSERT INTO document_bando_datiPubSimog( [idHeader], [simog_id_gara], [indexCollaborazione], [LINK_SITO], [NUMERO_QUOTIDIANI_NAZ], [NUMERO_QUOTIDIANI_REGIONALI], [DATA_PUBBLICAZIONE], [DATA_SCADENZA_PAG], [ORA_SCADENZA], [ID_SCELTA_CONTRAENTE], [versioneSimog], [HIDE_DATI_PUBBLICAZIONE], [DATA_SCADENZA_RICHIESTA_INVITO], [DATA_LETTERA_INVITO] ,[LINK_AFFIDAMENTO_DIRETTO])
		select @newId as [idHeader], [simog_id_gara], [indexCollaborazione], [LINK_SITO], [NUMERO_QUOTIDIANI_NAZ], [NUMERO_QUOTIDIANI_REGIONALI], [DATA_PUBBLICAZIONE], [DATA_SCADENZA_PAG], [ORA_SCADENZA], [ID_SCELTA_CONTRAENTE], [versioneSimog], [HIDE_DATI_PUBBLICAZIONE], [DATA_SCADENZA_RICHIESTA_INVITO], [DATA_LETTERA_INVITO] ,[LINK_AFFIDAMENTO_DIRETTO]
			from SIMOG_PUBBLICA_DATI_WS
			where id_gara = @idDoc

	exec CHECK_SEND_ALLEGATO_SIMOG @idDoc, 0, @attach output

	if isnull(@attach,'') <> ''
	begin
		
		update document_bando_datiPubSimog
				set fileBandoDiGara = @attach
			where idheader = @newId

	end

	IF  ISNULL(@newId,0) <> 0
	begin

		select @newId as id
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end

END










GO
