USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PARAMETRI_CONTROLLO_INIPEC_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[OLD_PARAMETRI_CONTROLLO_INIPEC_CREATE_FROM_USER] 
	( @idDoc int  , @idUser int )
AS
BEGIN


	declare @IdConf as int
	set @IdConf=-1
	
	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1
	
	/* Cerco un documento dello stesso tipo in lavorazione -- fatto dallo stesso utente */
	select @newId=id from ctl_doc with (nolock)  
		where tipodoc='PARAMETRI_CONTROLLO_INIPEC' 
			and statofunzionale='InLavorazione' and idpfu =@idUser
			and deleted = 0

	--se NON esiste uno in lavorazione per l'utente lo CREO
	if @newId = -1
	begin
		
		--se esiste uno confermato riporto le info sul nuovo documento
		select @IdConf = id from ctl_doc with (nolock) 
			where tipodoc='PARAMETRI_CONTROLLO_INIPEC' and statofunzionale='Confermato' and deleted =  0

		
		insert into CTL_DOC (  idPfuInCharge , idpfu, TipoDoc, StatoDoc, statofunzionale, prevdoc )		
			select @idUser,@idUser, 'PARAMETRI_CONTROLLO_INIPEC', 'Saved' as StatoDoc, 'InLavorazione',  @IdConf
		

		set @newId = @@identity

		
		if @IdConf = -1 
		begin
				insert into 
					Document_Parametri_Controlli_INIPEC	
					([IdHeader], [NumeroMesi_Dominio], [EMAIL], [ClientID], [ClientSecret]
					,[OggettoAmmessa],[TestoAmmessa],[OggettoIntegrativa],[TestoIntegrativa])
					values
					( @newId, '', '', '','','', '', '','')
								
		end
		else
		begin
			
			
			insert into 
				Document_Parametri_Controlli_INIPEC	
					([IdHeader], [NumeroMesi_Dominio], [EMAIL], [ClientID], [ClientSecret])
				select 
					@newId, [NumeroMesi_Dominio], [EMAIL], [ClientID], [ClientSecret]
					from 
						Document_Parametri_Controlli_INIPEC with (nolock)
					where idheader = @IdConf 
		end
	


		IF @@ERROR <> 0
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
			rollback tran
			return 99
		END

		


	end

	
	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END



GO
