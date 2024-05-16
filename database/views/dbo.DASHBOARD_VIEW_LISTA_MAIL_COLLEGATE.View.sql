USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_LISTA_MAIL_COLLEGATE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



---------------------------------------------------------------
---------------------------------------------------------------

CREATE view [dbo].[DASHBOARD_VIEW_LISTA_MAIL_COLLEGATE] as
	select 
		   ct.ID,
		   case ct.TypeDoc
				when 'DOCUMENT' then c.TipoDoc
				else ct.TypeDoc
		   end as TypeDoc,
		   ct.TypeDoc AS FilterDoc,

		   ct.iddoc as IdDoc,
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
		   ProfiliUtente.idpfu,
		   'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
	       
	from dbo.CTL_Mail_System ct with(nolock)
			left join  ProfiliUtente with(nolock) on ct.IdPfuDest=ProfiliUtente.IdPfu
			left join  aziende with(nolock) on pfuIdAzi=idazi or ct.idAziDest = idazi
			left outer join ctl_doc c with(nolock) on  c.id=ct.iddoc and ( 'DOCUMENT' = ct.TypeDoc or ct.TypeDoc = c.TipoDoc ) 
			
	where ct.deleted=0 and InOut='OUT'
	
	union all 
	
	select 
		   ct.ID,
		   case ct.TypeDoc
				when 'DOCUMENT' then c.TipoDoc
				else ct.TypeDoc
		   end as TypeDoc,
		   ct.TypeDoc AS FilterDoc,

		   c.LinkedDoc as IdDoc,
		   
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
		   ProfiliUtente.idpfu,
		   'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
	       
	from dbo.CTL_Mail_System ct with(nolock)
			left join  ProfiliUtente with(nolock) on ct.IdPfuDest=ProfiliUtente.IdPfu
			left join  aziende with(nolock) on pfuIdAzi=idazi or ct.idAziDest = idazi
			left outer join ctl_doc c with(nolock) on  c.id=ct.iddoc and ( 'DOCUMENT' = ct.TypeDoc or ct.TypeDoc = c.TipoDoc ) 
			
	where ct.deleted=0 and InOut='OUT'

	
	





GO
