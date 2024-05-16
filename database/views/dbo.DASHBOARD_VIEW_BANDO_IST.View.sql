USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDO_IST]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_BANDO_IST] as 
	select 
		   ct.ID,
		   case ct.TypeDoc
				when 'DOCUMENT' then c.TipoDoc
				else ct.TypeDoc
		   end as TypeDoc,
		  -- ct.TypeDoc AS FilterDoc,

		     case ct.TypeDoc
				when 'BANDO_REVOCATO' then 'REVOCA_BANDO'
				else ct.TypeDoc
		   end as FilterDoc,
		  
		   c.id as IdDoc,
		   
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
	       
	       from  CTL_Mail_System ct with (nolock)
				inner join CTL_Mail cm with(nolock) on   cm.id=ct.IdDoc 
				inner join ctl_doc c with(nolock) on c.id=cm.iddoc and c.TipoDoc in ('RETTIFICA_BANDO','PROROGA_BANDO','REVOCA_BANDO')

				left join  ProfiliUtente with(nolock) on ct.IdPfuDest=ProfiliUtente.IdPfu
				left join  aziende with(nolock) on pfuIdAzi=idazi or ct.idAziDest = idazi

			

			
			where ct.deleted=0 and InOut='OUT'
GO
