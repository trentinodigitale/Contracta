USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_PARTECIPANTI_STORICO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OFFERTA_PARTECIPANTI_STORICO]
AS
select 	
	c1.id,
	c1.id as STORICOGrid_ID_DOC,
	c1.protocollo,
	c1.data,
	c1.Idpfu,
	'OFFERTA_PARTECIPANTI' as STORICOGrid_OPEN_DOC_NAME,
	c2.id as LinkModified, 
	c1.Idpfu as APS_IdPfu
from ctl_doc C1 inner join ctl_doc c2 on c1.linkeddoc=c2.linkeddoc
where C1.tipodoc ='OFFERTA_PARTECIPANTI' and C2.tipodoc ='OFFERTA_PARTECIPANTI' and c1.statofunzionale in ('Annullato','Pubblicato') and c2.statofunzionale in ('Annullato','Pubblicato','InLavorazione')
GO
