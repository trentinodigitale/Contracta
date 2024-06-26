USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAzienda_NewGetEleAzi_I]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAzienda_NewGetEleAzi_I] (@Filtro NVARCHAR(80), @NumItem INT, @TipoDiRicerca INT)
AS
IF (@NumItem <> -1)
BEGIN
     SET ROWCOUNT @NumItem
END
IF (@TipoDiRicerca = 0)
   BEGIN
        --Ricerca alfabetica
        --@Filtro deve essere uguale ad una lettera dell'alfabeto
        IF @Filtro  = N'*'
           BEGIN
                SET @Filtro = N'[^A-Za-z]%'
           END 
        ELSE 
           BEGIN
                SET @Filtro = @Filtro + N'%'
           END
    SELECT CAST(aziRagioneSociale AS NVARCHAR(80)) AS RagSoc,
           CAST('' AS NVARCHAR(50)) AS E_Mail,
           CAST('' AS NVARCHAR(50)) AS WebAddress,
           CAST(Attivita_DescsI.dscTesto AS NVARCHAR(250)) AS Attivita,
           CAST(aziIndirizzoLeg AS NVARCHAR(80)) AS Indirizzo,
           CAST(aziLocalitaLeg AS NVARCHAR(80)) AS Localita,
           CAST(aziCAPLeg AS NVARCHAR(8)) AS CAP,
           CAST(aziProvinciaLeg AS NVARCHAR(20)) AS Provincia,
           CAST(aziStatoLeg AS NVARCHAR(20)) AS Stato,
           CAST('' AS NVARCHAR(20)) AS Tel,
           CAST('' AS NVARCHAR(20)) AS Fax,
           CAST(aziAcquirente AS NVARCHAR(2)) AS Acquirente,
           CAST(aziVenditore AS NVARCHAR(2)) AS Venditore,
           CAST(aziProspect AS NVARCHAR(2)) AS Prospect
      FROM Aziende, MPAziende, Attivita, DescsI Attivita_DescsI
     WHERE MPAziende.mpaIdazi = Aziende.IdAzi
       AND Attivita.atvAtecord = Aziende.aziAtvAtecord
       AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
       AND aziRagioneSociale LIKE @Filtro 
       AND aziDeleted = 0 
       AND aziProspect = 0 
       AND mpaDeleted = 0
       AND MPAziende.mpaIdMp = 1
     ORDER BY aziRagioneSociale
   END
ELSE
IF (@TipoDiRicerca = 1)
   BEGIN
        --Ricerca per ragione sociale
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT CAST(aziRagioneSociale AS NVARCHAR(80)) AS RagSoc,
               CAST('' AS NVARCHAR(50)) AS E_Mail,
               CAST('' AS NVARCHAR(50)) AS WebAddress,
               CAST(Attivita_DescsI.dscTesto AS NVARCHAR(250)) AS Attivita,
               CAST(aziIndirizzoLeg AS NVARCHAR(80)) AS Indirizzo,
               CAST(aziLocalitaLeg AS NVARCHAR(80)) AS Localita,
               CAST(aziCAPLeg AS NVARCHAR(8)) AS CAP,
               CAST(aziProvinciaLeg AS NVARCHAR(20)) AS Provincia,
               CAST(aziStatoLeg AS NVARCHAR(20)) AS Stato,
               CAST('' AS NVARCHAR(20)) AS Tel,
               CAST('' AS NVARCHAR(20)) AS Fax,
               CAST(aziAcquirente AS NVARCHAR(2)) AS Acquirente,
               CAST(aziVenditore AS NVARCHAR(2)) AS Venditore,
               CAST(aziProspect AS NVARCHAR(2)) AS Prospect
          FROM Aziende, MPAziende, Attivita, DescsI Attivita_DescsI
         WHERE MPAziende.mpaIdazi = Aziende.IdAzi
           AND Attivita.atvAtecord = Aziende.aziAtvAtecord
           AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
           AND aziRagioneSociale LIKE @Filtro 
           AND aziDeleted = 0 
           AND aziProspect = 0 
           AND mpaDeleted = 0
           AND mpaIdMp = 1
       ORDER BY aziRagioneSociale
   END
