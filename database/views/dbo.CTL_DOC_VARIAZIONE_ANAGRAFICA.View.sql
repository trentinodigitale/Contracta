USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_VARIAZIONE_ANAGRAFICA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[CTL_DOC_VARIAZIONE_ANAGRAFICA] as

	select case when i.statoInipec  <> 'NonPresente'  then '1' else '0' end Attiva_verifica_INIPEC, case when d.DZT_Name is not null then '1' else '0' end as INIPEC_ATTIVO
		, v.*

		from ctl_doc v
			left join lib_dictionary d with(nolock) on dzt_name = 'SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,GESTIONE_INIPEC,%' 
			left join Document_INIPEC i with(nolock) on i.idazi = v.azienda and i.idHeader = 0

GO
