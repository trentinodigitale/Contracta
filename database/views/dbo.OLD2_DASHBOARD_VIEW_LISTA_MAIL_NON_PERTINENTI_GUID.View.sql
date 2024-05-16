USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_LISTA_MAIL_NON_PERTINENTI_GUID]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[OLD2_DASHBOARD_VIEW_LISTA_MAIL_NON_PERTINENTI_GUID] as
select 
       ct.ID,

      -- isnull(b.mfidmsg,ct.iddoc) as IdDoc,
       ct.iddoc  as IdDoc,
       ct.MailGuid, 
       ct.MailFrom, 
       ct.MailTo, 
       cast(ct.MailObject as nvarchar(2000)) as MailObject ,
       cast(ct.MailBody as nvarchar(2000)) as MailBody ,       
       ct.MailCC, 
       ct.MailCCn, 
       ct.MailData, 
       'Mail' + ct.MailObj as MailObj, 
       ct.IdPfuMitt, 
       ct.IdPfuDest, 
       ct.Status, 
       ct.IsFromPec, 
       ct.IsToPec, 
       ct.InOut, 

	   notify.mailobj as attach,

       'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
       


from dbo.CTL_Mail_System ct with(nolock)
	
	left outer join dbo.CTL_Mail_System notify with(nolock) on notify.iddoc=ct.id and notify.TypeDoc = 'MAIL_REJECTED'
																	and notify.inout='out'and notify.datasent is not null
		
where ct.deleted=0 and ct.InOut='IN' --and ct.IdDoc = -1 
		and isnull( ct.MailGuid , '' ) <> ''
		and ct.TypeDoc = 'MAIL_REJECTED'

GO
