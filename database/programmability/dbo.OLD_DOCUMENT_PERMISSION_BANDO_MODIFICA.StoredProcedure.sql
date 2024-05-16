USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_BANDO_MODIFICA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





------------------------------------------------------------------
--Versione=1&data=2018-06-20&Attivita=197303&Nominativo=Enrico

CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_BANDO_MODIFICA]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and @param is null 
	begin
		select top 0 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
	
		-- Se stiamo aprendo un documento come create from
		-- non bisogna controllare il parametro idDoc che sarà NEW
		-- ma quello dopo la virgola nel parametro param  . es : AZIENDA, 123 o BANDO, 12356
		-- e poi eseguire il controllo sulla stored del documento di createFrom e non di quello
		-- di partenza
		if not @param is null and @param not in ( '@@@RIFERIMENTI.ADDFROM','@@@DOCUMENTAZIONE_RICHIESTA.AddNew','@@@DOCUMENTAZIONE_RICHIESTA.ADDFROM','@@@DOCUMENTAZIONE_RICHIESTA.DELETE_ROW','@@@COMMISSIONE.DELETE_ROW','@@@ENTI.DELETE_ROW','@@@COMMISSIONE.AddNew','@@@ENTI.AddNew','@@@RIFERIMENTI.AddNew' ,  '@@@PROCESS' , '@@@RELOAD' , '@@@SAVE' , '@@@RIFERIMENTI.DELETE_ROW', '@@@InfoTec_3DatePub.AddNew', '@@@InfoTec_DatePub.AddNew', '@@@InfoTec_2DatePub.AddNew', '@@@InfoTec_3DatePub.DELETE_ROW', '@@@InfoTec_DatePub.DELETE_ROW', '@@@InfoTec_2DatePub.DELETE_ROW' , '@@@ATTI_GARA.AddNew' , '@@@ATTI_GARA.DELETE_ROW' )
		begin
			
				-- non si puo creare di iniziativa
				select top 0 1 as bP_Read , 1 as bP_Write
				
			
		end
		else
		begin
			
			declare @TipoDoc as varchar(200)
			declare @LinkedDoc as int
			declare @Esito as varchar(100)
			declare @Errore as nvarchar(2000)
			declare @StatoDoc as varchar(100)

			select @StatoDoc=StatoDoc,@TipoDoc=TipoDoc,@LinkedDoc=LinkedDoc from ctl_doc where id = @idDoc

			set @Esito='OK'			
			
			if @Esito='OK'			
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
						

					set @idAziOwner = -1
					set @pfuInCharge = -1
					set @owner = -1
					set @passed = 0 -- non passato
					set @Azienda_doc = -1
					
					-- Recupero i valori della variabili utilizzate per i test di sicurezza
					select 
						@owner = isnull(idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
						@Azienda_doc = isnull(Azienda,-1)
						from 
							ctl_doc with(nolock) 
						where id = @idDoc
						
					
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
					
					
					--Se la tua azienda è la stessa azienda del documento
					if @idAzi = @Azienda_doc and @passed = 0
					begin
						set @passed = 1 --passato
					end 

					
					-- Se l'utente ha il profilo Amministratore 
					if @passed = 0 and exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue='Amministratore' and idpfu=@idPfu)
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
			else
			begin
				select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
			end	
		end
	
	end

end













GO
