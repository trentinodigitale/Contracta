USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_USER_DOC_OE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
-- ID_DOC = NEW e PARAM=XXX  Se 'InLavorazione' può aprirlo soltanto un utente della stessa azienda con profilo di RefConvOE
--	Se <> 'Inlavorazione' posso aprire se sono un utente della stessa azienda o un utente dell'aziMaster	
----Non si può fare la NEW con param vuoto
------------------------------------------------------------------
--Versione=1&data=2015-06-24&Attivita=65808&Nominativo=Federico
CREATE proc [dbo].[DOCUMENT_PERMISSION_USER_DOC_OE]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	--select * from CTL_Attach where idpfu = 35846

		declare @idAzi int
		set @idAzi = - 1

		select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

		-- ID_DOC è NEW e PARAM=XXX solo aziMaster con profilo di amministratore
		IF upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and not @param is null 
		BEGIN
			
			--exec DOCUMENT_PERMISSION_USER_DOC 35846 , 'new5' , 'USER_DOC_READONLY,35846'
			
			-- select 1 as bP_Read , 1 as bP_Write
			set @idDoc = rtrim(ltrim(dbo.GetColumnValue (@param, ',', 2)))

			--print @idDoc

			-- Se l'utente ha il profilo Amministratore e fa parte dell'aziMaster
			IF ( exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue in ('Amministratore','AdminOE','AdminEnte' , 'RefConvOE' ) and idpfu=@idPfu)
				AND
				exists (SELECT * FROM MarketPlace where mpidazimaster = @idAzi) ) OR ( @idDoc =  @idPfu )
			BEGIN
				select 1 as bP_Read , 1 as bP_Write
			END
			ELSE
			BEGIN
				SELECT TOP 0  0 as bP_Read , 0 as bP_Write
			END
			

		END
		ELSE
		BEGIN


			-- ID_DOC = NEW e PARAM=XXX  Se 'InLavorazione' può aprirlo soltanto un utente della stessa azienda con profilo di RefConvOE
			--	Se <> 'Inlavorazione' posso aprire se sono un utente della stessa azienda o un utente dell'aziMaster	

			--se non viene dalla parte pubblica
			if @idPfu > 0 and cast(@idDoc as int) > 0
			begin
				
				declare @owner int
				declare @pfuInCharge int
				declare @idAziOwner int
				declare @Azienda_doc int
				declare @Destinatario_User int
				declare @Destinatario_Azi int
				declare @passed int -- variabile di controllo
				declare @statoFunzionale varchar(500)
				
				set @idAziOwner = -1
				set @pfuInCharge = -1
				set @owner = -1
				set @passed = 0 -- non passato
				set @Azienda_doc = -1
				set @Destinatario_User = -1
				set @Destinatario_Azi = -1
				set @statoFunzionale = ''

				-- Recupero i valori della variabili utilizzate per i test di sicurezza
				SELECT
						@owner = isnull(idpfu,-20), 
						@pfuInCharge = isnull(idpfuincharge,-100),
						@Azienda_doc = isnull(Azienda,-1),
						@Destinatario_User = isnull(Destinatario_User,-1),
						--@Destinatario_Azi = isnull(Destinatario_Azi,-1),
						@Destinatario_Azi = isnull(Azienda,-1),
						@statoFunzionale = StatoFunzionale
					FROM ctl_doc with(nolock) 
					WHERE id = @idDoc

				select @idAziOwner = pfuIdAzi from profiliutente with(nolock) where idPfu = @owner
				

				--se sono owner del documento passo
				if @owner = @idPfu
				    set @passed = 1 --passato

				-- Se 'InLavorazione' può aprirlo soltanto un utente della stessa azienda con profilo di RefConvOE
				if @statoFunzionale = 'InLavorazione' and @idAzi = @Destinatario_Azi
					and 
				  exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue in ('RefConvOE' ) and idpfu=@idPfu)
				begin
					set @passed = 1 --passato
				end 
				
				IF @statoFunzionale <> 'InLavorazione'
				BEGIN

					-- se l'utente è dell'aziMaster
					IF exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi)
					BEGIN
						set @passed = 1 --passato
					END

					--Se la tua azienda è la stessa del destinatario, cioè i 2 utenti devono stare sulla stessa azienda
					if @idAzi = @Destinatario_Azi
					begin
						set @passed = 1 --passato
					end		

				END

				if @passed = 1
					select 1 as bP_Read , 1 as bP_Write
				else
					select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100

			end
			
		END


end





GO
