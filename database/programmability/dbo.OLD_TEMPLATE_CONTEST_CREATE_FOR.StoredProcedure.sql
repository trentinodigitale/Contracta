USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TEMPLATE_CONTEST_CREATE_FOR]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from CTL_Parametri where contesto = 'DGUE'  and oggetto = 'Template_Deseleziona_Parti'
--update CTL_Parametri set valore = 'SOLO_OBBLIGATORI' where contesto = 'DGUE'  and oggetto = 'Template_Deseleziona_Parti'
--select dbo.PARAMETRI ('DGUE','Template_Deseleziona_Parti','DefaultValue','','-1')

--select * from ctl_doc where id= 313716
--update ctl_doc set deleted = 1 where id= 313720

--select o.Row ,*
--	from ctl_doc_value o
--	where  o.idheader = 313720 and o.DSE_ID = 'VALORI' and o.DZT_Name = 'NotEditable' and  o.Value like '% SelRow %'  





CREATE    Proc [dbo].[OLD_TEMPLATE_CONTEST_CREATE_FOR]
	( @IdDoc int  , @idUser int , @tipoTemplate varchar(200) )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as int
	declare @Errore as nvarchar(2000)
	declare @PartiNonSelezionate as varchar(max)
		


	set @Id = null
	set @Errore=''

	select @id = id from ctl_doc where deleted = 0 and linkeddoc = @IdDoc and tipodoc = 'TEMPLATE_CONTEST' and jumpcheck = @tipoTemplate 

	if isnull( @id , 0 ) = 0
	begin

		
		declare @idTemplate int
		declare @Versione varchar(1000)


		-- recupero il template base
		select @idTemplate = id , @Versione = versione from ctl_doc where deleted = 0 and tipodoc = 'TEMPLATE_REQUEST' and StatoFunzionale = 'Pubblicato' and jumpcheck = 'DGUE'


		-- genero il template
		insert into ctl_doc ( [TipoDoc], [IdPfu], [Data], [Titolo], [LinkedDoc] , [IdDoc]  , jumpcheck  , Versione)
			values( 'TEMPLATE_CONTEST' , @idUser , getdate() , '' , @IdDoc , @idTemplate , @tipoTemplate , @Versione)

		set @id = SCOPE_IDENTITY()


		-- recupero le parti che sono obbligatori
		select  distinct 
			
			k2.Row as Riga , k2.Value as KeyRiga , t2.Value as Parti  , m2.Value as idModulo 
			into #Temp
			
			from ctl_doc_value o 
				inner join ctl_doc_value t on t.idheader = o.IdHeader and t.Row = o.Row and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.Value = 'Parti'
				inner join ctl_doc_value k on k.idheader = o.IdHeader and k.Row = o.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga' 

				-- recupero tutti gli elementi delle parti non obbligatorie
				inner join ctl_doc_value k2 on k2.idheader = o.IdHeader and k2.DSE_ID = 'VALORI' and k2.DZT_Name = 'KeyRiga'  and left( k.Value ,1 ) = left( k2.Value , 1 ) 
				inner join ctl_doc_value t2 on t2.idheader = o.IdHeader and t2.Row = k2.Row and t2.DSE_ID = 'VALORI' and t2.DZT_Name = 'REQUEST_PART' 
				inner join ctl_doc_value m2 on m2.idheader = o.IdHeader and m2.Row = k2.Row and m2.DSE_ID = 'VALORI' and m2.DZT_Name = 'idModulo' 
			where  o.idheader = @idTemplate and o.DSE_ID = 'VALORI' and o.DZT_Name = 'Obbligatorio' and o.Value <> '1'


				
		-- Porto le righe da selezionare sul template per contesto
		declare CurTemplateRequest Cursor local static for 
			
			select Riga  , Parti , idModulo from #Temp order by riga

		declare @row int
		declare @Riga int
		declare @Parti varchar(500)
		declare @idModulo int
		declare @Desc nvarchar(max)
		set @row = 0

		open CurTemplateRequest

		FETCH NEXT FROM CurTemplateRequest 	INTO  @Riga , @Parti , @idModulo
		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			-- gli associo tutte le richieste
			insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
				select @id as IdHeader, DSE_ID, @Row, DZT_Name, Value
					from ctl_doc_value 
						where idheader = @idTemplate and DSE_ID = 'VALORI' and DZT_Name not in ( 'FNZ_DEL' , 'FNZ_COPY' , 'FNZ_UPD' ,'EsitoRiga'  ) and row = @Riga


			-- se il rigo è riferito ad un modulo si aggiorna la descrizione recuperandola dal modulo
			if @Parti = 'Modulo'
			begin
				--select @Desc = '<b>' + dbo.HTML_Encode( Body ) + '</b></br>' + + dbo.HTML_Encode( Note ) from ctl_doc where id = @idModulo
				select @Desc = '<b>' +  cast(  Body  as nvarchar(max)) + '</b></br>' +  cast( Note as nvarchar(max))  from ctl_doc where id = @idModulo
				update CTL_DOC_Value set Value = @Desc where IdHeader = @id and DSE_ID = 'VALORI' and Row = @row and DZT_Name = 'DescrizioneEstesa'
			end

			-- rendo non editabili le spunte delle aree non removibili
			insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
				select  @id as IdHeader, 'VALORI' as DSE_ID, @Row, 'NotEditable' as DZT_Name, case when o.Value = '1' then ' SelRow ' else '' end as Value
					from ctl_doc_value o 
					where  idheader = @idTemplate and o.DSE_ID = 'VALORI' and o.DZT_Name = 'Obbligatorio' and row = @Riga


			-- aggiungo l'esito riga
			insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
				select  @id as IdHeader, 'VALORI' as DSE_ID, @Row, 'EsitoRiga' as DZT_Name, '' as Value



			set @row = @row + 1
			FETCH NEXT FROM CurTemplateRequest 	INTO  @Riga , @Parti , @idModulo
		end
		CLOSE CurTemplateRequest
		DEALLOCATE CurTemplateRequest


		--metto le spunte per le selezioni implicite
		delete from CTL_DOC_Value  where idheader = @id and DSE_ID = 'VALORI'  and DZT_Name = 'SelRow'
		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )
			
			select  @id as IdHeader, 'VALORI' as DSE_ID, Row, 'SelRow' as DZT_Name, '1' as Value
				from ( select distinct [Row] from ctl_doc_value where idheader = @id and DSE_ID = 'VALORI' /*and DZT_Name = 'KeyRiga' */ 
						--escludo le righe della parte iV
						--and value not like 'E.%'
						) as a

		--tolgo le spunte per i moduli indicati da un parametro
		--CONTESTO=DGUE
		--Oggetto=Template_Deseleziona_Parti
		--Proprietà=DefaultValue
		--Valore=lista delle parti da deselezionare
		--select dbo.PARAMETRI ('DGUE','Template_Deseleziona_Parti','DefaultValue','','-1')
		select @PartiNonSelezionate = dbo.PARAMETRI ('DGUE','Template_Deseleziona_Parti','DefaultValue','','-1')
		
		if @PartiNonSelezionate <> ''
		begin

			if @PartiNonSelezionate = 'SOLO_OBBLIGATORI'
			begin
				delete from ctl_Doc_value 
					where idheader = @id and DSE_ID = 'VALORI' and dzt_name='SelRow'
						and row not in (
					
								select o.Row 
									from ctl_doc_value o
									where  o.idheader = @id and o.DSE_ID = 'VALORI' and o.DZT_Name = 'NotEditable' and  o.Value like '% SelRow %'  
								
							)

			end
			else
			begin
				delete from ctl_Doc_value 
					where idheader = @id and DSE_ID = 'VALORI' and dzt_name='SelRow'
						and row in (
					
								select Row from ctl_doc_value 
									inner join ( select * from dbo.split (@PartiNonSelezionate,',') ) KeyRiga on value like Keyriga.items + '%'
								where 
									idheader = @id and DSE_ID = 'VALORI' and DZT_Name = 'KeyRiga'			
							)

			end
		end

		-- creo il documento per gestire la REQUEST MODULO_TEMPLATE_REQUEST
		exec MODULO_TEMPLATE_REQUEST_CREATE_FOR @id , @IdUser   ,@tipoTemplate , 1


		-- inizializzo i campi per la spunta degli obbligatori dove ci sono sezioni con campi obbligatori con errore
		update CTL_DOC_Value set Value = '<img src="../images/Domain/State_ERR.png"/>' where   @id = IdHeader and  'VALORI' = DSE_ID and  'EsitoRiga' =  DZT_Name and row in ( 
								select distinct row
									from ctl_doc_value r with(nolock)
										inner join DOCUMENT_REQUEST_GROUP g with(nolock) on g.idheader = r.value and g.Obbligatorio = 1 and g.TypeRequest in ( 'R' , 'M' ) and g.InCaricoA = 'Ente'
									where r.idheader = @id and DSE_ID = 'VALORI' and  DZT_Name = 'idModulo' 
						)
		

		-- /////////////////////
		-- le seguenti operazioni sono demandate alla pagina che gestisce il modulo perchè la complessità è troppo alta e non conviene replicarla
		-- 1) genero i record per tutti i campi da inserire
		-- 2) genero i guid di tutti i campi da inserire

		--E.P. nel caso di nuovo DGUE recupero modulo di esempio creato per andare a settare esito riga ok sui campi 
		--già valorizzati (che avevano sorgentecmpo <>'')
		declare @IdMod_Temp_Request as int
		if @Versione = '2'
		begin
			select @IdMod_Temp_Request = id from ctl_Doc where linkeddoc = @id and tipodoc='MODULO_TEMPLATE_REQUEST'

			--segno esito riga ok sul template contest per i campi già valorizzati
			exec TEMPLATE_CONTEXT_EVIDENCE_OBBLIG @IdMod_Temp_Request , ''

		end
		
		



	end


	
	if @Errore=''
		-- ritorna id odc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- ritorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	
end




GO
