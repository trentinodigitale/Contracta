USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LISTA_DOCUMENTI_DI_COMPETENZA_UTENTE_OE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[LISTA_DOCUMENTI_DI_COMPETENZA_UTENTE_OE] AS


	----------------------------------------------------------------------------------------------
	-- OFFERTE IN LAVORAZIONE,INVIATE LEGATE A GARE LA CUI DATA PRESENTAZIONE OFFERTA NON E' SUPERATA ---
	----------------------------------------------------------------------------------------------
	select 		O.id as idDoc, O.tipoDoc,
				O.Titolo  , 
				dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
				O.protocollo, O.DataInvio, O.StatoFunzionale, 
				O.idpfu, O.idPfuInCharge, O.Fascicolo

		from ctl_doc O with(nolock)
			inner join ctl_doc G with(nolock) on G.id=O.LinkedDoc  and G.Deleted=0 
			inner join document_bando DG with(nolock) on DG.idHeader=G.id and datediff(ss,getdate(),DG.DataScadenzaOfferta) >= 0  
			inner join LIB_Documents L with(nolock) on L.DOC_ID = O.TipoDoc
		where O.tipodoc in ( 'OFFERTA' ,'MANIFESTAZIONE_INTERESSE','DOMANDA') and O.deleted = 0 and O.statofunzionale  in ('InLavorazione','Inviato')

	UNION ALL

	--------------------------------------------------------------------------------------
	-- ISTANZE IN LAVORAZIONE e/o INVIATE LEGATE A BANDI IN CORSO  ----
	--------------------------------------------------------------------------------------
	select 		O.id as idDoc, O.tipoDoc,
				O.Titolo , 
				dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
				O.protocollo, O.DataInvio, O.StatoFunzionale, 
				O.idpfu, O.idPfuInCharge, O.Fascicolo

		from ctl_doc O with(nolock)
			inner join ctl_doc G with(nolock) on G.id=O.LinkedDoc  and G.Deleted=0 and datediff(minute,getdate(),G.DataScadenza) >= 0  
			--inner join document_bando DG with(nolock) on DG.idHeader=G.id and datediff(ss,getdate(),DG.DataScadenzaOfferta)<0  
			inner join profiliutente P  with(nolock)  on ( P.idpfu=O.idpfu or P.idpfu=O.idPfuInCharge) and p.pfuVenditore<>0
			inner join LIB_Documents L with(nolock) on L.DOC_ID = O.TipoDoc
		where O.tipodoc like 'ISTANZA%'  and O.deleted = 0 --and O.statofunzionale  in ('InLavorazione')


	UNION ALL
			
	--------------------------------------------------------------------------------------
	-- DGUE IN LAVORAZIONE LEGATE A ISTANZE DI BANDI IN CORSO  ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo  ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.idpfu, D.idPfuInCharge, D.Fascicolo

	from 
		ctl_doc D with(nolock) inner join
			ctl_doc O with(nolock) on O.id=D.LinkedDoc and O.tipodoc like 'ISTANZA%'  and O.deleted = 0 and O.statofunzionale  in ('InLavorazione')
				inner join ctl_doc G with(nolock) on G.id=O.LinkedDoc  and G.Deleted=0 and datediff(minute,getdate(),G.DataScadenza) >= 0  
				inner join profiliutente P  with(nolock)  on ( P.idpfu=D.idpfu or P.idpfu=D.idPfuInCharge) and p.pfuVenditore<>0
				inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
	where D.tipodoc = 'MODULO_TEMPLATE_REQUEST'  and D.deleted = 0 and D.statofunzionale  in ('InLavorazione')

	
	UNION ALL
			
	--------------------------------------------------------------------------------------
	-- DGUE MANDATARIA IN LAVORAZIONE LEGATE A OFFERTE IN LAVORAZIONE DI GARE IN CORSO  ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.idpfu, D.idPfuInCharge, D.Fascicolo

	from 
		ctl_doc D with(nolock) inner join
			ctl_doc O with(nolock) on O.id=D.LinkedDoc and O.tipodoc = 'OFFERTA'  and O.deleted = 0 and O.statofunzionale  in ('InLavorazione')
				inner join ctl_doc G with(nolock) on G.id=O.LinkedDoc  and G.Deleted=0  
				inner join document_bando DG with(nolock) on DG.idHeader=G.id and datediff(ss,getdate(),DG.DataScadenzaOfferta) >= 0  
				inner join profiliutente P with(nolock)  on ( P.idpfu=D.idpfu or P.idpfu=D.idPfuInCharge) and p.pfuVenditore<>0
				inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
	where D.tipodoc = 'MODULO_TEMPLATE_REQUEST'  and D.deleted = 0 and D.statofunzionale  in ('InLavorazione')

	UNION ALL
	--------------------------------------------------------------------------------------
	-- DGUE PARTECIPANTI IN LAVORAZIONE LEGATE A OFFERTE IN LAVORAZIONE DI GARE IN CORSO  ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.idpfu, D.idPfuInCharge, D.Fascicolo
			
	from 
		ctl_doc D with(nolock) inner join
			ctl_doc RC with(nolock) on RC.id=D.LinkedDoc and RC.tipodoc = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA'  and RC.deleted = 0 --and RC.statofunzionale  in ('InLavorazione')
				inner join ctl_doc R with(nolock) on R.id=RC.LinkedDoc  and R.Deleted=0 and R.TipoDoc = 'RICHIESTA_COMPILAZIONE_DGUE' --and R.statofunzionale  in ('InLavorazione')
				inner join ctl_doc O with(nolock) on O.id=R.LinkedDoc and O.tipodoc = 'OFFERTA'  and O.deleted = 0 and O.statofunzionale  in ('InLavorazione')
				inner join ctl_doc G with(nolock) on G.id=O.LinkedDoc  and G.Deleted=0  and G.StatoFunzionale <> 'Chiuso'
				--inner join document_bando DG with(nolock) on DG.idHeader=O.LinkedDoc and datediff(ss,getdate(),DG.DataScadenzaOfferta)<0  
				inner join profiliutente P  with(nolock)  on ( P.idpfu=D.idpfu or P.idpfu=D.idPfuInCharge) and p.pfuVenditore<>0
				inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
	where D.tipodoc = 'MODULO_TEMPLATE_REQUEST'  and D.deleted = 0 and D.statofunzionale  in ('InLavorazione')


	UNION ALL
	--------------------------------------------------------------------------------------
	-- CONTRATTO_CONVENZIONE in carico su convenzioni nons cadute  ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.Destinatario_User as Idpfu, D.idPfuInCharge, D.Fascicolo
			
	from 
		ctl_doc D with(nolock) 
			inner join ctl_doc CONV with (nolock) on CONV.id = D.LinkedDoc and CONV.tipodoc='CONVENZIONE' and CONV.StatoFunzionale <> 'Chiuso'
			inner join profiliutente P  with(nolock)  on ( P.idpfu=D.Destinatario_User or P.idpfu=D.idPfuInCharge) and p.pfuVenditore<>0
			inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
		where D.tipodoc = 'CONTRATTO_CONVENZIONE'  and D.deleted = 0 and D.statofunzionale  in ('Inviato')
	

	UNION ALL
	--------------------------------------------------------------------------------------
	-- CONTRATTO_GARA in carico su GAre non chiuse  ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.Destinatario_User as Idpfu, D.idPfuInCharge, D.Fascicolo
			
	from 
		ctl_doc D with(nolock) 
			
			inner join ctl_doc CON with (nolock) on CON.id = D.LinkedDoc and CON.tipodoc='CONTRATTO_GARA' and CON.Deleted=0
			inner join ctl_doc COM with (nolock) on COM.id = CON.LinkedDoc and COM.tipodoc='PDA_COMUNICAZIONE_GENERICA' and COM.Deleted=0
			inner join ctl_doc PDA with (nolock) on PDA.id = COM.LinkedDoc and PDA.tipodoc='PDA_MICROLOTTI' and PDA.Deleted=0
			inner join ctl_doc G with (nolock) on G.id = PDA.LinkedDoc and G.tipodoc='BANDO_GARA' and G.StatoFunzionale <> 'Chiuso'
			inner join profiliutente P  with(nolock)  on ( P.idpfu=D.Destinatario_User or P.idpfu=D.idPfuInCharge) and p.pfuVenditore<>0
			inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
		
		where D.tipodoc = 'CONTRATTO_GARA_FORN'  and D.deleted = 0 and D.statofunzionale  in ('Inviato')
	


	UNION ALL
	--------------------------------------------------------------------------------------
	-- ODC in carico su convenzioni non scadute  ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.Destinatario_User as Idpfu, D.idPfuInCharge, D.Fascicolo
			
	from 
		ctl_doc D with(nolock) 
			inner join ctl_doc CONV with (nolock) on CONV.id = D.LinkedDoc and CONV.tipodoc='CONVENZIONE' and CONV.StatoFunzionale <> 'Chiuso'
			inner join profiliutente P  with(nolock)  on  P.idpfu=D.idPfuInCharge and p.pfuVenditore<>0
			inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
		where D.tipodoc = 'ODC'  and D.deleted = 0 and D.statofunzionale  in ('Inviato')

	
	UNION ALL
	
	--------------------------------------------------------------------------------------
	-- PDA_COMUNICAZIONE_RISP in lavorazione su gare non chiuse ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.idpfu as Idpfu, D.idPfuInCharge, D.Fascicolo
			
	from 
		ctl_doc D with(nolock) 
			
			inner join ctl_doc CON with (nolock) on CON.id = D.LinkedDoc and CON.tipodoc='PDA_COMUNICAZIONE_GARA' and CON.Deleted=0
			inner join ctl_doc COM with (nolock) on COM.id = CON.LinkedDoc and COM.tipodoc='PDA_COMUNICAZIONE_GENERICA' and COM.Deleted=0
			inner join ctl_doc PDA with (nolock) on PDA.id = COM.LinkedDoc and PDA.tipodoc='PDA_MICROLOTTI' and PDA.Deleted=0
			inner join ctl_doc G with (nolock) on G.id = PDA.LinkedDoc and G.tipodoc='BANDO_GARA' and G.StatoFunzionale <> 'Chiuso'
			
			inner join profiliutente P  with(nolock)  on  P.idpfu=D.idPfu and p.pfuVenditore<>0
			inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
		where D.tipodoc in ('PDA_COMUNICAZIONE_RISP')  and D.deleted = 0 and D.statofunzionale  = 'InLavorazione'
	
	UNION ALL

	--------------------------------------------------------------------------------------
	-- PDA_COMUNICAZIONE_OFFERTA_RISP in lavorazione su gare non chiuse ----
	--------------------------------------------------------------------------------------
	select	D.id as idDoc, D.tipoDoc,
			D.Titolo ,
			dbo.cnv( L.DOC_DescML ,'I')  AS NomeDocumento ,
			D.protocollo, D.DataInvio, D.StatoFunzionale, 
			D.idpfu as Idpfu, D.idPfuInCharge, D.Fascicolo
			
	from 
		ctl_doc D with(nolock) 
			
			inner join ctl_doc CON with (nolock) on CON.id = D.LinkedDoc and CON.tipodoc='PDA_COMUNICAZIONE_OFFERTA' and CON.Deleted=0
			--inner join ctl_doc COM with (nolock) on COM.id = CON.LinkedDoc and COM.tipodoc='PDA_COMUNICAZIONE_GENERICA' and COM.Deleted=0
			--inner join ctl_doc PDA with (nolock) on PDA.id = COM.LinkedDoc and PDA.tipodoc='PDA_MICROLOTTI' and PDA.Deleted=0
			--inner join ctl_doc G with (nolock) on G.id = PDA.LinkedDoc and G.tipodoc='BANDO_GARA' and G.StatoFunzionale <> 'Chiuso'
			
			inner join profiliutente P  with(nolock)  on  P.idpfu=D.idPfu and p.pfuVenditore<>0
			inner join LIB_Documents L with(nolock) on L.DOC_ID = D.TipoDoc
		where D.tipodoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP')  and D.deleted = 0 and D.statofunzionale  = 'InLavorazione'
	

	


GO
