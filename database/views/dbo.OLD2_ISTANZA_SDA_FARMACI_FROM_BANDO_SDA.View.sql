USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_ISTANZA_SDA_FARMACI_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OLD2_ISTANZA_SDA_FARMACI_FROM_BANDO_SDA]  as
--Versione=2&data=2014-09-03&Attivita=62233&Nominativo=Sabato

SELECT distinct  

	id as ID_FROM ,
	Fascicolo,
	Versione,
	id as LinkedDoc,
	PrevDoc,
	--DataScadenza,
	DATACORRENTE,
	RichiestaFirma,
	SIGN_LOCK,
	SIGN_ATTACH,
	ProtocolloGenerale as ProtocolloRiferimento,
	StrutturaAziendale ,
    TipoBando
FROM         CTL_DOC_VIEW  
			inner join Document_Bando on id = idHeader

	where TipoDoc='BANDO_SDA'



GO
