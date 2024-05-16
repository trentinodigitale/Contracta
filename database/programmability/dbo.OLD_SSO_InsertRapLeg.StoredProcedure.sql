USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SSO_InsertRapLeg]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[OLD_SSO_InsertRapLeg] 
( 
	@idEnte INT,
	@CognomeRapLeg nvarchar(4000), 
	@NomeRapLeg nvarchar(4000), 
	@IndResidenzaRapLeg nvarchar(4000), 
	@CFRapLeg nvarchar(4000), 
	@LocalitaRapLeg nvarchar(4000), 
	@ResidenzaRapLeg nvarchar(4000)
)
AS


	SET NOCOUNT ON

	EXEC UpdAttrAzi @idEnte , 'CognomeRapLeg', @CognomeRapLeg 
	EXEC UpdAttrAzi @idEnte , 'NomeRapLeg', @NomeRapLeg 
	EXEC UpdAttrAzi @idEnte , 'IndResidenzaRapLeg', @IndResidenzaRapLeg 
	EXEC UpdAttrAzi @idEnte , 'CFRapLeg', @CFRapLeg 
	EXEC UpdAttrAzi @idEnte , 'LocalitaRapLeg', @LocalitaRapLeg 
	EXEC UpdAttrAzi @idEnte , 'ResidenzaRapLeg', @ResidenzaRapLeg 




GO
