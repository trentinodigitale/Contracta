USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_RICHIESTAQUOTA_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OLD_DASHBOARD_VIEW_RICHIESTAQUOTA_FROM_CONVENZIONE] as
select 
DOC_OWNER,
ID,
id as ID_FROM,
protocol as ProtocolloRiferimento,
NumOrd,
Total,
DOC_NAME as BodyContratto,
Id as LinkedDoc,
A.idazi as Azienda,
P.idpfu as IdPfuFrom,
'RICHIESTAQUOTA' as TIPODOC
from Document_Convenzione ,aziende A , profiliutente P
where 
	Deleted = 0
	and A.azivenditore=0
	and A.idazi=P.pfuidazi
	--and A.idazi not in (select mpIdAziMaster from marketplace)
	and statoConvenzione='Pubblicato'


GO
