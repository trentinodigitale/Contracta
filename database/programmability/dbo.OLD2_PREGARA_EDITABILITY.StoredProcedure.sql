USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PREGARA_EDITABILITY]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD2_PREGARA_EDITABILITY] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	declare @statofunzionale as varchar(100)
	declare @value as varchar(8000)
	set @value=''

	select 
		@statofunzionale=statofunzionale 
		from CTL_DOC with(nolock) 
			where Id=@idDoc
	
	IF ( @statofunzionale in ('InLavorazione','AnalisiStrategiaNonApp') )
	BEGIN
		set @value=@value + ''
	END
	IF ( @statofunzionale not in ('InLavorazione','AnalisiStrategiaNonApp') )
	BEGIN
		IF ( @statofunzionale in ('AnalisiStrategia') )
			set @value=@value + ' Titolo EnteProponente Body '
		ELSE
			set @value=@value + ' Titolo EnteProponente Body RupProponente '			
	END

	update CTL_DOC_Value set Value=@value
		where IdHeader=@idDoc and DSE_ID='NOT_EDITABLE' and DZT_Name='Not_Editable'

END
GO
