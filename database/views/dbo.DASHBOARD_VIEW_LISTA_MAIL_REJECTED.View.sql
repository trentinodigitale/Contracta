USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_LISTA_MAIL_REJECTED]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[DASHBOARD_VIEW_LISTA_MAIL_REJECTED] as
select 
       ct.ID,
       case ct.TypeDoc
			when 'DOCUMENT' then c.TipoDoc
			else ct.TypeDoc
       end as TypeDoc,
       ct.TypeDoc AS FilterDoc,

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
       'Viewer.asp?OWNER=&ModGriglia=DASHBOARD_VIEW_MAIL_GUIDGriglia&ModFiltro=DASHBOARD_VIEW_MAIL_GUIDFiltro&Table=DASHBOARD_VIEW_MAIL_GUID_REJECTED&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=1&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
	   
       
from dbo.CTL_Mail_System ct with(nolock)
		left join  ProfiliUtente with(nolock) on ct.IdPfuDest=ProfiliUtente.IdPfu
		left join  aziende with(nolock) on pfuIdAzi=idazi or ct.idAziDest = idazi
		--left outer join messagefields a with(nolock) on a.mfidmsg=ct.iddoc and a.mfFieldName='IdDoc' and (cast( a.mfIType as varchar ) + ';' + cast( a.mfIsubtype as varchar ) = ct.TypeDoc or ct.TypeDoc = 'TAB_MESSAGGI')
		--left outer join messagefields b with(nolock) on  b.mfFieldName='IdDoc' and a.mfFieldValue=b.mfFieldValue
		left outer join ctl_doc c with(nolock) on  c.id=ct.iddoc and ( 'DOCUMENT' = ct.TypeDoc or ct.TypeDoc = c.TipoDoc ) 
		
where ct.deleted=0 and InOut='OUT' and ( ct.TypeDoc not like  '%;%' and ct.typeDoc <> 'TAB_MESSAGGI' )


union all

select 
       ct.ID,
       ct.TypeDoc as TypeDoc,
       ct.TypeDoc AS FilterDoc,

       a.mfidmsg as IdDoc,
       
       ct.MailGuid, 
       ct.MailFrom, 
       ct.MailTo, 
       cast(ct.MailObject as nvarchar(2000)) as MailObject ,
       cast(ct.MailBody as nvarchar(2000)) as MailBody ,
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
       --'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path
       'Viewer.asp?OWNER=&ModGriglia=DASHBOARD_VIEW_MAIL_GUIDGriglia&ModFiltro=DASHBOARD_VIEW_MAIL_GUIDFiltro&Table=DASHBOARD_VIEW_MAIL_GUID_REJECTED&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=1&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ ct.MailGuid + '''&FilteredOnly=no##900,800' as Path

 from messagefields a  with(NOLOCK)
 		inner join messagefields b  with(NOLOCK) on  b.mfFieldName='IdDoc' and a.mfFieldValue=b.mfFieldValue
        inner join CTL_Mail_System ct on  ct.IdDoc = b.mfIdMsg and ct.deleted=0 and InOut='OUT' 
							and (cast( b.mfIType as varchar ) + ';' + cast( b.mfIsubtype as varchar ) = ct.TypeDoc or ct.TypeDoc = 'TAB_MESSAGGI')
		left join  ProfiliUtente with(nolock) on ct.IdPfuDest=ProfiliUtente.IdPfu
		left join  aziende with(nolock) on pfuIdAzi=idazi 	or ct.idAziDest = idazi						 

where  a.mfFieldName='IdDoc' 

UNION ALL

-- union per prendere gli invitati (ctl_doc_destinatari + documento BANDO_SEMPLIFICATO_INVITO)
select 
       mail.ID,
       case mail.TypeDoc
			when 'DOCUMENT' then doc.TipoDoc
			else mail.TypeDoc
       end as TypeDoc,
	   doc.tipodoc as FilterDoc,
       doc.id  as IdDoc,
       mail.MailGuid, 
       mail.MailFrom, 
       mail.MailTo, 
       cast(mail.MailObject as nvarchar(2000)) as MailObject ,
       cast(mail.MailBody as nvarchar(2000)) as MailBody ,       
       mail.MailCC, 
       mail.MailCCn, 
       mail.MailData, 
       mail.MailObj, 
       mail.IdPfuMitt, 
       mail.IdPfuDest, 
       mail.Status, 
       mail.IsFromPec, 
       mail.IsToPec, 
       mail.InOut, 
       az.aziRagioneSociale,
	   case when mail.idAziDest is not null then mail.idAziDest else  az.idazi end as idazi,       
       pfu.idpfu,
       --'Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_MAIL_GUID&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=2&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ mail.MailGuid + '''&FilteredOnly=no##900,800' as Path
	   'Viewer.asp?OWNER=&ModGriglia=DASHBOARD_VIEW_MAIL_GUIDGriglia&ModFiltro=DASHBOARD_VIEW_MAIL_GUIDFiltro&Table=DASHBOARD_VIEW_MAIL_GUID_REJECTED&DOCUMENT=LISTA_MAIL&IDENTITY=ID&PATHTOOLBAR=../CustomDoc/&TOOLBAR=TOOLBAR_VIEW_LISTA_MAIL_REJECTED&AreaAdd=no&AreaFiltro=&AreaFiltroWin=1&DOCUMENT=&Caption=Conversazione&Height=180,100*,210&numRowForPag=20&ACTIVESEL=1&Sort=MailData&SortOrder=desc&Exit=si&FilterHide=MailGuid='''+ mail.MailGuid + '''&FilteredOnly=no##900,800' as Path   	
	
	
	from CTL_DOC doc
			inner join  CTL_DOC_Destinatari dest with(nolock) ON doc.id = dest.idHeader
			inner join  CTL_Mail_System mail with(nolock) ON mail.idDoc = dest.idRow and mail.typedoc in ( 'BANDO_SEMPLIFICATO_INVITO' )
			left join ProfiliUtente pfu with(nolock) ON mail.IdPfuDest=pfu.IdPfu
			left join aziende az with(nolock) on pfu.pfuIdAzi=az.idazi or mail.idAziDest = az.idazi

	where  mail.deleted=0 and InOut='OUT' and ( mail.TypeDoc not like  '%;%' and mail.typeDoc <> 'TAB_MESSAGGI' )





GO
