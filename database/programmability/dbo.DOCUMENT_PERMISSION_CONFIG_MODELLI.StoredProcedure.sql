USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_CONFIG_MODELLI]    Script Date: 5/16/2024 2:38:53 PM ******/
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
CREATE proc [dbo].[DOCUMENT_PERMISSION_CONFIG_MODELLI]
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
			
			
			declare @idAzi int
			select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu
			
			--se non viene dalla parte pubblica
			if @idPfu>0
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
				

				-- Se l'utente ha il profilo Amministratore (che può valutare) 
				-- o il profilo Conf_Sistema_Valori (che può valutare) 
				if @passed = 0 and exists (select * from profiliutenteattrib with(nolock) where dztnome='profilo' and attvalue in ( 'Conf_Sistema_Valori','Amministratore' ) and idpfu=@idPfu)
				begin
					set @passed = 1 --passato
				end 

				--verifico se l'utente è tra i referenti tecnici del documento	linked -- GARA					
				if @passed = 0 and exists(
							select idheader 
								from CTL_DOC C with(nolock) 
									inner join Document_Bando_Riferimenti DR with(nolock) on DR.idHeader=C.LinkedDoc
									inner join profiliutente P with(nolock) on P.idpfu=DR.idpfu
								where  C.id=@idDoc and RuoloRiferimenti='ReferenteTecnico' and P.IdPfu=@idPfu
							)
				begin
					set @passed = 1 --passato
				end 

				--Se la tua azienda è la stessa azienda dell'owner del documento 
				--if @idAzi = @idAziOwner and @passed = 0
				--begin
				--	set @passed = 1 --passato
				--end 			
				
				--Se la tua azienda è la stessa indicata nella colonna azienda
				--if @idAzi = @Azienda_doc and @passed = 0
				--begin
				--	set @passed = 1 --passato
				--end 
				
				--Se la tua azienda è la stessa del destinatario
				--if @idAzi = @Destinatario_Azi and @passed = 0
				--begin
				--	set @passed = 1 --passato
				--end 
				
				-- verifico se l'utenet o la sua azienda è fra i destinatari
				--if 	@passed = 0
				--	if exists( select idrow from CTL_DOC_Destinatari where idHeader = @idDoc and (  IdPfu = @idPfu or IdAzi = @idAzi ) )
				--		set @passed = 1 --passato
				
				--quando sono sui modelli creati da un bando faccio questo controllo
				If @passed = 0 and  EXISTS ( Select id from ctl_doc with(nolock) where id=@idDoc and ISNULL(linkeddoc,0)>0 )
				BEGIN
					IF EXISTS ( Select id from ctl_doc with(nolock) where tipodoc='CONVENZIONE' and id=(Select LinkedDoc from ctl_doc where id=@idDoc))
					BEGIN
						exec DOCUMENT_PERMISSION_CONVENZIONE @idPfu  , @idDoc ,	@param 
					END
					ELSE
					BEGIN
						exec DOCUMENT_PERMISSION_DOC_NEW  @idPfu  , @idDoc ,	@param  
					END
					return
				END

				
				
				-- output
				if @passed = 1
					select 1 as bP_Read , 1 as bP_Write
				else
					select 0 as bP_Read , 0 as bP_Write from profiliutente with(nolock) where idpfu = -100
			end
			
		end
	
	end

end

GO
