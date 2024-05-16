USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_FASCICOLO_DOCUMENTI_AGGIUNTIVI_CREATE_FROM_FASCICOLO_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[OLD_FASCICOLO_DOCUMENTI_AGGIUNTIVI_CREATE_FROM_FASCICOLO_GARA] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @Errore as nvarchar(2000)	

	SET @Errore = ''

	SET NOCOUNT ON

	-- riapro un documento in lavorazione se già creato
	--SELECT @id = id
	--	from ctl_doc with(nolock) 
	--	where tipodoc = 'FASCICOLO_DOCUMENTI_AGGIUNTIVI' 
	--	and StatoFunzionale = 'InLavorazione' 
	--	and deleted = 0
	--	and LinkedDoc = @idDoc	

	--if isnull(@id , 0 ) = 0 
	--begin

	--	--inserisco nella ctl_doc		
	--	insert into CTL_DOC (
	--				IdPfu, TipoDoc, StatoDoc, Titolo, Body, Note, DataInvio, 
	--				ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)

	--		select 
	--			@idUser,
	--			'FASCICOLO_DOCUMENTI_AGGIUNTIVI',
	--			'Saved' ,
	--			'Documenti esterni',
	--			Titolo,
	--			Note,
	--			DataInvio,
	--			ProtocolloRiferimento,
	--			Fascicolo,
	--			@IdDoc  ,
	--			'InLavorazione',
	--			@idUser , 
	--			''
	--	from ctl_doc 
	--	where id = @idDoc

	--	set @id = SCOPE_IDENTITY ()	

	--end
	--else
	--begin		
	--	update ctl_doc set IdPfu=@idUser,idPfuInCharge=@idUser, DataDocumento = getdate() where id=@id
	--end
	
	insert into CTL_DOC (
				IdPfu, TipoDoc, StatoDoc, Titolo, Body, Note, DataInvio, 
				ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)

		select 
			@idUser,
			'FASCICOLO_DOCUMENTI_AGGIUNTIVI',
			'Saved' ,
			'Documenti esterni',
			Titolo,
			Note,
			NULL AS DataInvio,
			ProtocolloRiferimento,
			Fascicolo,
			@IdDoc  ,
			'InLavorazione',
			@idUser , 
			''
	from ctl_doc 
	where id = @idDoc

	set @id = SCOPE_IDENTITY ()	

	if @Errore=''
	begin
		select @id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END

GO
