USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AGGIORNA_CODIFICHE_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[AGGIORNA_CODIFICHE_CREATE_FROM_USER] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	
	declare @id as int 
	declare @IdAzi as int
	declare @attrib as varchar(500)


	select @IdAzi = pfuidazi from ProfiliUtente  where IdPfu = @idUser
		
	set @Id=0
		
	--Se e' presente una richiesta salvata dallo stesso utente la riapro
	select @id=id from ctl_doc where tipodoc='AGGIORNA_CODIFICHE' and IdPfu=@idUser and statofunzionale='InLavorazione' and deleted=0 and idpfu=@idUser
		
	if @id=0
	BEGIN
			
		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,  
						ProtocolloRiferimento,  Fascicolo, StatoFunzionale,IdPfuInCharge, jumpcheck)
			values	
					( @idUser, 'AGGIORNA_CODIFICHE', 'Saved' , 'Aggiorna Codifiche' , '' , @IdAzi 
						,''  , '' , 'InLavorazione', null , '')
						

		set @Id = SCOPE_IDENTITY()		



		--recupero tutti gli atttributi a dominio che hanno un valore obsoleto

		--popolo la ctl_doc_Value con questi attributi
		--per ogni attributo creo una sezione fatta in questo modo
		--sezione = attributo
		--dzt_name = attributo
		--tante righe row=0,1,2,ecc.. quanti sono i valori obsoleti
		--select * from CTL_DOC_Value where DSE_ID='enti' and IdHeader = 58496

		CREATE TABLE #Codifiche_Obsolete_Temp
		(
			Attributo varchar(600) COLLATE database_default,
			codice varchar(600) COLLATE database_default
			
		)

		insert into #Codifiche_Obsolete_Temp
			(Attributo,Codice)
			exec VERIFICA_DOMINI_PRODOTTI_METAPRODOTTI '',1
		
		--travaso tutto nella ctl_doc_value
		--faccio un cursore per ogni attributo per creare 
		--la griglia con il corretto valore di Row

		DECLARE crsAttribObsoleti CURSOR STATIC FOR 

			select distinct Attributo from #Codifiche_Obsolete_Temp

		OPEN crsAttribObsoleti

		FETCH NEXT FROM crsAttribObsoleti INTO @attrib
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			insert into 
				CTL_DOC_Value ([IdHeader], [DSE_ID], [Row], [DZT_Name], [Value])
				select 
					@Id as Idheader , Attributo as DES_ID, ROW_NUMBER()  OVER(ORDER BY Codice ASC) -1  AS Row,  
					Attributo as DZT_Name, codice as Value
					from 
						#Codifiche_Obsolete_Temp where Attributo = @attrib

			FETCH NEXT FROM crsAttribObsoleti INTO @attrib
		END

		CLOSE crsAttribObsoleti 
		DEALLOCATE crsAttribObsoleti 

		
		--select * from #Codifiche_Obsolete_Temp

	
	END
			
	

	
	--if @Errore=''
		-- rirorna id odc creato
	select @Id as id , '' as Errore
	--else
	--begin
		-- rirorna l'errore
	--	select 'Errore' as id , @Errore as Errore
	--end
		
	
	

END


GO
