USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONFERMA_AUTOMATICA_CONTROLLO_ALLEGATI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD_CONFERMA_AUTOMATICA_CONTROLLO_ALLEGATI] ( @IdDoc as int,@idprev as int, @out as varchar(20) output)
AS
BEGIN 	

set @out='si'


--SE SULLA NUOVA ISTANZA  SONO PRESENTI ALLEGATI FACCIO IL CONTROLLO
	IF EXISTS (select * from CTL_DOC_Value where DSE_ID='DOCUMENTAZIONE' and DZT_Name='Allegato' and ISNULL(value,'') <> '' and IdHeader=@IdDoc)
	BEGIN				
		----VERICA SE GLI ALLEGATI DELLLA SEZIONE DOCUMENTAZIONE SONO CAMBIATI------CONTROLLO FATTO SUI BLOB DEGLI ALLEGATI DELLE 2 ISTANZE
					
		select dbo.GetPos(CV2.value,'*',4)  as att into #temp_att 
				from CTL_DOC_Value CV2 
				where  CV2.IdHeader=@idprev and CV2.DSE_ID='DOCUMENTAZIONE' and CV2.DZT_Name='Allegato'
							
		select  cast(b.ATT_Obj as varbinary(max)) as blob_old into #temp_blob_old
			from  #temp_att CV2 
			inner join  ctl_attach b with(NOLOCK) on b.ATT_Hash=att 
						
		select dbo.GetPos(CV2.value,'*',4)  as att into #temp_att1 
				from CTL_DOC_Value CV2 
				where  CV2.IdHeader=@IdDoc and CV2.DSE_ID='DOCUMENTAZIONE' and CV2.DZT_Name='Allegato'
					
		select  cast(b.ATT_Obj as varbinary(max)) as blob_new into #temp_blob_new
			from  #temp_att1 CV2 
			inner join  ctl_attach b with(NOLOCK) on b.ATT_Hash=att 

			---LEFT E RIGHT JOIN IN CASO DI AGGIUNTA O RIMOZIONE RIGHE DAGLI ALLEGATI
			IF EXISTS ( select *
							from #temp_blob_new
							left join #temp_blob_old on blob_old=blob_new
							where blob_old IS NULL or blob_new IS NULL
						)
			BEGIN
				set @out='no'
			END	
			IF EXISTS ( select *
							from #temp_blob_new
							right join #temp_blob_old on blob_old=blob_new
							where blob_old IS NULL or blob_new IS NULL
						)
			BEGIN
				set @out='no'
			END		
	END

END


GO
