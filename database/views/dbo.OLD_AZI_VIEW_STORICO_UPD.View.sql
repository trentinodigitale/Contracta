USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AZI_VIEW_STORICO_UPD]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD_AZI_VIEW_STORICO_UPD]
AS

SELECT     id, IdPfu, TipoOperAnag, aziDataCreazione, IdAzi, Protocol, TipoOperAnag AS DETTAGLIGrid_OPEN_DOC_NAME, id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,case when Stato='Sended' then 'Inviato' else stato end as statofunzionale
	FROM         dbo.Document_Aziende with(nolock)
	WHERE     (TipoOperAnag NOT IN ('AZI_PERGIUR', 'AZI_PERFIS', 'AZI_RTI','AZI_UPD_ENTE', 'AZI_INI_RAPLEG','REGISTRAZIONE_FORNITORE')) and stato = 'sended'

UNION ALL

	select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc='AZI_UPD_DOCUMENTAZIONE'

UNION ALL

	select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc='SOSPENSIONE_ALBO' and ( StatoFunzionale='Archiviato' or StatoFunzionale='Sospeso' )

UNION ALL

	select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc='PROROGA_ALBO' and Deleted=0  and StatoFunzionale <> 'InLavorazione'

UNION ALL

	select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where  ( left ( tipoDoc , 12 ) = 'ISTANZA_Albo' or left ( tipoDoc , 11 ) = 'ISTANZA_SDA' ) and Deleted=0 and StatoDoc <> 'Saved' and StatoFunzionale <> 'InLavorazione'
	
UNION ALL

	select   Id,IdPfu, case 
							when left(JumpCheck,16) = 'ISTANZA_AlboProf' then  TipoDoc + '_ISTANZA_AlboProf' 
							when left(JumpCheck,21) = 'ISTANZA_AlboFornitori' then  TipoDoc + '_ISTANZA_AlboFornitori' 
							else TipoDoc
						end as TipoDoc
			,DataInvio,Destinatario_Azi  as IdAzi,Protocollo,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc in ('CONFERMA_ISCRIZIONE','CONFERMA_ISCRIZIONE_SDA','CONFERMA_ISCRIZIONE_LAVORI') and Deleted=0 and StatoFunzionale='Notificato'

UNION ALL

	select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,'VERIFICA_REGISTRAZIONE' AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc in ('VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') and Deleted=0 and StatoFunzionale <> 'InLavorazione'

UNION ALL

	select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,'VARIAZIONE_ANAGRAFICA' AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc in ('VARIAZIONE_ANAGRAFICA') and Deleted=0 and StatoFunzionale <> 'InLavorazione'

UNION ALL

	SELECT   id, IdPfu, TipoOperAnag, aziDataCreazione, IdAzi, Protocol, TipoOperAnag AS DETTAGLIGrid_OPEN_DOC_NAME, id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,case when Stato='Sended' then 'Inviato' else stato end as statofunzionale
	FROM         dbo.Document_Aziende with(nolock)
	WHERE     (TipoOperAnag IN ('AZI_UPD_ENTE')) and isOld=0 and stato = 'sended'

UNION ALL

	select   Id,IdPfu,TipoDoc as TipoOperAnag ,DataInvio as aziDataCreazione ,Azienda as IdAzi,Protocollo as Protocol , TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc in ('ALLINEAMENTO_DATI_AZI', 'NOTIER_ANNULLA_ISCRIZ','ACCORDO_CREA_GARE', 'NOTIER_ISCRIZ_PA' ) and Deleted=0 and StatoFunzionale <> 'InLavorazione'

UNION ALL

	SELECT     id, IdPfu, TipoOperAnag, aziDataCreazione, IdAzi, Protocol, TipoOperAnag AS DETTAGLIGrid_OPEN_DOC_NAME, id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,case when Stato='Sended' then 'Inviato' else stato end as statofunzionale
	FROM         dbo.Document_Aziende with(nolock)
	WHERE     TipoOperAnag IN ('AZI_INI_RAPLEG') and stato = 'sended' and EXISTS ( select * from LIB_Dictionary a with (nolock) where a.DZT_Name = 'SYS_ENTE_NUOVO_REGISTRA_RAPLEG' and isnull(a.DZT_ValueDef,'no') <> 'no' )

