USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_UTENTI_COMMISSIONI_NONCENSITI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_UTENTI_COMMISSIONI_NONCENSITI]
AS

   
   select * from Document_CommissionePda_Utenti where idrow in 
	   ( 
		--prendo a parità di codice fiscale gli ultimi dati inseriti
		select 
		max (idrow)  from 
			ctl_doc C inner join Document_CommissionePda_Utenti CU on C.id=CU.IdHeader
		where 
			C.tipodoc='COMMISSIONE_PDA' and C.StatoFunzionale='Pubblicato' and isnull(codicefiscale,'')<>'' and utentecommissione=''
		group by  CU.codicefiscale

		) 
	


GO
