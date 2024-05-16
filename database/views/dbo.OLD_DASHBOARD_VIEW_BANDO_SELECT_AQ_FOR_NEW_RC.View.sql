USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_BANDO_SELECT_AQ_FOR_NEW_RC]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_BANDO_SELECT_AQ_FOR_NEW_RC] as 


	select d.Id as ID_FROM , p.idpfu as idPfu_aderente, d.* ,s.*

		from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando s  with(nolock) on id = idheader
				left outer join CTL_DOC_Value b  with(nolock) on b.IdHeader = d.id and DSE_ID = 'ENTI' and DZT_Name = 'AZI_Ente' 
				inner join aziende a on ( b.Value = a.idazi ) or ( a.aziAcquirente > 0 and b.value is null )
				inner join profiliutente p  with(nolock) on  a.IdAzi = p.pfuidazi 
				inner join CTL_DOC PDA with(nolock) on d.id = PDA.LinkedDoc and PDA.TipoDoc = 'PDA_MICROLOTTI' and PDA.deleted = 0 
				inner join ( select distinct idheader from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_MICROLOTTI'  and Voce = 0 and StatoRiga = 'AggiudicazioneDef' ) PL on PL.idheader=PDA.id
		where d.deleted = 0 and d.TipoDoc in ( 'BANDO_GARA' ) and TipoSceltaContraente = 'ACCORDOQUADRO'
				and d.statoFunzionale in ( 'InAggiudicazione' , 'InEsame' , 'Pubblicato' )
				and getDate() <= isnull( s.DataRiferimentoFine , getdate())
				and TipoAccordoQuadro = 'multiround'






GO
