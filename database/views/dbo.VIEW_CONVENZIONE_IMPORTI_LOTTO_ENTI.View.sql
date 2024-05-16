USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONVENZIONE_IMPORTI_LOTTO_ENTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_CONVENZIONE_IMPORTI_LOTTO_ENTI] 
AS

select 
		CL.idrow as IdHeader , CL.idrow as IDROW, TE.AZI_Ente,TE.rda_total , isnull(E.Impegnato,0) as TotaleEroso, ( TE.rda_total/T.rda_total) *100  as PercComposizione
		,DASHBOARD_VIEW_QUOTA_VIEW.Importo as totale_allocato
	from 

	document_convenzione_lotti CL	with (nolock) inner join
		(
		--ordinato per convenzione - lotto - ente
		SELECT 
			C.Linkeddoc as IdHeader,C.Azienda as AZI_Ente, numerolotto,
			--sum(qty*valoreeconomico) as rda_total 
			sum ( qty*valoreeconomico + isnull(ValoreAccessorioTecnico,0) ) as rda_total 
			--, case 
			--	when isnull(erosione,'si')='si' then sum(qty*valoreeconomico) 
			--end as impegnato

				from ctl_doc C with (nolock)
		 			inner join document_odc O with (nolock) on C.ID=O.RDA_ID
						inner join document_microlotti_dettagli D  with (nolock) on C.id=D.idheader and D.tipodoc='ODC' 
				where 
					C.tipodoc = 'ODC' and C.jumpcheck = 'IMPEGNATO' and C.statofunzionale in ('Inviato','Accettato')
					and C.Deleted=0
				group by C.Linkeddoc,C.Azienda,numerolotto--,erosione

		) TE on TE.IdHeader=CL.idheader and CL.numerolotto=TE.numerolotto

		
		inner join
			(
				--ordinato per convenzione - lotto
				SELECT 
					C.Linkeddoc as IdHeader,numerolotto, --sum(qty*valoreeconomico) as rda_total
					sum ( qty*valoreeconomico + isnull(ValoreAccessorioTecnico,0) ) as rda_total 
					from ctl_doc C  with (nolock) 
		 				inner join document_odc O  with (nolock)  on C.ID=O.RDA_ID
							inner join document_microlotti_dettagli D  with (nolock)  on C.id=D.idheader and D.tipodoc='ODC'
					where 
						C.tipodoc = 'ODC' and C.jumpcheck = 'IMPEGNATO' and C.statofunzionale in ('Inviato','Accettato')
						and C.Deleted=0
					group by C.Linkeddoc,numerolotto

			) T on TE.IdHeader = T.IdHeader and TE.numerolotto = T.numerolotto
		
		left join
			(
			--eroso per convenzione - lotto - ente
			SELECT 
					C.Linkeddoc as IdHeader,C.Azienda as AZI_Ente, numerolotto,--sum(qty*valoreeconomico) as impegnato
					sum ( qty*valoreeconomico + isnull(ValoreAccessorioTecnico,0) ) as impegnato 
					from ctl_doc C  with (nolock) 
		 				inner join document_odc O  with (nolock)  on C.ID=O.RDA_ID
							inner join document_microlotti_dettagli D  with (nolock)  on C.id=D.idheader and D.tipodoc='ODC' and isnull(erosione,'si')='si'
					where 
						C.tipodoc = 'ODC' and C.jumpcheck = 'IMPEGNATO' and C.statofunzionale in ('Inviato','Accettato')
						and C.Deleted=0
					group by C.Linkeddoc,C.Azienda,numerolotto

			) E on E.IdHeader=CL.idheader and CL.numerolotto=E.numerolotto and E.AZI_Ente=TE.AZI_Ente

		left join DASHBOARD_VIEW_QUOTA_VIEW on DASHBOARD_VIEW_QUOTA_VIEW.LinkedDoc=TE.IdHeader and Value_tec__Azi=TE.AZI_Ente and DASHBOARD_VIEW_QUOTA_VIEW.StatoDoc in ('Sent','Sended')


GO
