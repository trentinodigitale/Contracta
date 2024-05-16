USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_PRODOTTIPRINCIPALI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CONVENZIONE_PRODOTTIPRINCIPALI]
as

select 
	P.* ,
	case isnull(DCPP.IdRowPrincipale,0)
		when 0 then 0
		else 1 
	end  as CheckPrincipale
from 
	( 
	 select DCP1.idheader,DCP1.idrow,PP.codice,PP.Descrizione,PP.idrow as IdRowPrincipale from 
	 (select 
		DCP.* 
	  from 
		Document_Convenzione D inner join Document_Convenzione_Product DCP 
		on D.id=DCP.idheader and DCP.TipoProdotto='principale'
	 ) PP inner join Document_Convenzione_Product DCP1 on PP.idheader=DCP1.idheader
	) P  	
	
	left join Document_Convenzione_Prodotti_Principale  DCPP
	
	on P.idheader=DCPP.idConvenzione and P.idrow=DCPP.IdRowProdotto 
	and P.idrowprincipale=DCPP.idrowprincipale
	
	--select * from Document_Convenzione_Product where idheader=11

GO
