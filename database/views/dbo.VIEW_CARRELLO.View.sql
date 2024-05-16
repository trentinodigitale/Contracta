USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CARRELLO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_CARRELLO] 
AS
SELECT 
	P.*,isnull(PA.attvalue,0) as NumeroOrdinativi_FromCarrello
  FROM ProfiliUtente P
  left outer join profiliutenteattrib PA on P.idpfu=PA.idpfu and PA.dztnome='NumeroOrdinativi_FromCarrello'	
 WHERE 
pfuDeleted = 0
GO
