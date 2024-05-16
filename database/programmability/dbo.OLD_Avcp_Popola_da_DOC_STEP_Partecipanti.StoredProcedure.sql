USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Avcp_Popola_da_DOC_STEP_Partecipanti]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[OLD_Avcp_Popola_da_DOC_STEP_Partecipanti] 
( 
	@idRow int , @NewDoc int
)
AS
BEGIN

	declare @idX int

	declare @Versione int
	declare @PrevDoc int
	declare @Fascicolo varchar(500)
	declare @idNewOE  int 
	declare @RagioneSociale nvarchar(max)
	declare @Aggiudicatario varchar(10)
	declare @MinDate datetime

	set @MinDate = '1900-01-01'

	select @Versione = Versione , @Fascicolo = Fascicolo from ctl_doc with(nolock) where id = @NewDoc

	--------------------------------------------------
	-- recuperiamo i partecipanti alle gare / lotti--
	--------------------------------------------------
	--if exists (
 --       select  * from tempdb.dbo.sysobjects o
 --               where o.xtype in ('U') and o.id = object_id(N'tempdb..#partecipanti_avcp')
	--)
	--begin
 --       DROP TABLE #partecipanti_avcp
	--end

	CREATE TABLE #partecipanti_avcp 
	(
		[Idrow] [int] IDENTITY(1,1) NOT NULL,

        idPfu [INT] NULL,
        idHeader [INT] NULL,
        RuoloPartecipante [varchar](100) collate DATABASE_DEFAULT NULL,
        Estero [varchar](1) collate DATABASE_DEFAULT NULL,
        CodiceFiscale [varchar](50) collate DATABASE_DEFAULT NULL,
        RagioneSociale [nvarchar](1500) collate DATABASE_DEFAULT NULL,
        Aggiudicatario [varchar](1) collate DATABASE_DEFAULT NULL,
		-----
        Azienda [INT] NULL,
        idCtlDoc_OffertaPartecipanti [INT] NULL, 
		idOffertaInviata [INT] NULL, --Id dell'offerta inviata. mi serve per recuperare i gruppi nel ciclo di inserimento documenti
		--------
		isRTI int null ,

		----------
		LastUpdate datetime null
	)


	--------------------------------------------------
	-- recuperiamo i partecipanti alle gare / lotti--
	--------------------------------------------------
	INSERT INTO #partecipanti_avcp 
		(
				--[Idrow] [int] IDENTITY(1,1) NOT NULL,
				idHeader ,
				idPfu ,
				RuoloPartecipante,
				Estero ,
				CodiceFiscale,
				RagioneSociale,
				Aggiudicatario ,
				Azienda,
				idCtlDoc_OffertaPartecipanti,
				idOffertaInviata,

				isRTI,
				LastUpdate
		)
			SELECT
				
					L.Idrow ,
                    azi.idPfu ,
                    --@idBando as idHeader,
                    NULL as RuoloPartecipante,

                    CASE WHEN (upper(az.aziStatoLeg) = 'ITALIA' OR upper(az.aziStatoLeg) = 'ITALY') THEN '0'
                                ELSE '1'
                    END AS Estero,

                    rtrim(ltrim(dm.vatValore_FT )) as CodiceFiscale,

                    case when isNull( D.Value , '' ) <> '' and isnull( R.Value, '0')  = '1' then D.Value else az.aziRagioneSociale end as RagioneSociale,
                        
					case when LP.id is  not null
						then '1'
						else '0' 
						end as Aggiudicatario,

                    azi.idazi as Azienda,
                    P.id as idCtlDoc_OffertaPartecipanti,
					O.id as idOffertaInviata ,

					isNull( R.Value , 0 ) as isRTI ,

					isnull ( 
						case when 						
									case when isnull( Doc.Datainvio, @MinDate )  > isnull( azi.DataIscrizione , @MinDate)  then Doc.Datainvio else azi.DataIscrizione end
									>
									case when  isnull( O.DataInvio , @MinDate )  > isnull( P.DataInvio , @MinDate ) then O.DataInvio  else  P.DataInvio end
							then
								case when isnull( Doc.Datainvio , @MinDate ) > isnull( azi.DataIscrizione , @MinDate ) then Doc.Datainvio else azi.DataIscrizione end
							else
								case when isnull(  O.DataInvio , @MinDate ) > isnull( P.DataInvio , @MinDate ) then O.DataInvio  else  P.DataInvio end
							end , @MinDate ) as LastUpdate

				FROM [document_AVCP_lotti] L
					
					--inner join document_bando B with(nolock) on B.idheader = L.idBando
					--inner join CTL_DOC Doc with(nolock) on Doc.id = L.idBando   --BANDO

					--left join CTL_DOC Pda with(nolock) on Pda.tipodoc = 'PDA_MICROLOTTI' and Pda.deleted = 0 and Pda.LinkedDoc = Doc.id

					--inner join Ctl_Doc_Destinatari azi with(nolock) on azi.idHeader = L.idBando and isnull(azi.Seleziona, 'includi') <> 'escludi' -- INVITATI / PARTECIPANTI
					--inner join aziende az with(nolock) on  az.idazi = azi.idazi
					--INNER JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'									

						
					--left Join Ctl_Doc O  with(nolock) on O.TipoDoc in ( 'OFFERTA' )  and O.linkeddoc = L.idBando and O.StatoDoc = 'Sended' and O.deleted = 0 and O.Azienda = azi.IdAzi -- OFFERTE PRESENTATE
					--left join document_microlotti_dettagli lo with(nolock) on lo.idheader = O.id and lo.TipoDoc = 'OFFERTA' and lo.numeroLotto = L.NumeroLotto and lo.Voce = 0 -- se ha partecipato al lotto

					--left join CTL_DOC P with(nolock) on P.tipodoc='OFFERTA_PARTECIPANTI' and P.LinkedDoc =O.id and P.StatoFunzionale ='Pubblicato' and P.deleted = 0 
					--left join CTL_DOC_VALUE R with(nolock) on R.idheader = P.id and R.DSE_ID = 'RTI' and R.DZT_Name = 'PartecipaFormaRTI' and isnull( R.Value, '0')  = '1'
					--left join CTL_DOC_Value D with(nolock) on D.idheader = P.id and D.DZT_Name = 'DenominazioneATI' and D.DSE_ID in (  'TESTATA1', 'TESTATA_RTI' )

					-- verifico se è aggiudicatario
					--left join Document_PDA_OFFERTE PO with(nolock)  on PO.idheader = Pda.id and PO.IdMsg = O.id
					--left join Document_MicroLotti_Dettagli LP with(nolock) on LP.idheader = PO.IdRow and LP.TipoDoc = 'PDA_OFFERTE' and LP.NumeroLotto = L.NumeroLotto and LP.Voce = 0 and LP.posizione in ( 'Idoneo definitivo' , 'Aggiudicatario definitivo' )





					inner join document_bando B with(nolock,index([ICX_Document_Bando_IdHeader]) ) on B.idheader = L.idBando
					inner join CTL_DOC Doc with(nolock,index( [ICX_CTL_DOC_id])) on Doc.id = L.idBando   --BANDO

					left join CTL_DOC Pda with(nolock,index([ICX_CTL_DOC_LinkedDoc_Azienda_TipoDoc_StatoFunzionale_Deleted])) on Pda.tipodoc = 'PDA_MICROLOTTI' and Pda.deleted = 0 and Pda.LinkedDoc = Doc.id and pda.azienda = doc.azienda

					inner join Ctl_Doc_Destinatari azi with(nolock,index([IX_CTL_DOC_Destinatari_idHeader_Seleziona])) on azi.idHeader = L.idBando   and isnull(azi.Seleziona, 'includi') <> 'escludi' -- INVITATI / PARTECIPANTI
					inner join aziende az with(nolock,index([IX_Aziende_IdAzi])) on  az.idazi = azi.idazi
					INNER JOIN Dm_Attributi dm with(nolock,index([IX_DM_ATTRIBUTI_lnk_dztNome_vatValore_FV_vatIDzt])) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'									

						
					left Join Ctl_Doc O  with(nolock,index([ICX_CTL_DOC_LinkedDoc_Azienda_TipoDoc_StatoFunzionale_Deleted])) on O.TipoDoc in ( 'OFFERTA' )  and O.linkeddoc = L.idBando and O.StatoDoc = 'Sended' and O.deleted = 0 and O.Azienda = azi.IdAzi -- OFFERTE PRESENTATE
					left join document_microlotti_dettagli lo with(nolock,index([icx_Document_MicroLotti_Dettagli_idHeaderTipoDoc])) on lo.idheader = O.id and lo.TipoDoc = 'OFFERTA' and lo.numeroLotto = L.NumeroLotto and lo.Voce = 0 -- se ha partecipato al lotto

					left join CTL_DOC P with(nolock,index([ICX_CTL_DOC_LinkedDoc_Azienda_TipoDoc_StatoFunzionale_Deleted])) on P.tipodoc='OFFERTA_PARTECIPANTI' and P.LinkedDoc =O.id and P.StatoFunzionale ='Pubblicato' and P.deleted = 0 
					left join CTL_DOC_VALUE R with(nolock,index([ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name])) on R.idheader = P.id and R.DSE_ID = 'RTI' and R.DZT_Name = 'PartecipaFormaRTI' and isnull( R.Value, '0')  = '1'
					left join CTL_DOC_Value D with(nolock,index([ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name])) on D.idheader = P.id and D.DZT_Name = 'DenominazioneATI' and D.DSE_ID in (  'TESTATA1', 'TESTATA_RTI' )

					-- verifico se è aggiudicatario
					left join Document_PDA_OFFERTE PO with(nolock,index([IX_Document_PDA_OFFERTE_IdHeader_TipoDoc]))  on PO.idheader = Pda.id and PO.IdMsg = O.id
					left join Document_MicroLotti_Dettagli LP with(nolock,index([icx_Document_MicroLotti_Dettagli_idHeaderTipoDoc])) on LP.idheader = PO.IdRow and LP.TipoDoc = 'PDA_OFFERTE' and LP.NumeroLotto = L.NumeroLotto and LP.Voce = 0 and LP.posizione in ( 'Idoneo definitivo' , 'Aggiudicatario definitivo' )

									
				WHERE 
					L.idRow = @idRow
					and
					(
						-- gare ad invito prendo solo gli invitati ovvero tutti quelli in Ctl_Doc_Destinatari
						( B.TipoBandoGara = '3' or Doc.TipoDoc = 'BANDO_SEMPLIFICATO' ) --  = 'INVITO' ) 
						or
						( not ( B.TipoBandoGara = '3' or Doc.TipoDoc = 'BANDO_SEMPLIFICATO' )  -- solo i partecipanti che hanno inviato offerta

							and O.Id is Not null
							and datediff( minute, B.DataAperturaOfferte,  getdate())  > 0 -- è stata superata la data apertura offerte
							
							
							and 
							(
								(
									PDA.StatoFunzionale in ( '' ,  'VERIFICA_AMMINISTRATIVA' )  -- se la gara è prima di aprire le buste e verificare a quali lotti si è partecipato
																								-- ogni fornitore ha partecipato a tutti i lotti
								)
								or
								(
									PDA.StatoFunzionale not in ( '' ,  'VERIFICA_AMMINISTRATIVA' )  
									and lo.Id is Not null  -- se la gara ha superato la verifica mministrativa si associano solo i lotti a cui si è partecipato
								)
							)
						)
					)

	



		

	-----------------------------------------------------
	-- CONFRONTIAMO I PARTECIPANTI CON QUELLI PRESENTI
	-----------------------------------------------------



	-----------------------------------------------------
	-- eventuali partecipanti assenti nel nuovo popolamento che erano stati inseriti in prededenza dalle gare li rimuovo , se messi da un utente li lascio
	select D.id into #Annullati
		from CtL_DOC D -- documento precedente
			left join CTL_DOC_Value RS with(nolock) on RS.idheader = D.id and RS.DZT_Name = 'RagioneSociale' and RS.DSE_ID = 'TESTATA' and D.TipoDoc = 'AVCP_GRUPPO' -- Ragione Sociale del precedente OE
			left join Document_avcp_partecipanti N with(nolock) on N.idheader = D.id and D.TipoDoc = 'AVCP_OE' 
			left join #partecipanti_avcp P on   ( D.TipoDoc = 'AVCP_OE' and  P.CodiceFiscale = N.Codicefiscale) or ( D.TipoDoc = 'AVCP_GRUPPO' and  P.RagioneSociale = RS.Value ) 
			where D.LinkedDoc = @Versione and D.idpfu = -20 and D.StatoFunzionale = 'Pubblicato' and D.TipoDoc in ('AVCP_OE','AVCP_GRUPPO') 
					and P.Idrow is null  -- manca nell'elenco dei partecipanti

	update D set statofunzionale = 'Annullato' , deleted = 1 from CTL_DOC D where id in ( select id from #Annullati  ) 
				


	
	-----------------------------------------------------
	-- rimuovo eventuali partecipanti la cui data di creazione è inferiore rispetto a quella calcolata perchè li reinserisco
	select D.id as PrevDoc  , P.idRow into #Variati
		from CtL_DOC D -- documento precedente
			left join CTL_DOC_Value RS with(nolock) on RS.idheader = D.id and RS.DZT_Name = 'RagioneSociale' and RS.DSE_ID = 'TESTATA' and D.TipoDoc = 'AVCP_GRUPPO' -- Ragione Sociale del precedente OE
			left join Document_avcp_partecipanti N with(nolock) on N.idheader = D.id and D.TipoDoc = 'AVCP_OE' 
			left join #partecipanti_avcp P on   ( D.TipoDoc = 'AVCP_OE' and  P.CodiceFiscale = N.Codicefiscale) or ( D.TipoDoc = 'AVCP_GRUPPO' and  P.RagioneSociale = RS.Value ) 
			where D.LinkedDoc = @Versione and  D.StatoFunzionale = 'Pubblicato' and D.TipoDoc in ('AVCP_OE','AVCP_GRUPPO') 
					and 
					(
						D.data < P.LastUpdate -- la data creazione è minore rispetto a quella attuale
						or
						P.Aggiudicatario <> N.aggiudicatario -- è cambiata la situazione di aggiudicazione ( questa dovrebbe evolvere per essere gestita con la data
					)

	update D set	statofunzionale = 'Variato' , deleted = 1 from ctl_doc D where id in ( select PrevDoc from #Variati )




	-----------------------------------------------------
	-- tolgo dal popolamento quei partecipanti già presenti per non reinserirli 
	select P.Idrow into #Del
		from CtL_DOC D -- documento precedente
			left join CTL_DOC_Value RS with(nolock) on RS.idheader = D.id and RS.DZT_Name = 'RagioneSociale' and RS.DSE_ID = 'TESTATA' and D.TipoDoc = 'AVCP_GRUPPO' -- Ragione Sociale del precedente OE
			left join Document_avcp_partecipanti N with(nolock) on N.idheader = D.id and D.TipoDoc = 'AVCP_OE' 
			inner join #partecipanti_avcp P on   ( D.TipoDoc = 'AVCP_OE' and  P.CodiceFiscale = N.Codicefiscale) or ( D.TipoDoc = 'AVCP_GRUPPO' and  P.RagioneSociale = RS.Value ) 
			where D.LinkedDoc = @Versione  and  D.StatoFunzionale = 'Pubblicato' and D.TipoDoc in ('AVCP_OE','AVCP_GRUPPO') 
					and D.data > P.LastUpdate -- la data creazione è minore rispetto a quella attuale

	delete from #partecipanti_avcp where idrow in ( select idrow from #Del ) 



	-----------------------------------------------------
	-- tolgo dal popolamento quei partecipanti che sono poresenti più volte perchè hanno fatto più offerte semmai su lotti differenti
	while exists( select * from #partecipanti_avcp where isRTI = 0 group by CodiceFiscale having count(*) > 1 )
	begin
	
		delete from  #partecipanti_avcp  where idrow in ( select min(idrow) from #partecipanti_avcp where isRTI = 0 group by CodiceFiscale having count(*) > 1 )

	end



	-----------------------------------------------------
	-- CICLIAMO SUI PARTECIPANTI DA INSERIRE
	-----------------------------------------------------
	DECLARE curs_STEP_Partecipanti  CURSOR STATIC FOR     
			select P.idrow ,V.PrevDoc , p.RagioneSociale , p.Aggiudicatario
				from #partecipanti_avcp P
					left join #Variati V on V.Idrow = P.Idrow
				
				order by idrow

	OPEN curs_STEP_Partecipanti 

	FETCH NEXT FROM curs_STEP_Partecipanti INTO @idX , @PrevDoc , @RagioneSociale , @Aggiudicatario
	
	WHILE @@FETCH_STATUS = 0   
	BEGIN  
								



		-- creo il documento del partecipante
		INSERT INTO ctl_doc 
			(
					tipodoc,
					statoFunzionale,
					deleted,
					JumpCheck,
					data,
					PrevDoc,
					Fascicolo,
					LinkedDoc,
					Note,
					idpfu,
					Azienda
			)
			SELECT
					CASE when isRTI = 0  then 'AVCP_OE'
								else 'AVCP_GRUPPO'
					END  as tipodoc,
					'Pubblicato',
					0,
					'',
					GETDATE() as data,
					@PrevDoc as prevdoc,
					@fascicolo as Fascicolo,
					@versione as LinkedDoc, -- versione del documento lotto
					'' as note,
					-20 as idpfu,
					Azienda
				FROM #partecipanti_avcp 
				WHERE idrow  = @idx
		
		SET @idNewOE = Scope_identity()



		-- caricamento dei partecipanti al gruppo
		if exists( select idrow from #partecipanti_avcp where isRTI <> 0 and Idrow = @idX )
		begin

			-- inserisco nella ctl_doc_value i dati relativi alla denominazione ( RagioneSociale ) e il Tipo del gruppo
			INSERT INTO ctl_doc_value (IdHeader, dse_id, Row, dzt_Name, value)
							VALUES  (@idNewOE, 'TESTATA',0,'RagioneSociale',@RagioneSociale)

			INSERT INTO ctl_doc_value (IdHeader, dse_id, Row, dzt_Name, value)
							VALUES  (@idNewOE, 'TESTATA',0,'aziIdDscFormaSoc','845326')

			INSERT INTO ctl_doc_value (IdHeader, dse_id, Row, dzt_Name, value)
							VALUES  (@idNewOE, 'TESTATA',0,'Aggiudicatario', @Aggiudicatario)

			-- CREO I MEMBRI DEL GRUPPO
			INSERT INTO Document_avcp_partecipanti
					(
					IdHeader,
					RuoloPartecipante,
					Estero,
					CodiceFiscale,
					RagioneSociale,
					Aggiudicatario
					)
				SELECT	--inserisco N record
							@idNewOE as idHeader,

							dbo.getRuoloGruppo_Avcp(
								
								case when isnull( DO.Ruolo_Impresa , '' ) = '' 
									then case when  ROW_NUMBER() over( order by do.IdRow )  = 1 then 'Mandataria' else 'Mandante' end
									else DO.Ruolo_Impresa 
								end 
								) as RuoloPartecipante,

							CASE WHEN (upper(isnull( A.aziStatoLeg, 'ITALIA' ) ) = 'ITALIA' OR upper(isnull( aziStatoLeg, '' ) ) = 'ITALY') THEN '0'
								ELSE '1'
							END AS Estero,							
							
							isnull( CF.vatValore_FT , DO.CodiceFiscale ) as CodiceFiscale,
							isnull( A.aziRagioneSociale , DO.RagSoc ) as RagioneSociale,
							Aggiudicatario as Aggiudicatario

							
					FROM ctl_doc D with(nolock)
						INNER JOIN Document_offerta_partecipanti DO with(nolock) ON DO.idheader=D.id and DO.TipoRiferimento = 'RTI' -- Prendo solo le RTI, in futuro capire cosa fare con TipoRiferimento = 'ESECUTRICI'
						INNER JOIN #partecipanti_avcp P ON p.IDROW = @idX

						-- dal Cerco di risalire all'azienda dal CF - a causa che non sempre ho trovato l'idazi valorizzato
						left join DM_Attributi DA with(nolock) on  DA.idApp = 1 and DA.vatValore_FT = DO.CodiceFiscale and DA.dztNome = 'CodiceFiscale' and isnull( DO.IdAzi , 0 ) = 0 
						left join aziende A with(nolock) on A.idazi = DA.lnk or A.idazi = DO.IdAzi

						left join DM_Attributi CF  with(nolock) on  CF.idApp = 1 and CF.dztNome = 'CodiceFiscale' and a.idazi = CF.lnk

					WHERE D.id = P.idCtlDoc_OffertaPartecipanti
					order by DO.IdRow

		end
		else
		begin  -- OE singolo

			INSERT INTO Document_avcp_partecipanti
					(
						IdHeader,
						RuoloPartecipante,
						Estero,
						CodiceFiscale,
						RagioneSociale,
						Aggiudicatario
					)
				SELECT
						@idNewOE as idHeader,
						P.RuoloPartecipante,
						P.estero,
						P.CodiceFiscale,
						P.RagioneSociale ,   ----left(@Denom,80),
						P.Aggiudicatario
					FROM #partecipanti_avcp P
					WHERE Idrow  = @idx
		end


		

		-- EFFETTUO eventuali differenze con il precedente


		FETCH NEXT FROM curs_STEP_Partecipanti INTO @idx , @PrevDoc , @RagioneSociale , @Aggiudicatario

	END  


	CLOSE curs_STEP_Partecipanti   
	DEALLOCATE curs_STEP_Partecipanti


	-- VERIFICHIAMO SE ABBIAMO FATTO OPERAZIONI SUI PARTECIPANTI
	if	exists ( select * from #Annullati ) 
		OR 
		exists ( select * from #Variati )
		OR 
		EXISTS( select * from #partecipanti_avcp )
	BEGIN
		-- nel caso il lotto non ha subito modifiche -- GLI CAMBIAMO LO STATO
		if exists( select idrow from document_AVCP_lotti with(nolock) where Note = 'Non ha subito modifiche' AND idrow = @idrow )
			update [document_AVCP_lotti] set Note = 'Aggiornata rispetto alla versione precedente' where idrow = @idrow

	END


	--- controlli formali sul lotto CARICATO
	--EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @NewDoc


end
GO
