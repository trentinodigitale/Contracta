USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONVENZIONE_IMPORTI_ENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[VIEW_CONVENZIONE_IMPORTI_ENTI] 
AS

select 
		TE.*, ( TE.rda_total/T.rda_total) *100  as PercComposizione,DASHBOARD_VIEW_QUOTA_VIEW.Importo as totale_allocato
	from 
	(
	SELECT 
		C.Linkeddoc as IdHeader,C.Linkeddoc as IdRow,C.Azienda as AZI_Ente, sum(rda_total) as rda_total , sum(TotaleEroso) as TotaleEroso
			from ctl_doc C
		 		inner join document_odc O on C.ID=O.RDA_ID
					--inner join document_microlotti_dettagli D on C.id=D.idheader and D.tipodoc='ODC'
			where 
				C.tipodoc = 'ODC' and C.jumpcheck = 'IMPEGNATO'  and C.statofunzionale in ('Inviato','InApprove','Accettato') and c.deleted = 0 
				--C.tipodoc = 'ODC' and C.jumpcheck <> 'STORNATO' and C.statofunzionale in ('Inviato','InApprove','Accettato') and c.deleted = 0 
			group by C.Linkeddoc,C.Azienda
	) TE inner join
		(
			SELECT 
			C.Linkeddoc as IdHeader,sum(rda_total) as rda_total , sum(TotaleEroso) as TotaleEroso
				from ctl_doc C
		 			inner join document_odc O on C.ID=O.RDA_ID
						--inner join document_microlotti_dettagli D on C.id=D.idheader and D.tipodoc='ODC'
				where 
					C.tipodoc = 'ODC' and C.jumpcheck = 'IMPEGNATO' and C.statofunzionale in ('Inviato','InApprove','Accettato') and c.deleted = 0 
					--C.tipodoc = 'ODC' and C.jumpcheck <> 'STORNATO' and C.statofunzionale in ('Inviato','InApprove','Accettato') and c.deleted = 0 
				group by C.Linkeddoc
		) T on TE.IdHeader = T.IdHeader
	
		left join DASHBOARD_VIEW_QUOTA_VIEW on DASHBOARD_VIEW_QUOTA_VIEW.LinkedDoc=TE.IdHeader and Value_tec__Azi=TE.AZI_Ente and DASHBOARD_VIEW_QUOTA_VIEW.StatoDoc in ('Sent','Sended')
		
GO
