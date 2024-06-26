USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_GETNEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[RDA_GETNEW]
AS
SELECT     b.tdrCodiceRaccordo AS CodiceSocieta, dbo.Document_RDA.RDA_Protocol AS NumeroRDA, REPLICATE('0', 2 - LEN(RTRIM(g.Valore))) + RTRIM(g.Valore)
                       AS CodicePlant, '      ' AS CodAssieme, REPLACE(CAST(dbo.Document_RDA_Product.RDP_CodArtProd AS varchar(6)), 'XXXXXX', '999999') 
                      AS CodiceArticolo, '        ' AS EsponenteModifica, l.pfuLogin AS LoginUtente, 0 AS QtAnnua, dbo.Document_RDA_Product.RDP_Qt AS Qty, 
                      dbo.Document_RDA_Product.RDP_Merceologia AS Merceologia, dbo.Document_RDA_Product.RDP_DataPrevCons AS DataScadProd, 
                      dbo.Document_RDA.RDA_DataCreazione AS DataIns, '3' AS Utilizzo, 'Y' AS FlagAssegnazione, ' ' AS FlagEvasione, '                         ' AS Note, 
                      '        ' AS DataInsRdo, ' ' AS FlagOfferta, '   ' AS CodOperFase, k.REL_ValueOutput AS Destinatario, '000' AS Fase, '00000' AS CodiceLavoro, 
                      ' ' AS Operazione, CAST(l.pfuE_Mail AS varchar(50)) AS EMailUtente, n.tdrCodiceRaccordo AS Lingua, '00000' AS Commessa, 
                      dbo.Document_RDA.RDA_ID, dbo.Document_RDA.RDA_Owner, dbo.Document_RDA.RDA_Name, dbo.Document_RDA.RDA_DataCreazione, 
                      dbo.Document_RDA.RDA_Protocol, dbo.Document_RDA.RDA_Object, dbo.Document_RDA.RDA_Total, dbo.Document_RDA.RDA_Stato, 
                      dbo.Document_RDA.RDA_AZI, dbo.Document_RDA.RDA_Plant_CDC, dbo.Document_RDA.RDA_Valuta, dbo.Document_RDA.RDA_InBudget, 
                      dbo.Document_RDA.RDA_BDG_Periodo, dbo.Document_RDA.RDA_Deleted, dbo.Document_RDA.RDA_BuyerRole, 
                      dbo.Document_RDA.RDA_ResidualBudget, dbo.Document_RDA.RDA_CEO, dbo.Document_RDA.RDA_SOCRic, dbo.Document_RDA.RDA_PlantRic, 
                      dbo.Document_RDA.RDA_MCE, dbo.Document_RDA_Product.RDP_idRow, dbo.Document_RDA_Product.RDP_RDA_ID, 
                      dbo.Document_RDA_Product.RDP_VDS, dbo.Document_RDA_Product.RDP_Merceologia, dbo.Document_RDA_Product.RDP_Progetto, 
                      dbo.Document_RDA_Product.RDP_Fornitore, dbo.Document_RDA_Product.RDP_CodArtProd, dbo.Document_RDA_Product.RDP_Commessa, 
                      dbo.Document_RDA_Product.RDP_Importo, dbo.Document_RDA_Product.RDP_Qt, dbo.Document_RDA_Product.RDP_DataPrevCons, 
                      dbo.Document_RDA_Product.RDP_Desc, dbo.Document_RDA_Product.RDP_Allegato, dbo.Document_RDA_Product.RDP_TiketBudget, 
                      dbo.Document_RDA_Product.RDP_InBudget, dbo.Document_RDA_Product.RDP_ResidualBudget, 
                      dbo.Document_RDA_Product.RDP_TipoInvestimento
FROM         dbo.TipiDatiRange AS b INNER JOIN
                      dbo.DizionarioAttributi AS a ON b.tdrIdTid = a.dztIdTid INNER JOIN
                      dbo.Document_RDA INNER JOIN
                      dbo.Document_RDA_Product ON dbo.Document_RDA.RDA_ID = dbo.Document_RDA_Product.RDP_RDA_ID ON 
                      b.tdrCodice = dbo.Document_RDA.RDA_AZI INNER JOIN
                      dbo.AZ_STRUTTURA AS f ON SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, 1, 8) = f.IdAz AND SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, 
                      10, 15) = f.Path INNER JOIN
                      dbo.AZ_ATTRIBUTI AS g ON f.IdStrutt = g.IdStrutt INNER JOIN
                      dbo.DizionarioAttributi AS h ON g.IdAttr = h.IdDzt INNER JOIN
                      dbo.TipiDatiRange AS n INNER JOIN
                      dbo.DizionarioAttributi AS m ON n.tdrIdTid = m.dztIdTid INNER JOIN
                      dbo.ProfiliUtente AS l ON n.tdrCodice = CAST(l.pfuIdLng AS varchar) ON dbo.Document_RDA.RDA_Owner = l.IdPfu INNER JOIN
                      dbo.CTL_Relations AS k ON l.pfuLogin = k.REL_ValueInput
WHERE     (a.dztNome = 'carcodsoclistino') AND (b.tdrDeleted = 0) AND (h.dztNome = 'carcodiceplant') AND (m.dztNome = 'carlingua') AND (n.tdrDeleted = 0) AND 
                      (k.REL_Type = 'LOGIN_CICS')




GO
