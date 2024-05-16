USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DOCUMENT_OFFERTA_PARTECIPANTI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_DOCUMENT_OFFERTA_PARTECIPANTI_VIEW]
AS


	select 
		C.*,ltrim(rtrim(TMF.Stato)) as StatoGD, tmf.idmsg as idPdA,'' as PresenzaDGUE
		,ISNULL(LZ.DZT_ValueDef,'NO') as  SYS_OFFERTA_PRESENZA_ESECUTRICI
	from 
		ctl_doc C, tab_messaggi_fields TMF
		left join LIB_Dictionary LZ on Lz.DZT_Name='SYS_OFFERTA_PRESENZA_ESECUTRICI' 
	where 
		C.tipodoc='offerta_partecipanti'
		and C.fascicolo=TMF.protocolbg
		and TMF.isubtype in (169,107)
		and c.jumpcheck='DocumentoGenerico'

union all

select 
	C.*, case C.statofunzionale when  ('InLavorazione') then '1' else '2' end as StatoGD,P.id  as idPdA,value as PresenzaDGUE
	,ISNULL(LZ.DZT_ValueDef,'NO') as  SYS_OFFERTA_PRESENZA_ESECUTRICI
from 
	ctl_doc C 
		left join document_pda_offerte DO on C.linkeddoc=DO.idmsg and DO.tipodoc='OFFERTA'
		left join ctl_doc P on P.id=DO.idheader and P.tipodoc='PDA_MICROLOTTI' and p.deleted=0
		left join ctl_doc offerta on offerta.id=DO.IdMsg
		left join CTL_DOC_Value CV on CV.IdHeader=offerta.LinkedDoc and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE'
		left join LIB_Dictionary LZ on Lz.DZT_Name='SYS_OFFERTA_PRESENZA_ESECUTRICI' 
	
where 
	C.tipodoc='offerta_partecipanti'
	--and C.fascicolo=TMF.protocolbg
	--and TMF.isubtype in (169,107)
	and c.jumpcheck<>'DocumentoGenerico'
	--and C.statofunzionale='Pubblicato'



GO
