USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[QUOTIDIANI_FORNITORI_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	
CREATE PROCEDURE [dbo].[QUOTIDIANI_FORNITORI_CREATE_FROM_USER] 	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @StatoFunzionale varchar(100)
	declare @IdAzi as int
	declare @LAstId as int

	set @Id = null
	set @Errore=''

	select @IdAzi = pfuidazi from profiliutente where idpfu = @idUser

	--vedo se esiste uno in lavorazione per utente
	SELECT @Id = ID 
		FROM CTL_DOC 
		where  Tipodoc = 'QUOTIDIANI_FORNITORI' and StatoFunzionale = 'InLavorazione' and deleted = 0 and idpfu = @idUser

	if @Errore = '' and @Id is null
	begin


		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
					ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck , PrevDoc)
				
			select @idUser,  'QUOTIDIANI_FORNITORI', 'Saved' ,  '' , '' , @IdAzi ,null
					,''  , '' , 0  ,'InLavorazione', @idUser , '' , 0
				

		set @Id = @@identity		

		--recupero ultimo confermato
		set @LAstId= -1
		select @LAstId = id from ctl_Doc where tipodoc='QUOTIDIANI_FORNITORI' and statofunzionale='Confermato' and deleted=0

		if @LAstId<> -1 
		begin
		
		-- copio tutti gli elementi del documento precedente confermato se esiste
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			select @Id as IdHeader, DSE_ID, Row, DZT_Name, Value 
				from CTL_DOC_Value
				where idheader = @LAstId and DSE_ID in ( 'VALORI' )
		end

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
