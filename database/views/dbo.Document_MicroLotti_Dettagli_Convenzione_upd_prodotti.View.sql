USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_MicroLotti_Dettagli_Convenzione_upd_prodotti]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[Document_MicroLotti_Dettagli_Convenzione_upd_prodotti] as 

select 
	 * 
	,
     ' NumeroLotto Voce ' as NotEditable		
	from Document_MicroLotti_Dettagli
		 where tipodoc='CONVENZIONE_UPD_PRODOTTI'


GO
