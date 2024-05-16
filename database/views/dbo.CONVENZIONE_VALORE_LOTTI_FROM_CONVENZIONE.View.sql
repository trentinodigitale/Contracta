USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_VALORE_LOTTI_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CONVENZIONE_VALORE_LOTTI_FROM_CONVENZIONE] as 
select

	  C.id as ID_FROM ,
	  idRow, 
	  idHeader, 
	   
	  StatoLottoConvenzione, 
	  NumeroLotto, 
	  Descrizione, 
	  Importo, 
	  Impegnato, 
	  Estensione, 
	  Finale, 
	  Residuo,
	  'escludi' as Seleziona


from CTL_DOC C
inner join dbo.Document_Convenzione_LOTTI DC on DC.idheader=C.Id
where C.tipodoc='CONVENZIONE'
GO
