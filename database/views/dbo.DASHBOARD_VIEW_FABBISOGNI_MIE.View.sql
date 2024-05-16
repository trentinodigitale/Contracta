USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_FABBISOGNI_MIE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_FABBISOGNI_MIE]  as
--Utente settatto sulla ctl_doc_destinatari
	select 
			  CD.idrow as Id,
			  C.IdPfu,
			  TipoDoc, 
			  StatoDoc, 
			  Data, 
			  Protocollo, 
			  Deleted,
			  Titolo,
			  DataInvio,
			  cast(Body as nvarchar(4000)) as Oggetto,
			  CD.idpfu as OWNER,
			  B.DataPresentazioneRisposte as DataRiferimentoFine,
		 
			  P.pfuIdAzi,
			  C.idpfuinCharge,
			  CD.idHeader,
			  CD.statoiscrizione as  StatoFunzionale
		from CTL_DOC C
			left join  Document_Bando B on B.idheader=C.id
			inner join CTL_DOC_Destinatari CD on C.id=CD.idHeader and ISNULL(CD.IdPfu,0)<>0
			inner join ProfiliUtente P on P.pfuIdAzi=Cd.IdAzi 
		where tipodoc = 'BANDO_FABBISOGNI' and deleted=0 

UNION
--utenti coinvolti nella cronologia della richiesta in arrivo
	select 
			  CD.idrow as Id,
			  C.IdPfu,
			  TipoDoc, 
			  StatoDoc, 
			  Data, 
			  Protocollo, 
			  Deleted,
			  Titolo,
			  DataInvio,
			  cast(Body as nvarchar(4000)) as Oggetto,
			  CA.APS_IdPfu as OWNER,
			  B.DataPresentazioneRisposte as DataRiferimentoFine,
			  		 
			  P.pfuIdAzi,
			  C.idpfuinCharge,
			  CD.idHeader,
			  CD.statoiscrizione as  StatoFunzionale
		from CTL_DOC C
			inner join  Document_Bando B on B.idheader=C.id
			inner join CTL_DOC_Destinatari CD on C.id=CD.idHeader
			inner join ProfiliUtente P on P.pfuIdAzi=Cd.IdAzi 
			inner join CTL_ApprovalSteps CA on CA.APS_Doc_Type='BANDO_FABBISOGNI_IA' and CA.APS_ID_DOC=CD.idHeader and CA.APS_IdPfu=P.IdPfu
		where tipodoc = 'BANDO_FABBISOGNI' and deleted=0 






GO
