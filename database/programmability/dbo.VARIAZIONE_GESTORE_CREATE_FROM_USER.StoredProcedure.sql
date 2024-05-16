USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VARIAZIONE_GESTORE_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[VARIAZIONE_GESTORE_CREATE_FROM_USER] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @errore nvarchar(1000) = ''
	

	if @Errore=''
	begin
		
		set @Id=0
		
		--Se e' presente una richiesta salvata dallo stesso utente la riapro
		select @id=id from ctl_doc with(nolock) where tipodoc='VARIAZIONE_GESTORE' and statofunzionale='InLavorazione' and deleted=0 
		
		if @id=0
		begin
			--Document_Configurazione_Variazione_Gestore
			
			
			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, StatoFunzionale)
				values	( @idUser, 'VARIAZIONE_GESTORE', 'Saved', 'InLavorazione')

			SET @Id = SCOPE_IDENTITY()
			
			insert into Document_Configurazione_Variazione_Gestore( [idheader], [MesiFrequenza], [GiorniScadenza], [mail_alert_pec_oe_ko], [mail_alert_pec_ente_ko] )
				select @Id, b.[MesiFrequenza], b.[GiorniScadenza], b.[mail_alert_pec_oe_ko], b.[mail_alert_pec_ente_ko]	
					from ctl_doc a with(nolock)
							inner join Document_Configurazione_Variazione_Gestore b with(nolock) on b.idheader = a.Id and b.deleted = 0
					where tipodoc = 'VARIAZIONE_GESTORE' and StatoFunzionale = 'Confermato' and a.Deleted = 0

		end

	end

	
	if @Errore=''
		-- rirorna id odc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	

END


GO
