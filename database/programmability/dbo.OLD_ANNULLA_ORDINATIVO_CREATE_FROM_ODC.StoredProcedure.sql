USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANNULLA_ORDINATIVO_CREATE_FROM_ODC]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_ANNULLA_ORDINATIVO_CREATE_FROM_ODC] 
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdConvenzione as int
	declare @IdOrdinativo as int	
	declare @IdAzi as int

	set @Id = ''
	set @Errore=''
	
	--verifico se sono raggiunti I termini di scadenza convezione, in questo caso blocco con messaggio 
	--"Impossibile annullare l'ordinativo. Superata la Scadenza della Convezione"

	--recupero id convenzione
	select @IdConvenzione=id_convenzione from document_odc where rda_id=@IdDoc	
	
	--controllo se convenzione scaduta
	--if exists (select * from document_convenzione where id=@IdConvenzione and getdate() > datafine)	
	--	set @Errore='Impossibile annullare l''ordinativo. Superata la Scadenza della Convezione'

	if @Errore=''
	begin
		--Se e' presente una richiesta nello stato di :InApprovazione esco con messaggio di blocco "E' gia' presente una richiesta di annullamento in corso"
		if exists (select * from ctl_doc where tipodoc='ANNULLA_ORDINATIVO' and linkeddoc=@IdDoc and statofunzionale='InApprove' and deleted=0 )
			set @Errore='E'' gia'' presente una richiesta di annullamento in corso'
	end

	if @Errore=''
	begin
		
		--recupero azienda utente collegato
		select @IdAzi=pfuidazi from profiliutente where idpfu=@idUser and pfudeleted=0

		set @Id=0
		
		--Se e' presente una richiesta salvata riapro quella
		select @id=id from ctl_doc where tipodoc='ANNULLA_ORDINATIVO' and linkeddoc=@IdDoc and statofunzionale='InLavorazione' and deleted=0
		
		if @id=0
		begin
			
			--inserisco nella ctl_doc		
			insert into CTL_DOC (
					 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
						ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
				
					select @idUser,  'ANNULLA_ORDINATIVO', 'Saved' , 'Annulla ordinativo ' + Titolo , note , @IdAzi ,null
						,Protocollo  , Fascicolo , @IdDoc  ,'InLavorazione', @idUser , ''
					from CTL_DOC 
						where Id = @IdDoc

			set @Id = @@identity		
			
			

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
