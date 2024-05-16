USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_DOC_BASE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
--	1)   Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
--  2)   Se il tuo idpfu coincide con l'idpfu dell'utente che ha in carico il documento ctl_doc.idPfuInCharge
--  3)   Se la tua azienda è la stessa azienda dell'owner del documento 
--  4)   Se fai parte dell'azienda dell'ente, cioè dell'azienda master
--  5)   Se fai parte dell'azienda destinataria
--  6)   Se fai parte della stessa azienda dell'utente destinatario
--  7)   Se è un documento nuovo (si sta creando un documento, quindi idDoc NEW )
------------------------------------------------------------------
--Versione=1&data=2023-01-12&Attivita=490455&Nominativo=Enrico
CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_DOC_BASE]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin
	
	SET NOCOUNT ON

	declare @TipoDoc as varchar(200)
	declare @LinkedDoc as int
	declare @Esito as varchar(100)
	declare @Errore as nvarchar(2000)
	declare @StatoFunzionale as varchar(100)
	declare @idAzi int
	declare @owner int
	declare @pfuInCharge int
	declare @idAziOwner int
	declare @Azienda_doc int
	declare @Destinatario_User int
	declare @Destinatario_Azi int
	declare @Aziena_Destinatario_User as int

	declare @passed int 




	if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and @param is null 
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
	
		-- Se stiamo aprendo un documento come create from
		-- non bisogna controllare il parametro idDoc che sarà NEW
		-- ma quello dopo la virgola nel parametro param  . es : AZIENDA, 123 o BANDO, 12356
		-- e poi eseguire il controllo sulla stored del documento di createFrom e non di quello
		-- di partenza
		
		--if not @param is null 
		--begin

		--	select 1 as bP_Read , 1 as bP_Write

		--end
		--else
		begin
			
			select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

			-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master e non vieni dalla parte pubblica
			if exists (SELECT * FROM MarketPlace with (nolock) where mpidazimaster = @idAzi) and @idPfu > 0 
			begin
				select 1 as bP_Read , 1 as bP_Write
			end
			else
			begin
				
				set @idAziOwner = -1
				set @pfuInCharge = -1
				set @owner = -1
				set @passed = 0 -- non passato
				set @Azienda_doc = -1
				set @Destinatario_User = -1
				set @Destinatario_Azi = -1
				set @Aziena_Destinatario_User = -1 

				-- Recupero i valori della variabili utilizzate per i test di sicurezza
				select 
						@owner = isnull(idpfu,-20) , 
						@pfuInCharge = isnull(idpfuincharge,-100),
						@Azienda_doc = isnull(Azienda,-1),
						@Destinatario_User = isnull(Destinatario_User,-1),
						@Destinatario_Azi = isnull(Destinatario_Azi,-1)
					from ctl_doc a with(nolock) 
							
					where a.id = @idDoc
				
				select @idAziOwner = pfuIdAzi from profiliutente with(nolock) where idPfu = @owner
				
				--Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
				if @idPfu = @owner and @passed = 0
				begin
					set @passed = 1 --passato
				end 
				
				-- Se il tuo idpfu coincide con l'idpfu dell'utente che ha in carico il documento ctl_doc.idPfuInCharge
				if @idPfu = @pfuInCharge  and @passed = 0
				begin
					set @passed = 1 --passato
				end 
				
				--Se sei il destinatario del documento 

				--Se la tua azienda è la stessa azienda dell'owner del documento 
				if @idAzi = @idAziOwner and @passed = 0
				begin
					set @passed = 1 --passato
				end 			
				
				--Se la tua azienda è la stessa azienda del documento 
				if @idAzi = @Azienda_doc and @passed = 0
				begin
					set @passed = 1 --passato
				end
				
				-- Se fai parte dell'azienda destinataria del documento
				IF @idAzi = @Destinatario_Azi and @passed = 0
				BEGIN
					set @passed = 1 --passato
				END
				
				select @Aziena_Destinatario_User = pfuIdAzi from profiliutente with(nolock) where idPfu = @Destinatario_User
				-- se fai parte della stessa azienda dell'utente destinatario
				IF @idAzi = @Aziena_Destinatario_User and @passed = 0
				BEGIN
					set @passed = 1 --passato
				END


				--se ho superato i controlli restituisco il record altrimenti no
				if @passed = 1
					select 1 as bP_Read , 1 as bP_Write
				else
					select top 0 0 as bP_Read , 0 as bP_Write
				
			end
	
		end
	end
end







GO
