USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_ALLEGATI_PROTOCOLLO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_VIEW_ALLEGATI_PROTOCOLLO] AS

	select  a.id,
			b.IdRow,
			b.[Value] as Allegato
		from v_protgen a with(nolock) 
				inner join CTL_DOC_Value b with(nolock) on b.IdHeader = CAST(a.Appl_Id_Evento as int) and b.DSE_ID = 'allegati_protocollo' and b.DZT_Name IN ( 'Allegato', 'Allegato_ODC')
		where a.Appl_Sigla not in ( 'CHIARIMENTI_PORTALE','DETAIL_CHIARIMENTI_BANDO' )
		 
	UNION ALL

		select  a.id,
				b.IdRow,
				b.[Value] as Allegato
			from v_protgen a with(nolock) 
					inner join Document_Chiarimenti_Protocollo b with(nolock) ON b.IdHeader = CAST(a.Appl_Id_Evento as int) and b.DZT_Name IN (  'Allegato', 'Allegato_risp_quesito' )
			where a.Appl_Sigla in ( 'CHIARIMENTI_PORTALE','DETAIL_CHIARIMENTI_BANDO' )

	UNION ALL

		select  a.id,
				b.IdRow,
				b.[Value] as Allegato
			from v_protgen a with(nolock) 
					inner join Document_Microlotti_DOC_Value b with(nolock) ON b.IdHeader = CAST(a.Appl_Id_Evento as int) and b.DZT_Name in ( 'Allegato', 'Allegato_BE') and b.DSE_ID = 'allegati_protocollo'
			where a.Appl_Sigla in ( 'OFFERTA_BT', 'OFFERTA_BE' )

	UNION ALL

		select  a.id,
				b.IdRow,
				b.[Value] as Allegato
			from v_protgen a with(nolock) 
					inner join Document_COM_DPE_Allegati_Protocollo b with(nolock) ON b.IdHeader = CAST(a.Appl_Id_Evento as int) and b.DZT_Name in ( 'Allegato') and b.DSE_ID = 'allegati_protocollo'
			where a.Appl_Sigla in ( 'COM_DPE_FORNITORE' )
	
	

GO
