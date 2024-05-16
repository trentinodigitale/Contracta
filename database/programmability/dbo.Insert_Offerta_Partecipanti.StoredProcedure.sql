USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Insert_Offerta_Partecipanti]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Insert_Offerta_Partecipanti] (

@TipoRiferimento VARCHAR(50),
@IdAziRiferimento INT,
@RagSocRiferimento NVARCHAR(400),
@IdAzi  INT,
@RagSoc NVARCHAR(400),
@CodiceFiscale NVARCHAR(50),
@IndirizzoLeg NVARCHAR(200),
@LocalitaLeg  NVARCHAR(200),
@ProvinciaLeg  NVARCHAR(200), 
@Ruolo varchar(50),
@idmsg INT
)

AS
declare @idheader as int
DECLARE @descruoloimpresa as VARCHAR(100)

select @idheader=id from ctl_doc where tipodoc='OFFERTA_PARTECIPANTI' and deleted=0 and LinkedDoc=@idmsg and Jumpcheck='DocumentoGenerico'

set @descruoloimpresa=''
if @Ruolo = '1'
	set @descruoloimpresa='Mandataria'
if @Ruolo = '2'
	set @descruoloimpresa='Mandante'

--inserisco entrata relativa all'azienda partecipante nella Document_Offerta_Partecipanti
insert into Document_Offerta_Partecipanti
 (IdHeader, TipoRiferimento, IdAziRiferimento, RagSocRiferimento, IdAzi, RagSoc, CodiceFiscale, IndirizzoLeg, LocalitaLeg, ProvinciaLeg , Ruolo_Impresa )
values
 ( @idheader , @TipoRiferimento, @IdAziRiferimento, @RagSocRiferimento, @IdAzi, @RagSoc, @CodiceFiscale, @IndirizzoLeg, @LocalitaLeg, @ProvinciaLeg , @descruoloimpresa )

SET ANSI_NULLS OFF

GO
