USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetArticlesFromLastOAP]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[GetArticlesFromLastOAP]
(
     @IdAzi INT, 
     @ArtCode NVARCHAR(20),
     @CodiceArtForn NVARCHAR(20),
     @SediDest VARCHAR(500),
     @Variazione  VARCHAR(1),
     @Viewed VARCHAR(1),
     @iIdPfu INT,
     @cContext CHAR(1),
     @vTiporiga VARCHAR(20),
     @vSuffLng VARCHAR(5),
     @bOcl BIT,
     @AcceptedProgrammeOrder INT       
)
AS
SET NOCOUNT ON
DECLARE @vRecordSET VARCHAR(8000)
DECLARE @vS VARCHAR(500)
DECLARE @vIdazi VARCHAR(500)
DECLARE @vPath  VARCHAR(500)
DECLARE @vFiltro VARCHAR(4000)
DECLARE @vDesc varchar(4000)
DECLARE @vRep varchar(10)
DECLARE @iVal int 
SET @iVal = 3 	
SET @vDesc = '(select d.dsctesto from tipidatirange x inner join (
						select idtid from tipidati where tidnome like ''CARTipoRiga'') y
				 on (x.tdridtid = y.idtid and x.tdrcodice = tot.TipoRiga AND x.tdrDeleted = 0)
			inner join QQQ d on x.tdriddsc = d.iddsc) as ''DescTipoRiga'''		
SET @vFiltro = ''
SET @variazione = CONVERT(VARCHAR(2),@variazione)
SET @Viewed = CONVERT(VARCHAR(2),@Viewed)
IF @Idazi IS null
   BEGIN
	RAISERROR ('Errore Parametro @Idazi mancante',16,1)
	RETURN 99
   END 
IF @SediDest <> ''
   BEGIN
	SET @vS = @SediDest
	SET @vIdazi = SUBSTRING(@vS,1,PATINDEX ('%#%',@vS)-1)
	SET @vPath = SUBSTRING (@vS,PATINDEX ('%#%',@vS)+1,LEN(@vS))
   END 	
		
IF @cContext NOT IN ('','S','B')
   BEGIN
	RAISERROR ('Errore Parametro @cContext ERRATO',16,1)
	RETURN 99
   END
     
IF @cContext='' OR @cContext='S'
   BEGIN
        IF @AcceptedProgrammeOrder = '2'
        SET @vRecordSET = 'select oapD.TipoRiga,oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
			          oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg,oapd.VariatoForn, oapd.AcceptedProgrammeOrder
	                     from oapdettaglio as oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
			          on oapd.idoap = oapT.idoap
 		            where opaA.idazi = '+convert(VARCHAR(30),@idazi)+' AND oapT.IdPfuDest = '+convert(VARCHAR(30),@iIdPfu)
        ELSE
        SET @vRecordSET = 'select oapD.TipoRiga,oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
			          oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg,oapd.VariatoForn, oapd.AcceptedProgrammeOrder
	                     from oapdettaglio as oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
			          on oapd.idoap = oapT.idoap
 		            where opaA.idazi = '+convert(VARCHAR(30),@idazi)+' AND oapT.IdPfuDest = '+convert(VARCHAR(30),@iIdPfu) +
                              ' AND oapd.AcceptedProgrammeOrder = ' + cast(@AcceptedProgrammeOrder as varchar(10))
   END 
ELSE
   BEGIN
        IF @AcceptedProgrammeOrder = '2'
        SET @vRecordSET = 'select oapD.TipoRiga,oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
			         oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg, oapd.AcceptedProgrammeOrder
	                    from OapUtenti as OapU,oapdettaglio as oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
			         on oapd.idoap = oapT.idoap
 		           where OapU.IdOaP=oapT.IdOaP AND opaA.idazi = '+convert(VARCHAR(30),@idazi)+' AND OapU.IdPfu='+convert(VARCHAR(30),@iIdPfu)
        ELSE
        SET @vRecordSET = 'select oapD.TipoRiga,oapD.IdOaP,oapD.ArtCode,oapD.DescrArt,oapD.CodiceArtForn,
			         oapD.DataForn,oapD.Variazione,oapD.Viewed,oapT.DataOap,oapT.CodicePlant,oapT.sedidest,oapD.ViewedForn,oapD.IdMsg, oapd.AcceptedProgrammeOrder
	                    from OapUtenti as OapU,oapdettaglio as oapD inner join oapaziende opaA on oapD.IdOaP = opaA.IdOaPLast inner join oaptestata oapT
			         on oapd.idoap = oapT.idoap
 		           where OapU.IdOaP=oapT.IdOaP AND opaA.idazi = '+convert(VARCHAR(30),@idazi)+' AND OapU.IdPfu='+convert(VARCHAR(30),@iIdPfu) +
                              ' AND oapd.AcceptedProgrammeOrder = ' + cast(@AcceptedProgrammeOrder as varchar(10))
   END 
			
IF @artcode <> '' 
   BEGIN
	SET @vFiltro = @vFiltro + ' and oapD.ArtCode like '+''''+replace(replace(@ArtCode,'*','%'),'_','[_]')+'''' 
    END 
		
IF @CodiceArtForn <> '' 
   BEGIN
	SET @vFiltro = @vFiltro + ' and oapD.CodiceArtForn like '+''''+replace(replace(@CodiceArtForn,'*','%'),'_','[_]')+''''
   END 
IF @Variazione <> '' 
   BEGIN
	SET @vFiltro = @vFiltro + ' and oapD.Variazione = '+''''+@Variazione+''''
   END
IF @Viewed  <> '' 
   BEGIN
	SET @vFiltro = @vFiltro + 
					case when @cContext = 'S' then ' and oapD.ViewedForn = '+''''+@Viewed+'''' 
							else ' and oapD.Viewed = '+''''+@Viewed+''''
					end 	
   END 
if @vTiporiga <> ''
	begin
		SET @vFiltro = @vFiltro +  ' and oapD.Tiporiga = '+''''+@vTiporiga+''''
	end
/* controllo del 20021204 */
	if (@bOcl = 1) 
			begin
				SET @vFiltro = @vFiltro +  ' and oapD.Tiporiga <> '+''''+cast(@iVal as varchar(10))+''''
			end 
/* -----------------------*/ 		
IF @sediDest <> '' 
   BEGIN
	SET @vRecordSET = 'select tot.*,xxx.descrizione,#@# from ('+@vRecordset+ @vFiltro+') as tot inner join (select az_struttura.Descrizione,convert(varchar(100),idaz)+''#''+path as sedidest from az_struttura where az_struttura.IdAz = '+
									''''+@vIdazi+''''+' and  az_struttura.Path  = '+''''+@vPath+''''+' and az_struttura.deleted = 0) as  xxx
							on tot.sedidest = xxx.sedidest'
   END 
		
IF @SediDest = ''
   BEGIN
	SET @vRecordSET = 'select tot.*,xxx.descrizione,#@# from ('+@vRecordset+ @vFiltro+') as tot inner join az_struttura xxx
			          on tot.sedidest = convert(varchar(100),xxx.idaz)+''#''+ Path '
   END 
	/* 
	Ordinamento risultato su recordSET 
	richiesto da Zumpano in data 20020905
	*/
	SET @vRecordSET = @vRecordSET + ' order by tot.artcode,xxx.descrizione'
	/*
	Scelta_Lingua 	
	*/
	SET @vRep = case 
			when @vSuffLng = 'I' then 'Descsi'
			when @vSuffLng = 'E' then 'Descse'
			when @vSuffLng = 'UK' then 'Descsuk'
			when @vSuffLng = 'FRA' then 'Descsfra'
			when @vSuffLng = 'LNG1' then 'Descslng1'
			when @vSuffLng = 'LNG2' then 'Descslng2'
			when @vSuffLng = 'LNG3' then 'Descslng3'
			when @vSuffLng = 'LNG4' then 'Descslng4'
		  end 
	SET @vDesc = replace(@vDesc,'QQQ',@vRep)
	
	/*
	Sostituzione della stringa #@# nel recordSET con la variabile @vdesc
	*/
	SET @vRecordSET = replace(@vRecordset,'#@#',@vdesc)
--print @vRecordset
EXECUTE (@vRecordset)
SET NOCOUNT OFF
GO
