USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_CONSULTAZIONE_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_BANDO_CONSULTAZIONE_TESTATA_VIEW] AS
 select
	b.*,
	C.*,
	v2.Value as UserRUP,
	case when getdate() >= b.DataScadenzaOfferta and c.StatoFunzionale <> 'InLavorazione' then '1' else '0' end as SCADENZA_INVIO_RISPOSTE,
	a.aziRagioneSociale,
	C.Azienda as StazioneAppaltante
 from CTL_DOC C with(NOLOCK)
	inner join Document_Bando b with(NOLOCK) on C.id = b.idheader
	left outer join CTL_DOC_Value v2 with(NOLOCK) on b.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'
	inner join aziende a with(nolock) on c.azienda = a.IdAzi
where /*C.deleted=0
	 and */TipoDoc='BANDO_CONSULTAZIONE'
GO
