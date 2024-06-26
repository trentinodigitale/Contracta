USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_QUESTIONARIO_FABBISOGNI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_MAIL_QUESTIONARIO_FABBISOGNI] as

select 
	 C.id as iddoc
	,'I' as LNG
	,C.Protocollo as ProtocolloQuestionario
	,C2.Protocollo 
	,C1.Protocollo as ProtocolloRichiesta
	,C1.Body as OggettoRichiesta
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C.body as Oggetto
	, convert( varchar , D.DataRiferimentoFine , 103 ) + ' ' + convert( varchar , D.DataRiferimentoFine , 108 ) as DataScadenza
	, convert( varchar , D.DataRiferimentoInizio , 103 ) + ' ' + convert( varchar , D.DataRiferimentoInizio , 108 ) as Datainizio
	, convert( varchar , D.DataPresentazioneRisposte , 103 ) + ' ' + convert( varchar , D.DataPresentazioneRisposte , 108 ) as DataFine
	--, c.azienda
	, a.aziRagioneSociale as RagioneSocialeCompilatore
	, p.pfuNome as NominativoCompilatore
from
	ctl_doc C 
	inner join aziende a on a.idazi = c.azienda
	inner join profiliutente p on p.idpfu = c.idPfu --InCharge
	inner join Document_Bando D on D.idHeader=C.Linkeddoc
	inner join ctl_doc C1 on C1.id=C.Linkeddoc and  C1.tipodoc='BANDO_FABBISOGNI'
	left join ctl_doc C2 on C2.linkedDoc=C.id and C2.tipodoc='SUB_QUESTIONARIO_FABBISOGNI'
where C.tipodoc='QUESTIONARIO_FABBISOGNI' and C.Deleted=0



GO
