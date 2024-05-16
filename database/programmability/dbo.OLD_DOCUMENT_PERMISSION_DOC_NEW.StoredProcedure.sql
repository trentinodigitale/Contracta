USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_DOC_NEW]    Script Date: 5/16/2024 2:38:55 PM ******/
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
--Versione=2&data=2014-28-10&Attivita=62090&Nominativo=Sabato
--Versione=3&data=2014-10-24&Attivita=64680&Nominativo=Federico
--Versione=4&data=2015-02-26&Attivita=70503&Nominativo=Enrico
CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_DOC_NEW]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON

	declare @User_Has_Profilo_Investigativo as int

	set @User_Has_Profilo_Investigativo = 0
	
	if exists (select idpfu from ProfiliUtenteAttrib with(nolock) where  dztnome = 'Profilo' and attvalue ='Profilo_Investigativo' and idPfu = @idPfu)
		set @User_Has_Profilo_Investigativo = 1

	--Recupero il tipodoc e jumpcheck
	declare @Jumpcheck_2 as varchar(100) = ''
	declare @TipoDoc_2 as varchar(200) = ''
	declare @StatoDoc_2 as varchar(100) = ''
	IF ISNUMERIC(@idDoc)=1
	begin
		select @Jumpcheck_2 = isnull(jumpcheck,''), @TipoDoc_2 = isnull(tipodoc,''), @StatoDoc_2 = StatoFunzionale 
			from CTL_DOC with(nolock) where id = @idDoc
	end

	if (( upper( substring( @idDoc, 1, 3 ) ) = 'NEW' or @idDoc = '' )  and dbo.GetPos( ISNULL( @param , '' ) , '@@@' , 1 ) = ''  -- @param is null 
		or
		exists( select idpfu from ProfiliUtenteAttrib with(nolock) where  dztnome = 'Profilo' and attvalue in ('Direttore', 'Amministratore' ) and idPfu = @idPfu ))
		and
		(	@Jumpcheck_2 not in('0-RETTIFICA_ECONOMICA_OFFERTA','0-RETTIFICA_TECNICA_OFFERTA') 
			or  @TipoDoc_2 <> 'PDA_COMUNICAZIONE_GARA' 
			--and @StatoDoc_2 <> 'Inviato'
			)
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
		

		-- CASO AMPIEZZA DI GAMMA NUOVA
		DECLARE @IdHeader int

		set @IdHeader = null

		IF  EXISTS (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%')
		and exists (select id from LIB_Dictionary with(nolock)
						where dzt_name = 'NewAmpiezzaGamma')
		and dbo.PARAMETRI('OFFERTA_AMPIEZZA','NewAmpiezzaGamma','ATTIVA','NO',-1) = 'YES'
		begin

			select @IdHeader=IdHeader from Document_MicroLotti_Dettagli x with (nolock)			
					where x.TipoDoc = 'OFFERTA_AMPIEZZA' and x.idHeaderLotto = @idDoc

			if @IdHeader is not null
			begin
				if exists (select ID from CTL_DOC with(nolock) where Id = @IdHeader and TipoDoc = 'OFFERTA')
				and ( exists(select idpfu from ProfiliUtente with(nolock) where IdPfu = @idPfu
						and SUBSTRING(pfufunzionalita,			575,1)='1') --OE con il permesso ampiezza di gamma
					OR exists( select idpfu from profiliutente with (nolock) -- azienda ente master
								inner join MarketPlace with (nolock) on mpIdAziMaster = pfuidazi
									where IdPfu = @idPfu)
					)
				begin
					select 1 as bP_Read , 1 as bP_Write
					return
				end
			end

		end

		-- Se stiamo aprendo un documento come create from
		-- non bisogna controllare il parametro idDoc che sarà NEW
		-- ma quello dopo la virgola nel parametro param  . es : AZIENDA, 123 o BANDO, 12356
		-- e poi eseguire il controllo sulla stored del documento di createFrom e non di quello
		-- di partenza
		
		--if not @param is null 
		--begin
			
			
		--	-- declare @document varchar(250)
		--	-- declare @storedPerm varchar(250)
			
		--	-- set @idDoc = cast ( substring ( @param, charindex(',', @param) + 1, len( @param ) ) as int )
		--	-- set @document = substring ( @param, , charindex(',', @param) )
			
		--	-- if exists(select top 1 * from lib_documents where doc_id = @document)
		--	-- begin
			
		--	-- 	select top 1 @storedPerm = isnull(DOC_DocPermission, '') from lib_documents where doc_id = @document
				
		--	-- 	if @storedPerm <> ''
		--	-- 	begin
		--	-- 	
		--	-- 		exec 
		--	-- 	 
		--	-- 	end
				
		--	-- end	
		--	-- else
		--	-- begin
				
		--		select 1 as bP_Read , 1 as bP_Write
				
		--	-- end
			
			
		--end
		--else
		begin
			
			-- SE IDDOC è stringa vuota e param è valorizzato siamo in un makedocfrom
			IF (@idDoc = '' or upper( substring( @idDoc, 1, 3 ) ) = 'NEW') and not @param is null 
			BEGIN
				--set @idDoc = cast ( substring ( @param, charindex(',', @param) + 1, len( @param ) ) as int )
				set @idDoc = dbo.GetPos( @param , ',' , 2 ) 

				if dbo.GetPos( @param , ',' , 1 ) = 'LOTTO' -- in questo caso stiamo creando un esito per un lotto in una PDA
				begin 
					-- recuperiamo l'id del documento risalendo dalla microlotti dettagli alla PDA
					select @idDoc = o.idheader from document_microlotti_dettagli d with(nolock)
						inner join document_pda_offerte o with(nolock) on d.idheader = o.idrow
						where d.id = @idDoc

				end 
				else
				begin
					--E.P. per gli altri makedocfrom faccio passare per adesso
					--perchè andrebbero gestiti i vari documenti che voglio craere dalle diverse sorgenti
					select 1 as bP_Read , 1 as bP_Write
					return
				end
			END

			-- per la PDA_MICROLOTTI controllo accesso sul tipo utente
			declare @TipoDoc as varchar(200)
			declare @LinkedDoc as int
			declare @Esito as varchar(100)
			declare @Errore as nvarchar(2000)
			declare @StatoDoc as varchar(100)
			declare @JumpCheck as varchar(100)
			declare @PresidenteCommissione int

			IF ISNUMERIC(@idDoc) = 1
			BEGIN

				select @StatoDoc=StatoDoc,@TipoDoc=TipoDoc,@LinkedDoc=LinkedDoc,@JumpCheck=JumpCheck from ctl_doc with(nolock) where id = @idDoc
				--select @idDoc
				--effettuo i controlli so se l'utente collegato non ha il profilo investigativo
				
				if @TipoDoc = 'PDA_MICROLOTTI' and @User_Has_Profilo_Investigativo=0
				begin
		
					--chiamo la stored per i controlli sul tipo utente
					CREATE TABLE #TempCheck(
						[Id] [varchar](200) collate DATABASE_DEFAULT NULL,
						[Errore] [varchar](200) collate DATABASE_DEFAULT NULL
					)  
				
					insert into #TempCheck select top 0 '' as id,'' as errore from aziende 
				
					--chiamo la stored di controllo specifica
					insert into #TempCheck  exec CK_PDA_MICROLOTTI_CREATE_FROM_BANDO 
																@LinkedDoc, 
																@idPfu				
				
					select @Esito=id,@Errore=Errore from #TempCheck
				
					--cancello la tabella temporanea
					drop table #TempCheck	
				end
				else
					set  @Esito='OK'
				
			END
			
			
			
			if @Esito='OK'			
			begin
				
				declare @proceduragara as varchar(50)
				declare @EvidenzaPubblica as varchar(1)

				set @proceduragara=''
				set @EvidenzaPubblica='0'

				--se sono su un bando procedura aperta posso aprire
				if @TipoDoc in ('BANDO_GARA','BANDO_SDA','BANDO_SEMPLIFICATO','BANDO_CONSULTAZIONE','BANDO_CONCORSO') 
				begin
					select top 1 @proceduragara=proceduragara,@EvidenzaPubblica=EvidenzaPubblica from document_bando with (nolock) where idheader=@idDoc
				end

				if @TipoDoc in ('BANDO') OR isnull(@EvidenzaPubblica,'0') = '1'
				begin
					
					set @proceduragara='15476'
				end
				
				if @proceduragara='15476' and @StatoDoc='Sended'
				begin
				
					select 1 as bP_Read , 1 as bP_Write
					return
				end	
				--SELEct  ISNUMERIC(@idDoc)
				--per la risposta alla COM_DPE controllo se chi sta aprendo la risposta sia chi ha fatto la comunicazione oppure un utente della stessa azienda
				--if @TipoDoc = 'COM_DPE_RISPOSTA'
				--begin
					
				--	--chi sta aprendo la risposta sia chi ha fatto la comunicazione
				--	IF EXISTS ( Select * from Document_Com_DPE where idcom=@LinkedDoc and Owner=@idPfu)
				--	begin
				--		select 1 as bP_Read , 1 as bP_Write
				--	end	
				--	else
				--	   begin

				--		  --chi sta aprendo la risposta un utente della stessa azienda di chi ha creato la COM_DPE
				--		  IF EXISTS ( Select * from profiliUtente where idpfu=@idpfu and pfuidazi=(Select pfuidazi from profiliUtente where idpfu=(Select owner from Document_Com_DPE where IdCom=@LinkedDoc) ) )
				--		  begin
				--		    select 1 as bP_Read , 1 as bP_Write
				--		  end	
				--		 -- else
				--		--	 select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100
					
				--	   end
					   
				--end

				--else
				--begin

					declare @idAzi int
					select @idAzi = pfuIdAzi  from profiliutente with(nolock) where idPfu = @idPfu

					-- Se fai parte dell'azienda dell'ente, cioè dell'azienda master
					-- e non vieni dalla parte pubblica
					if exists(SELECT * FROM MarketPlace where mpidazimaster = @idAzi) 
						and @idPfu>0
						and -- hai almeno un ruolo associato
						exists( select * from profiliutenteattrib with(nolock) where dztnome = 'UserRole' and idpfu = @idPfu )
						and ( 
								@Jumpcheck_2 not in('0-RETTIFICA_ECONOMICA_OFFERTA','0-RETTIFICA_TECNICA_OFFERTA') 
								or @TipoDoc_2 <> 'PDA_COMUNICAZIONE_GARA' 
								--and @StatoDoc_2 <> 'Inviato'
							 )
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
						declare @LettaBusta as int
						declare @passed int -- variabile di controllo
						

						set @idAziOwner = -1
						set @pfuInCharge = -1
						set @owner = -1
						set @passed = 0 -- non passato
						set @Azienda_doc = -1
						set @Destinatario_User = -1
						set @Destinatario_Azi = -1
						set @LettaBusta = 0

						-- Recupero i valori della variabili utilizzate per i test di sicurezza
						select 
							@owner = isnull(idpfu,-20) , @pfuInCharge = isnull(idpfuincharge,-100),
							@Azienda_doc = isnull(Azienda,-1),@Destinatario_User = isnull(Destinatario_User,-1),
							@Destinatario_Azi = isnull(Destinatario_Azi,-1)
						from 
							ctl_doc with(nolock) 
						where id = @idDoc
						
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
						
						--se tipodoc COMMISSIONE_PDA faccio passare se azienda dell'utente collegato è la stessa dell'azienda del bando
						if @TipoDoc='COMMISSIONE_PDA' and  @passed = 0
						begin	
							if exists ( select id from CTL_DOC with (nolock) where id = @LinkedDoc and Azienda = @idAzi )
								set @passed = 1 --passato
						end

						--Se la tua azienda è la stessa azienda dell'owner del documento 
						--Se la tua azienda è la stessa indicata nella colonna azienda
						if @idAzi in (  @idAziOwner , @Azienda_doc  ) and @passed = 0
						begin
							
							--per i tipi doc di seguito controllo che l'utente collegato ha il permesso di ACCESSO_DOC_OE
							if @TipoDoc = 'OFFERTA' or @tipodoc like 'ISTANZA_%'
							begin
								 if exists (select * from ProfiliUtenteAttrib with(nolock) where  idpfu = @idPfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE')
									set @passed = 1 --passato
							end
							else	
								print 2
								set @passed = 1 --passato
						end 			
						
						----Se la tua azienda è la stessa indicata nella colonna azienda
						--if @idAzi = @Azienda_doc and @passed = 0
						--begin
						--	--per i tipi doc di seguito controllo che l'utente collegato ha il permesso di ACCESSO_DOC_OE
						--	if @TipoDoc in ( 'OFFERTA','ISTANZA_Albo_ME_2','ISTANZA_AlboFornitori','ISTANZA_AlboOperaEco','ISTANZA_SDA_FARMACI','ISTANZA_AlboProf' )
						--	begin
						--		 if exists (select * from ProfiliUtenteAttrib where  idpfu = @idPfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE')
						--			set @passed = 1 --passato
						--	end
						--	else	
						--		set @passed = 1 --passato
						--end 
						
						--Se la tua azienda è la stessa del destinatario
						if @idAzi = @Destinatario_Azi and @passed = 0
						begin
							set @passed = 1 --passato
						end 

						-- verifico se l'utenet o la sua azienda è fra i destinatari
						if 	@passed = 0
							if exists( select idrow from CTL_DOC_Destinatari with(nolock) where idHeader = @idDoc and (  IdPfu = @idPfu or IdAzi = @idAzi ) )
								set @passed = 1 --passato


						--verifico se l'utente è tra i partecipanti 
						--aggiunto che ha ilpermesso di ACCESSO_DOC_OE
						if exists(
							select P.idpfu,idazi from ctl_doc C1 with(nolock) inner join document_offerta_partecipanti DO with(nolock)
								inner join profiliutente P with(nolock) on P.pfuidazi=DO.idazi
								inner join ProfiliUtenteAttrib PA with(nolock) on PA.idpfu= P.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
								on DO.idheader=c1.id and TipoRiferimento in ('RTI','ESECUTRICI')
								where linkeddoc=@idDoc	and P.idpfu=@idPfu			)
						begin
							set @passed = 1 --passato
						end 

						--verifico se l'utente è tra i referenti tecnici del documento						
						if exists(
							    	select idheader 
										from Document_Bando_Riferimenti DR with(nolock) 
											inner join profiliutente P with(nolock) on P.idpfu=DR.idpfu
										where idHeader=@idDoc and RuoloRiferimenti='ReferenteTecnico' and P.idpfu=@idPfu		
							    	)
						begin
							set @passed = 1 --passato
						end 






						if 	@passed = 0
						begin
							if @TipoDoc in ('CONFORMITA_MICROLOTTI_OFF')  
							begin
						
								-- se l'utente è il soggetto della verifica conformità passa
								declare @IdPDA as int
								declare @IdPfuPadre as int

								select @IdPDA=c1.linkeddoc,@IdPfuPadre=c1.idpfu
									from ctl_doc C with(nolock)
										inner join document_microlotti_dettagli D with(nolock) on C.linkeddoc=D.id 
											inner join ctl_doc C1 with(nolock) on C1.id=D.idheader
									where C.id=@idDoc 

								if exists(select idrow from ctl_doc_value with(nolock) where idheader=@IdPDA and dse_id='COMMISSIONE_GIUDICATRICE_D' and DZT_Name='NominativoCommissioneGiudicatrice' and value=cast(@idPfu as varchar(100)))
									set @passed = 1 --passato
								
								--se l'utente è chi ha creato il documento padre di CONFORMITA_MICROLOTTI_OFF
								if @IdPfuPadre=@idPfu
									set @passed = 1 --passato
							end
						end

						--per le istanze tutti gli utenti che appartengono all'ente possono aprirle
						if @TipoDoc like 'Istanza%' 
						BEGIN
							if exists (select idpfu from ProfiliUtente with(nolock) where pfuVenditore<>1 and IdPfu=@idPfu)
								set @passed = 1 
						END

						--Vedo se sono utente dell'azienda presente sul documento oppure su uno dei linkeddoc a risalire						
						if @passed = 0
							set  @passed  = dbo.verifica_apertura_doc_linkeddoc(@idDoc,@idPfu)
						

	   
					   if @TipoDoc = 'COM_DPE_RISPOSTA' and @passed = 0
					   begin
					
						  --chi sta aprendo la risposta sia chi ha fatto la comunicazione
						  IF EXISTS ( Select IdCom from Document_Com_DPE with(nolock) where idcom=@LinkedDoc and Owner=@idPfu)
						  begin
							 --select 1 as bP_Read , 1 as bP_Write
							 set  @passed = 1
						  end	
						  else
						  begin

							 --chi sta aprendo la risposta un utente della stessa azienda di chi ha creato la COM_DPE
							 IF EXISTS ( Select idpfu from profiliUtente with(nolock) where idpfu=@idpfu and pfuidazi=(Select pfuidazi from profiliUtente where idpfu=(Select owner from Document_Com_DPE where IdCom=@LinkedDoc) ) )
							 begin
								    --select 1 as bP_Read , 1 as bP_Write
								    set  @passed = 1
							 end	
							 
						  end
					   
					   end


					   -- verifichiamo per l'offerta se l'utente è stato abilitato all'AQ 
					   if  @passed = 0 and @Tipodoc = 'OFFERTA'
					   begin
							IF EXISTS (  select AB.id 
											from CTL_DOC OFFERTA with(nolock) 
												inner join CTL_DOC AB with(nolock) on AB.LinkedDoc=OFFERTA.LinkedDoc and AB.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and AB.StatoFunzionale='Confermato'
											where OFFERTA.Id=@IdDoc and AB.IdPfu=@idPfu
										)
							BEGIN
								set @passed=1
							END

					   end

					   --Se Passed = 1 e tipodoc = 'PDA_COMUNICAZIONE GARA'
					   --Vado a controllare se l'utente può accedere andando a verificare 
					   --che la busta sia stata aperta (almeno una busta nel caso dei lotti) relativamente se si tratta
					   --di rettifica tecnica o economica
					   if @passed = 1 and @TipoDoc = 'PDA_COMUNICAZIONE_GARA' and @StatoDoc_2 = 'Inviato'
					   begin
							if @JumpCheck in ('0-RETTIFICA_ECONOMICA_OFFERTA','0-RETTIFICA_TECNICA_OFFERTA')
							begin
								-- Controllo se non esiste un flag di Apertura rettifica da parte del RUP
								if not exists(select
												idrow
												from
													CTL_DOC_VALUE with(nolock)
												where idheader = @idDoc and DZT_Name = 'ApertaRettificaPresidente' and [Value] = 1)
								-- Nel caso in cui non fosse presente il flag e SONO il presidente della commissione tecnica/economica lo inserisco
								begin

									-- Recupero a seconda del tipo di rettifica il Presidente Tecnico o Economico
									if @JumpCheck = '0-RETTIFICA_ECONOMICA_OFFERTA'
									begin
										select
											@PresidenteCommissione = CommEco.UtenteCommissione
											from
												--Rettifica
												CTL_DOC RET with(nolock)
												--Salgo sull'offerta
												left join CTL_DOC offer with(nolock) on offer.id = RET.linkeddoc
												--Accedo al doc della commissione
												left join CTL_DOC Commissione with (nolock) on offer.linkedDoc = Commissione.linkedDoc and Commissione.tipodoc = 'COMMISSIONE_PDA' and Commissione.StatoFunzionale = 'Pubblicato'
												--IdPfu Presidente Commissione Economica
												left join Document_CommissionePda_Utenti CommEco with(nolock) on Commissione.id = CommEco.IdHeader and CommEco.RuoloCommissione = 15548 and CommEco.TipoCommissione = 'C'
											where RET.id = @idDoc

											
										--Controllo se la busta è stata aperta Busta Eco
										if exists(select top 1
														id
														from 
															PDA_LST_BUSTE_ECO_OFFERTE_VIEW with (nolock)
														where bReadDocumentazione = 0
															and	idmsgfornitore = @LinkedDoc)
										begin
											set @LettaBusta = 1
										end
									end
									else
									begin
										select
											@PresidenteCommissione = CommTec.UtenteCommissione
											from
												--Rettifica
												CTL_DOC RET with(nolock)
												--Salgo sull'offerta
												left join CTL_DOC offer with(nolock) on offer.id = RET.linkeddoc
												--Accedo al doc della commissione
												left join CTL_DOC Commissione with (nolock) on offer.linkedDoc = Commissione.linkedDoc and Commissione.tipodoc = 'COMMISSIONE_PDA' and Commissione.StatoFunzionale = 'Pubblicato'
												--IdPfu Presidente Commissione Tecnica
												left join Document_CommissionePda_Utenti CommTec with(nolock) on Commissione.id = CommTec.IdHeader and CommTec.RuoloCommissione = 15548 and CommTec.TipoCommissione = 'G'
											where RET.id = @idDoc

										-- Controllo se la busta è stata aperta Busta Tec
										if exists(select top 1
														id
														from 
															PDA_LST_BUSTE_TEC_OFFERTE_VIEW with (nolock)
														where bReadDocumentazione = 0
															and	idmsgfornitore = @LinkedDoc)
										begin
											set @LettaBusta = 1
										end
									end

									--Se il Presidente corrisponde all'utente collegato allora significa che il Presidente ha preso visione della rettifica e quindi sblocco l'accesso per tutti gli utenti
									if @PresidenteCommissione = @IdPfu and @LettaBusta = 1
									begin
										insert into CTL_DOC_VALUE([IdHeader],[DZT_Name],[Value])
										select
											@idDoc, 'ApertaRettificaPresidente', 1
									end

									--Controllo se è presente il flag per il record corrente e quindi consentire l'accesso al documento
									--oppure se l'utente è un Operatore Economico lascio passare
									if	(not exists(select
												idrow
												from
													CTL_DOC_VALUE with(nolock)
												where idheader = @idDoc and DZT_Name = 'ApertaRettificaPresidente' and [Value] = 1)
										and
										not exists (select P.idpfu
														from 
															ProfiliUtente P with(nolock)
														inner join Aziende A with(nolock) on P.pfuidazi = A.idazi
														where IdPfu = @IdPfu
															and A.AziVenditore <> 0)
										)
									begin
										set @passed = 0
									end
	
								end
							end
						end

						-- Verifico se l'utente stà aprendo la scheda della sua azienda
						if @passed = 1
							select 1 as bP_Read , 1 as bP_Write
						else
							select 0 as bP_Read , 0 as bP_Write from profiliutente with(nolock) where idpfu = -100
						
					--end

					   

				end
			end
			else
			begin
				select 0 as bP_Read , 0 as bP_Write from profiliutente with(nolock) where idpfu = -100
			end	
		end
	
	end

end






















GO
