USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_OE_FROM_AVCP_GRUPPO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[AVCP_OE_FROM_AVCP_GRUPPO] as
select
	id as ID_FROM,
	id as PrevDoc,
	Fascicolo,
	LinkedDoc,
	C1.Value as Aggiudicatario,
	C2.Value as aziIdDscFormaSoc,
	C3.Value as RagioneSociale


from ctl_doc 
left join ctl_doc_value C1 on C1.idheader=id and C1.DSE_ID='TESTATA' and C1.Dzt_Name='Aggiudicatario'
left join ctl_doc_value C2 on C2.idheader=id and C2.DSE_ID='TESTATA' and C2.Dzt_Name='aziIdDscFormaSoc'
left join ctl_doc_value C3 on C3.idheader=id and C3.DSE_ID='TESTATA' and C3.Dzt_Name='RagioneSociale'
where tipodoc='AVCP_GRUPPO'

GO
