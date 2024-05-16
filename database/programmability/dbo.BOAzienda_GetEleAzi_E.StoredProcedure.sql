USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAzienda_GetEleAzi_E]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAzienda_GetEleAzi_E] (@Filtro NVARCHAR(80), @NumItem INT)
AS
 DECLARE @Start NVARCHAR(80)
IF @Filtro LIKE N'[A-za-z]%'
   BEGIN
         SET @Start = LEFT(@Filtro,1) + N'%'
   END 
ELSE 
   BEGIN
         SET @Start = N'[^A-Za-z]%'
   END
SET ROWCOUNT @NumItem
SELECT CAST(aziRagioneSociale AS NVARCHAR(80)) AS RagSoc,
       CAST(aziE_Mail AS NVARCHAR(50)) AS E_Mail,
       CAST(aziSitoWeb AS NVARCHAR(50)) AS WebAddress,
       CAST(Attivita_DescsE.dscTesto AS NVARCHAR(250)) AS Attivita,
       CAST(aziIndirizzoLeg AS NVARCHAR(80)) AS Indirizzo,
       CAST(aziLocalitaLeg AS NVARCHAR(80)) AS Localita,
       CAST(aziCAPLeg AS NVARCHAR(8)) AS CAP,
       CAST(aziProvinciaLeg AS NVARCHAR(20)) AS Provincia,
       CAST(aziStatoLeg AS NVARCHAR(20)) AS Stato,
       CAST(aziTelefono1 AS NVARCHAR(20)) AS Tel,
       CAST(aziFAX AS NVARCHAR(20)) AS Fax,
       CAST(aziAcquirente AS NVARCHAR(2)) AS Acquirente,
       CAST(aziVenditore AS NVARCHAR(2)) AS Venditore,
       CAST(aziProspect AS NVARCHAR(2)) AS Prospect
  FROM Aziende, Attivita, DescsE Attivita_DescsE
 WHERE Attivita.atvAtecord = Aziende.aziAtvAtecord
   AND Attivita_DescsE.IdDsc = Attivita.atvIdDsc  
   AND aziRagioneSociale LIKE @Start
   AND aziRagioneSociale > @Filtro
ORDER BY aziRagioneSociale
SET ROWCOUNT 0
GO
