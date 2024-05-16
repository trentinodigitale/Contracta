USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SCHEDA_ANAGRAFICA_View_Elenco_DGUE_Compilati]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[SCHEDA_ANAGRAFICA_View_Elenco_DGUE_Compilati] as


select
	CM.id,
	CM.Azienda as OE,
	CM.Azienda as idazi,
	CL.dataInvio,
	CM.Fascicolo,
	CM.idpfu,
	CL.Protocollo as ProtocolloRiferimento,
	case when ISNULL(CM.VersioneLinkedDoc,'')='' then  'DGUE_ISTANTE'  else CM.VersioneLinkedDoc end as RuoloDgue,

	A.aziRagioneSociale, -- RICHIEDENTE

	convert( varchar(10) , CL.DataInvio , 121 )   as DataDA ,
	convert( varchar(10) , CL.DataInvio , 121 )   as DataA,
	CM.TipoDoc as OPEN_DOC_NAME,
	CM.Id as ELENCO_DGUEGrid_ID_DOC,
	CM.TipoDoc as ELENCO_DGUEGrid_OPEN_DOC_NAME

	,P.IdPfu as  OWNER

	from CTL_DOC CM  with(nolock)
		inner join ctl_doc CL  with(nolock) on CL.id=Cm.LinkedDoc and CL.StatoFunzionale <> 'InLavorazione'
		inner join ctl_doc CR  with(nolock) on CR.id=CL.LinkedDoc 

		left join ctl_doc O  with(nolock) on O.id=CR.LinkedDoc 
		left join ctl_doc B  with(nolock) on B.id=O.LinkedDoc 

		left join aziende A  with(nolock) on A.IdAzi=CR.Azienda

		-- il risultato è dato agli utenti che
		--								appartengono alla propria azienda
		--														-- appartengono all'azienda richidente se è un ente
		inner join ProfiliUtente P  with(nolock) on P.pfuIdAzi=CM.Azienda or (  P.pfuIdAzi=Cr.Azienda and a.aziAcquirente <> 0 ) or P.pfuIdAzi=isnull( b.Azienda , 0 ) 

	where CM.TipoDoc='MODULO_TEMPLATE_REQUEST' and CM.Deleted=0
		and isnull( cl.Protocollo  , '' ) <> '' -- per filtrare solo i DGUE collegati a documenti che hanno effettivamente raggiunto il loro scopo 





GO
