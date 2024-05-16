USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ODC_PRODOTTI_FROM_CARRELLO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--aggiunto il calcolo della qt disponibile
---------------------------------------------------------------

CREATE VIEW [dbo].[ODC_PRODOTTI_FROM_CARRELLO] as
--Versione=2&data=2012-06-28&Attivita=38848&Nominativo=Sabato
SELECT b.Id
     , b.Marca
     , b.Codice                     AS RDP_CodArtProd
     , b.Descrizione                AS RDP_Desc
     , b.QtMin
     
     , b.PrezzoUnitario             AS RDP_Importo
     , b.IdPfu                      AS ID_FROM 
     , b.Plant                      AS RDA_PlantRic 
     , Id_Convenzione  
     , CAST(Fornitore AS VARCHAR) AS RDP_Fornitore 
     --, NumConf                    AS RDP_Qt
     , case when c.TipoOrdine in ( 'S' , 'C' ) then b.QtMin  else 1 end                    AS RDP_Qt
     , b.Nota
	 , case when c.TipoOrdine in ( 'S' , 'C' ) then ' Descrizione  PrezzoUnitario RDP_Desc RDP_Importo ' else '' end as NonEditabili
     , p.PercSconto
	 , 1 as CoefCorr
	 , Id_Product
	 , case when c.TipoOrdine in ( 'B' ) then b.ImportoCompenso else 0 end as ImportoCompenso
	 , p.QtMax
	 , p.TipoProdotto
	 , p.UnitMis
	 , p.IVA
	 , g.QT as QTDisp
--  FROM Carrello
FROM         Carrello b
	inner join dbo.Document_Convenzione c on c.ID = cast( b.Id_Convenzione  as int )
	left outer join Document_Convenzione_Product p on p.idRow = Id_Product
	inner join ( 

			select pr.idRow , 
					case when isnull( pr.QtMaxRow , 0 ) = 0 then null 
					else pr.QtMaxRow - isnull( s.RDP_Qt , 0 ) 
					end as QT
				  FROM Document_Convenzione_Product pr 
					left outer join ( 
							select sum( RDP_Qt ) as RDP_Qt , Id_Product 
								from Document_ODC o
									inner join Document_Convenzione c on c.ID = o.Id_Convenzione
									inner join Document_ODC_Product p on RDP_RDA_ID = RDA_ID

							--where year( RDA_DataCreazione  )  = year ( getdate()) and RDA_Stato <> 'Saved'  and rda_deleted = 0 
							where dbo.DifferenzaAnni( c.DataInizio , RDA_DataCreazione  )  = dbo.DifferenzaAnni( c.DataInizio , getdate()  ) and RDA_Stato in ('In consegna','SendOrder','Evaso' )  and rda_deleted = 0 
							group by Id_Product 
						) as s on s.Id_Product = pr.idRow

		) as g on g.idRow = p.idRow





GO
