USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SOSTITUZIONE_RUP_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[SOSTITUZIONE_RUP_CREATE_FROM_BANDO_GARA] 
	( @idDoc int , @IdUser int  , @forzaCopia int = 0, @idOUT int = 0 out)
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	
	declare @Errore as nvarchar(2000)
	declare @IdPfu as INT

	set @Id=0
	set @Errore = ''

	IF @forzaCopia = 0
	BEGIN
		-- controllo se esiste una sostituzione in corso
		select @Id=id from CTL_DOC where linkedDoc = @idDoc and Tipodoc='SOSTITUZIONE_RUP' and StatoFunzionale = 'InLavorazione'
	END

	if ( @id IS NULL or @id=0 )
	begin 
		
		Insert into CTL_DOC (idpfu,Titolo,tipodoc,LinkedDoc,Azienda,ProtocolloRiferimento,Fascicolo,Body,JumpCheck)
		Select  @IdUser as idpfu ,
				'Sostituzione R.U.P.' ,
				'SOSTITUZIONE_RUP',
				 @idDoc  as LinkedDoc,
				 Azienda,
				 Protocollo,
				 Fascicolo,
				 Body,
				 case when TipoProceduraCaratteristica='RDO' then 'BANDO_RDO' else TipoDoc end
		from CTL_DOC 
		left join Document_Bando on id=idHeader 
		where id=@idDoc and deleted=0
	    set @id=@@IDENTITY	

		---recupero e inserisco il precedente RUP
		insert into ctl_doc_value (idheader,DSE_ID,dzt_name,Value)
		select @id,'TESTATA','UserRup_OLD',value
		from ctl_doc_value rup where rup.idHeader = @idDoc and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'

	end
	--se esiste metto idpfu l'utente che è collegato
	else
	begin 
		update CTL_DOC set idpfu=@IdUser where id=@Id

	end

	IF @forzaCopia = 0
	BEGIN
		if @Errore = ''
		begin
			-- rirorna l'id della Commissione
			select @Id as id
	
		end
		else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
	END
	ELSE
		SET @idOUT = @id


END














GO
