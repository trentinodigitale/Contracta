USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_FILTER_CONFORMITA_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[VIEW_FILTER_CONFORMITA_BANDO_SEMPLIFICATO] as 

	select Codice , 'No' as conformita 
		from Document_Modelli_MicroLotti 
		where Conformita like '%###No###%' and deleted=0

	union

	select Codice , 'Ex-Ante' as conformita 
		from Document_Modelli_MicroLotti 
		where Conformita like '%###Ex-Ante###%'  and deleted=0

	union

	select Codice , 'Ex-Post' as conformita 
		from Document_Modelli_MicroLotti 
		where Conformita like '%###Ex-Post###%'  and deleted=0

GO
