USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_LOTTI_GARA_ATTESA_CONTRATTO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--select * from [DASHBOARD_VIEW_LOTTI_GARA_ATTESA_CONTRATTO]

CREATE VIEW [dbo].[DASHBOARD_VIEW_LOTTI_GARA_ATTESA_CONTRATTO] AS
	--Versione=5&data=2019-09-10&Attvita=263206&Nominativo=Enrico
	--Versione=4&data=2019-05-31&Attvita=248246&Nominativo=Enrico
	--Versione=3&data=2018-11-21&Attvita=215319&Nominativo=Sabato
	--Versione=2&data=2018-08-16&Attvita=203503&Nominativo=Sabato
	--Versione=1&data=2017-12-13&Attvita=166096&Nominativo=federico

	select 

		 D.id as ID, --min tolto

		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		C.id as GridViewer_ID_DOC,

		isnull (sub.value,c.idpfu)as idpfu , --min tolto , nel caso in cui è subentrato un utente allora sarà visibile all'utente di subentro altrimenti fa quello che faceva prima

		isnull(TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
		,isnull(lotti.CIG, db.cig) as CIG,
		lotti.NumeroLotto
		,ISNULL(TipoSceltaContraente,'') as TipoSceltaContraente
		
		, CU.Cottimo_Gara_Unificato

	from ctl_doc C   with(nolock)
			inner join ( select min( id ) as id , idheader  , IdaziAggiudicataria , NumeroLotto from Document_comunicazione_StatoLotti  with(nolock) where  Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto ) as D  on C.id=D.idheader 
--			inner join Document_comunicazione_StatoLotti D   with(nolock) on C.id=D.idheader and d.Deleted = 0
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI' and c1.Deleted = 0
			inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = 'PDA_MICROLOTTI' and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0 and lotti.StatoRiga='AggiudicazioneDef'
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc='BANDO_GARA'
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader -- and ISNULL(TipoProceduraCaratteristica,'') = '' 
			
			--ENRPAN att. 189504
			--and ProceduraGara <> 15478  --diverso da negoziata

			---- CONTRATTO
			--left join ctl_doc cont with(nolock) ON cont.LinkedDoc = c.id and cont.tipodoc = 'CONTRATTO_GARA' and cont.Deleted = 0 and cont.statofunzionale in ('Confermato','InLavorazione','Inviato') and cont.destinatario_azi=D.IdAziAggiudicataria
			---- LOTTI DEL CONTRATTO
			--left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc = 'CONTRATTO_GARA' and lottic.cig = lotti.cig and isnull(lottiC.Voce,0) = 0

			left join
				(
			
				select 
					cont.LinkedDoc, cont.id as IdContratto, lottiC.id as IdLottoContratto,cont.destinatario_azi,lottic.cig
						from ctl_doc cont with(nolock)
							left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc = cont.tipodoc and isnull(lottiC.Voce,0) = 0
					where cont.tipodoc='CONTRATTO_GARA' and  cont.statofunzionale in ('Confermato','InLavorazione','Inviato')  and cont.Deleted = 0 
					
				) CONTRATTO on CONTRATTO.LinkedDoc=C.Id and CONTRATTO.Destinatario_Azi=D.IdAziAggiudicataria 
					and ( ( isnull(CONTRATTO.CIG,'') = lotti.cig and Divisione_lotti <> '0') or Divisione_lotti = '0' )


				left outer join ctl_doc_value SUB with( nolock ) on SUB.DSE_ID='Subentro' and dzt_name = 'Subentro'  and c.id = SUB.idheader and ISNULL(SUB.Row,0)=0
	
				--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
				cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) CU  


				left join
					CTL_DOC_Value Stip_Contr with (nolock)  on Stip_Contr.IdHeader = C.Id 
															and Stip_Contr.DSE_ID ='DIRIGENTE'
															and Stip_Contr.DZT_NAME='StipulaDelContratto'
															 

			where C.tipodoc='PDA_COMUNICAZIONE_GENERICA'
				and C.jumpcheck='0-ESITO_DEFINITIVO_MICROLOTTI'
				and C.statoDoc='Sended'
				
				and	(	
						
						----ENRPAN
						--( Divisione_lotti <> '0' and lottiC.Id is null )  
						--OR  
						--( Divisione_lotti = '0' and cont.Id is null ) 

						
						--ENRPAN
						( Divisione_lotti <> '0' and CONTRATTO.IdLottoContratto is null )  
						OR  
						( Divisione_lotti = '0' and CONTRATTO.IdContratto is null ) 

					)
				
				--ENRPAN
				--and isnull(DB.TipoAggiudicazione,'') <> 'multifornitore'
				and isnull(DB.GeneraConvenzione,'0') = '0'
				
				--stilupacontratto sulla com di esito deve essere si
				--se non presente per il pregresso è come se fosse si
				and ISNULL(Stip_Contr.value,'1')='1'

			--group by D.idheader, C.Protocollo, D.IdaziAggiudicataria,cast(C.Body as nvarchar(4000)),C.Data,C.tipodoc,C.id , TipoProceduraCaratteristica ,isnull(lotti.CIG, db.cig),lotti.NumeroLotto,ISNULL(TipoSceltaContraente,'')


