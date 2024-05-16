USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_FORMULARI_DETTAGLI_IA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_FORMULARI_DETTAGLI_IA] AS

	Select 
		cv1.IdRow,
		CA.ATV_ID as IdHeader,		
		--CA.ATV_IdDoc  as IdHeader,	
		cv1.DSE_ID,
		cv1.DZT_Name,
		cv1.Value as Profilo_Destinazione,
		cv2.Value as Note,
		cv3.Value as Allegato,
		P.IdPfu as owner,
		Cv1.Row			
	from CTL_DOC_Value CV1 with(NOLOCK) 
		inner join CTL_Attivita CA with(NOLOCK) on CA.ATV_IdDoc=CV1.IdHeader and CA.ATV_DocumentName in ('FORMULARI_IA')
		--inner join 
		--	( select ATV_IdDoc,max(atv_id) as atv_id
		--		from CTL_Attivita with(NOLOCK)
		--			where ATV_DocumentName = 'FORMULARI_IA'
		--				group by ATV_IdDoc
		--	) CA on CA.ATV_IdDoc=CV1.IdHeader

		cross join aziende A with(NOLOCK) 
		Left join MarketPlace M with(NOLOCK)  on M.mpIdAziMaster=A.IdAzi
		LEFT JOIN ProfiliUtente p with(NOLOCK) ON p.pfuIdAzi=A.IdAzi and (  
																			( A.aziVenditore > 0 and CV1.Value like '%OE%') or 
																			( A.aziAcquirente > 0  and CV1.Value like '%Ente%' ) or 
																			ISNULL(CV1.Value,'')='' or
																			( M.mpIdAziMaster > 0  and CV1.Value like '%Gestore%')
																			)
		inner join CTL_DOC_Value CV2 with(NOLOCK) on CV1.IdHeader=Cv2.IdHeader and CV1.Row=Cv2.Row and CV2.DSE_ID='DETTAGLI' and  cv2.DZT_Name='Note'
		left join CTL_DOC_Value CV3 with(NOLOCK) on CV1.IdHeader=Cv3.IdHeader and CV1.Row=Cv3.Row and CV3.DSE_ID='DETTAGLI' and  cv3.DZT_Name='Allegato'
	where  CV1.DSE_ID ='DETTAGLI' and cv1.DZT_Name='Profilo_Destinazione' and P.pfuDeleted=0 and ISNULL(P.IdPfu,0)>0 

GO
