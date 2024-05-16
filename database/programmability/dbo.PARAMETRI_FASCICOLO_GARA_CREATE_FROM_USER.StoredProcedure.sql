USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PARAMETRI_FASCICOLO_GARA_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[PARAMETRI_FASCICOLO_GARA_CREATE_FROM_USER] 
	( @idDoc int  , @idUser int )
AS
BEGIN


	--Versione=1&data=2015-03-23Attivita=68663&Nominativo=Sabato

	declare @IdConf as int
	set @IdConf=-1

	

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1
	
	select @newId=id from ctl_doc with (nolock)  where tipodoc='PARAMETRI_FASCICOLO_GARA' and statofunzionale='InLavorazione' and idpfu =@idUser

	--se NON esiste uno in lavorazione per l'utente lo CREO
	if @newId = -1
	begin
		
		--se esiste uno confermato riporot le info sul nuovo documento
		select @IdConf = id from ctl_doc with (nolock) where tipodoc='PARAMETRI_FASCICOLO_GARA' and statofunzionale='Confermato' 

		
		insert into CTL_DOC (  idPfuInCharge , idpfu, TipoDoc, StatoDoc, statofunzionale, prevdoc )		
			select @idUser,@idUser, 'PARAMETRI_FASCICOLO_GARA', 'Saved' as StatoDoc, 'InLavorazione',  @IdConf
		

		set @newId = @@identity

		
		if @IdConf = -1 
		begin
				insert into 
					Document_Config_FascicoloGara	
					( [IdHeader], [PercorsoDiRete], [Soglia], [EMAIL], [NumGiorni])
					values
					( @newId, '', null, '', null)
								
		end
		else
		begin
			
			
			insert into 
				Document_Config_FascicoloGara
					( [IdHeader], [PercorsoDiRete], [Soglia], [EMAIL], [NumGiorni], [OrganizzazioneFile])
				select 
					@newId, [PercorsoDiRete], [Soglia], [EMAIL], [NumGiorni],[OrganizzazioneFile]
						from Document_Config_FascicoloGara with (nolock) where idheader =@IdConf 
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
