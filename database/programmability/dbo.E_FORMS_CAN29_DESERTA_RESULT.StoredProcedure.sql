USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CAN29_DESERTA_RESULT]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[E_FORMS_CAN29_DESERTA_RESULT] ( @idProc int , @idUser int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	-- prendiamo tutti i lotti della gara cambiando solo la decision reason, se deserta "no-rece" se revocata "chan-need"

	-------------
	-- OUTPUT ---
	-------------
	SELECT  dbo.eFroms_GetIdentifier('RES', d.NumeroLotto,'') AS LOTTO_RESULT_ID, -- OPT-322
			'clos-nw' AS LOTTO_RESULT_TENDER_RESULT_CODE, -- BT-142
			case when b.StatoFunzionale = 'revocato' then 'chan-need' else 'no-rece' end AS LOTTO_RESULT_DECISION_REASON,
			dbo.eFroms_GetIdentifier('LOT', d.NumeroLotto,'') as LOTTO_RESULT_TENDER_LOT_ID -- BT-13713
		FROM ctl_doc b WITH(NOLOCK) 
				inner join Document_MicroLotti_Dettagli d WITH(NOLOCK) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
		WHERE b.id = @idProc and d.StatoRiga <> 'Revocato'
		ORDER BY d.id

END
GO
