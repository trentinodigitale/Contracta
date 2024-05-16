USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Richiesta_CIG_Document]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[Richiesta_CIG_Document] as 

	select 
		case when G.idheader is not null or L.idheader is not null then '1' else '0' end as ErroreInInvio
		, C.* 
		, dbo.PARAMETRI('RICHIESTA_CIG_GARA_DELEGA','GestioneCiGconDelega','HIDE','0',-1) as SIMOGgareDelegaParam
		--, S.*
		from CTL_DOC C with(nolock)
			left outer join ( select idheader from Document_SIMOG_GARA_VIEW with(nolock) where StatoRichiestaGARA = 'Errore'  group by idheader ) as G on G.idheader = c.id --mi darà record solo in caso si errore
			left outer join ( select idheader from Document_SIMOG_LOTTI_VIEW with(nolock) where StatoRichiestaLOTTO = 'Errore'  group by idheader ) as L on L.idheader = c.id --mi darà record solo in caso si errore
			--cross join ( select  dbo.attivoSimog() as simog )  as S

GO
