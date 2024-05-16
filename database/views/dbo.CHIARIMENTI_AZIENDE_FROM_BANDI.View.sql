USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_AZIENDE_FROM_BANDI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CHIARIMENTI_AZIENDE_FROM_BANDI]  AS
select c.id_from,p.idpfu,a.aziragionesociale,a.azitelefono1,a.azifax,a.azie_mail from
aziende a,
profiliutente p,
CHIARIMENTI_PORTALE_FROM_BANDI c
where 
a.idazi=p.pfuidazi
and a.azivenditore <>0
and p.idpfu > 0
union all
select c.id_from,p.idpfu,'','','','' from
aziende a,
profiliutente p,
CHIARIMENTI_PORTALE_FROM_BANDI c
where 
a.idazi=p.pfuidazi
and a.azivenditore <>0
and p.idpfu < 0

union all
select c.id_from,p.idpfu,'Portale','','','' from
aziende a,
profiliutente p,
CHIARIMENTI_PORTALE_FROM_BANDI c
where 
a.idazi=p.pfuidazi
and a.azivenditore =0
and a.aziacquirente > 0
and p.idpfu>0






GO
