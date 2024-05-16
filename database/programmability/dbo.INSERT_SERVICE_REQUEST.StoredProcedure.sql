USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INSERT_SERVICE_REQUEST]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[INSERT_SERVICE_REQUEST] ( @integrazione varchar(50), @operazioneRichiesta varchar(50), @idPfu INT,  @idDocRichiedente INT = NULL )
AS
BEGIN

	SET NOCOUNT ON

	declare @idAzi INT
	declare @statoRichiesta varchar(20)

	set @statoRichiesta = 'Inserita'

	-- SE ESISTE IL PARAMETRO CON CONTESTO 'SERVICE_REQUEST' E OGGETTO IL NOME DELL'INTEGRAZIONE, ED LA PROPRIETA ATTIVO A YES
	IF dbo.PARAMETRI( 'SERVICE_REQUEST', @integrazione, 'ATTIVO', 'NO', -1) = 'YES'
	BEGIN

		select @idAzi = pfuIdAzi from profiliutente with(nolock) where idpfu = @idPfu

		if exists(select * from CTL_Relations where REL_Type = 'SERVICE_REQUEST' and REL_ValueInput=@integrazione + '-' + @operazioneRichiesta)
		begin
			
			
			INSERT INTO Services_Integration_Request([idRichiesta],[integrazione],[operazioneRichiesta],[statoRichiesta],[isOld],[dateIn],[idPfu],[idAzi])
							--VALUES  (@idDocRichiedente, @integrazione, @operazioneRichiesta, @statoRichiesta,0,getDate(),@idPfu,@idAzi)
		
		
				--select @idDocRichiedente,case when dbo.GetPos( REL_ValueOutput , '#' , 2 ) <>'' then dbo.GetPos( REL_ValueOutput , '#' , 2 ) else   @integrazione end ,
				--				dbo.GetPos( REL_ValueOutput , '#' , 1 ) ,@statoRichiesta,0,getDate(),@idPfu,@idAzi
					
				select @idDocRichiedente,@integrazione,REL_ValueOutput ,@statoRichiesta,0,getDate(),@idPfu,@idAzi	
					from CTL_Relations 
					where REL_Type = 'SERVICE_REQUEST' and REL_ValueInput=@integrazione + '-' + @operazioneRichiesta
					order by REL_idRow

		


		end
		else
		begin
			INSERT INTO Services_Integration_Request([idRichiesta],[integrazione],[operazioneRichiesta],[statoRichiesta],[isOld],[dateIn],[idPfu],[idAzi])
									VALUES  (@idDocRichiedente, @integrazione, @operazioneRichiesta, @statoRichiesta,0,getDate(),@idPfu,@idAzi)
		end

	END

END



GO
