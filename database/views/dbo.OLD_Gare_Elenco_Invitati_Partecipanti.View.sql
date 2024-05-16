USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Gare_Elenco_Invitati_Partecipanti]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_Gare_Elenco_Invitati_Partecipanti] as 

	SELECT	Doc.id as idBando ,
			cast( doc.body as nvarchar(max)) as DescrizioneBando,
			Doc.Protocollo as RegistroBando,
			LEFT(CONVERT(VARCHAR, Doc.DataInvio, 120), 10) as DataPubblicazioneBando,
			dbo.GetDescTipoProcedura ( doc.Tipodoc , B.TipoProceduraCaratteristica , B.ProceduraGara )  as TipologiaGara, --DescTipoProcedura,

			case when B.Divisione_lotti = '0' then B.CIG else L.CIG end as CIG ,

			L.NumeroLotto ,
			L.Descrizione as DescrizioneCIG ,

			CASE WHEN LO.ID IS NULL THEN NULL ELSE O.id END as idOfferta , 
			CASE WHEN LO.ID IS NULL THEN NULL ELSE isnull( O.Protocollo , '' ) END as RegistroOfferta ,

			isnull( DO.Ruolo_Impresa , '' ) as RuoloPartecipante ,
			--coalesce( DO.IdAzi , CAST( O.Azienda AS INT ) , azi.idazi ) as idAzienda ,
			--isnull( DO.RagSoc , az.aziRAgioneSociale ) as RagioneSociale ,
			--isnull( DO.CodiceFiscale , rtrim(ltrim(dm.vatValore_FT )) ) as CodiceFiscale,

