USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_COPY_FROM_ISTANZA_AlboProf_3]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[ISTANZA_COPY_FROM_ISTANZA_AlboProf_3]( @idDoc as int , @oldIdDoc as int, @idpfu as int ) 
as
--@idDoc nuovo id
--@oldIdDoc id istanza precedente
--@idpfu -20 fisso per adesso
--riceve l'id della nuova istanza creata, il linkeddoc è il bando, prevdoc istanza precedente

declare @IdAzi int

declare @Valore nvarchar (4000)
declare @RagSoc		nvarchar( 500)
declare @NaGi nvarchar( 500)
declare @INDIRIZZOLEG nvarchar( 500)
declare @LOCALITALEG nvarchar( 500)
declare @CAPLEG nvarchar( 500)
declare @PROVINCIALEG nvarchar( 500)
declare @NUMTEL nvarchar( 500)
declare @NUMTEL2 nvarchar( 500)
declare @NUMFAX nvarchar( 500)
declare @EMail nvarchar( 500)
declare @PIVA nvarchar( 500)
declare @NomeRapLeg varchar(500)
declare @CognomeRapLeg varchar(500)
declare @CFRapLeg varchar(500)
declare @TelefonoRapLeg varchar(500)
declare @CellulareRapLeg varchar(500)
declare @EmailRapLeg varchar(500)
declare @RuoloRapLeg varchar(500)

--recupero azienda associata all'istanza
Select @IdAzi=azienda from CTL_DOC where id=@idDoc

--recupero tutti i valori
Select 	 @RagSoc=aziRagioneSociale 
		,@NaGi=aziIdDscFormasoc 
		,@INDIRIZZOLEG=aziIndirizzoLeg
		,@LOCALITALEG=aziLocalitaLeg 
		,@CAPLEG=aziCAPLeg
		,@PROVINCIALEG=aziProvinciaLeg
		,@NUMTEL=aziTelefono1
		,@NUMTEL2=aziTelefono2 
		,@NUMFAX=aziFAX
		,@EMail=aziE_Mail
		,@PIVA=aziPartitaIVA 
from Aziende where idazi = @IdAzi


insert into Document_Offerta_Partecipanti (  [IdHeader], [TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa], [StatoDGUE], [AllegatoDGUE], [IdDocRicDGUE], [EsitoRiga], [Allegato])
	select @idDoc , [TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa], [StatoDGUE], [AllegatoDGUE], [IdDocRicDGUE], [EsitoRiga], [Allegato] 
		from Document_Offerta_Partecipanti where IdHeader=@oldIdDoc


















GO
