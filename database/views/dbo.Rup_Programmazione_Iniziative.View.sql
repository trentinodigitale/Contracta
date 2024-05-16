USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Rup_Programmazione_Iniziative]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW
	
	[dbo].[Rup_Programmazione_Iniziative]

	as

	select 
		NumeroDocumento as ID_Iniziativa,UserRup
			from CTL_DOC with (nolock)
				inner join Document_programmazione_iniziativa with (nolock) on idheader= id

			where
				Tipodoc='PROGRAMMAZIONE_INIZIATIVA' and deleted=0 and StatoFunzionale in  ('Approved', 'Revised')

		union
	select
		'I0000' as ID_Iniziativa , DMV_COD
			from ELENCO_RESPONSABILI_AZI where RUOLO in ('RUP','RUP_PDG')
GO
