USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_TEMPLATE_REQUEST_GROUP_TOOLTIP_CREATE_FROM_DOC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	
CREATE PROCEDURE [dbo].[OLD2_TEMPLATE_REQUEST_GROUP_TOOLTIP_CREATE_FROM_DOC] 	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @StatoFunzionale varchar(100)
	
	declare @IdAzi as int

	set @Id = null
	set @Errore=''


		
	select @StatoFunzionale = StatoFunzionale from CTL_DOC with (nolock) where id=@IdDoc	and Tipodoc = 'TEMPLATE_REQUEST_GROUP'
	
	--recupero azienda utente collegato
	select @IdAzi = pfuidazi from profiliutente with (nolock) where idpfu =  @idUser

	if @StatoFunzionale <> 'Pubblicato' 
	begin
		set @Errore='Impossibile modificare i campi "Aiuto Informazioni" per un documento il cui stato e'' diverso da Pubblicato'
	end

	SELECT @Id = ID FROM CTL_DOC where linkeddoc=@IdDoc	and Tipodoc = 'TEMPLATE_REQUEST_GROUP_TOOLTIP' and StatoFunzionale = 'InLavorazione' and deleted = 0

	if @Errore = '' and @Id is null
	begin



		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
					ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck ,  note , NumeroDocumento  )
				
			select @idUser,  'TEMPLATE_REQUEST_GROUP_TOOLTIP', 'Saved' ,  Titolo , Body , @IdAzi ,null
					,'Modifica aiuto informazioni'  , Fascicolo , id  ,'InLavorazione', @idUser , 'DGUE' ,  Note , NumeroDocumento
				from CTL_DOC with(nolock) 
				where Id = @IdDoc

		set @Id = @@identity		

			


		-- copio i tooltip dalla sorgente
		insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
			select  @Id, [DSE_ID], [Row], [DZT_Name], [Value] 
				from CTL_DOC_Value  with(nolock) 
				where IdHeader = @IdDoc and [DSE_ID] = 'TIPOLOGIA' and dzt_name in ('Tooltip','Tooltip_UK')



	end

	
	


	if @Errore=''
		-- rirorna id  creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		

end







GO
