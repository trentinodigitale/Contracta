USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_DETAIL_OFFER_PERMISSION_DOC_NEW]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
--	1)   Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
--  2)   Se il tuo idpfu coincide con l'idpfu dell'utente che ha in carico il documento ctl_doc.idPfuInCharge
--  3)   Se la tua azienda è la stessa azienda dell'owner del documento 
--  4)   Se fai parte dell'azienda dell'ente, cioè dell'azienda master
--  5)   Se fai parte dell'azienda destinataria
--  6)   Se è un documento nuovo (si sta creando un documento, quindi idDoc NEW )
------------------------------------------------------------------

CREATE proc [dbo].[OLD_DOCUMENT_DETAIL_OFFER_PERMISSION_DOC_NEW]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

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
		
		if not @param is null 
		begin
			
			
			-- declare @document varchar(250)
			-- declare @storedPerm varchar(250)
			
			-- set @idDoc = cast ( substring ( @param, charindex(',', @param) + 1, len( @param ) ) as int )
			-- set @document = substring ( @param, , charindex(',', @param) )
			
			-- if exists(select top 1 * from lib_documents where doc_id = @document)
			-- begin
			
			-- 	select top 1 @storedPerm = isnull(DOC_DocPermission, '') from lib_documents where doc_id = @document
				
			-- 	if @storedPerm <> ''
			-- 	begin
			-- 	
			-- 		exec 
			-- 	 
			-- 	end
				
			-- end	
			-- else
			-- begin
				
				select 1 as bP_Read , 1 as bP_Write
				
			-- end
			
			
		end
		else
		begin
		
			declare @idAzi int
			select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

			-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master
			-- e non vieni dalla parte pubblica
			if exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi) and @idPfu>0
			begin
				select 1 as bP_Read , 1 as bP_Write
			end
			else
			begin
				
				declare @owner int
				declare @pfuInCharge int
				declare @idAziOwner int
				declare @Azienda_doc int
				declare @Destinatario_User int
				declare @Destinatario_Azi int
				declare @passed int -- variabile di controllo
				declare @IdDocRiferimento int				
								

				set @idAziOwner = -1
				set @pfuInCharge = -1
				set @owner = -1
				set @passed = 0 -- non passato
				set @Azienda_doc = -1
				set @Destinatario_User = -1
				set @Destinatario_Azi = -1

				--recupero iddoc della ctl_doc dalla col idheader della document_microlotti_dettagli
				select @IdDocRiferimento=IdHeader   from document_microlotti_dettagli where id=@idDoc
				
				--select * from Document_MicroLotti_dettagli where id=2873

				--BANDO_SEMP_OFF_ECO
				--BANDO_SEMP_OFF_TEC
				--BANDO_SEMP_OFF_EVAL
				--OFFERTA_BUSTA_ECO   tipodoc='OFFERTA' salgo sulla ctl_doc con idheader
				--OFFERTA_BUSTA_TEC	  tipodoc='OFFERTA' salgo sulla ctl_doc con idheader 			
				--select * from document_microlotti_dettagli where voce <> '0' and tipodoc='OFFERTA' 
				--select * from ctl_doc where id=37900
								

				--select distinct tipodoc from document_microlotti_dettagli

				-- Recupero i valori della variabili utilizzate per i test di sicurezza
				select 
					@owner = isnull(idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
					@Azienda_doc = isnull(Azienda,-1),@Destinatario_User = isnull(Destinatario_User,-1),
					@Destinatario_Azi = isnull(Destinatario_Azi,-1)
				from 
					ctl_doc with(nolock) 
				where id = @IdDocRiferimento
				
				-- recupero azienda del destinatario
				if @Destinatario_User <> -1
					select @Destinatario_Azi = pfuIdAzi from profiliutente with(nolock) where idPfu = @Destinatario_User

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
				
				--Se la tua azienda è la stessa azienda dell'owner del documento 
				if @idAzi = @idAziOwner and @passed = 0
				begin
					set @passed = 1 --passato
				end 			
				
				--Se la tua azienda è la stessa indicata nella colonna azienda
				if @idAzi = @Azienda_doc and @passed = 0
				begin
					set @passed = 1 --passato
				end 
				
				--Se la tua azienda è la stessa del destinatario
				if @idAzi = @Destinatario_Azi and @passed = 0
				begin
					set @passed = 1 --passato
				end 
				
				--se la tu aazienda è uno dei destinatari
				if @passed = 0
					if exists (select idazi from ctl_doc_destinatari where idheader=@IdDocRiferimento and idazi=@idAzi)
						set @passed = 1 --passato

				-- Verifico se l'utente stà aprendo la scheda della sua azienda
				if @passed = 1
					select 1 as bP_Read , 1 as bP_Write
				else
					select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
				
			end
			
		end
	
	end

end

GO
