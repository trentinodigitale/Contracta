USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_USER_DOC]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
--SE ID_DOC = NEW e PARAM=XXX   solo aziMaster con profilo di amministratore . oppure se stai modificando/aprendo te stesso
	
--SE ID_DOC <> NEW e PARAM vuoto, la colonna idpfu della ctl_doc deve essere l'idpfu che sta facendo l'operazione se statoFunzionale = 'InLavorazione'
--							  oppure 
--							stato funzionale <> 'InLavorazione e la colonna destinatarioUser deve coincidere con l'azienda dell'utente in sessione	(cioè i 2 utenti devono stare sulla stessa azienda)
--							 oppure
--							stato funzionale <> 'InLavorazione e l'utente collegato è un utente dell'azienda master
	
--Non si può fare la NEW con param vuoto
------------------------------------------------------------------
--Versione=1&data=2014-11-11&Attivita=65808&Nominativo=Enrico
--Versione=2&data=2015-06-24&Attivita=65808&Nominativo=Federico
CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_USER_DOC]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and @param is null 
	begin

		-- non permetto la creazione di utenti tramite questo documento
		--select top 0 0 as bP_Read , 0 as bP_Write

		-- lascio passare SOLO l'utente amministratore
		IF ( exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue in ('Amministratore','AdminOE','AdminEnte'  ) and idpfu=@idPfu) )
				
			BEGIN
				select 1 as bP_Read , 1 as bP_Write
			END
			ELSE
			BEGIN
				SELECT TOP 0  0 as bP_Read , 0 as bP_Write
			END


	end
	else if upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and @param = '@@@PROCESS'
	begin
		select top 1 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
	
		declare @idAzi int
		set @idAzi = - 1

		select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

		-- ID_DOC è NEW e PARAM=XXX solo aziMaster con profilo di amministratore
		IF upper( substring( @idDoc, 1, 3 ) ) = 'NEW' and not @param is null
		BEGIN

			-- select 1 as bP_Read , 1 as bP_Write
			set @idDoc = rtrim(ltrim(dbo.GetColumnValue (@param, ',', 2)))

			-- Se l'utente ha il profilo Amministratore oppure ha il permesso 350 di modifica utente e fa parte dell'aziMaster 
			-- oppure l'utente modifica se stesso
			 IF (
				    exists ( 
						  select 
							 * 
							 from 
								    profiliutente P left join profiliutenteattrib PA on P.IdPfu = PA.idpfu 
								    where 
									   (
										  ( dztnome='profilo' and attvalue in ('Amministratore','AdminOE','AdminEnte' , 'RefConvOE' ) )
										  or 
											 substring(pfuFunzionalita,350,1)=1 
									   )
									   and P.idpfu=@idPfu
						  ) 
				    AND 
				    exists ( select * from MarketPlace where mpidazimaster = @idAzi )
				)
				OR 
				( cast(@idDoc as varchar(100)) =  cast(@idPfu as varchar(100)) )

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
						@Destinatario_Azi = isnull(Destinatario_Azi,-1),
						@statoFunzionale = StatoFunzionale
					FROM ctl_doc with(nolock) 
					WHERE id = @idDoc

				select @idAziOwner = pfuIdAzi from profiliutente with(nolock) where idPfu = @owner
				
				--se statoFunzionale = 'InLavorazione' e se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
				if @statoFunzionale = 'InLavorazione' and @idPfu = @owner and @passed = 0
				begin
					set @passed = 1 --passato
				end 
				--se sono il destinatario del documento PASSO
				if @idPfu = @Destinatario_User and @passed = 0
				BEGIN
					set @passed = 1 --passato
				END
				
				IF @statoFunzionale <> 'InLavorazione' and @passed = 0
				BEGIN

					-- Se il tuo idpfu coincide con l'idpfu dell'utente che ha in carico il documento ctl_doc.idPfuInCharge
					if @idPfu = @pfuInCharge
					begin
						set @passed = 1 --passato
					end 

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

					--SE sei amministratore di utenti e 
					--Se la tua azienda è la stessa indicata nella colonna azienda
					IF ( exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue in ('Amministratore','AdminOE','AdminEnte','RefConvOE'  ) and idpfu=@idPfu) )
					BEGIN
						if @idAzi = @Azienda_doc and @passed = 0 
						begin
							set @passed = 1 --passato
						end 
					END
				END

				if @passed = 1
					select 1 as bP_Read , 1 as bP_Write
				else
					select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
				
				-- recupero azienda del destinatario
				--if @Destinatario_User <> -1
				--	select @Destinatario_Azi = pfuIdAzi from profiliutente with(nolock) where idPfu = @Destinatario_User
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
				
				-- verifico se l'utenet o la sua azienda è fra i destinatari
				--if 	@passed = 0
				--	if exists( select idrow from CTL_DOC_Destinatari where idHeader = @idDoc and (  IdPfu = @idPfu or IdAzi = @idAzi ) )
				--		set @passed = 1 --passato

			end
			
		END
	
	end

end









GO
