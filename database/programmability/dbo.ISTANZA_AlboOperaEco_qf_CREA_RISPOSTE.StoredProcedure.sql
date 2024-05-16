USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_AlboOperaEco_qf_CREA_RISPOSTE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[ISTANZA_AlboOperaEco_qf_CREA_RISPOSTE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN

    SET NOCOUNT ON;

    declare @Id as INT
    declare @AreaValutazioneTestata as varchar(100)
    declare @AreaValutazione as varchar(100)
    declare @idazi as int
    declare @idbando as int
    declare @titolo varchar(100)
    declare @idaziForn int
    declare @cnt as int
    	
    -- legge area valutazione dalla testata del bando
    set @AreaValutazioneTestata=null
    	
    select @AreaValutazioneTestata=AreaValutazione,@idazi=c.azienda,@idbando=b.linkeddoc,
    @titolo=b.titolo,@idaziForn=b.azienda
    from document_bando a
    inner join ctl_doc b on a.idheader=b.linkeddoc
    inner join ctl_doc c on c.id=a.idheader
    where b.id=@idDoc
    	
    -- memorizza tutte le aree di valutazione di dettaglio in una tabella temporanea
    select distinct(areavalutazione) into #temp_aree
    from Document_Bando_DocumentazioneRichiesta
    where idheader=@idDoc and isnull(areavalutazione,'')<>''
    
    -- genera il documento per l'area di valutazione di testata
    set @cnt = 1
    exec Insert_Document_QUESTIONARIO_FORNITORE @idDoc,@IdUser,@AreaValutazioneTestata,@titolo , @idbando , @idazi ,1,@idaziForn,@cnt
	
    -- scorre le altre aree di valutazione
    DECLARE crs2 CURSOR FOR SELECT 
		  areavalutazione from #temp_aree
    


	OPEN crs2

    FETCH NEXT FROM crs2 INTO @AreaValutazione


    -- per ogni riga di bolla o packing list utile alle accise
    WHILE @@FETCH_STATUS = 0
    BEGIN
	   
	   -- genera il documento per l'area di valutazione di testata
	   set @cnt = @cnt + 1
	   exec Insert_Document_QUESTIONARIO_FORNITORE @idDoc,@IdUser,@AreaValutazione,@titolo , @idbando , @idazi ,0,@idaziForn,@cnt
	
	   
    
	   FETCH NEXT FROM crs2 INTO @AreaValutazione
    end	

    CLOSE crs2
    DEALLOCATE crs2
    
    
	
END












GO
