USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_DOCUMENTI_DA_PERFEZIONARE_I_MIEI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_DASHBOARD_VIEW_DOCUMENTI_DA_PERFEZIONARE_I_MIEI] as
  ----PRENDO I DOCUMENTI CHE HO  IN CARICO
	select	
			C.id,
			C.Titolo,
			C.Protocollo,
			C.ProtocolloRiferimento,
			C.TipoDoc,
			C.DataInvio,
			C.Fascicolo,
			C.statofunzionale,			
			C.TipoDoc as OPEN_DOC_NAME,
			C.idPfuInCharge as owner,
			A.aziRagioneSociale,
			convert( varchar(10) , c.DataInvio , 121 )   as DataDA ,
			convert( varchar(10) , c.DataInvio , 121 )   as DataA,
			CO.datascadenza as DataScadenzaOfferta

		from  ctl_doc C
				inner join ProfiliUtente P on P.pfuIdAzi=C.Destinatario_Azi
				inner join aziende A on A.IdAzi=C.Azienda
				inner join ctl_doc CO on CO.id=C.LinkedDoc
		where C.tipodoc='RICHIESTA_COMPILAZIONE_DGUE' and c.Deleted=0

	union 
	----PRENDO I DOCUMENTI che dove idpfu sia presente nella ctl_approvalsteps di presa in carico e rilascia
	select	
			C.id,
			C.Titolo,
			C.Protocollo,
			C.ProtocolloRiferimento,
			C.TipoDoc,
			C.DataInvio,
			C.Fascicolo,
			C.statofunzionale,
			C.TipoDoc as OPEN_DOC_NAME,
			CA.APS_IdPfu as owner,
			A.aziRagioneSociale,
			convert( varchar(10) , c.DataInvio , 121 )   as DataDA ,
			convert( varchar(10) , c.DataInvio , 121 )   as DataA,
			CO.datascadenza as DataScadenzaOfferta

		from  ctl_doc C
				inner join ProfiliUtente P on P.pfuIdAzi=C.Destinatario_Azi
				inner join aziende A on A.IdAzi=C.Azienda
				inner join ctl_doc CO on CO.id=C.LinkedDoc
				inner join CTL_ApprovalSteps CA on CA.APS_ID_DOC=C.Id and CA.APS_State in ('CHECK_IN','CHECK_OUT') and CA.APS_Doc_Type='RICHIESTA_COMPILAZIONE_DGUE'
		where C.tipodoc='RICHIESTA_COMPILAZIONE_DGUE' and c.Deleted=0	



GO
