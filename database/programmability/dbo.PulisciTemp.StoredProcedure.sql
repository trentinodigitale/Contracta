USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PulisciTemp]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[PulisciTemp] AS
DELETE FROM TempRicerche
DELETE FROM TempRicercheArticoli
DELETE FROM TempRicercheParametri
DELETE FROM TempModelli
DELETE FROM TempModelliGruppi
DELETE FROM TempModelliAllegati
DELETE FROM TempModelliArticoli
DELETE FROM TempModelliColonne
DELETE FROM TempModelliAziende
DELETE FROM TempModelliGruppiXColonne
DELETE FROM TempModelliArticoliXColonne
DELETE FROM TempValoriAttributi
DELETE FROM TempValoriAttributi_Datetime
DELETE FROM TempValoriAttributi_Descr
DELETE FROM TempValoriAttributi_Float
DELETE FROM TempValoriAttributi_Int
DELETE FROM TempValoriAttributi_Keys
DELETE FROM TempValoriAttributi_Money
DELETE FROM TempValoriAttributi_Nvarchar
DELETE FROM TempOfferte
DELETE FROM TempOfferteAllegati
DELETE FROM TempOfferteArticoli
DELETE FROM TempOfferteArticoliXColonne
GO
