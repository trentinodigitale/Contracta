USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[QUESTIONARIO_DOMANDA_CREATE_FROM_DOC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	
CREATE PROCEDURE [dbo].[QUESTIONARIO_DOMANDA_CREATE_FROM_DOC] 	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @StatoFunzionale varchar(100)
	declare @IdConvenzione as int
	declare @IdOrdinativo as int	
	declare @IdAzi as int

	set @Id = null
	set @Errore=''


	

	if @IdDoc <> 0 
	begin
		select @StatoFunzionale = StatoFunzionale from CTL_DOC where id=@IdDoc	and Tipodoc = 'QUESTIONARIO_DOMANDA'
	

		if @StatoFunzionale <> 'Pubblicato' 
		begin
			set @Errore='Impossibile modificare il Dominio il cui stato e'' diverso da Pubblicato'
		end

		SELECT @Id = ID FROM CTL_DOC where PrevDoc=@IdDoc	and Tipodoc = 'QUESTIONARIO_DOMANDA' and StatoFunzionale = 'InLavorazione' and deleted = 0



		if @Errore = '' and @Id is null
		begin



			--inserisco nella ctl_doc		
			insert into CTL_DOC (
						IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
						ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck , PrevDoc , note)
				
				select @idUser,  'QUESTIONARIO_DOMANDA', 'Saved' ,  Titolo , Body , @IdAzi ,null
						,''  , Fascicolo , 0  ,'InLavorazione', @idUser , '' , @IdDoc , Note
					from CTL_DOC 
					where Id = @IdDoc

			set @Id = @@identity		

			-- copio tutti gli elementi
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				select @Id as IdHeader, DSE_ID, Row, DZT_Name, Value 
					from CTL_DOC_Value
					where idheader = @IdDoc and DSE_ID in (  'VALORI' , 'TIPOLOGIA' , 'ATTRIBUTO' , 'RIGHE' )


		end

	end
	else
	begin

		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
					ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck , PrevDoc)
				
			select @idUser,  'QUESTIONARIO_DOMANDA', 'Saved' ,  'Senza Titolo' as Titolo , '' as note , 0 ,null
					,''  , '' , 0  ,'InLavorazione', @idUser , '' , @IdDoc

		set @Id = @@identity		

	end


	if @Errore=''
		-- rirorna id  creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		

end





GO
