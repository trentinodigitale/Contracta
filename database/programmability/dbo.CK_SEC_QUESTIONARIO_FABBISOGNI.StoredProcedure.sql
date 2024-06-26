USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_QUESTIONARIO_FABBISOGNI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[CK_SEC_QUESTIONARIO_FABBISOGNI] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.


	
	
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @richiestafirma varchar(50)
	
	set @Blocco = ''

	select 
			@richiestafirma=ISNULL(richiestafirma,'')
		from ctl_doc
		where id = @IdDoc
	
	---Se non è richiesta la firma nasconde il FOLDER FIRMA
    if  @richiestafirma <> 'si'
    begin

		if @SectionName in ( 'FIRMA' )
		begin 
			set @Blocco = 'NON_VISIBILE'		
		end 
    
    end
	---Se non sono l'utente che ha in carico il documento non faccio vedere il FOLDER dei SUB_QUESTIOANARI
    if @SectionName in ( 'SUB_QUESTIONARI' ) 
	BEGIN


		-- se l'utente non appartiene all'azienda compilatore
		IF NOT EXISTS (Select * from ctl_doc inner join profiliutente p on p.idpfu = @IdUser and pfuidazi = cast( azienda as int ) where id=@IdDoc   )
		BEGIN
			set @Blocco = 'NON_VISIBILE'
		END

		-- momentaneamente , fino ad implementazione successiva, per i questionari qualitativi si comemnta l'uso dei subquestionari
		if exists ( select d.id from ctl_doc d inner join ctl_doc b on b.id = d.linkeddoc and b.TipoDoc = 'BANDO_FABB_QUALITATIVO' where d.id = @idDoc )
			set @Blocco = 'NON_VISIBILE'

		
	END
 


	select @Blocco as Blocco

end






GO
