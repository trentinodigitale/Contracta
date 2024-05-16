USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_COME_ESITO_GARA_LISTA_MAIL]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_DASHBOARD_VIEW_COME_ESITO_GARA_LISTA_MAIL] as
select 
       ct.ID,
       ct.TypeDoc,
       ct.iddoc ,
       ct.MailGuid, 
       ct.MailFrom, 
       ct.MailTo, 
       ct.MailObject, 
       ct.MailBody, 
       ct.MailCC, 
       ct.MailCCn, 
       ct.MailData, 
       ct.MailObj, 
       ct.IdPfuMitt, 
       ct.IdPfuDest, 
       ct.Status, 
       ct.IsFromPec, 
       ct.IsToPec, 
       ct.InOut, 
       aziRagioneSociale,
       idazi,
       ProfiliUtente.IdPfu,
       'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
       
from dbo.CTL_Mail_System ct 
		left join  ProfiliUtente on ct.IdPfuDest=ProfiliUtente.IdPfu
		left join  aziende on pfuIdAzi=idazi 
where ct.deleted=0 and InOut='OUT' and typedoc in ('COM_ESITO_GARA')
--and ct.iddoc=23594

union all

select 
       ct.ID,
       'COM_ESITO_GARA' as TypeDoc,
       cf.idrow as IdDoc,  
       ct.MailGuid, 
       ct.MailFrom, 
       ct.MailTo, 
       ct.MailObject, 
       ct.MailBody, 
       ct.MailCC, 
       ct.MailCCn, 
       ct.MailData, 
       ct.MailObj, 
       ct.IdPfuMitt, 
       ct.IdPfuDest, 
       ct.Status, 
       ct.IsFromPec, 
       ct.IsToPec, 
       ct.InOut, 
       aziRagioneSociale,
       idazi,
       ProfiliUtente.idpfu,
       'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
       
from dbo.CTL_Mail_System ct 
		left join  ProfiliUtente on ct.IdPfuDest=ProfiliUtente.IdPfu
		left join  aziende on pfuIdAzi=idazi 
		left outer join Document_EsitoGara c on  c.id=ct.iddoc
        left outer join Document_EsitoGara_fornitori cf on  cf.idheader=ct.iddoc and c.id=cf.idheader 

where ct.deleted=0 and InOut='OUT' and typedoc in ('ESITO_GARA')  and ct.IdPfuDest=-1
GO
