USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_GENDOC_55_171]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[CK_SEC_GENDOC_55_171] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	select '' as Blocco
end


GO
