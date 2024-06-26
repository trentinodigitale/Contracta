USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MAKE_DOMINI_QUESTIONARIO_AMMINISTRATIVO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[MAKE_DOMINI_QUESTIONARIO_AMMINISTRATIVO] 	(  @idDoc int  )
AS
BEGIN


SET NOCOUNT ON;


	declare @Keyriga as varchar(100)
	declare @Descrizione as nvarchar(500)
	declare @ElencoValori as nvarchar(max)
	
	--cancello le righe dei domini associate al documento se ci sono
	delete CTL_DomainValues where idheader=@idDoc and DMV_DM_ID='DOM_QUEST_AMM'


	--ciclo sulle righe parametri singola/multipla per andare 
	--a popolare i domini associati
	DECLARE crsSez CURSOR STATIC FOR 
	
		select 
			P.KeyRiga,P.Descrizione as Parametro, P.ElencoValori
			from 
				Document_Questionario_Amministrativo P
			where 
				P.idheader = @idDoc and P.TipoParametroQuestionario in ('SceltaSingola','SceltaMultipla')

	OPEN crsSez
	FETCH NEXT FROM crsSez INTO @Keyriga,@Descrizione,@ElencoValori
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		--metto nella @Detail_SezioniCondizionate le info delle sezioni condizionate
		insert into CTL_DomainValues
			( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Module], [DMV_Deleted])
		
			select
				@idDoc as idHeader,
				'DOM_QUEST_AMM' as DMV_DM_ID,
				'I' as DMV_LNG,
				items as DMV_Cod,
				@Keyriga as DMV_Father,
				1 as DMV_Level,
				items as DMV_DescML,
				'' as DMV_Image,
				ROW_NUMBER() OVER(ORDER BY items ASC) as DMV_Sort,
				'' as DMV_CodExt,
				'TEMPLATE_GARA' as DMV_Module,
				0 as DMV_Deleted
			
					from dbo.Split(@ElencoValori,'###') 
	
		


		FETCH NEXT FROM crsSez INTO @Keyriga,@Descrizione,@ElencoValori
	END

	CLOSE crsSez 
	DEALLOCATE crsSez 


	--aggiorno la data sulla lib_domain per togliere dalla cache il dominio
	update lib_domain set DM_LastUpdate = GETDATE() where DM_ID='DOM_QUEST_AMM'

END



GO