UNION ALL

	select   Id,IdPfu,TipoDoc as TipoOperAnag ,DataInvio as aziDataCreazione ,Azienda as IdAzi,Protocollo as Protocol ,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where  TipoDoc in ( 'UPD_MERC_ADDITIONAL_INFO', 'AZI_TO_DELETE_VERIFICATO' ) and Deleted=0 and StatoFunzionale <> 'InLavorazione'

UNION ALL

	select   Id,IdPfu,'ISTANZA_ME_INFO_AGGIUNTIVE' as TipoOperAnag ,DataInvio as aziDataCreazione ,Azienda as IdAzi,Protocollo as Protocol ,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where TipoDoc like 'ISTANZA_ME_INFO_AGGIUNTIVE%'  and Deleted=0 and StatoFunzionale <> 'InLavorazione'

UNION ALL
	
	select   Id,IdPfu,TipoDoc as TipoOperAnag ,DataInvio as aziDataCreazione ,Azienda as IdAzi,Protocollo as Protocol ,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where  TipoDoc in ( 'PERFEZ_UTENTE' ) and Deleted=0 

UNION ALL
	
	select   Id,IdPfu,TipoDoc as TipoOperAnag ,DataInvio as aziDataCreazione ,Destinatario_Azi as IdAzi,Protocollo as Protocol ,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where  TipoDoc in ( 'VARIAZIONE_DATI_AZIENDA' ) and Deleted=0 

--UNION ALL
	
--	select   Id,IdPfu, TipoDoc,DataInvio as aziDataCreazione ,azienda as IdAzi,Protocollo as Protocol ,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
--	from CTL_DOC with(nolock)
--	where  TipoDoc in ( 'RIPRISTINA_AZI' ) and Deleted=0 

UNION ALL
	
	select   Id,IdPfu, TipoDoc,DataInvio as aziDataCreazione ,azienda as IdAzi,Protocollo as Protocol ,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	from CTL_DOC with(nolock)
	where  TipoDoc in ( 'ACCORDO_CREA_FABBISOGNI','ACCORDO_CREA_SDA','RIPRISTINA_AZI', 'ACCORDO_CREA_CONVENZIONI') and Deleted=0 

-- INIPEC Comunicazioni
UNION ALL

	--select   Id,IdPfu,TipoDoc,DataInvio,Azienda,Protocollo,TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,id AS DETTAGLIGrid_ID_DOC,IdPfu as APS_IdPfu,statofunzionale
	--from CTL_DOC with(nolock)
	--where TipoDoc='PDA_COMUNICAZIONE_GARA'
	--and Jumpcheck like '%-COMUNICAZIONE_FORNITORE_INIPEC'

	select 
		a.IdCom as Id,
		a.Owner as IdPfu,
		'COM_DPE' as TipoDoc,
		DataCreazione as DataInvio,
		b.IdAzi as Azienda,
		a.Protocollo as Protocollo,
		'COM_DPE' as DETTAGLIGrid_OPEN_DOC_NAME,
		a.IdCom as DETTAGLIGrid_ID_DOC,
		a.Owner as APS_IdPfu,
		CASE StatoCom
            WHEN 'InProtocollazione' THEN 'InProtocollazione'
			WHEN 'Salvato' THEN 'InLavorazione'
			WHEN 'Richiamata' THEN 'Annullata'
			WHEN 'Inviato' THEN 'Inviato'
		END as statofunzionale
	from Document_com_Dpe a with (nolock)
		inner join Document_com_Dpe_fornitori b with (nolock) on a.IdCom = b.IdCom
		inner join Document_INIPEC c with (nolock) on a.IdCom = c.IdCom

GO
