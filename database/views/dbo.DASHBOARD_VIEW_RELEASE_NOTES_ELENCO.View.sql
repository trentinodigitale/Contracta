USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RELEASE_NOTES_ELENCO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW	[dbo].[DASHBOARD_VIEW_RELEASE_NOTES_ELENCO] as


	select  
			CA.ATV_id as id,
			CA.ATV_id as idheader,
			CA.ATV_IdPfu as idpfu,
			CV.value as Release,
			C.DataInvio,
			C.Protocollo,					
			CA.ATV_Object as Descrizione,
			CA.ATV_Object as Descrizioneestesa,
			CA.ATV_DocumentName as OPEN_DOC_NAME,
			CA.ATV_Execute,
			CV2.Value as DataPubblicazione
			,convert( varchar(10) , cv2.Value , 121 )   as Datainviodal 
			,convert( varchar(10) , cv2.Value , 121 )   as Datainvioal 

		from CTL_Attivita CA WITH(NOLOCK)
			inner join ctl_doc c WITH(NOLOCK) on C.id=CA.ATV_IdDoc
			left join CTL_DOC_Value CV with(NOLOCK) on cv.IdHeader=C.id and cv.DSE_ID='INFO' and cv.DZT_Name='Release'
			left join CTL_DOC_Value CV2 with(NOLOCK) on cv2.IdHeader=id and cv2.DSE_ID='INFO' and cv2.DZT_Name='DataPubblicazione'
			where CA.ATV_DocumentName in ('RELEASE_NOTES_IA')



GO
