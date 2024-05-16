USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_LISTA_MOTIVAZIONE_ESITI_LOTTO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[PDA_LISTA_MOTIVAZIONE_ESITI_LOTTO] as
select d.* , tipodoc + '.800.600' as OPEN_DOC_NAME
		
		from CTL_Doc d
		where ( tipodoc like 'ESITO_LOTTO%' or tipodoc = 'PDA_VALUTA_LOTTO_TEC'  )
			and StatoDoc = 'Sended'
			and deleted = 0
GO
