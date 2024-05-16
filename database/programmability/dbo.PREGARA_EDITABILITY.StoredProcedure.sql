USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PREGARA_EDITABILITY]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PREGARA_EDITABILITY] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	declare @statofunzionale as varchar(100)
	declare @value as varchar(8000)
	set @value=''

	select 
		@statofunzionale='%,' + statofunzionale + ',%' 
		from CTL_DOC with(nolock) 
			where Id=@idDoc
	
	--IF ( @statofunzionale in ('InLavorazione','AnalisiStrategiaNonApp') )
	--BEGIN
	--	set @value=@value + ''
	--END
	--IF ( @statofunzionale not in ('InLavorazione','AnalisiStrategiaNonApp') )
	--BEGIN
	--	IF ( @statofunzionale in ('AnalisiStrategia') )
	--		set @value=@value + ' Titolo EnteProponente Body '
	--	ELSE
	--		set @value=@value + ' Titolo EnteProponente Body RupProponente '			
	--END
	select 
		@value=@value + REL_ValueOutput 

		from CTL_Relations with(nolock) 
		where rel_type='DOCUMENT_PREGARA_NOT_EDITABLE_STRATEGIA_For_Stato' 
			 and REL_ValueInput like @statofunzionale 

	-- se l'utente che ha in carico il documento non appartiene all'Ente Espletante il campo UserRup sarà non editabile
	if not exists( select * from ctl_doc d with(nolock) inner join profiliutente p with(nolock) on d.idPfuInCharge = p.idpfu and p.pfuidazi = d.Azienda where d.id = @idDoc ) 
			set @value=@value + ' UserRup '




	update CTL_DOC_Value set Value=@value
		where IdHeader=@idDoc and DSE_ID='NOT_EDITABLE' and DZT_Name='Not_Editable'

END
GO
