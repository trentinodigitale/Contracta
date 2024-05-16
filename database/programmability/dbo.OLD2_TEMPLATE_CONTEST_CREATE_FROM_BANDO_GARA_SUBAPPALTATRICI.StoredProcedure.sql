USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_TEMPLATE_CONTEST_CREATE_FROM_BANDO_GARA_SUBAPPALTATRICI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Proc [dbo].[OLD2_TEMPLATE_CONTEST_CREATE_FROM_BANDO_GARA_SUBAPPALTATRICI]
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	
	
	select top 0 
		cast( '' as varchar(250)) as id , 
		cast( '' as varchar(max)) as Errore
		into #Result

	insert into #Result exec TEMPLATE_CONTEST_CREATE_FOR @IdDoc , @idUser , 'DGUE_ESECUTRICI'

	select * from #Result

end
GO
