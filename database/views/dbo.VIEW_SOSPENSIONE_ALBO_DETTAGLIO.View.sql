USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_SOSPENSIONE_ALBO_DETTAGLIO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_SOSPENSIONE_ALBO_DETTAGLIO] as 
select  
		c.ID ,
		c.ID as IdHeader,
		c.ID as IDRow,
		a.ANAGDOC,
		a.allegato
from AZIENDE_DOCUMENTAZIONE  a
inner join CTL_DOC c  on a.idazi=c.Azienda
where c.tipodoc='SOSPENSIONE_ALBO' and a.StatoDocumentazione='Scaduto' and ISNULL(c.LinkedDoc,0)=0 and a.Deleted=0
union
select 
		ca.IdHEader as ID ,
		ca.IdHEader ,
		ca.IDRow as IDRow,
		ca.ANAGDOC,
		ca.allegato
from CTL_DOC_ALLEGATI ca
inner join CTL_DOC ct on idHeader=ID
where ct.tipodoc='SOSPENSIONE_ALBO' 



GO