--			Do.idAziRiferimento as idAziendaAusiliata , 
			coalesce( case when tipologia = 'AUSILIARE_NO_RTI' then  CAST( O.Azienda AS INT ) else DO.IdAzi end  , CAST( O.Azienda AS INT ) , azi.idazi ) as idAzienda ,
			isnull(  case when tipologia = 'AUSILIARE_NO_RTI' then  az.aziRAgioneSociale else DO.RagSoc end , az.aziRAgioneSociale ) as RagioneSociale ,
			isnull(  case when tipologia = 'AUSILIARE_NO_RTI' then  rtrim(ltrim(dm.vatValore_FT )) else DO.CodiceFiscale end  , rtrim(ltrim(dm.vatValore_FT )) ) as CodiceFiscale,

			case when tipologia = 'AUSILIARE_NO_RTI' then null else Do.idAziRiferimento end as idAziendaAusiliata , 


			case when isNull( D.Value , '' ) <> '' and isnull( R.Value, '0')  = '1' then D.Value else az.aziRagioneSociale end as RagioneSocialeRTI,
                        
			azi.idazi as Azienda,

			isNull( R.Value , 0 ) as isRTI,
			
			--lo.id as idLotto
			
			--az.aziIdDscFormaSoc,
			--az.azistatoleg2
			case when isnull( LP.posizione , '' ) in ( 'Idoneo definitivo' , 'Aggiudicatario definitivo' )
				then 'S'
				else 'N' 
				end as Aggiudicatario		
			--P.id as idCtlDoc_OffertaPartecipanti,
			--O.id as idOffertaInviata ,		
			,lp.Posizione 

			, isnull(lt2.StatoRiga,'') as StatoLotto

			, LP.ValoreImportoLotto --as ImportoAggiudicato
			, isnull( l.ValoreImportoLotto , ImportoBaseAsta2 ) as BaseAsta

			, B.TipoAppaltoGara
			--FACCIAMO QUESTO CASE PER NON AGGIUNGERE NEL DOCUMENTO OCP_ISTANZIA_IMPRESE le aziende che sono solo AUSILIARIE ma non presenti in RTI
			--kpf 427121  non lo facciamo in RuoloPartecipante per non compromettere le logiche che la usano
			, case when isnull( R.Value, '0')  = '1' and  DO.tiporiferimento = 'AUSILIARIE' then 1
				   when isnull( R.Value, '0')  = '0' and  DO.tiporiferimento = 'AUSILIARIE' and tipologia = 'BASE' then 1
				   else 0
			  end as Ausiliaria
		FROM CTL_DOC Doc with(nolock) --BANDO
			inner join document_bando B with(nolock) on B.idheader = Doc.id
			inner join  document_microlotti_dettagli L with(nolock) on l.TipoDoc = Doc.TipoDoc and L.voce = 0 and l.IdHeader = doc.Id

			left join CTL_DOC Pda with(nolock) on Pda.tipodoc = 'PDA_MICROLOTTI' and Pda.deleted = 0 and Pda.LinkedDoc = Doc.id

			inner join Ctl_Doc_Destinatari azi with(nolock) on azi.idHeader = Doc.id and isnull(azi.Seleziona, 'includi') <> 'escludi' -- INVITATI / PARTECIPANTI
			inner join aziende az with(nolock) on  az.idazi = azi.idazi
			INNER JOIN Dm_Attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale'									
					
			left Join Ctl_Doc O  with(nolock) on O.TipoDoc in ( 'OFFERTA' )  and O.linkeddoc = Doc.id and O.StatoDoc = 'Sended' and O.deleted = 0 and CAST( O.Azienda AS INT ) = azi.IdAzi -- OFFERTE PRESENTATE
			left join document_microlotti_dettagli lo with(nolock) on lo.idheader = O.id and lo.TipoDoc = 'OFFERTA' and lo.numeroLotto = L.NumeroLotto and lo.Voce = 0 -- se ha partecipato al lotto

			-- lotti della PDA
			left join  document_microlotti_dettagli lt2 WITH (NOLOCK) on  lt2.IdHeader = pda.Id and lt2.NumeroLotto = L.NumeroLotto and lt2.Voce = 0 and lt2.TipoDoc = 'PDA_MICROLOTTI'

			left join CTL_DOC P with(nolock) on P.tipodoc='OFFERTA_PARTECIPANTI' and P.LinkedDoc = O.id and P.StatoFunzionale ='Pubblicato' and P.deleted = 0 
			left join CTL_DOC_VALUE R with(nolock) on R.idheader = P.id and R.DSE_ID = 'RTI' and R.DZT_Name = 'PartecipaFormaRTI' and isnull( R.Value, '0')  = '1'
			left join CTL_DOC_Value D with(nolock) on D.idheader = P.id and D.DZT_Name = 'DenominazioneATI' and D.DSE_ID in (  'TESTATA1', 'TESTATA_RTI' )

			left JOIN Document_offerta_partecipanti DO with(nolock) ON DO.idheader=P.id and DO.TipoRiferimento in (  'RTI' , 'AUSILIARIE' )

			---- verifico se è aggiudicatario
			left join Document_PDA_OFFERTE PO with(nolock)  on PO.idheader = Pda.id and PO.IdMsg = O.id
			left join Document_MicroLotti_Dettagli LP with(nolock) on LP.idheader = PO.IdRow and LP.TipoDoc = 'PDA_OFFERTE' and LP.NumeroLotto = L.NumeroLotto and LP.Voce = 0 


			---- Queste join servono a far uscire chi ha oresentato l'offerta nel caso faccia uso di ausiliarie senza essere in RTI
			left JOIN ( select idheader , min( idrow ) as Min_idrow , count(*) as N_ausiliarie from Document_offerta_partecipanti  with(nolock) where TipoRiferimento = 'AUSILIARIE'  group by idheader ) as AU ON AU.idheader=P.id 
			inner join ( SELECT 'BASE' as tipologia union all select  'AUSILIARE_NO_RTI' as tipologia ) as Tip on	tipologia = 'BASE'
																													or
																													(  tipologia = 'AUSILIARE_NO_RTI' 
																														and  isNull( R.Value , 0 ) = '0' /* no RTI - quando è presente la RTI la mandataria viene già ritornata */ 
																														and Min_idrow = DO.IdRow  -- solo una volta devo inserire il fornitore altrimenti lo ripeterei nel caso esiste più di un ausiliaria
																														)

									
		WHERE DOC.TipoDoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' )
				and
				(
					-- per le gare ad invito prendo solo gli invitati ovvero tutti quelli in Ctl_Doc_Destinatari
					( B.TipoBandoGara = '3' or Doc.TipoDoc = 'BANDO_SEMPLIFICATO' ) --  = 'INVITO' ) 
					or
					( not ( B.TipoBandoGara = '3' or Doc.TipoDoc = 'BANDO_SEMPLIFICATO' )  -- solo i partecipanti che hanno inviato offerta

						and O.Id is Not null
						and
						(
							B.VisualizzaNotifiche = 1 -- le offerte sono disponibili alla visualizzazione
					
							or
							(
								datediff( minute, B.DataAperturaOfferte,  getdate())  > 0 -- è stata superata la data apertura offerte
							
							
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
					)
				)
				and doc.StatoFunzionale <> 'InLAvorazione' 
GO
