USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_SCHEDA_ANAGRAFICA_OCP_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_SCHEDA_ANAGRAFICA_OCP_VIEW]
AS
--Versione=2&data=2014-09-01&Attivita=61998&Nominativo=Sabato

	SELECT d.*

		 , case when dzt.id is null then 0 else 1 end as OCP_Modulo_Attivo

	 FROM document_aziende d with(nolock)
		
		left join LIB_Dictionary dzt with(nolock) on dzt.DZT_Name = 'SYS_MODULI_RESULT' and SUBSTRING(dzt.dzt_valuedef, 424,1) = '1'

GO
