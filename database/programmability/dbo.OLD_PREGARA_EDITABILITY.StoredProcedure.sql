USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PREGARA_EDITABILITY]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_PREGARA_EDITABILITY] ( @idDoc int , @IdUser int  )
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


	-- se l'utente che ha in carico il documento non appartiene all'Ente Espletante il campo UserRup sarà non editabile
	if not exists( select * from ctl_doc d with(nolock) inner join profiliutente p with(nolock) on d.idPfuInCharge = p.idpfu and p.pfuidazi = d.Azienda where d.id = @idDoc ) 
			set @value=@value + ' UserRup '




	update CTL_DOC_Value set Value=@value
		where IdHeader=@idDoc and DSE_ID='NOT_EDITABLE' and DZT_Name='Not_Editable'

END
GO
