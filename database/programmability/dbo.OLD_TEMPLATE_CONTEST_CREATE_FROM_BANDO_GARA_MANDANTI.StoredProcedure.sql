USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TEMPLATE_CONTEST_CREATE_FROM_BANDO_GARA_MANDANTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  Proc [dbo].[OLD_TEMPLATE_CONTEST_CREATE_FROM_BANDO_GARA_MANDANTI]
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	
	
	--select top 0 
	--	cast( '' as varchar(250)) as id , 
	--	cast( '' as varchar(max)) as Errore
	--	into #Result

	--insert into #Result exec TEMPLATE_CONTEST_CREATE_FOR @IdDoc , @idUser , 'DGUE_RTI'

	--select * from #Result


	exec TEMPLATE_CONTEST_CREATE_FOR @IdDoc , @idUser , 'DGUE_RTI'
end

GO
