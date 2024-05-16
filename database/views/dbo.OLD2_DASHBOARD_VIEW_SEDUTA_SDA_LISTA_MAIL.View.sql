USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_SEDUTA_SDA_LISTA_MAIL]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_DASHBOARD_VIEW_SEDUTA_SDA_LISTA_MAIL] as
select 
       CV.IdHeader as ID,
       ct.TypeDoc,
	   CV.IdHeader as iddoc ,
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
       case when ct.idAziDest is not null then ct.idAziDest else  idazi end as idazi,
       ProfiliUtente.IdPfu,
       'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
       
from 
	CTL_DOC_Value CV with (nolock)
	
		inner join CTL_Mail_System ct with (nolock) on ct.IdDoc=cast(CV.Value as int)
		left join  ProfiliUtente with (nolock) on ct.IdPfuDest=ProfiliUtente.IdPfu
		left join  aziende with (nolock) on pfuIdAzi=idazi  or idAziDest = idazi
	
	where CV.DSE_ID='COMUNICAZIONI' and CV.DZT_Name='idDoc' and  ct.deleted=0 and InOut='OUT' 


GO
