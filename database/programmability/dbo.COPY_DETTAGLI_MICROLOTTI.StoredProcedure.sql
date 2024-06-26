USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COPY_DETTAGLI_MICROLOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE  [dbo].[COPY_DETTAGLI_MICROLOTTI] ( @query as Varchar(max) , @ColToExclud as Varchar(max)='' )

as
begin


	declare @sql as varchar(max)
	declare @crlf varchar(10)
	set @crlf = '
'

	set @sql = '

		declare @IdSource int
		declare @IdDest int

		declare crs_cdm cursor static for 
		' + @query + '
				
		open crs_cdm 
		fetch next from crs_cdm into @IdSource , @IdDest

		while @@fetch_status=0 
		begin 

			exec COPY_RECORD ''Document_MicroLotti_Dettagli'' ,@IdSource  , @IdDest , ''Id,IdHeader,TipoDoc,' + @ColToExclud + '''
			
			fetch next from crs_cdm into @IdSource , @IdDest
		end 


		close crs_cdm 
		deallocate crs_cdm
'

	--print @sql
	exec (@sql )

end


GO