ELSE
IF (@TipoDiRicerca = 2)
   BEGIN
        --Ricerca per indirizzo
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT CAST(aziRagioneSociale AS NVARCHAR(80)) AS RagSoc,
               CAST('' AS NVARCHAR(50)) AS E_Mail,
               CAST('' AS NVARCHAR(50)) AS WebAddress,
               CAST(Attivita_DescsI.dscTesto AS NVARCHAR(250)) AS Attivita,
               CAST(aziIndirizzoLeg AS NVARCHAR(80)) AS Indirizzo,
               CAST(aziLocalitaLeg AS NVARCHAR(80)) AS Localita,
               CAST(aziCAPLeg AS NVARCHAR(8)) AS CAP,
               CAST(aziProvinciaLeg AS NVARCHAR(20)) AS Provincia,
               CAST(aziStatoLeg AS NVARCHAR(20)) AS Stato,
               CAST('' AS NVARCHAR(20)) AS Tel,
               CAST('' AS NVARCHAR(20)) AS Fax,
               CAST(aziAcquirente AS NVARCHAR(2)) AS Acquirente,
               CAST(aziVenditore AS NVARCHAR(2)) AS Venditore,
               CAST(aziProspect AS NVARCHAR(2)) AS Prospect
          FROM Aziende, MPAziende, Attivita, DescsI Attivita_DescsI
         WHERE MPAziende.mpaIdAzi = Aziende.IdAzi
           AND Attivita.atvAtecord = Aziende.aziAtvAtecord
           AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
           AND aziIndirizzoLeg LIKE @Filtro 
           AND aziDeleted = 0 
           AND aziProspect = 0 
           AND mpaDeleted = 0
           AND mpaIdMp = 1
        ORDER BY aziRagioneSociale
    END
ELSE
IF (@TipoDiRicerca = 3)
   BEGIN
        --Ricerca per attivita economica
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT CAST(Aziende.aziRagioneSociale AS NVARCHAR(80)) AS RagSoc,
               CAST('' AS NVARCHAR(50)) AS E_Mail,
               CAST('' AS NVARCHAR(50)) AS WebAddress,
               CAST(DescsI.dscTesto AS NVARCHAR(250)) AS Attivita,
               CAST(Aziende.aziIndirizzoLeg AS NVARCHAR(80)) AS Indirizzo,
               CAST(Aziende.aziLocalitaLeg AS NVARCHAR(80)) AS Localita,
               CAST(Aziende.aziCAPLeg AS NVARCHAR(8)) AS CAP,
               CAST(Aziende.aziProvinciaLeg AS NVARCHAR(20)) AS Provincia,
               CAST(Aziende.aziStatoLeg AS NVARCHAR(20)) AS Stato,
               CAST('' AS NVARCHAR(20)) AS Tel,
               CAST('' AS NVARCHAR(20)) AS Fax,
               CAST(Aziende.aziAcquirente AS NVARCHAR(2)) AS Acquirente,
               CAST(Aziende.aziVenditore AS NVARCHAR(2)) AS Venditore,
               CAST(Aziende.aziProspect AS NVARCHAR(2)) AS Prospect
          FROM DescsI, Attivita, AziAteco, Aziende, MPAziende
         WHERE DescsI.IdDsc = Attivita.atvIdDsc
           AND aziAteco.atvAtecord = Attivita.atvAtecord
           AND Aziende.idazi = AziAteco.idazi
           AND MPAziende.mpaIdAzi = Aziende.IdAzi 
           AND DescsI.dsctesto LIKE @Filtro 
           AND Aziende.aziProspect = 0 
           AND Aziende.AziDeleted = 0 
           AND MPAziende.mpaDeleted = 0
           AND MPAziende.mpaIdMp = 1
         ORDER BY aziRagioneSociale
   END
ELSE
IF (@TipoDiRicerca = 4)
   BEGIN
        --Ricerca per località
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT CAST(aziRagioneSociale AS NVARCHAR(80)) AS RagSoc,
               CAST('' AS NVARCHAR(50)) AS E_Mail,
               CAST('' AS NVARCHAR(50)) AS WebAddress,
               CAST(Attivita_DescsI.dscTesto AS NVARCHAR(250)) AS Attivita,
               CAST(aziIndirizzoLeg AS NVARCHAR(80)) AS Indirizzo,
               CAST(aziLocalitaLeg AS NVARCHAR(80)) AS Localita,
               CAST(aziCAPLeg AS NVARCHAR(8)) AS CAP,
               CAST(aziProvinciaLeg AS NVARCHAR(20)) AS Provincia,
               CAST(aziStatoLeg AS NVARCHAR(20)) AS Stato,
               CAST('' AS NVARCHAR(20)) AS Tel,
               CAST('' AS NVARCHAR(20)) AS Fax,
               CAST(aziAcquirente AS NVARCHAR(2)) AS Acquirente,
               CAST(aziVenditore AS NVARCHAR(2)) AS Venditore,
               CAST(aziProspect AS NVARCHAR(2)) AS Prospect
          FROM Aziende, Attivita, DescsI Attivita_DescsI, MPAziende
         WHERE Attivita.atvAtecord = Aziende.aziAtvAtecord
           AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
           AND MPAziende.mpaIdAzi = Aziende.IdAzi
           AND aziLocalitaLeg LIKE @Filtro 
           AND aziDeleted = 0 
           AND aziProspect = 0 
           AND mpaDeleted = 0
           AND mpaIdMp = 1
          ORDER BY aziRagioneSociale
   END
IF(@NumItem <> -1)
  BEGIN
       SET ROWCOUNT 0
  END
GO
