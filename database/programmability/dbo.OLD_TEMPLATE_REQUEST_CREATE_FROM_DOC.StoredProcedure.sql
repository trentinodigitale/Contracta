USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TEMPLATE_REQUEST_CREATE_FROM_DOC]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






	
CREATE PROCEDURE [dbo].[OLD_TEMPLATE_REQUEST_CREATE_FROM_DOC] 	( @IdDoc int  , @idUser int )
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

		
	select @StatoFunzionale = StatoFunzionale from CTL_DOC where id=@IdDoc	and Tipodoc = 'TEMPLATE_REQUEST'
	

	if @StatoFunzionale <> 'Pubblicato' 
	begin
		set @Errore='Impossibile modificare il Modulo richiesto il cui stato e'' diverso da Pubblicato'
	end

		
	SELECT @Id = ID FROM CTL_DOC with (nolock) where PrevDoc=@IdDoc	and Tipodoc = 'TEMPLATE_REQUEST' and StatoFunzionale = 'InLavorazione' and deleted = 0



	if @Errore = '' and @Id is null
	begin



		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
					ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck , PrevDoc , note , NumeroDocumento, VersioneLinkedDoc, Versione  )
				
			select @idUser,  'TEMPLATE_REQUEST', 'Saved' ,  Titolo , Body , @IdAzi ,null
					,''  , Fascicolo , 0  ,'InLavorazione', @idUser , 'DGUE' , @IdDoc , Note , NumeroDocumento, VersioneLinkedDoc  , Versione
				from CTL_DOC with(nolock) 
				where Id = @IdDoc

		set @Id = @@identity		

			

		-- copia tutti gli elementi della ctl_Doc_value
		insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
			select  @Id, [DSE_ID], [Row], [DZT_Name], [Value] 
				from CTL_DOC_Value  with(nolock) 
				where IdHeader = @IdDoc 
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
