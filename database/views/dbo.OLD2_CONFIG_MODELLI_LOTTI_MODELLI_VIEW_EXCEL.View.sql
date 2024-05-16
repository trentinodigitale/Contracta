USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CONFIG_MODELLI_LOTTI_MODELLI_VIEW_EXCEL]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_CONFIG_MODELLI_LOTTI_MODELLI_VIEW_EXCEL]
as

	select B.CIG , G.Titolo , G.Body , G.id as ID_DOC ,  m.* 
		from 
			(
				select * from 
				(
					select idheader,  row, value, dzt_name
					from CTL_DOC_Value  with(nolock)
					where ( (dse_id = 'MODELLI' ) )
        
				) as P
					pivot
					(
						min(value)
						--value
						for p.dzt_name in ([Descrizione],
											[LottoVoce],
											[MOD_Bando],
											[MOD_BandoSempl],
											[MOD_Cauzione],
											[MOD_ConfDett],
											[MOD_ConfLista],
											[MOD_Offerta],
											[MOD_OffertaDrill],
											[MOD_OffertaInd],
											[MOD_OffertaINPUT],
											[MOD_OffertaTec],
											[MOD_PDA],
											[MOD_PDADrillLista],
											[MOD_PDADrillTestata],
											[MOD_PERFEZIONAMENTO_CONTRATTO],
											[MOD_SCRITTURA_PRIVATA],
											[NonEditabili],
											[Numero_Decimali],
											[NumeroDec],
											[Presenza_Obbligatoria],
											[TipoFile]
											 )
					) as PIV
			) as M
			inner join  ctl_doc d with(nolock) on d.id = M.idheader
			inner join  ctl_doc G with(nolock) on G.id = d.LinkedDoc
			inner join  Document_Bando B with(nolock) on B.idheader = d.LinkedDoc

GO
