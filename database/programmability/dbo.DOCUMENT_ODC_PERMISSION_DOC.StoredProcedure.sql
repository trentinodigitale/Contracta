USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_ODC_PERMISSION_DOC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create proc [dbo].[DOCUMENT_ODC_PERMISSION_DOC]( 
	@idPfu   as int ,
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL     )
as
begin

	declare @idAzi			int
    declare @IdAziMaster as int
	declare @Destinatario_User int
	declare @Destinatario_Azi int
	declare @idAziOwner int
	declare @passed int 
	declare @owner int

	set @Destinatario_User = -1
	set @Destinatario_Azi = -1
	set @idAziOwner = -1
	set @owner = -1
	set @passed = 0 
	

	select @IdAziMaster=mpidazimaster from marketplace
	
	--recupero azienda utente collegato
	select @idAzi = pfuIdAzi  from profiliutente with(nolock)	where idPfu = @idPfu


	--se azienda master vede tutto
	if @idAzi=@IdAziMaster and @idPfu>0
	begin
		select  top 1 1 as bP_Read , 1 as bP_Write
	end
	else
	begin

		-- Recupero i valori della variabili utilizzate per i test di sicurezza
		select 
			@owner = isnull(RDA_Owner,-100) , 
			@Destinatario_Azi = isnull(IdAziDest,-1)
		from 
			Document_ODC with(nolock) 
		where RDA_ID = @idDoc

		-- recupero azienda del mittente
		select @idAziOwner = pfuIdAzi from profiliutente with(nolock) where idPfu = @owner
		
		
		--Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
		if @idPfu = @owner and @passed = 0
		begin
			set @passed = 1 --passato
		end 
		
		--Se la tua azienda è la stessa azienda dell'owner del documento 
		if @idAzi = @idAziOwner and @passed = 0
		begin
			set @passed = 1 --passato
		end
		
		--Se la tua azienda è la stessa del destinatario
		if @idAzi = @Destinatario_Azi and @passed = 0
		begin
			set @passed = 1 --passato
		end 
		
		-- Verifico se l'utente stà aprendo la scheda della sua azienda
		if @passed = 1
			select 1 as bP_Read , 1 as bP_Write
		else
			select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
				

	end
	

end

GO
