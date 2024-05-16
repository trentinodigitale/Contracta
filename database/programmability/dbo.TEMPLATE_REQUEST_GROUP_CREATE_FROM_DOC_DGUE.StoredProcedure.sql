USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TEMPLATE_REQUEST_GROUP_CREATE_FROM_DOC_DGUE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--update CTL_DOC set Deleted = 1 where Id = 98729





	
CREATE PROCEDURE [dbo].[TEMPLATE_REQUEST_GROUP_CREATE_FROM_DOC_DGUE] 	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @StatoFunzionale varchar(100)
	declare @IdConvenzione as int
	declare @IdOrdinativo as int	
	declare @IdAzi as int

	set @Id = null
	set @Errore=''


	

	if @IdDoc <> 0 
	begin
		select @StatoFunzionale = StatoFunzionale from CTL_DOC where id=@IdDoc	and Tipodoc = 'TEMPLATE_REQUEST_GROUP'
	

		if @StatoFunzionale <> 'Pubblicato' 
		begin
			set @Errore='Impossibile modificare il Modulo richieste il cui stato e'' diverso da Pubblicato'
		end

		SELECT @Id = ID FROM CTL_DOC where PrevDoc=@IdDoc	and Tipodoc = 'TEMPLATE_REQUEST_GROUP' and StatoFunzionale = 'InLavorazione' and deleted = 0



		if @Errore = '' and @Id is null
		begin



			--inserisco nella ctl_doc		
			insert into CTL_DOC (
						IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
						ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck , PrevDoc , note, NumeroDocumento)
				
				select @idUser,  'TEMPLATE_REQUEST_GROUP', 'Saved' ,  Titolo , Body , @IdAzi ,null
						,''  , Fascicolo , 0  ,'InLavorazione', @idUser , 'DGUE' , @IdDoc , Note , NumeroDocumento
					from CTL_DOC 
					where Id = @IdDoc

			set @Id = @@identity		

			-- copio tutti gli elementi
			insert into [dbo].[DOCUMENT_CRITERI_QUESTIONARI] (  idHeader, ItemLevel, ItemPath, Domanda_Elenco, DZT_TYPE, idCriterion, GL1, RL1, GL2, RL2, GL3, RL3, GL4, RL4, O1, O2, ITEM_ID, CRITERION_CODE, UUID, Description, PI ,RG_FLD_TYPE)
				select @Id as IdHeader, ItemLevel, ItemPath, Domanda_Elenco, DZT_TYPE, idCriterion, GL1, RL1, GL2, RL2, GL3, RL3, GL4, RL4, O1, O2, ITEM_ID, CRITERION_CODE, UUID, Description, PI , RG_FLD_TYPE
					from [DOCUMENT_CRITERI_QUESTIONARI]
					where idheader = @IdDoc  
					order by idrow


		end

	end
	else
	begin

		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
					ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck , PrevDoc)
				
			select @idUser,  'TEMPLATE_REQUEST_GROUP', 'Saved' ,  'Senza Titolo' as Titolo , '' as note , 0 ,null
					,''  , '' , 0  ,'InLavorazione', @idUser , 'DGUE' , @IdDoc

		set @Id = @@identity		

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
