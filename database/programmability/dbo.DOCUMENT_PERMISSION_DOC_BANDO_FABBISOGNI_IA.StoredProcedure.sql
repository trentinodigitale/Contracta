USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_DOC_BANDO_FABBISOGNI_IA]    Script Date: 5/16/2024 2:38:53 PM ******/
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
--Versione=1&data=2019-04-29&Attivita=242254&Nominativo=Enrico

CREATE proc [dbo].[DOCUMENT_PERMISSION_DOC_BANDO_FABBISOGNI_IA]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON


	if ( upper( substring( @idDoc, 1, 3 ) ) = 'NEW' or @idDoc = '' )  and dbo.GetPos( ISNULL( @param , '' ) , '@@@' , 1 ) = ''  -- @param is null 
		or
		exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue in ('Direttore', 'Amministratore' ) and idPfu = @idPfu )
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
		
		if exists (select idrow from CTL_DOC_Destinatari with (nolock) where idrow = @idDoc and IdPfu = @idPfu)	
			select 1 as bP_Read , 1 as bP_Write

		else			
		begin
			
			declare @idAzi int
			select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

			-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master
			-- e non vieni dalla parte pubblica
			if exists(SELECT * FROM MarketPlace with(nolock) where mpidazimaster = @idAzi) and @idPfu>0
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
						

				set @idAziOwner = -1
				set @pfuInCharge = -1
				set @owner = -1
				set @passed = 0 -- non passato
				set @Azienda_doc = -1
				set @Destinatario_User = -1
				set @Destinatario_Azi = -1

				-- Recupero i valori della variabili utilizzate per i test di sicurezza
				select 
					@owner = isnull(B.idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
					@Azienda_doc = isnull(Azienda,-1),@Destinatario_User = isnull(Destinatario_User,-1),
					--@Destinatario_Azi = isnull(Destinatario_Azi,-1)
					@Destinatario_Azi = isnull(BD.IdAzi,-1)
				from 
					CTL_DOC_Destinatari BD with(nolock)
						inner join ctl_doc B with(nolock)  on id = idheader
				where idrow = @idDoc
				
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
	end

end






















GO
