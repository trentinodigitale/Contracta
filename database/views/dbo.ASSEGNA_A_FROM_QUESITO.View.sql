USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ASSEGNA_A_FROM_QUESITO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ASSEGNA_A_FROM_QUESITO] as
select 
	  c.id,
	  c.id as ID_FROM,
	  c.id as linkedDoc,
	  /*c.TipoDoc*/ 'DETAIL_CHIARIMENTI_BANDO' as VersioneLinkedDoc,
	  p.pfunome as jumpcheck,
	  C.IdpfuInCharge as Versione
from document_chiarimenti c
		left join profiliUtente p on C.IdpfuInCharge = p.idpfu
--where c.tipodoc in ('VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN','CAMBIO_RAPLEG','RICHIESTA_UTENTI', 'ISTANZA_AlboOperaEco', 'ISTANZA_SDA_FARMACI','OFFERTA')


GO
