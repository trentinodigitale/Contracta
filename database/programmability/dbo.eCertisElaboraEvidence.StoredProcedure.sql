USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[eCertisElaboraEvidence]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eCertisElaboraEvidence] ( @idChiamata INT = -1, @idpfu INT = -20 )
AS
BEGIN

	SET NOCOUNT ON

	INSERT INTO Document_eCertis_evidence ( [idHeader], [dateIns], [deleted], [evidenceId], [criterionId], [criterionVersionId], [criterionNationalEntity], [typeCode], [name], [description] )
		SELECT l.[idHeader], l.[dateIns], l.[deleted], l.[evidenceId], l.[criterionId], l.[criterionVersionId], l.[criterionNationalEntity], l.[typeCode], l.[name], l.[description] 
			FROM Document_eCertis_evidence_lavoro l with(nolock)
					left join Document_eCertis_evidence e with(nolock) ON e.evidenceId = l.evidenceId
			WHERE l.idPfu = @idpfu and e.id is null

END


GO
