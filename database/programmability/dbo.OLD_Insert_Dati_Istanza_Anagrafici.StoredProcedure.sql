USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Insert_Dati_Istanza_Anagrafici]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[OLD_Insert_Dati_Istanza_Anagrafici] 
	( @idDoc int, @IdAzi int, @merc varchar(5000) )
AS
BEGIN
	SET NOCOUNT ON;

	insert into CTL_DOC_Value 
		(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'ANNOCOSTITUZIONE', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'ANNOCOSTITUZIONE'


	insert into CTL_DOC_Value 
		(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'RuoloRapLeg', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'RuoloRapLeg'

	insert into CTL_DOC_Value 
		(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'IscrCCIAA', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'IscrCCIAA'
	
	insert into CTL_DOC_Value 
		(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'SedeCCIAA', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'SedeCCIAA'


	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'NomeRapLeg', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'NomeRapLeg'


	insert into CTL_DOC_Value 
		(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'CognomeRapLeg', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'CognomeRapLeg'

	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'TelefonoRapLeg', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'TelefonoRapLeg'


	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'EmailRapLeg', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'EmailRapLeg'

	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	select @idDoc, 'TESTATA', 0, 'codicefiscale', vatvalore_ft
		from DM_Attributi 
		where idapp = 1 and lnk = @IdAzi and dztNome = 'codicefiscale'


declare @RagSoc nvarchar(80)
declare @CAPLEG nvarchar(10)
declare @INDIRIZZOLEG  nvarchar(80)
declare @LOCALITALEG nvarchar(80)
declare @NUMFAX nvarchar(80)
declare @NUMTEL nvarchar(80)
declare @NUMTEL2 nvarchar(80)
declare @PIVA nvarchar(80)
declare @PROVINCIALEG nvarchar(80)
declare @NaGi varchar(20)
declare @STATOLOCALITALEG nvarchar(80)

	
	select 
	@RagSoc=[aziRagioneSociale],
	@CAPLEG=[aziCAPLeg],
	@INDIRIZZOLEG=[aziIndirizzoLeg],
	@LOCALITALEG=[aziLocalitaLeg],
	@NUMFAX=[aziFAX],
	@NUMTEL=[aziTelefono1],
	@NUMTEL2=[aziTelefono2],
	@PIVA=[aziPartitaIVA],
	@PROVINCIALEG=[aziProvinciaLeg],
	@NaGi=[aziIdDscFormaSoc],
	@STATOLOCALITALEG=[aziStatoLeg]

	from aziende
	where idazi=@IdAzi


	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'RagSoc', @RagSoc)
	
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'CAPLEG', @CAPLEG)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'INDIRIZZOLEG', @INDIRIZZOLEG)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'LOCALITALEG', @LOCALITALEG)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'NUMFAX', @NUMFAX)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'NUMTEL', @NUMTEL)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'NUMTEL2', @NUMTEL2)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'PIVA', @PIVA)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'PROVINCIALEG', @PROVINCIALEG)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'NaGi', @NaGi)
	
	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'TESTATA', 0, 'STATOLOCALITALEG', @STATOLOCALITALEG)
	


	insert into CTL_DOC_Value 
	(IdHeader , DSE_ID , row, DZT_Name , value)
	values
	(@idDoc, 'DISPLAY_ABILITAZIONI', 0, 'MerceologiaBando', @Merc)



end
GO
