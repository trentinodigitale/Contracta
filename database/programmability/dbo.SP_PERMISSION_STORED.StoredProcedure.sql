USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_PERMISSION_STORED]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SP_PERMISSION_STORED]
( 
	@idPfu   as int  , 
	@Modello as varchar(2000) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON

	
	declare @passed int -- variabile di controllo
						

	set @passed = 1 -- 1 passa 0 blocca

	if @passed = 1
		select 1 as bP_Read , 1 as bP_Write
	else
		select top 0 0 as bP_Read , 0 as bP_Write 
end
GO
