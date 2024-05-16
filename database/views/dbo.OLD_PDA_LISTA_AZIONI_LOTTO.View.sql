USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_LISTA_AZIONI_LOTTO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_PDA_LISTA_AZIONI_LOTTO] as
	select d.* , tipodoc + '.800.600' as OPEN_DOC_NAME
		from CTL_Doc d with (nolock)
				inner join profiliutente p with (nolock) on d.IdPfu = p.IdPfu 
		where tipodoc in ( 'DECADENZA','ESITO_LOTTO_ANOMALIA','RETT_VALORE_LOTTO_AGG' , 'ESITO_ECO_LOTTO_AMMESSA' , 'ESITO_ECO_LOTTO_ANNULLA' , 
							'ESITO_ECO_LOTTO_ESCLUSA' , 'ESITO_ECO_LOTTO_VERIFICA' ,'RETT_VALORE_ECONOMICO', 'PDA_VALUTA_LOTTO_ECO' ) 
					and StatoDoc in (  'Sended' ) and isnull(StatoFunzionale,'') <> 'Annullato' and Deleted = 0




GO
