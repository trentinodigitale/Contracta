USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_AGGIUDICATARIA_ATTESA_CONTRATTO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_DASHBOARD_VIEW_AGGIUDICATARIA_ATTESA_CONTRATTO] as

	--Versione=2&data=2018-02-22&Attvita=183678&Nominativo=sabato

	--select 
	--	 min (D.id) as ID, 
	--	 D.idheader, 
	--	 C.Protocollo,
	--	 cast(C.Body as nvarchar(4000)) as Descrizione,
	--	 C.Data as DataInvio,
	--	 D.IdaziAggiudicataria as muIdAziDest,
	--	 C.tipodoc as GridViewer_OPEN_DOC_NAME,
	--	 --min(c.id) as GridViewer_ID_DOC
	--	C.id as GridViewer_ID_DOC,
	--	min(C.idpfu) as idpfu ,
	--	TipoProceduraCaratteristica

	--from  
	--	ctl_doc C   with(nolock) 
	--	inner join Document_comunicazione_StatoLotti D   with(nolock) on C.id=D.idheader and d.Deleted = 0
	--	inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI'
	--	inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc='BANDO_GARA'
	--	inner join document_bando DB   with(nolock) on C2.id=DB.idheader and ProceduraGara=15478  --15478 negoziata

	--where 
	--	C.tipodoc='PDA_COMUNICAZIONE_GENERICA'
	--	and C.jumpcheck='0-ESITO_DEFINITIVO_MICROLOTTI'
	--	and C.statoDoc='Sended'
	--	and C.id not in 
	--		(
	--		select linkeddoc 
	--			from ctl_doc  with(nolock) 
	--			where tipodoc='SCRITTURA_PRIVATA' 
	--			and statofunzionale in ('Confermato','InLavorazione','Inviato') 
	--			and destinatario_azi=D.IdAziAggiudicataria and deleted=0)
				
	--group by
	--	D.idheader, C.Protocollo, D.IdaziAggiudicataria,cast(C.Body as nvarchar(4000)),C.Data,C.tipodoc,C.id , TipoProceduraCaratteristica

	select 
		 --min (D.id) as ID, 
		 D.id as ID, 
		 D.idheader, 
		 C.Protocollo,
		 cast(C.Body as nvarchar(4000)) as Descrizione,
		 C.Data as DataInvio,
		 D.IdaziAggiudicataria as muIdAziDest,
		 C.tipodoc as GridViewer_OPEN_DOC_NAME,
		 --min(c.id) as GridViewer_ID_DOC
		C.id as GridViewer_ID_DOC,
		--min(C.idpfu) as idpfu ,
		--C.idpfu,
		isnull( SUB.Value , C1.IdPfu ) as idpfu,
		TipoProceduraCaratteristica

	from  
		ctl_doc C   with(nolock) 
			inner join ( select  min (id) as ID,  idheader , IdaziAggiudicataria,NumeroLotto from Document_comunicazione_StatoLotti with(nolock) where Deleted = 0 group by idheader , IdaziAggiudicataria,numerolotto ) as D  on C.id=D.idheader --and d.Deleted = 0
			inner join ctl_doc_value DC  with(nolock) on c.id = DC.idheader and DC.DSE_ID='DIRIGENTE' and DC.DZT_Name='AggiudicazioneCondizionata'
			inner join ctl_doc c1   with(nolock) on c.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI'
			
			--aggiunta la join con lo stato del lotto sulla PDA che deve essere definitivo
			--se la comunicazione di esito non condizionata oppure se condizionata ed eseguito i controlli
			inner join document_microlotti_dettagli PDA_LOTTI with(nolock) on PDA_LOTTI.idheader=c1.id and PDA_LOTTI.tipodoc= 'PDA_MICROLOTTI' and PDA_LOTTI.StatoRiga='AggiudicazioneDef' and PDA_LOTTI.NumeroLotto=D.NumeroLotto and PDA_LOTTI.voce=0

			inner join ctl_doc c2   with(nolock) on c1.linkedDoc=c2.id and C2.tipodoc='BANDO_GARA'
			inner join document_bando DB   with(nolock) on C2.id=DB.idheader and ProceduraGara=15478  --15478 negoziata
			left outer join ctl_doc_value SUB with( nolock ) on c.id = SUB.idheader and SUB.DSE_ID='Subentro' and SUB.dzt_name = 'Subentro'  
			
	where 
		C.tipodoc='PDA_COMUNICAZIONE_GENERICA'
		and C.jumpcheck='0-ESITO_DEFINITIVO_MICROLOTTI'
		and C.statoDoc='Sended'
		and C.id not in 
			(
			select linkeddoc 
				from ctl_doc  with(nolock) 
				where tipodoc='SCRITTURA_PRIVATA' 
				and statofunzionale in ('Confermato','InLavorazione','Inviato') 
				and destinatario_azi=D.IdAziAggiudicataria and deleted=0)
		
		
				
	--group by
	--	D.idheader, C.Protocollo, D.IdaziAggiudicataria,cast(C.Body as nvarchar(4000)),C.Data,C.tipodoc,C.id , TipoProceduraCaratteristica




GO
