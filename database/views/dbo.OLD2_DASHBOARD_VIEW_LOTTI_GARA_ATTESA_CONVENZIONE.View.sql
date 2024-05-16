USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_LOTTI_GARA_ATTESA_CONVENZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_LOTTI_GARA_ATTESA_CONVENZIONE] AS
	--Versione=1&data=2021-08-05&Attvita=387395&Nominativo=Enrico


	select 

		 D.id as ID, --min tolto

		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		C.id as GridViewer_ID_DOC,

		C.idpfu as idpfu , --min tolto

		isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
		,isnull(lotti.CIG, db.cig) as CIG,
		lotti.NumeroLotto
		,ISNULL(TipoSceltaContraente,'') as TipoSceltaContraente
		,lotti.StatoRiga
	from ctl_doc C   with(nolock)
			inner join ( 
						select min( id ) as id , idheader  , IdaziAggiudicataria , NumeroLotto
							from 
								Document_comunicazione_StatoLotti  with(nolock) 
							where  Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto 
						) as D  on C.id=D.idheader 

			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI' and c1.Deleted = 0
			inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = 'PDA_MICROLOTTI' and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0 
						and lotti.StatoRiga in ('AggiudicazioneDef', 'AggiudicazioneCond')
			--AGGIUNTA PER PRENDERE SOLO GLI IDONEI NEL GIRO MULTIFORNITORE, VA BENE ANCHE PER MONOFORNITORE
			inner join Document_PDA_OFFERTE PDA_OFF with(nolock)  on PDA_OFF.idheader=C1.id
			inner join Document_MicroLotti_Dettagli DMO with(nolock) on PDA_OFF.IdRow=DMO.IdHeader and DMO.TipoDoc='PDA_OFFERTE' 
																		--and DMO.Posizione in ('Idoneo Definitivo','Aggiudicatario Definitivo','Idoneo definitivo condizionato') 
																		and  ( DMO.Posizione like 'Idoneo%' or DMO.Posizione like 'Aggiudicatario%')
																		and DMO.numerolotto=D.numerolotto and DMO.voce=0 and PDA_OFF.idAziPartecipante=D.IdAziAggiudicataria
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc IN ( 'BANDO_GARA','BANDO_SEMPLIFICATO')
			
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader 
						
			left join
				(
			
				/*select 
					CONV.id as IdConvenzione, lottiC.id as IdLottoConvenzione, DETT_CONV.AZI_Dest,lottic.cig
					from 
						ctl_doc CONV with(nolock)
							inner join Document_Convenzione DETT_CONV  with(nolock) on DETT_CONV.ID=CONV.id
							left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = CONV.id and lottic.TipoDoc = CONV.tipodoc and isnull(lottiC.Voce,0) = 0
					where 
						CONV.tipodoc='CONVENZIONE'  and CONV.Deleted = 0  --and  CONV.statofunzionale in ('InLavorazione','Pubblicato') 
					
				) CONVENZIONE on CONVENZIONE.AZI_Dest=D.IdAziAggiudicataria 
					and ( ( isnull(CONVENZIONE.CIG,'') = lotti.cig and Divisione_lotti <> '0') or Divisione_lotti = '0' )
				*/
				select 
					distinct  CONV.id as IdConvenzione, DETT_CONV.AZI_Dest,lottic.cig
					from 
						ctl_doc CONV with(nolock)
							inner join Document_Convenzione DETT_CONV  with(nolock) on DETT_CONV.ID=CONV.id
							left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = CONV.id and lottic.TipoDoc = CONV.tipodoc
					where 
						CONV.tipodoc='CONVENZIONE'  and CONV.Deleted = 0  
					
				) CONVENZIONE on CONVENZIONE.AZI_Dest=D.IdAziAggiudicataria 
							and (  ( isnull(CONVENZIONE.CIG,'') = lotti.cig and Divisione_lotti <> '0')
									 or 
								   ( Divisione_lotti = '0' and isnull(CONVENZIONE.CIG,'') = db.cig )
								 )
	

	where C.tipodoc='PDA_COMUNICAZIONE_GENERICA'
			and C.jumpcheck='0-ESITO_DEFINITIVO_MICROLOTTI'
			and C.statoDoc='Sended'
				
			and	(	
						
					--ENRPAN
					/*( Divisione_lotti <> '0' and CONVENZIONE.IdLottoConvenzione is null )  
					OR  
					( Divisione_lotti = '0' and CONVENZIONE.IdConvenzione is null ) 
					*/
					CONVENZIONE.CIG is null
				)
				
			--ENRPAN
			and isnull(DB.GeneraConvenzione,'0') = '1'



