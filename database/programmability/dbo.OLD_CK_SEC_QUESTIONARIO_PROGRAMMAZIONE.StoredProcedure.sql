USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_QUESTIONARIO_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_CK_SEC_QUESTIONARIO_PROGRAMMAZIONE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
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


		--MOMENTANEAMENTE NON VISIBILE
		set @Blocco = 'NON_VISIBILE'
		-- se l'utente non appartiene all'azienda compilatore
		IF NOT EXISTS (Select * from ctl_doc inner join profiliutente p on p.idpfu = @IdUser and pfuidazi = cast( azienda as int ) where id=@IdDoc   )
		BEGIN
			set @Blocco = 'NON_VISIBILE'
		END

		

		
	END
 


	select @Blocco as Blocco

end





GO
