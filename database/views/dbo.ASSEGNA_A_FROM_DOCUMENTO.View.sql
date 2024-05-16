USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ASSEGNA_A_FROM_DOCUMENTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[ASSEGNA_A_FROM_DOCUMENTO] as
select 
	  c.id,
	  c.id as ID_FROM,
	  c.id as linkedDoc,
	  c.TipoDoc as VersioneLinkedDoc,
	  p.pfunome as jumpcheck,
	  isnull( C.IdpfuInCharge , p.idpfu ) as Versione
from CTL_DOC c
		left join profiliUtente p on ( C.IdpfuInCharge = p.idpfu or ( c.tipodoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' ) and c.idpfu = p.idpfu ) )
--where c.tipodoc in ('VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN','CAMBIO_RAPLEG','RICHIESTA_UTENTI', 'ISTANZA_AlboOperaEco', 'ISTANZA_SDA_FARMACI','OFFERTA')



GO
