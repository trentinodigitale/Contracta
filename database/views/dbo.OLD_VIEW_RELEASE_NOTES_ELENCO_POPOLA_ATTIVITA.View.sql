USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_RELEASE_NOTES_ELENCO_POPOLA_ATTIVITA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW	[dbo].[OLD_VIEW_RELEASE_NOTES_ELENCO_POPOLA_ATTIVITA] as


select  
	w.id,
	w.id as idheader,
	w.idpfu,
	CV.value as Release,
	C.DataInvio,
	C.Protocollo,
	case 
		when  ISNULL(M.mpIdAziMaster,0) > 0  and  a.aziAcquirente > 0 then ISNULL(cv3.Value ,'') + '
			' + ISNULL(cv1.Value ,'') 
		when  ISNULL(M.mpIdAziMaster,0) > 0  and  a.aziVenditore > 0 then ISNULL(cv3.Value ,'') + '
			' + ISNULL(cv2.Value ,'') 
		when  a.aziVenditore > 0 then cv2.Value 
		when  a.aziAcquirente > 0 then cv1.Value 
	end as Descrizione,
	--case 
	--	when  ISNULL(M.mpIdAziMaster,0) > 0  and  a.aziAcquirente > 0 then 'RELEASE_NOTES_IA'
	--	when  ISNULL(M.mpIdAziMaster,0) > 0  and  a.aziVenditore > 0  then 'RELEASE_NOTES_IA'
	--	when  a.aziVenditore > 0 then 'RELEASE_NOTES_IA_OE'
	--	when  a.aziAcquirente > 0 then 'RELEASE_NOTES_IA_ENTE'
	--end as OPEN_DOC_NAME
	'RELEASE_NOTES_IA' as OPEN_DOC_NAME
		

from
	 ( 
		select distinct
					id
					,P.idpfu									
					from ctl_doc with(NOLOCK)
						left join CTL_DOC_Value CV1 with(NOLOCK) on cv1.IdHeader=id and cv1.DSE_ID='DETTAGLI' and cv1.DZT_Name='Profilo_Destinazione'					
						cross join aziende A with(NOLOCK) 
						Left join MarketPlace M with(NOLOCK)  on M.mpIdAziMaster=A.IdAzi
						LEFT JOIN ProfiliUtente p with(NOLOCK) ON p.pfuIdAzi=A.IdAzi and (  
																							( A.aziVenditore > 0 and CV1.Value like '%OE%') or 
																							( A.aziAcquirente > 0  and CV1.Value like '%Ente%' ) or 
																							ISNULL(CV1.Value,'')='' or
																							( M.mpIdAziMaster > 0  and CV1.Value like '%Gestore%')
																						  )
					where TipoDoc='RELEASE_NOTES' and deleted=0 and StatoFunzionale='Pubblicato' and P.pfuDeleted=0 and ISNULL(P.IdPfu,0)>0 
		) as w
		inner JOIN ProfiliUtente p with(NOLOCK) ON p.idpfu=w.Idpfu
		inner JOIN aziende a with(NOLOCK) ON a.IdAzi=p.pfuIdAzi
		left JOIN MarketPlace M with(NOLOCK) ON M.mpIdAziMaster=p.pfuIdAzi
		left join CTL_DOC_Value CV with(NOLOCK) on cv.IdHeader=W.id and cv.DSE_ID='INFO' and cv.DZT_Name='Release'
		left join CTL_DOC_Value CV1 with(NOLOCK) on cv1.IdHeader=W.id and cv1.DSE_ID='INFO' and cv1.DZT_Name='descrizione_ente'
		left join CTL_DOC_Value CV2 with(NOLOCK) on cv2.IdHeader=W.id and cv2.DSE_ID='INFO' and cv2.DZT_Name='descrizione_fornitore'
		left join CTL_DOC_Value CV3 with(NOLOCK) on cv3.IdHeader=W.id and cv3.DSE_ID='INFO' and cv3.DZT_Name='descrizione_gestore'		
		inner join ctl_doc C with(NOLOCK) on C.id=W.id
		--where  P.idpfu=45094 












GO
