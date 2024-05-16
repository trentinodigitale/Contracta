USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RICHIESTA_COMPILAZIONE_DGUE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_RICHIESTA_COMPILAZIONE_DGUE] as

select 
	 C.id as iddoc
	,'I' as LNG
	,C.Protocollo as ProtocolloQuestionario
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C.body as Oggetto
	,A.aziRagioneSociale
	,A2.aziRagioneSociale as aziRagioneSocialeM
	,case when C.JumpCheck='RTI' then 'Mandante' when C.JumpCheck='ESECUTRICI' then 'Società Esecutrice'  when C.JumpCheck='AUSILIARIE' then 'Ausiliaria'  end as TipoRiferimento
	,Case when DB.TipoBandoGara=1 then 'all''Avviso' when DB.TipoBandoGara=2 then 'al Bando' when DB.TipoBandoGara=3 then 'all''Invito' end as TipoBando
	,BANDO.Protocollo as ProtocolloBando
	,bando.Body as OggettoBando
	, convert( varchar , DB.DataScadenzaOfferta , 103 ) + ' ore ' +  convert( varchar , DB.DataScadenzaOfferta , 108 ) as  Dataterminepresentazioneofferte
	,DB.CIG
from ctl_doc C 
	inner join Aziende A on A.IdAzi=C.Destinatario_Azi
	inner join Aziende A2 on A2.IdAzi=C.Azienda
	inner join ctl_doc O on O.id=C.LinkedDoc
	inner join ctl_doc BANDO on BANDO.id=O.LinkedDoc
	inner join document_bando DB on DB.idHeader=O.LinkedDoc
where C.tipodoc='RICHIESTA_COMPILAZIONE_DGUE' and C.Deleted=0







GO
