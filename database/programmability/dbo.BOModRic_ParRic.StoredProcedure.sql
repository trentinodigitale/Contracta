USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ParRic]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_ParRic](@IdRic INT) AS
  SELECT * FROM RicercheParametri
    WHERE rpmIdRic = @IdRic
    ORDER BY rpmIdVat
GO
