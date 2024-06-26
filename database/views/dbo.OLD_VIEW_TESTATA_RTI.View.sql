USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_TESTATA_RTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_VIEW_TESTATA_RTI] as
select 
	*
from 
	ctl_doc_value 

union all

select 
	CV.IdRow,CV.IdHeader,cv.DSE_ID,cv.Row,'LblModificaPartecipanti' as DZT_Name, 
	'<img alt="Attenzione:Partecipanti Modificati" src="../../ctl_library/images/domain/ReportWarning.gif"><a href="../../ctl_library/path.asp?url=ctl%5Flibrary%2Fdocument%2Fuserdocument%2Easp%3FMODE%3DSHOW%26lo%3Dbase%26JScript%3DOFFERTA%5FPARTECIPANTI%26DOCUMENT%3DOFFERTA%5FPARTECIPANTI%26IDDOC%3D' + cast(OP.id as varchar) +'&KEY=document">' +
	dbo.CNV('clicca qui per la modifica dei partecipanti','I') + '</a>' as Value
from 
	ctl_doc C 
		left join ctl_doc_value CV on C.id=CV.Idheader and c.tipodoc='OFFERTA' and CV.dzt_name='DenominazioneATI'
		left join ctl_doc OP on OP.linkeddoc=C.id and OP.tipodoc='OFFERTA_PARTECIPANTI' and OP.statofunzionale='pubblicato'
		left join ctl_doc_value OPV on OPV.idheader=OP.id and OPV.dzt_name='DenominazioneATI'
where 	
	isnull(CV.value,'')<>isnull(OPV.value,'')
GO
