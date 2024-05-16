USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RISOLVE_TEMPLATE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROCEDURE [dbo].[RISOLVE_TEMPLATE] 
	( @value nvarchar(max) , @Id int ,  @contesto as varchar(200), @value_out nvarchar(max)  output )
AS
BEGIN
	
	if @contesto='CONTRATTO_GARA' 
			exec RISOLVE_VERBALE_CONTRATTO_GARA @value , @Id ,@contesto, @value_out output
		
	else
			exec  RISOLVE_VERBALEGARA @value , @Id ,@contesto, @value_out output
		
	


END


GO
