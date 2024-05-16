USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_BANDO_SELECT_AQ_FOR_NEW_RC]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_BANDO_SELECT_AQ_FOR_NEW_RC] as 


	select d.Id as ID_FROM , p.idpfu as idPfu_aderente, d.* ,s.*

		from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando s  with(nolock) on id = idheader
				left outer join CTL_DOC_Value b  with(nolock) on b.IdHeader = d.id and DSE_ID = 'ENTI' and DZT_Name = 'AZI_Ente' 
				inner join aziende a on ( b.Value = a.idazi ) or ( a.aziAcquirente > 0 and b.value is null )
				inner join profiliutente p  with(nolock) on  a.IdAzi = p.pfuidazi 
		where d.deleted = 0 and TipoDoc in ( 'BANDO_GARA' ) and TipoSceltaContraente = 'ACCORDOQUADRO'
				and d.statoFunzionale in ( 'InAggiudicazione' , 'InEsame' , 'Pubblicato' )
				and getDate() <= isnull( s.DataRiferimentoFine , getdate())





GO
