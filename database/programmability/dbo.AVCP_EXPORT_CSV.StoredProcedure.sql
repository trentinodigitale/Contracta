USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AVCP_EXPORT_CSV]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[AVCP_EXPORT_CSV] 
(
	@IdPfu						int,
	@P_Azi_Ente					varchar(80),
	@P_CIG						varchar(80),
	@P_Anno						varchar(80),
	@P_Oggetto                  varchar(8000),
	@PerCF                      varchar(10) = 'si'
)
as
begin
	set nocount on

	declare @Cmd 	varchar(8000)


	declare @NumeroAutorita varchar(100)
	declare @cig  varchar(100)
	declare @cfprop  varchar(100)
	declare @Denominazione  varchar(1000)
	declare @Oggetto  varchar(8000)
	declare @Scelta_contraente  varchar(100)
	declare @ImportoAggiudicazione  varchar(100)
	declare @DataInizio  varchar(100)
	declare @Datafine  varchar(100)
	declare @ImportoSommeLiquidate  varchar(100)

	declare @Gruppo  varchar(1000)
	declare @Ruolopartecipante  varchar(100)
	declare @Ragionesociale  varchar(1000)
	declare @Codicefiscale  varchar(100)
	declare @EsteroCodicefiscale varchar(100)
	declare @aggiudicatario varchar(10)
	
	declare @IMP_DataInizio datetime
	declare @IMP_DataFine datetime
	declare @IMP_DataLiquidazione datetime
	declare @IMP_Importo float

	DECLARE @FETCH_STATUS_partecipanti INT
	DECLARE @FETCH_STATUS_IMPORTI INT

	declare @ID INT
	declare @Versione varchar(50)
	declare @DataPubblicazione  datetime

	create table #TempAzi ( lnk int )
	
	-- se è stata chiesta l'esportazione per idazi netto e non per codicefiscale	        
    if @PerCF = 'si'
    begin

	    insert into #TempAzi ( lnk ) 
	            select b.lnk 
 		            from DM_Attributi a with(Nolock)
							inner join DM_Attributi b with(Nolock) on b.dztNome='codicefiscale' and a.vatValore_FT = b.vatValore_FT 
					where a.dztNome='codicefiscale' and a.lnk = @P_Azi_Ente
    end
    else
    begin

	    insert into #TempAzi ( lnk ) 
	            select idazi as lnk 
		            from aziende with(nolock)
					where idazi = @P_Azi_Ente
        
    end
	
	-- Estraggo i lotti 

	select l.id , l.Versione , og.cig as NumeroAutorita, o.cig , o.cfprop , o.Denominazione ,o.DataPubblicazione,  o.Oggetto , o.Scelta_contraente ,o.ImportoAggiudicazione , o.DataInizio , o.Datafine , o.ImportoSommeLiquidate ,

					cast( '' as varchar(1000))  as Gruppo,
					cast( '' as varchar(10))	as Ruolopartecipante ,
					cast( '' as varchar(1000))  as Ragionesociale ,
					cast( '' as varchar(1000))  as Codicefiscale ,
					cast( '' as varchar(1000))  as EsteroCodicefiscale ,
					cast( '' as varchar(1000))  as aggiudicatario

		into #TempLotti
			
		from ctl_doc l with(Nolock)
        	                left outer join ctl_doc g with(Nolock) on l.Linkeddoc = g.versione and g.statofunzionale = 'Pubblicato' and g.TipoDoc = 'AVCP_GARA' and g.Deleted = 0
        	                left outer join document_avcp_lotti og with(Nolock) on g.id = og.idheader
        	                inner join document_avcp_lotti o with(Nolock) on l.id = o.idheader
                       where l.tipodoc = 'AVCP_LOTTO' 
                                and l.statofunzionale = 'Pubblicato' 
                                and convert( varchar(7) , o.DataPubblicazione , 121)  >= '2012-12'
                                and l.azienda in (select lnk from #TempAzi )
                                and (  @P_CIG = '' or o.CIG = @P_CIG or og.Cig = @P_CIG )
                                and ( o.Anno = @P_Anno or og.Anno = @P_Anno )
                                and ( @P_Oggetto = '' or o.Oggetto like '%' + @P_Oggetto + '%' or og.oggetto like '%' + @P_Oggetto + '%' )
                                and ( isnull(l.Linkeddoc,0) = 0 or  g.id is not null )

								and l.Deleted = 0

		order by  o.DataPubblicazione, og.cig , o.cig
		    
	------------------------------------------
	--per ogni lotto prendiamo i partecipanti	
	------------------------------------------
	declare CurProg Cursor static for
				Select Id , Versione ,DataPubblicazione,NumeroAutorita,cig
					from #TempLotti
					order by DataPubblicazione

	open CurProg



	FETCH NEXT FROM CurProg  INTO @id , @Versione , @DataPubblicazione, @NumeroAutorita, @cig

	WHILE @@FETCH_STATUS = 0
	BEGIN

		
		------------------------------------------
		--Apro un cursore con i partecipanti alla gara
		------------------------------------------
		declare CurPartecipanti Cursor static for  
			select 
					isnull( v.Value , '' ) as Gruppo,
					a.Ruolopartecipante ,
					Ragionesociale ,
					case when Estero = '0' then Codicefiscale else '' end as Codicefiscale ,
					case when Estero <> '0' then Codicefiscale else '' end as EsteroCodicefiscale ,
					aggiudicatario
	
				from  CTL_DOC p with(Nolock)
						inner join dbo.document_AVCP_partecipanti a with(Nolock) on p.id = a.idheader
						left outer join  ctl_doc_value v with(Nolock) on v.idheader = p.id and v.DSE_ID = 'TESTATA' and v.dzt_name = 'RagioneSociale'
					where p.tipoDoc in ('AVCP_OE','AVCP_GRUPPO') and p.statofunzionale = 'Pubblicato'
							and cast( p.LinkedDoc as varchar ) = @Versione and p.Deleted = 0
					--order by a.Idrow
					order by a.aggiudicatario desc , Gruppo asc , a.Ruolopartecipante desc , Ragionesociale																		
		
		open CurPartecipanti

		FETCH NEXT FROM CurPartecipanti  INTO @Gruppo , @Ruolopartecipante , @Ragionesociale , @Codicefiscale , @EsteroCodicefiscale , @aggiudicatario
		SET @FETCH_STATUS_partecipanti = @@FETCH_STATUS


		-- se ci sono i partecipanti con il primo record aggiorno il record inserito sulla gara
		if @FETCH_STATUS_partecipanti = 0 
		begin
			update #TempLotti 
				set Gruppo			  = @Gruppo 
				, Ruolopartecipante   = @Ruolopartecipante 
				, Ragionesociale	  = @Ragionesociale 
				, Codicefiscale       = @Codicefiscale 
				, EsteroCodicefiscale = @EsteroCodicefiscale
				, aggiudicatario	  = @aggiudicatario
				where id = @id
				
			FETCH NEXT FROM CurPartecipanti  INTO @Gruppo , @Ruolopartecipante , @Ragionesociale , @Codicefiscale , @EsteroCodicefiscale , @aggiudicatario
			SET @FETCH_STATUS_partecipanti = @@FETCH_STATUS
		end



		------------------------------------------
		--Apro un cursore per gli importi della gara
		------------------------------------------
		declare CurImporti Cursor static for  
			--COMMENTO CON ATTTIVITA' 325925
			--select DataInizio, DataFine, DataLiquidazione, Importo	
			--	from  document_AVCP_Importi with(Nolock)
			--	where idheader = @Id
			--	order by Idrow
			select DataInizio, DataFine, NULL as DataLiquidazione, ImportoSommeLiquidate	
				from  document_AVCP_Lotti with(Nolock)
				where idheader = @Id
				order by Idrow
		
		open CurImporti

		FETCH NEXT FROM CurImporti  INTO @IMP_DataInizio, @IMP_DataFine, @IMP_DataLiquidazione, @IMP_Importo
		SET @FETCH_STATUS_IMPORTI = @@FETCH_STATUS


		-- se ci sono i partecipanti con il primo record aggiorno il record inserito sulla gara
		if @FETCH_STATUS_IMPORTI = 0 
		begin
			update #TempLotti 
				set  DataInizio = @IMP_DataInizio, DataFine = @IMP_DataFine, ImportoSommeLiquidate = @IMP_Importo
				where id = @id
				
			FETCH NEXT FROM CurImporti  INTO @IMP_DataInizio, @IMP_DataFine, @IMP_DataLiquidazione, @IMP_Importo
			SET @FETCH_STATUS_IMPORTI = @@FETCH_STATUS
		end



		-- per i restanti aggiungo le righe nella tabella temporanea
		WHILE @FETCH_STATUS_partecipanti = 0 or @FETCH_STATUS_IMPORTI  =0
		BEGIN
		
			-- se i dati dei partecipanti sono assenti svuoto i campi di appoggio
			if @FETCH_STATUS_partecipanti <> 0
			begin			
				select @Gruppo = '', @Ruolopartecipante = '', @Ragionesociale = '', @Codicefiscale = '', @EsteroCodicefiscale = '' , @aggiudicatario = ''
			end

			-- se i dati degli importi sono assenti svuoto i campi di appoggio
			if @FETCH_STATUS_IMPORTI <> 0
			begin			
				select @IMP_DataInizio = null , @IMP_DataFine = null , @IMP_DataLiquidazione = null , @IMP_Importo = null
			end
		
			-- inserisco il record completo
			insert into  #TempLotti ( id , versione , /*DataPubblicazione , */ Gruppo , Ruolopartecipante , Ragionesociale , Codicefiscale , EsteroCodicefiscale , aggiudicatario ,
										DataInizio , DataFine  ,  ImportoSommeLiquidate , NumeroAutorita, cig)
			
				values ( @id , @Versione ,/* @DataPubblicazione ,*/ @Gruppo , @Ruolopartecipante , @Ragionesociale , @Codicefiscale ,@EsteroCodicefiscale, @aggiudicatario ,
										@IMP_DataInizio , @IMP_DataFine ,  @IMP_Importo , @NumeroAutorita, @cig )



			-- muovo il cursore dei partecipanti
			if @FETCH_STATUS_partecipanti = 0
			begin			
				FETCH NEXT FROM CurPartecipanti  INTO @Gruppo , @Ruolopartecipante , @Ragionesociale , @Codicefiscale , @EsteroCodicefiscale , @aggiudicatario
				SET @FETCH_STATUS_partecipanti = @@FETCH_STATUS
			end

			-- muovo il cursore degli importi
			if @FETCH_STATUS_IMPORTI = 0
			begin 
				FETCH NEXT FROM CurImporti  INTO @IMP_DataInizio, @IMP_DataFine, @IMP_DataLiquidazione, @IMP_Importo
				SET @FETCH_STATUS_IMPORTI = @@FETCH_STATUS
			end
		END 

		CLOSE CurPartecipanti
		DEALLOCATE CurPartecipanti

		CLOSE CurImporti
		DEALLOCATE CurImporti

		-- passo alla gara successiva             
		FETCH NEXT FROM CurProg INTO @id , @Versione , @DataPubblicazione, @NumeroAutorita, @cig
	END 
	CLOSE CurProg
	DEALLOCATE CurProg

	declare @crlf varchar (10)
	set @crlf = '
