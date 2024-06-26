USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DGUE_COPY_FROM_DOC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[DGUE_COPY_FROM_DOC]( @idDoc as int , @idpfu int , @newId as int ) 
AS
--Versione=1&data=2017-10-13&Attivita=167911&Nominativo=Enrico
--@idDoc = id del documento da cui copiare il dgue
--@newId = id del nuovo doc a cui associare il nuovo dgue
BEGIN

    ---------------------COPIA DGUE SE TROVA IL DOC LINKEDDOC ALLA PRECEDENTE----------------------------------------------------------------------
	
    declare @iddgue as int
    declare @NEW_iddgue as int
	declare @VersioneFrom as varchar(10)
	declare @VersioneDest as varchar(10)
	declare @JumpCheck_FROM as varchar(500)
	declare @idTemplateDest as int

    set @iddgue=0

	set @VersioneFrom = ''
	set @VersioneDest = '' 
	set @JumpCheck_FROM = ''

    --recupero dgue prec
    select @iddgue=id , @JumpCheck_FROM = jumpcheck from ctl_doc with (nolock) 
		where LinkedDoc=@idDoc and TipoDoc='MODULO_TEMPLATE_REQUEST' and deleted = 0 
    
    	
    IF @iddgue > 0
	BEGIN
		
		--recupero versione del DGUE FROM
		select @VersioneFrom = ISNULL(versione,'') from ctl_doc with (nolock) where id = @iddgue

		--recupero versione del DGUE DEST
		--CRITERIO DI RECUPERO USATO LO STESSO PRESENTE NELLA STORED MODULO_TEMPLATE_REQUEST_CREATE_FOR
		if @JumpCheck_FROM not in ('DGUE_RTI','DGUE_AUSILIARIE','DGUE_ESECUTRICI','DGUE_SUBAPPALTO')
		BEGIN
			
			-- recupero la versione dal template legato al linkeddoc del linkeddoc del nuovo documento
			select @idTemplateDest = t.id, @VersioneDest = ISNULL(t.Versione,'')
				from ctl_doc I with(nolock) 
					inner join CTL_DOC t with(nolock)  on t.linkeddoc = I.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
					where I.id = @newId and T.JumpCheck=@JumpCheck_FROM
		END
		ELSE
		BEGIN
			
			-- recupero la versione dal template 
			select  @idTemplateDest = t.id, @VersioneDest = ISNULL(t.Versione,'')
				from ctl_doc I with(nolock)  ---RISPOSTA
					inner join ctl_doc IR with(nolock)  on IR.id=I.LinkedDoc and IR.TipoDoc='RICHIESTA_COMPILAZIONE_DGUE'
					inner join ctl_doc O with(nolock)  on  IR.LinkedDoc=O.id --and O.TipoDoc='OFFERTA'
					inner join CTL_DOC t with(nolock)  on t.linkeddoc = O.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
					where I.id = @newId  and T.JumpCheck=@JumpCheck_FROM

			-- se non trovo il template specifico provo con quello della mandataria ( BASE ) 
			if isnull( @idTemplateDest , 0 ) = 0 
			BEGIN
				
				-- recupero l'id del template
				select @idTemplateDest = t.id , @VersioneDest = ISNULL(t.Versione,'')
					from ctl_doc I with(nolock)  ---RISPOSTA
						inner join ctl_doc IR with(nolock)  on IR.id=I.LinkedDoc and IR.TipoDoc='RICHIESTA_COMPILAZIONE_DGUE'
						inner join ctl_doc O with(nolock)  on  IR.LinkedDoc=O.id --and O.TipoDoc='OFFERTA'
						inner join CTL_DOC t with(nolock)  on t.linkeddoc = O.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
						where I.id = @idDoc  and T.JumpCheck='DGUE_MANDATARIA'
			end
		END

		
		if isnull( @idTemplateDest , 0 ) = 0 
		BEGIN
			
			-- provo a navigare per le istanze
			select @idTemplateDest = t.id , @VersioneDest = ISNULL(t.Versione,'')
				from ctl_doc I with(nolock)  ---RISPOSTA
					inner join CTL_DOC t with(nolock)  on t.linkeddoc = i.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
					where I.id = @idDoc  
		END
		
		--SE HO TROVATO IL TEMPLATE DEST E sto lavorando con la stessa versione allora copio il DGUE
		--altrimenti NO
		
		if @idTemplateDest <> 0 AND @VersioneFrom = @VersioneDest
		BEGIN			
		   -- creo una copia del DGUE
		   INSERT into CTL_DOC ( IdPfu,  TipoDoc  )
			  select @idPfu as idpfu , TipoDoc   
				 from CTL_DOC with(nolock)
				 where id = @iddgue

		   set @NEW_iddgue = SCOPE_IDENTITY()

		   -- ricopio tutti i valori, rimuovendo il documento firmato
		   exec COPY_RECORD  'CTL_DOC'  ,@iddgue  , @NEW_iddgue , ',IdPfu,TipoDoc,ID,SIGN_HASH,SIGN_ATTACH,SIGN_LOCK'	
	   
		   --associo nuovo dgue al nuov doc	
		   update CTL_DOC set LinkedDoc=@newId,data=GETDATE() where id=@NEW_iddgue

		   --ricopio il dgue prec nel nuovo
		   insert	CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			  select @NEW_iddgue as IdHeader, DSE_ID, Row, DZT_Name, Value 
				 from CTL_DOC_Value with(nolock) where idheader = @iddgue 

		   --insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
		   --select  @NEW_iddgue as  idHeader, DSE_ID, MOD_Name
		   --	from CTL_DOC_SECTION_MODEL
		   --		where IdHeader = @iddgue
		   --print @IdTemplateDest
		  -- --KPF 553440 In fase di rinnovo dell'istanza di abilitazione allo sda, nel documento DGUE proponiamo il dato non aggiornato della sede legale 
		  -- e non svuotiamo la data
		   if @VersioneFrom = '2'
		   BEGIN
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
				
				update CV set Value=CVS.Value
					from CTL_DOC_Value CV with(nolock)
						inner join #Attrib_Da_Non_Copiare T on CV.DZT_Name=T.MA_DZT_Name
						inner join  ctl_doc IDMOD with(nolock)  on  IDMOD.deleted = 0 and IDMOD.TipoDoc = 'MODULO_TEMPLATE_REQUEST' and IDMOD.linkeddoc = @IdTemplateDest						
						inner join CTL_DOC_Value CVS with(nolock) on CVS.IdHeader = IDMOD.id and CVS.DSE_ID in (  'MODULO' , 'ITERAZIONI' , 'UUID' ) and cv.dse_id=cvs.DSE_ID
										and CVS.DZT_Name=T.MA_DZT_Name
				where CV.IdHeader = @NEW_iddgue

				truncate table #Attrib_Da_Non_Copiare;
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
				--select * from #Attrib_Da_Non_Copiare
				update CTL_DOC_Value set Value='' where IdHeader = @NEW_iddgue
					and DZT_Name in (select MA_DZT_Name from #Attrib_Da_Non_Copiare) 
		   END


		   --SOLO SE LA VERSIONE NON è LA NUOVA GENERO IL MODELLO
		   --E LO LEGO NELLA CTL_DOC_SECTION_MODEL
		   if @VersioneFrom < '2'
		   BEGIN

				-- GENERO LA COPIA PERSONALIZATA DEL MODELLO
				declare @Modello_Modulo		as varchar (500)
				declare @OLD_MOD			as varchar (500)

				select  @OLD_MOD = MOD_Name
					from CTL_DOC_SECTION_MODEL
						where IdHeader = @iddgue and DSE_ID = 'MODULO'

				--ogni documento avrà sempre la sua rappresentazione
				set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @NEW_iddgue as varchar )

				--associo il modello per la compilazione del modulo 
				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @NEW_iddgue  , 'MODULO' , @Modello_Modulo )
				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @NEW_iddgue  , 'MODULO_SAVE' , @Modello_Modulo ) --+ '_SAVE')

				--insert into CTL_Models ( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
				--	select @Modello_Modulo as MOD_ID, @Modello_Modulo as MOD_Name, @Modello_Modulo as MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template 
				--		from CTL_Models with(nolock) 
				--		where MOD_ID = @OLD_MOD

				--insert into CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module ) 
				--	select @Modello_Modulo as MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_Len, DZT_Dec, DZT_Format, DZT_Help, DZT_Multivalue, MA_Module
				--		from CTL_ModelAttributes with(nolock) 
				--		where MA_MOD_ID = @OLD_MOD

				--INSERT INTO CTL_ModelAttributeProperties ( MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module )
				--	SELECT @Modello_Modulo AS MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
				--		from CTL_ModelAttributeProperties with(nolock) 
				--		where MAP_MA_MOD_ID = @OLD_MOD

	   
				exec MAKE_MODULO_TEMPLATE_REQUEST  0, '' ,@NEW_iddgue
			END
		END
		
	END

END
GO
