USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_NEW_RISULTATODIGARA]    Script Date: 5/16/2024 2:38:53 PM ******/
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
--  7)   Se la procedura è aperta (come un albo) puoi visualizzarne il dettaglio
--  8)   Se 'BANDO_GARA' o 'BANDO_SDA' e EvidenzaPubblica = 1
------------------------------------------------------------------
--Versione=1&data=2014-11-11&Attivita=65808&Nominativo=Enrico
CREATE proc [dbo].[DOCUMENT_PERMISSION_NEW_RISULTATODIGARA]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin
	
	set nocount on

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
			declare @nPermessoOblio as varchar(10)

			select @idAzi = pfuIdAzi ,@nPermessoOblio=SUBSTRING(pfuFunzionalita , 466,1) from profiliutente with(nolock) where idPfu = @idPfu

			-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master
			-- e non vieni dalla parte pubblica
			--if exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi) and @idPfu>0
			--begin
			--	select 1 as bP_Read , 1 as bP_Write
			--end
			--else
			--se non è utente dell aparte pubblica
			if @idPfu>0
			begin
				





				declare @owner int
				declare @pfuInCharge int
				declare @idAziOwner int
				declare @Azienda_doc int
				declare @Destinatario_User int
				declare @Destinatario_Azi int
				declare @passed int -- variabile di controllo
				declare @DataDirittoOblio as datetime
				declare @TipoDocumentoEsito as varchar(500)


				set @idAziOwner = -1
				set @pfuInCharge = -1
				set @owner = -1
				set @passed = 0 -- non passato
				set @Azienda_doc = -1
				set @Destinatario_User = -1
				set @Destinatario_Azi = -1

				
				--select * from CTL_DOC_Value where idheader = 420362

				--recupero data diritto oblio della gara
				select @DataDirittoOblio =DataDirittoOblio , @TipoDocumentoEsito=DE.Value 
					from CTL_DOC with(nolock) 
						inner join Document_Bando DG with(nolock)  on DG.idHeader = LinkedDoc 
						left join CTL_DOC_Value DE with(nolock)  on DE.idHeader = Id and DSE_ID='TESTATA'  and DZT_Name='TipoDocumentoEsito'
					where Id = @idDoc
				--se esito di tipo curricula commissione
				 
				if @TipoDocumentoEsito <> 'CV Commissione' or  @DataDirittoOblio >= GETDATE() or  @nPermessoOblio ='1'
				begin	
				


					-- Recupero i valori della variabili utilizzate per i test di sicurezza
					select 
						@owner = isnull(idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
						@Azienda_doc = isnull(Azienda,-1),@Destinatario_User = isnull(Destinatario_User,-1),
						@Destinatario_Azi = isnull(Destinatario_Azi,-1)
					from 
						ctl_doc with(nolock) 
					where id = @idDoc
				
					-- recupero azienda del destinatario
					--if @Destinatario_User <> -1
					--	select @Destinatario_Azi = pfuIdAzi from profiliutente with(nolock) where idPfu = @Destinatario_User

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
				end
				else
					set @passed = 0 --passato

				-- Se l'utente ha il profilo Amministratore (che può valutare) 
				--if exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue='Amministratore' and idpfu=@idPfu)
				--begin
				--	set @passed = 1 --passato
				--end 

				
				
				-- output
				if @passed = 1
					select 1 as bP_Read , 1 as bP_Write
				else
					select top 0 0 as bP_Read , 0 as bP_Write 
			end
			
		end
	
	end

end
GO
