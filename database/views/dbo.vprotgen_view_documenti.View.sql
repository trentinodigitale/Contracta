USE [AFLink_TND]
GO
/****** Object:  View [dbo].[vprotgen_view_documenti]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vprotgen_view_documenti] as
	select  a.id,
			cast( appl_id_evento as INT) as ID_DOC_DA_PROTOCOLLARE,
			Numero_Protocollo as PROTOCOLLO_GENERALE,
			Appl_Id_Evento as ID_DOC,
			case when Appl_Sigla = 'OFFERTA_BA' then b.Protocollo + '_BA_' + c.vatValore_FT else '' end as NOME_FILE_OFFERTA_BA
	from v_protgen a with(nolock)
			left join CTL_DOC b with(nolock) on b.Id = a.Appl_Id_Evento
			left join DM_Attributi c with(nolock) on c.lnk = b.Azienda and c.dztNome = 'codicefiscale'
	where ISNUMERIC(appl_id_evento) = 1 and flag_annullato = 0
GO
