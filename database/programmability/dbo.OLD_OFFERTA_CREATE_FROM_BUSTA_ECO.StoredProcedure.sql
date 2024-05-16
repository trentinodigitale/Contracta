USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OFFERTA_CREATE_FROM_BUSTA_ECO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_OFFERTA_CREATE_FROM_BUSTA_ECO] ( @idDoc int  , @idUser int , @NoSquenza int = 0 )
AS
BEGIN
	SET NOCOUNT ON
	declare @Errore as nvarchar(MAX)
	set @Errore = ''
	
	--INSERISCO IL FLAG PER INDICARE richiesta_apertura_busta
	IF NOT EXISTS ( select * from CTL_DOC_Value where IdHeader=@IdDoc and DSE_ID='BUSTA_ECONOMICA' and  DZT_Name='richiesta_apertura_busta' and value='1' ) 
	BEGIN

		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @IdDoc , 'BUSTA_ECONOMICA' , 0 , 'richiesta_apertura_busta' , '1' )

		select top 0 cast('' as varchar(max)) as blocco into #temp

		insert into #temp 
			exec CK_SEC_DOC_OFFERTA_CONTROLLI 'BUSTA_ECONOMICA',@idDoc,@idUser , @NoSquenza
	
		select top 1 @Errore=blocco from #temp 		
	

		If @Errore <> ''
			delete from CTL_DOC_Value where IdHeader=@IdDoc and DSE_ID='BUSTA_ECONOMICA' and  DZT_Name='richiesta_apertura_busta' and value='1' 


	end



	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @idDoc as id, 'FLD_BUSTA_ECONOMICA' AS FOLDER
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end





END


GO