-- recupero i documenti per dare visibilità al RUP
union all

	select 

		 D.id as ID, --min tolto

		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		C.id as GridViewer_ID_DOC,

		v2.value as idpfu , --min tolto

		isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
		,isnull(lotti.CIG, db.cig) as CIG,
		lotti.NumeroLotto
		,ISNULL(TipoSceltaContraente,'') as TipoSceltaContraente
		,lotti.StatoRiga
	from ctl_doc C   with(nolock)
			inner join ( select min( id ) as id , idheader  , IdaziAggiudicataria , NumeroLotto from Document_comunicazione_StatoLotti  with(nolock) where  Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto ) as D  on C.id=D.idheader 
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI' and c1.Deleted = 0
			inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = 'PDA_MICROLOTTI' and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0
				 and lotti.StatoRiga in ('AggiudicazioneDef', 'AggiudicazioneCond')
			--AGGIUNTA PER PRENDERE SOLO GLI IDONEI NEL GIRO MULTIFORNITORE, VA BENE ANCHE PER MONOFORNITORE
			inner join Document_PDA_OFFERTE PDA_OFF with(nolock)  on PDA_OFF.idheader=C1.id
			inner join Document_MicroLotti_Dettagli DMO with(nolock) on PDA_OFF.IdRow=DMO.IdHeader and DMO.TipoDoc='PDA_OFFERTE' 
																		--and DMO.Posizione in ('Idoneo Definitivo','Aggiudicatario Definitivo') 
																		and  ( DMO.Posizione like 'Idoneo%' or DMO.Posizione like 'Aggiudicatario%')
																		and DMO.numerolotto=D.numerolotto and DMO.voce=0 and PDA_OFF.idAziPartecipante=D.IdAziAggiudicataria
			
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc IN ( 'BANDO_GARA','BANDO_SEMPLIFICATO')
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader
			
			
			left join
				(
			
				/*select 
					CONV.id as IdConvenzione, lottiC.id as IdLottoConvenzione, DETT_CONV.AZI_Dest,lottic.cig
					from 
						ctl_doc CONV with(nolock)
							inner join Document_Convenzione DETT_CONV  with(nolock) on DETT_CONV.ID=CONV.id
							left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = CONV.id and lottic.TipoDoc = CONV.tipodoc and isnull(lottiC.Voce,0) = 0
					where 
						CONV.tipodoc='CONVENZIONE'  and CONV.Deleted = 0  --and  CONV.statofunzionale in ('InLavorazione','Pubblicato') 
					
				) CONVENZIONE on CONVENZIONE.AZI_Dest=D.IdAziAggiudicataria 
					and ( ( isnull(CONVENZIONE.CIG,'') = lotti.cig and Divisione_lotti <> '0') or Divisione_lotti = '0' )
			*/
				select 
						distinct  CONV.id as IdConvenzione, DETT_CONV.AZI_Dest,lottic.cig
						from 
							ctl_doc CONV with(nolock)
								inner join Document_Convenzione DETT_CONV  with(nolock) on DETT_CONV.ID=CONV.id
								left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = CONV.id and lottic.TipoDoc = CONV.tipodoc
						where 
							CONV.tipodoc='CONVENZIONE'  and CONV.Deleted = 0  
					
					) CONVENZIONE on CONVENZIONE.AZI_Dest=D.IdAziAggiudicataria 
								and (  ( isnull(CONVENZIONE.CIG,'') = lotti.cig and Divisione_lotti <> '0')
									 or 
								   ( Divisione_lotti = '0' and isnull(CONVENZIONE.CIG,'') = db.cig )
								 )

			-- recuperato il RUP della gara
			left outer join CTL_DOC_Value v2 with(nolock) on db.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'
			

	where C.tipodoc='PDA_COMUNICAZIONE_GENERICA'
		and C.jumpcheck='0-ESITO_DEFINITIVO_MICROLOTTI'
		and C.statoDoc='Sended'
		and	(	
					
			--ENRPAN
			/*( Divisione_lotti <> '0' and CONVENZIONE.IdLottoConvenzione is null )  
			OR  
			( Divisione_lotti = '0' and CONVENZIONE.IdConvenzione is null ) 
			*/
			CONVENZIONE.CIG is null
			)
				
		--ENRPAN
		and isnull(DB.GeneraConvenzione,'0') = '1'

		--il record esce solamente se il RUP è diverso dal compilatore, percè è già uscito dalla altra query
		and v2.value <> C.idpfu 










GO