'

	--------------------------------------------------------
	-- ESTRAZIONE DEL RECORDSET PRODOTTO
	--------------------------------------------------------
	

	select id , Versione , isnull(  NumeroAutorita , '' ) as NumeroBAndo  , isnull( cig , '' ) as CIG , 
			isnull( cfprop , '' ) as cfprop , isnull( Denominazione , '' ) as Denominazione  ,
			
			--isnull( convert( varchar(10) , DataPubblicazione , 105 ) , '' ) as DataPubblicazione,  
			DataPubblicazione, -- devo far uscire il valore grezzo, per far uscire un datetime e non una stringa. con l'xlsx è meglio così

			-- tronco a 250 essendo il limite imposto da anac per l'oggetto
			left(isnull(cast( Oggetto as nvarchar(max)), '' ),250) as Oggetto ,
			--isnull( replace( left( cast( Oggetto as varchar(250)),250 ), @crlf , ' ') , '' ) as Oggetto ,

			isnull( Scelta_contraente , '' ) as Scelta_contraente , 
			isnull( dbo.AF_FormatNumber( ImportoAggiudicazione ,2 ) , '' )as ImportoAggiudicazione , 

			-- passando alla versione xlsx le date le faccio uscire come dato grezzo, datetime, non più come stringhe
			--isnull( convert( varchar(10) , DataInizio , 105 ) , '' ) as DataInizio ,
			-- isnull ( convert( varchar(10) , Datafine ,105 ) , '' ) as Datafine 
			DataInizio,
			Datafine,

			isnull( dbo.AF_FormatNumber( ImportoSommeLiquidate ,2), '' ) as ImportoSommeLiquidate ,

			isnull( Gruppo , '' ) as Descrizione, isnull( Ruolopartecipante , '' ) as Ruolopartecipante ,
			isnull( Ragionesociale , '' ) as Ragionesociale , isnull( Codicefiscale ,'' ) as Codicefiscale ,
			isnull( EsteroCodicefiscale ,'' ) as AziCodiceFiscale , isnull( aggiudicatario , '' ) as aggiudicatario

	--select * 
	from #TempLotti

		order by /*DataPubblicazione , */  id  ,cig desc , NumeroAutorita desc, cfprop desc
				,  isnull( aggiudicatario , '' ) desc , isnull( Gruppo , '' ) asc ,  isnull( Ruolopartecipante , '' ) desc  , isnull( Ragionesociale , '' ) 


 		set nocount off
	
end









GO