-- recupero i documenti per dare visibilità al RUP
union 

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
		
		, CU.Cottimo_Gara_Unificato

	from ctl_doc C   with(nolock)
			inner join ( select min( id ) as id , idheader  , IdaziAggiudicataria , NumeroLotto from Document_comunicazione_StatoLotti  with(nolock) where  Deleted = 0 group by idheader , IdaziAggiudicataria , NumeroLotto ) as D  on C.id=D.idheader 
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI' and c1.Deleted = 0
			inner join Document_MicroLotti_Dettagli lotti with(nolock) on lotti.IdHeader = C.LinkedDoc and lotti.TipoDoc = 'PDA_MICROLOTTI' and lotti.NumeroLotto = D.NumeroLotto and ISNULL(lotti.voce,0) = 0 and lotti.StatoRiga='AggiudicazioneDef'
			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc='BANDO_GARA'
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader-- and ISNULL(TipoProceduraCaratteristica,'') = '' 
			
			---- CONTRATTO
			--left join ctl_doc cont with(nolock) ON cont.LinkedDoc = c.id and cont.tipodoc = 'CONTRATTO_GARA' and cont.Deleted = 0 and cont.statofunzionale in ('Confermato','InLavorazione','Inviato') and cont.destinatario_azi=D.IdAziAggiudicataria
			---- LOTTI DEL CONTRATTO
			--left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc = 'CONTRATTO_GARA' and lottic.cig = lotti.cig and isnull(lottiC.Voce,0) = 0

			left join
				(
			
				select 
					cont.LinkedDoc, cont.id as IdContratto, lottiC.id as IdLottoContratto,cont.destinatario_azi,lottic.cig
						from ctl_doc cont with(nolock)
							left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc = cont.tipodoc and isnull(lottiC.Voce,0) = 0
					where cont.tipodoc='CONTRATTO_GARA' and  cont.statofunzionale in ('Confermato','InLavorazione','Inviato')  and cont.Deleted = 0 
					
				) CONTRATTO on CONTRATTO.LinkedDoc=C.Id and CONTRATTO.Destinatario_Azi=D.IdAziAggiudicataria --and isnull(CONTRATTO.CIG,'') = lotti.cig
					and ( ( isnull(CONTRATTO.CIG,'') = lotti.cig and Divisione_lotti <> '0') or Divisione_lotti = '0' )

			-- recuperato il RUP della gara
			left outer join CTL_DOC_Value v2 with(nolock) on db.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune' and v2.Row=0
			
			--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
			cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) CU  

			left join
					CTL_DOC_Value Stip_Contr with (nolock)  on Stip_Contr.IdHeader = C.Id 
															and Stip_Contr.DSE_ID ='DIRIGENTE'
															and Stip_Contr.DZT_NAME='StipulaDelContratto'

			where C.tipodoc='PDA_COMUNICAZIONE_GENERICA'
				and C.jumpcheck='0-ESITO_DEFINITIVO_MICROLOTTI'
				and C.statoDoc='Sended'
				and	(	
					
												
						----ENRPAN
						--( Divisione_lotti <> '0' and lottiC.Id is null )  
						--OR  
						--( Divisione_lotti = '0' and cont.Id is null ) 

						--ENRPAN
						( Divisione_lotti <> '0' and CONTRATTO.IdLottoContratto is null )  
						OR  
						( Divisione_lotti = '0' and CONTRATTO.IdContratto is null ) 

					)
				
				--ENRPAN
				and isnull(DB.GeneraConvenzione,'0') = '0'

				--il record esce solamente se il RUP è diverso dal compilatore, percè è già uscito dalla altra query
				and v2.value <> C.idpfu 

				--stilupacontratto sulla com di esito deve essere si
				--se non presente per il pregresso è come se fosse si
				and ISNULL(Stip_Contr.value,'1')='1'

GO
