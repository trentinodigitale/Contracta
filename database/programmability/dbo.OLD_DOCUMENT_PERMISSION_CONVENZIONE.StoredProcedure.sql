USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
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
--  6)   Se è un documento nuovo (si sta creando un documento, quindi idDoc NEW )
--  7)   Se la procedura è aperta (come un albo) puoi visualizzarne il dettaglio
--  8)   Se 'BANDO_GARA' o 'BANDO_SDA' e EvidenzaPubblica = 1
------------------------------------------------------------------
--Versione=1&data=2014-11-11&Attivita=65808&Nominativo=Enrico
CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_CONVENZIONE]
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

			select 1 as bP_Read , 1 as bP_Write

		end
		else
		begin
			

			-- per la PDA_MICROLOTTI controllo accesso sul tipo utente
			declare @TipoDoc as varchar(200)
			declare @LinkedDoc as int
			declare @Esito as varchar(100)
			declare @Errore as nvarchar(2000)
			declare @StatoFunzionale as varchar(100)

			select @StatoFunzionale=StatoFunzionale,@TipoDoc=TipoDoc,@LinkedDoc=LinkedDoc from ctl_doc where id = @idDoc

			declare @idAzi int
			select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

			-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master
			-- e non vieni dalla parte pubblica
			if exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi) and @idPfu>0 --or @StatoFunzionale in ( 'Pubblicato' )
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
				
				declare @referente INT
				declare @aziendaDestConv INT

				set @idAziOwner = -1
				set @pfuInCharge = -1
				set @owner = -1
				set @passed = 0 -- non passato
				set @Azienda_doc = -1
				set @Destinatario_User = -1
				set @Destinatario_Azi = -1

				set @referente = -1
				set @aziendaDestConv = -1

				-- Recupero i valori della variabili utilizzate per i test di sicurezza
				select 
						@owner = isnull(idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
						@Azienda_doc = isnull(Azienda,-1),@Destinatario_User = isnull(Destinatario_User,-1),
						@Destinatario_Azi = isnull(Destinatario_Azi,-1),
						@referente = isnull(b.ReferenteFornitore,-1),
						@aziendaDestConv = isnull( b.AZI_Dest, -1)
					from ctl_doc a with(nolock) 
							left join Document_Convenzione b with(nolock) ON b.id = a.id
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
				
				--Se la tua azienda è la stessa azienda dell'owner del documento 
				if @idAzi = @idAziOwner and @passed = 0
				begin
					set @passed = 1 --passato
				end 			
				
				--se l'utente ha il profilo NegozioElettronico passa
				if exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue in ( 'GestoreNegoziElettro','GestoreConvenzioni') and idpfu=@idPfu)
				begin
					set @passed = 1 --passato
				end 

				-- Se fai parte dell'azienda destinataria della convenzione ed hai il profilo RefConvOE
				IF @idAzi = @aziendaDestConv AND exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue in ('RefConvOE','RespOrdOE') and idpfu=@idPfu)
				BEGIN
					set @passed = 1 --passato
				END
				                
				
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
