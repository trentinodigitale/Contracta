USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_ENTE_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[COM_DPE_ENTE_TESTATA_VIEW] as 

	select 
			c.idcom , p.idpfu , name , protocollo , 
			statocom , notacom , datacreazione , 
			datascadenzacom ,obbligo , 
			dataobbligo , p.pfuidazi as azienda,
			isnull( convert(varchar(100),DataScadenza,120) , '3000-12-31' ) as DataScadenza,
			RichiestaRisposta,
			f.IdComEnte,
			f.DataProtocolloGenerale,
			f.ProtocolloGenerale,
			convert(varchar(100),GetDate(),120) as DataCurr
		from Document_Com_DPE c with(nolock) 
			inner join profiliutente p with(nolock) on c.owner = p.idpfu
			inner join Document_Com_DPE_Enti f with(nolock) on f.IdCom=c.IdCom


GO
