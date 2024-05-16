USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_GESTIONE_GUUE_F03_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_GESTIONE_GUUE_F03_CREATE_FROM_CONVENZIONE] ( @id int , @IdUser int )
AS
BEGIN 

	-- INPUT :
	--	@id --id della convenzione 
	--	@IdUser
	
	SET NOCOUNT ON

	-- OGNI NUOVA INVOCAZIONE A QUESTA STORED CREERA' UN NUOVO DOCUMENTO DI GESTIONE_GUUE_F03 se non esiste
	-- CON I DELTA TED COLLEGATI
	
	declare @Errore			 NVARCHAR(2000)
	declare @newid			 INT
	declare @lotti			 varchar(max)
	declare @idGara			 INT
	declare @lotto			 varchar(max)
	declare @id_delta		 INT
	declare @cig			varchar(100)
	declare @TipoDoc  varchar(100)

	set @Errore = ''
	set @newId = null

	--recupero TipoDoc del documento sorgente
	select @TipoDoc = Tipodoc from CTL_DOC with (nolock) where id= @id


	-- PRIMA DI CREARE IL DOCUMENTO CERCO LO STESSO TIPODOC
	SELECT  @newId = id
		FROM CTL_DOC WITH(NOLOCK)
			WHERE tipodoc = 'GESTIONE_GUUE_F03' and Deleted = 0 and  LinkedDoc = @id and StatoFunzionale <> 'Annullato'

	--SE LO DEVO CREARE DEVE ESSERE PRESENTE SULLA CONVENZIONE DataStipulaConvenzione
	IF @newId is null 
	begin
		if @TipoDoc='CONVENZIONE'
		begin
			IF EXISTS ( select * from Document_Convenzione with(nolock) where id=@id and ISNULL(DataStipulaConvenzione,'')='' )
			BEGIN
				set @Errore='È previsto l’invio dei dati alla GUUE. È pertanto necessario indicare la data di stipula convenzione completa.'
			END
		end
		else
		begin
			--PER IL COTRATTO CONTROLLO CHE è VALORIZZATA DATA STIPULA DEL CONTRATTO
			IF not EXISTS ( select * from ctl_doc_value with(nolock) where idheader=@id and dse_id = 'CONTRATTO' and dzt_name='DataStipula' and ISNULL(value,'') <> ''  )
			BEGIN
				set @Errore='È previsto l’invio dei dati alla GUUE. È pertanto necessario indicare la data di stipula del contratto.'
			END
		end
	end

	IF @newId is null and @Errore=''
	begin
		
		if @TipoDoc='CONVENZIONE'
		begin

			INSERT INTO CTL_DOC (IdPfu,  TipoDoc, DataDocumento, idpfuincharge ,Azienda ,Destinatario_Azi, body,LinkedDoc, titolo, Deleted,JumpCheck) 
				select  @IdUser, 'GESTIONE_GUUE_F03',getDate(),  @IdUser ,P.pfuidazi,DC.AZI_Dest,'',@id, 'Gestione GUUE', 0,'CONVENZIONE'
					from ctl_doc C with(nolock)
						inner join Document_Convenzione DC with(nolock) on DC.id=C.id
						inner join ProfiliUtente P with(nolock) on P.idpfu=C.IdPfu
					where C.id = @id	

			set @newId = SCOPE_IDENTITY()
		end
		else
		begin
			--CONTRATTO_GARA
			INSERT INTO CTL_DOC (IdPfu,  TipoDoc, DataDocumento, idpfuincharge ,Azienda ,Destinatario_Azi, body,LinkedDoc, titolo, Deleted,JumpCheck) 
				select  @IdUser, 'GESTIONE_GUUE_F03',getDate(),  @IdUser ,P.pfuidazi,C.Destinatario_Azi,'',@id, 'Gestione GUUE', 0,'CONTRATTO_GARA'
					from ctl_doc C with(nolock)
						--inner join Document_Convenzione DC with(nolock) on DC.id=C.id
						inner join ProfiliUtente P with(nolock) on P.idpfu=C.IdPfu
					where C.id = @id	

			set @newId = SCOPE_IDENTITY()
		end

		--INSERISCE TUTTI I LOTTI PRESENTI SULLA CONVENZIONE/CONTRATTO_GARA
		insert into CTL_DOC_Value (IdHeader,row,DSE_ID,DZT_Name,Value)
			select @newId,ROW_NUMBER() over (order by cast(numerolotto as int))-1 as RowNUm,'LISTA_LOTTI','IdLotto' ,id 
				from Document_MicroLotti_Dettagli with(nolock) 
					where IdHeader=@id and voce=0 and TipoDoc=@TipoDoc --'CONVENZIONE'
						and StatoRiga not in ('Trasferito')
		
		--PER OGNI LOTTO CALCOLIAMO LA M (numero aggiudicatari)
		insert into CTL_DOC_Value (IdHeader,row,DSE_ID,DZT_Name,Value)
			select @newId,ROW_NUMBER() over (order by cast(dettconv.numerolotto as int))-1 as RowNUm,'LISTA_LOTTI','Num_Aggiudicatari' ,
					case when count(aggiud.id)=0 then 1 else count(aggiud.id) end as Value
				from 
					Document_MicroLotti_Dettagli dettConv  with(nolock) 
					-- Relazione per CIG tra la gara e la conv
						left join ( 
							
							select  
								lg.id  , cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
								from 
									Document_MicroLotti_Dettagli lg with(nolock)  
										inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
								where 
									isnull( lg.voce , 0 ) = 0 and isnull( CIG ,'' ) <> '' 

							) as lg  on  lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and dettConv.NumeroLotto=lg.NumeroLotto 

						left join CTL_DOC gr with(nolock) ON gr.LinkedDoc = lg.Id and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato'		
						left join Document_Convenzione dc with(nolock) on dc.ID = dettConv.IdHeader
						left join Document_microlotti_dettagli aggiud with(nolock) ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' --and ISNULL(aggiud.PercAgg,0) = 100 --and aggiud.Aggiudicata=dc.AZI_Dest	--prendo solo 100 del destinatario della convenzione		
				where 
					dettConv.IdHeader=@id and dettConv.voce=0 and dettConv.TipoDoc=@TipoDoc --'CONVENZIONE'
					and dettConv.StatoRiga not in ('Trasferito') 
					group by dettConv.numerolotto,dettConv.cig

		--CHIAMIAMO LA SP PER CREARE DELTA_TED_AGGIUDICAZIONE SE NON ESISTE PER QUEL CIG
		DECLARE curs2 CURSOR FAST_FORWARD FOR
		
			select 
				dettConv.NumeroLotto, 
				lg.LinkedDoc,
				DAGG.idHeader as ID_DELTA,
				lg.cig 

			--select lg.LinkedDoc as id_gara,lg.cig 
				from 
					Document_MicroLotti_Dettagli dettConv  with(nolock) 
						-- Relazione per CIG tra la gara e la conv
						left join ( 
									select  lg.id  , cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
										from Document_MicroLotti_Dettagli lg with(nolock)  
											inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
										where isnull( lg.voce , 0 ) = 0 and isnull( CIG ,'' ) <> '' 
									) as lg  on  lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and dettConv.NumeroLotto=lg.NumeroLotto 
						--Vedo se per quel CIG esiste già DELTA_TED_AGGIUDICAZIONE
						left join Document_TED_Aggiudicazione DAGG with(nolock) on DAGG.TED_CIG_AGG=lg.CIG
				where 
					dettConv.IdHeader=@id and dettConv.voce=0 and dettConv.TipoDoc=@TipoDoc --'CONVENZIONE'
					and dettConv.StatoRiga not in ('Trasferito') 
						
		
		OPEN curs2
		FETCH NEXT FROM curs2 INTO @lotto,@idGara,@id_delta,@CIG

		WHILE @@FETCH_STATUS = 0   
		BEGIN  
			--LEGO IL DOCUMENTO DELTA AGGIUDICAZIONE A QUESTA GESTIONE GUEE
			IF @id_delta IS NOT NULL
			BEGIN
				insert into CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Row,Value )
					select 
							@newId,'DELTA_TED_AGGIUDICAZIONE','Id',Row,@id_delta
						from 
							CTL_DOC_Value CV
								inner join Document_MicroLotti_Dettagli DT with(nolock) on DT.Id=CV.Value
						where 
							CV.IdHeader=@newId and dse_id='LISTA_LOTTI' and DZT_Name='IdLotto'
			END
			ELSE
			BEGIN
				
				--Chiamiamo la stored base N volte, una per lotto. Questo per creare 1 documento per ogni lotto
				EXEC DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_BANDO @idGara ,@IdUser , @lotto , @TipoDoc, 0 , @id
				
				--LEGO IL DELTA APPENA CREATO AL DOCUMENTO
				select @id_delta=idHeader from Document_TED_Aggiudicazione where TED_CIG_AGG=@CIG
				
				insert into CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Row,Value )
					select @newId,'DELTA_TED_AGGIUDICAZIONE','Id',Row,@id_delta
						from CTL_DOC_Value CV
							inner join Document_MicroLotti_Dettagli DT with(nolock) on DT.Id=CV.Value and NumeroLotto = @lotto							
							where CV.IdHeader=@newId and dse_id='LISTA_LOTTI' and DZT_Name='IdLotto'
			END

			FETCH NEXT FROM curs2 INTO @lotto,@idGara,@id_delta,@CIG

		END  

		CLOSE curs2   
		DEALLOCATE curs2
		
	end
	
	IF ISNULL(@newId,0) <> 0
	BEGIN
		select @newId as id
	END
	ELSE
	BEGIN
		
		select 'Errore' as id , @Errore as Errore

	END
END
GO
