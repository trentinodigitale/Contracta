USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODULO_TEMPLATE_REQUEST_COPY_CONTENT_VER2]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[MODULO_TEMPLATE_REQUEST_COPY_CONTENT_VER2]  ( @idDoc_From int ,@IdDoc_to int  , @IdUser int )
AS
BEGIN

	--declare @idDoc_From int ,@IdDoc_to int  , @IdUser int

	--set @idDoc_From = 421471
	--set @IdDoc_to = 430951
	--set @IdUser = 35845

	declare @Statofunzionale varchar(500) 
	declare @Azienda varchar(500) 
	declare @LinkedDoc int
	declare @AziendaFrom as int
	declare @AziendaDest as int
	declare @IdUserFrom as int 
	declare @IdTemplateSource as int
	declare @IdTemplateDest as int

	set @LinkedDoc = 0
	set @Azienda = 0
	set @AziendaFrom = 0

	--recupero il documento a cui è legato il DGUE destinazione
	select @LinkedDoc  = LinkedDoc  , @Azienda = azienda 
		from CTL_DOC  with(nolock) 
		where id = @IdDoc_to and StatoFunzionale = 'InLavorazione' and TipoDoc = 'MODULO_TEMPLATE_REQUEST' 
	
	--stato funzionale del documento a cui è collegato il DGUE destinazione
	select @Statofunzionale = Statofunzionale  
		from ctl_doc  with(nolock) where id = @LinkedDoc

	--azienda documento DGUE sorgente da cui devo copiare
	select @AziendaFrom=Azienda,@IdUserFrom=Idpfu 
		from CTL_DOC  with(nolock) where Id=@idDoc_From

	--se azienda vale 0 allora recupero azienda del from dall'utente compilatore dl from
	if @AziendaFrom=0
		select @AziendaFrom = pfuidazi from ProfiliUtente with (nolock) where IdPfu = @IdUserFrom

	-- ricopio se il documento di destinazione è in lavorazione
	-- ricopio se il documento sorgente appartiene alla mia stessa azienda

	--select @Statofunzionale
	--select pfuidazi from profiliutente  with(nolock) where idpfu =  @IdUser and pfuidazi  = @AziendaFrom 
	if @Statofunzionale =  'InLavorazione' and exists ( select pfuidazi from profiliutente  with(nolock) where idpfu =  @IdUser and pfuidazi  = @AziendaFrom ) 

	BEGIN

		--recupero idtemplate del dgue sorgente
		SELECT @IdTemplateSource = dbo.GetIdTemplateComtest( @idDoc_From  ) 
			
		--recupero idtemplate del dgue destinatario
		SELECT @IdTemplateDest = dbo.GetIdTemplateComtest( @IdDoc_to  ) 

		
		--select @IdTemplateSource
		--select @IdTemplateDest
		--return

		--inserisco in una tabella temporanea i prefissi dei criteri del template sorgente
		select 
				distinct TEMPLATE_REQUEST_GROUP, 'MOD_' + replace(keyriga,'.','_') as PreFix_Mod_Source 
				into #Source
			from 
				 TEMPLATE_REQUEST_PARTS  with(nolock)
			where 
				idtemplate = @IdTemplateSource and REQUEST_PART ='modulo'

		

		--recupero a parità di numerodocumento del criterio i prefissi sul template destinatario
		select 
			PreFix_Mod_Source, 
			'MOD_' + replace(D.keyriga,'.','_') as PreFix_Mod_Dest

				into #Raccordo

				from 
					#Source S
						inner join TEMPLATE_REQUEST_PARTS D on S.TEMPLATE_REQUEST_GROUP = D.TEMPLATE_REQUEST_GROUP		
					where idTemplate = @IdTemplateDest
		
		--inserisco in una temp gli attributi che sono in carico all'ente
		--del dgue destinatario CHE NON DEVO RICOPIARE
		select 
			'MOD_' +  replace(k.value, '.','_') +  '_FLD_'  + dbo.GetID_ElementModulo(itemPath,ItemLevel,TypeRequest) as MA_DZT_Name			
				into #Attrib_Da_Non_Copiare	
			from
		
				CTL_DOC_Value t with(nolock)
					inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
					inner join CTL_DOC_Value M  with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
					inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.value
				
			where t.idheader = @IdTemplateDest   and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and InCAricoA = 'ente'
			--order by 1 
		
		--AGGIUNTO CON KPF 549318  richiesto da IC per svuotare la data in coda al DGUE
		insert into #Attrib_Da_Non_Copiare ( MA_DZT_Name)
			select 
				'MOD_' +  replace(k.value, '.','_') +  '_FLD_'  + dbo.GetID_ElementModulo(itemPath,ItemLevel,TypeRequest) as MA_DZT_Name			
			
				from
		
					CTL_DOC_Value t with(nolock)
						inner join CTL_DOC_Value k  with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
						inner join CTL_DOC_Value M  with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
						inner join DOCUMENT_REQUEST_GROUP G  with(nolock) on G.idheader = M.value
				
				where t.idheader = @IdTemplateDest   and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and G.DescrizioneEstesa='Data'




		--select * from #Raccordo
		--drop table #Raccordo
		--drop table #Source
		--drop table #temp
		--return

		--cancello i record del dgue destinazione
		--tranne gli attributi in carico all'ente CHE NON DEVO RICOPIARE
		--set @IdDoc_to = -10000 -- per debug
		delete from CTL_DOC_Value where IdHeader = @IdDoc_to
				and DZT_Name not in (select MA_DZT_Name from #Attrib_Da_Non_Copiare) 
		
		--drop table #Attrib_Da_Non_Copiare

		--copio i record del dgue sorgente sul dgue destinazione anteponendo 'COPY_' al dzt_name
		--tranne gli attributi in carico all'ente CHE NON DEVO RICOPIARE
		insert into CTL_DOC_Value
			( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
			select 
				@IdDoc_to as idheader  , DSE_ID ,Row ,'COPY_' + DZT_Name  as DZT_Name ,value  		
				from 
					CTL_DOC_Value with(nolock)  
				where 
					IdHeader = @idDoc_From  and DZT_Name not in (select MA_DZT_Name from #Attrib_Da_Non_Copiare) 
					and left(DZT_Name,5) <> 'COPY_'		
		
		--select * from #temp

		--return

		--rimpiazzo i prefissi COPY_.... con il prefisso corrispondente sul template destinatario
		--per tutte le sezioni del dgue: ITERAZIONI,MODULO,OBBLIGATORI,UUID
		
		--SEZIONI UUID e MODULO rimpiazzo i dztname con _F
		update 
			t
				set t.DZT_Name = REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source ,  PreFix_Mod_Dest  )
		--select t.DZT_Name , REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source ,  PreFix_Mod_Dest  )
			from 
				CTL_DOC_Value t with(nolock) 
				--#temp t 
					inner join #Raccordo on t.DZT_Name like 'COPY_' + PreFix_Mod_Source + '_F%'
			where 
				t.idheader = @IdDoc_to and t.DSE_ID in ('UUID', 'MODULO')	
		
		--SEZIONI UUID e MODULO rimpiazzo i dztname con _%
		update 
			t
				set t.DZT_Name = REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source + '_' ,  PreFix_Mod_Dest + '_'  )
		--select PreFix_Mod_Source, PreFix_Mod_Dest, t.DZT_Name  , REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source + '_' ,  PreFix_Mod_Dest + '_'  )
			from 
				CTL_DOC_Value t with(nolock) 
				--#temp t 
					inner join #Raccordo on t.DZT_Name like 'COPY_' + PreFix_Mod_Source + '_%_F%'
			where 
				t.idheader = @IdDoc_to and t.DSE_ID in ('UUID', 'MODULO')	

		--SEZIONE OBBLIGATORI prima vado per uguaglianza ed aggiorno anche nel value dove ci sono i riferimenti degli attributi
		update 
			t
				set 
					t.DZT_Name = REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source,  PreFix_Mod_Dest )
					, t.Value = REPLACE (t.Value ,  PreFix_Mod_Source + '_F' ,  PreFix_Mod_Dest + '_F' )
			from 
				CTL_DOC_Value t with(nolock) 
				--#temp t 
					inner join #Raccordo on t.DZT_Name = 'COPY_' + PreFix_Mod_Source 
			where 
				t.idheader = @IdDoc_to and t.DSE_ID in ('OBBLIGATORI')	
	
		--SEZIONE OBBLIGATORI  vado per like ed aggiorno anche nel value dove ci sono i riferimenti degli attributi
		update 
			t
				set 
					t.DZT_Name = REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source + '_',  PreFix_Mod_Dest + '_' )
					, t.Value = REPLACE (t.Value ,  PreFix_Mod_Source + '_' ,  PreFix_Mod_Dest + '_' )
			from 
				CTL_DOC_Value t with(nolock) 
					--#temp t 
					inner join #Raccordo on t.DZT_Name like 'COPY_' + PreFix_Mod_Source + '_%'
			where 
				t.idheader = @IdDoc_to and t.DSE_ID in ('OBBLIGATORI')	

		--SEZIONE ITERAZIONI KPF 516693 non funziona in quanto nel source non ci sono le iterazioni
		--update 
		--	t
		--		set 
		--			t.DZT_Name = REPLACE (t.DZT_Name , 'COPY_' + PreFix_Mod_Source + '@@@',  PreFix_Mod_Dest + '@@@' )
		--	from 
		--		CTL_DOC_Value t  with(nolock) 
		--		--#temp t                  
		--			inner join #Raccordo on t.DZT_Name like 'COPY_' + PreFix_Mod_Source + '@@@%'
		--	where 
		--		t.idheader = @IdDoc_to and t.DSE_ID in ('ITERAZIONI')	
		
		--PER LE ITERAZIONI TOLGO IL COPY
		update 
			t
				set 
					t.DZT_Name = REPLACE (t.DZT_Name , 'COPY_' ,  '' )
			from 
				CTL_DOC_Value t  with(nolock) 				
			where 
				t.idheader = @IdDoc_to and t.DSE_ID in ('ITERAZIONI')	

		
		--RIPULISCO EVENTUALI DZT_NAME CHE INIZIANO CON COPY_ CHE SONO RIMASTI E CHE NON SERVONO SUL NUOVO
		delete CTL_DOC_Value where idheader = @IdDoc_to and left(DZT_Name,5) = 'COPY_'		

		
		
		--cancello le temp
		drop table #Source
		drop table #Raccordo
		drop table #Attrib_Da_Non_Copiare

	END

END




GO
