USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AVCP_IMPORT_CSV_DELETE_OLD_OE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc  [dbo].[OLD2_AVCP_IMPORT_CSV_DELETE_OLD_OE](  @Idrow int , @idDoc int , @idDocLottoPrev int , @idUser int)
AS
BEGIN 
 	set nocount on

	declare @MinRow int
	declare @MaxRow int
	declare @Cig nvarchar(200)
	declare @curCig nvarchar(200)
	declare @IdRiga int
	declare @FineCiclo int 

	set @MinRow = @Idrow
	set @MaxRow = @Idrow
	set @FineCiclo = 1

	------------------------------
	-- cerco le righe relative al lotto
	------------------------------
	declare CurImportCSV_FROW Cursor static for  
		select Idrow, Cig  
			from document_AVCP_Import_CSV 
			where idheader = @idDoc and isnull( cast( warning as varchar (4000)), '' ) = '' and Idrow >= @Idrow
			order by Idrow
	
	open CurImportCSV_FROW

	-- prendo il primo record
	FETCH NEXT FROM CurImportCSV_FROW  INTO @idRiga, @Cig
	set @curCig = @Cig
	
	-- ciclo su tutti  i record finche ci sono
	WHILE @@FETCH_STATUS = 0 and @FineCiclo = 1
	BEGIN
	
		if isnull( @Cig  , '' ) <> '' and  isnull( @Cig  , '' ) <> @curCig
		begin
			set @FineCiclo = 0
		end
		else
			set @MaxRow = @idRiga

		-- fine ciclo
		FETCH NEXT FROM CurImportCSV_FROW  INTO @idRiga, @Cig
	END
	 
	CLOSE CurImportCSV_FROW
	DEALLOCATE CurImportCSV_FROW


	------------------------------
	-- prendo tutti gli oe
	------------------------------
	select distinct o.id , o.tipoDoc , v.Value as RagSoc , p.Codicefiscale 
		into #Temp	
		from CTL_DOC l
			inner join CTL_DOC o on l.versione = o.LinkedDoc and o.StatoFunzionale = 'Pubblicato' and o.tipoDoc in ( 'AVCP_OE' , 'AVCP_GRUPPO' )
			left outer join CTL_DOC_VALUE v on o.id = v.idheader and v.dzt_name = 'RagioneSociale'
			left outer join document_AVCP_partecipanti p on p.idheader = o.id
		where l.id = @idDocLottoPrev
		
	
	select id , tipoDoc 
	into #TempOE
	from (
		-- prendo i gruppo non presenti
		select distinct id , tipoDoc --, RagSoc , Codicefiscale  
			from #Temp 
			where tipoDoc = 'AVCP_GRUPPO'
				and RagSoc not in ( select Gruppo 
										from  document_AVCP_Import_CSV
										where idheader = @idDoc and idrow >= @MinRow and idRow <= @MaxRow )

		union 
		
		-- prendo gli OE non presenti
		select distinct id , tipoDoc -- , RagSoc , Codicefiscale  
			from #Temp 
			where tipoDoc = 'AVCP_OE'
				and Codicefiscale not in ( select Codicefiscale
										from  document_AVCP_Import_CSV
										where idheader = @idDoc and idrow >= @MinRow and idRow <= @MaxRow and isnull(Gruppo,'') = '')
	) as a
	
	
	-- per ogni OE risultante devo effettuare l'annullamento
	declare @tipodoc	as varchar(50)
	declare @tipodocCTL as varchar(50)
	declare @tipoOE as varchar(50)
	 
	
	declare CurImportCSV_DEL_OE Cursor static for  
		select id , tipoDoc 
			from #TempOE 
	
	open CurImportCSV_DEL_OE

	-- prendo il primo record
	FETCH NEXT FROM CurImportCSV_DEL_OE  INTO @idDoc , @tipoOE
	
	-- ciclo su tutti  i record finche ci sono
	WHILE @@FETCH_STATUS = 0 and @FineCiclo = 1
	BEGIN
	
		----------------------------
		-- annullo l'OE corrente
		----------------------------
		update CTL_DOC set StatoFunzionale='Annullato',Deleted=1 where id = @idDoc

			
		set  @tipodocCTL = @tipoOE 
		set  @tipodoc = dbo.CNV( @tipoOE , 'I' ) 


		----------------------------
		-- creo il documento fittizio di operazione per evidenziare l'annullamento nello storico		
		----------------------------
		If ( @tipodocCTL = 'AVCP_OE' )
		BEGIN
			Insert into CTL_DOC (Idpfu,Titolo,TipoDoc,LinkedDoc,Fascicolo,DataInvio,StatoFunzionale)
				Select @idUser,'Cancellazione ' + @tipodoc + ' - Ragione Sociale : ' + RagioneSociale ,'AVCP_ACTION',@idDoc,Fascicolo,getDate(),'Conclusa'
					from ctl_doc 
						inner join document_AVCP_partecipanti on idheader=id
					where id=@idDoc
		END

		If ( @tipodocCTL = 'AVCP_GRUPPO' )
		BEGIN
			Insert into CTL_DOC (Idpfu,Titolo,TipoDoc,LinkedDoc,Fascicolo,DataInvio,StatoFunzionale)
				Select @idUser,'Cancellazione ' + @tipodoc + ' - Ragione Sociale : ' + Value ,'AVCP_ACTION',@idDoc,Fascicolo,getDate(),'Conclusa'
					from ctl_doc 
						inner join ctl_doc_value on idheader=id and DSE_ID='TESTATA' and DZT_Name = 'RagioneSociale'
					where id=@idDoc
		END


		-- fine ciclo
		FETCH NEXT FROM CurImportCSV_DEL_OE  INTO @idDoc , @tipoOE
	END
	 
	CLOSE CurImportCSV_DEL_OE
	DEALLOCATE CurImportCSV_DEL_OE


END






GO
