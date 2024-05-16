USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAzienda_GetNumAziende]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAzienda_GetNumAziende](@Filtro NVARCHAR(80), @TipoDiRicerca INT)
AS
IF (@TipoDiRicerca = 0)
   BEGIN
        --Ricerca alfabetica
        --@Filtro deve essere uguale ad una lettera dell'alfabeto
        SET @Filtro = @Filtro + N'%'
 
        SELECT Count(*) AS NumElement
          FROM Aziende, Attivita, DescsI Attivita_DescsI
         WHERE Attivita.atvAtecord = Aziende.aziAtvAtecord
           AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
           AND aziRagioneSociale LIKE @Filtro 
           AND aziVenditore < 5 
           AND aziAcquirente < 5 
           AND aziProspect < 5
   END
ELSE
IF (@TipoDiRicerca = 1)
   BEGIN
        --Ricerca per ragione sociale
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT Count(*) AS NumElement
          FROM Aziende, DescsI Attivita_DescsI, Attivita
         WHERE Attivita.atvAtecord = Aziende.aziAtvAtecord
           AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
           AND aziRagioneSociale LIKE @Filtro 
           AND aziVenditore < 5 
           AND aziAcquirente < 5 
           AND aziProspect < 5
   END
ELSE
IF (@TipoDiRicerca = 2)
   BEGIN
        --Ricerca per indirizzo
 
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT Count(*) AS NumElement
          FROM Aziende, Attivita, DescsI Attivita_DescsI
         WHERE Attivita.atvAtecord = Aziende.aziAtvAtecord
           AND Attivita_DescsI.IdDsc = Attivita.atvIdDsc 
           AND (aziIndirizzoLeg LIKE @Filtro OR aziLocalitaLeg LIKE @Filtro)
           AND aziVenditore < 5 
           AND aziAcquirente < 5 
           AND aziProspect < 5
   END
ELSE
IF (@TipoDiRicerca = 3)
   BEGIN
        --Ricerca per attivita economica
 
        SET @Filtro = N'%' + @Filtro + N'%'
 
        SELECT Count(*) AS NumElement
          FROM DescsI, Attivita, AziAteco, Aziende
         WHERE DescsI.IdDsc = Attivita.atvIdDsc
           AND aziAteco.atvAtecord = Attivita.atvAtecord
           AND Aziende.idazi = AziAteco.idazi 
           AND DescsI.dsctesto LIKE @Filtro
   END
GO
