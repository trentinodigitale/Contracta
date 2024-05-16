USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_AlboOperaEco_FROM_BANDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[ISTANZA_AlboOperaEco_FROM_BANDO]  as
--Versione=2&data=2014-09-03&Attivita=62233&Nominativo=Sabato

SELECT distinct  

id as ID_FROM ,
Fascicolo,
id as LinkedDoc,
PrevDoc,
--DataScadenza,
DATACORRENTE,
RichiestaFirma,
SIGN_LOCK,
SIGN_ATTACH,
ProtocolloGenerale as ProtocolloRiferimento,
StrutturaAziendale                   
FROM         CTL_DOC_VIEW  

	where TipoDoc='BANDO'

GO
