USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GenTempData]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GenTempData] (@strISubTpe VARCHAR(8000), @bGenInsert BIT = 0)
AS

DECLARE @SQLCommand          VARCHAR(8000)

SET NOCOUNT ON

EXEC DropTempTables
EXEC CreateTempTables

/* FunctionsGroups */

SET @SQLCommand = '
INSERT INTO TempFncGrp (IdGrp, grpName)
SELECT IdGrp, RTRIM(grpName) + ''_001''
  FROM FunctionsGroups
 WHERE IdGrp IN (
			SELECT DISTINCT dcmIdGrp
			  FROM Document 
			 WHERE dcmisubtype IN (' + @strISubTpe + ')
			   AND dcmDeleted = 0
			UNION
			SELECT DISTINCT mpfIdGrp 
			  FROM MPFolder
			 WHERE mpfSubType IN (' + @strISubTpe + ')
			   AND mpfDeleted = 0
			UNION
			SELECT DISTINCT pfIdGrp
			  FROM PublicFolders, FolderTypes, Document
			 WHERE ftidPf = IdPf
                           AND ftIdDcm = IdDcm 
                           AND dcmISuBType IN (' + @strISubTpe + ')
			   AND pfDeleted = 0
			UNION
			SELECT DISTINCT ctIdGrp
			  FROM CompanyTab
			 WHERE ctISubType IN (' + @strISubTpe + ')
			   AND ctDeleted = 0
			   AND ctIdGrp IS NOT NULL
			UNION 
			SELECT DISTINCT caIdGrp
			  FROM CompanyArea
			 WHERE caIdct IN (SELECT Idct
			                    FROM CompanyTab
			                   WHERE ctISubType IN (' + @strISubTpe + ')
			                     AND ctDeleted = 0)
			   AND caDeleted = 0
			   AND caIdGrp IS NOT NULL
                   )
ORDER BY 1
'

EXEC (@SQLCommand)

/* Functions */

SET @SQLCommand = '
INSERT INTO TempFnc (IdFnc, grpName, fncLocation, fncName, fncCaption, fncIcon, fncUserFunz, fncUse, fncHide, 
                     fncCommand, fncParam, fncCondition, fncOrder )
SELECT IdFnc, grpName, fncLocation, fncName, fncCaption, fncIcon,
       fncUserFunz, fncUse, fncHide, fncCommand, fncParam, fncCondition, fncOrder 
  FROM Functions, TempFncGrp
 WHERE fncidgrp = IdGrp
   AND fncdeleted = 0
ORDER BY 1
'

EXEC (@SQLCommand)


/* MPDocumenti */

SET @SQLCommand = '
INSERT INTO TempMPDoc (docIdMp, docItype, docPath, docIdMpMod, docISubType, docIsReplicable)
SELECT docIdMp, docItype, docPath, docIdMpMod, docISubType, docIsReplicable
  FROM MPDocumenti 
 WHERE docISubType IN (' + @strISubTpe + ')
   AND docIType = 55
   AND docDeleted = 0 
ORDER BY 1'

EXEC (@SQLCommand)

/* MPModelli */

SET @SQLCommand = '
INSERT INTO TempMpm (IdMpMod, mpmIdMp, mpmDesc, mpmTipo, mpmidmpmodvisual)
SELECT IdMpMod, mpmIdMp, mpmDesc, mpmTipo, mpmidmpmodvisual 
  FROM MPModelli 
 WHERE IdMpMod  in 
(SELECT caIdMpMod
   FROM CompanyArea, CompanyTab
  WHERE caIdCt = IdCt
    AND ctItype = 55
    AND ctIsubType IN (' + @strISubTpe + ')
 UNION
 SELECT docIdMpMod
   FROM TempMPDoc
  UNION
 SELECT dbo.GetIdModFromParam (fncCommand, fncParam, 1)
   FROM TempFnc
  WHERE fncCommand IN (''DELETEARTICLE'', ''EXECUTESEARCH'' , ''ADDROW'', ''EXECUTESEARCH'', ''SEARCH_COMPANY'', 
        ''INSERTARTICLE_FROMCATALOGUE'')
    AND fncParam IS NOT NULL
  UNION
 SELECT dbo.GetIdModFromParam (fncCommand, fncParam, 2)
   FROM TempFnc
  WHERE fncCommand IN (''DELETEARTICLE'', ''EXECUTESEARCH'' , ''ADDROW'', ''EXECUTESEARCH'', ''SEARCH_COMPANY'', 
        ''INSERTARTICLE_FROMCATALOGUE'')
    AND fncParam IS NOT NULL
)
AND mpmDeleted = 0
ORDER BY 1'

EXEC (@SQLCommand)

/* MPModelliAttributi */

SET @SQLCommand = '
INSERT INTO TempMPMA (IdMdlAtt, mpmaIdMpMod, mpmaIdDzt, dztNome, mpmaRegObblig, mpmaOrdine, mpmaValoreDef, mpmaLocked, 
                     mpmaShadow, mpmaOpzioni, mpmaOper)
SELECT IdMdlAtt, mpmaIdMpMod, mpmaIdDzt, dztNome, mpmaRegObblig, mpmaOrdine, mpmaValoreDef, mpmaLocked, mpmaShadow,
       mpmaOpzioni, mpmaOper
  FROM MPModelliAttributi, DizionarioAttributi
 WHERE mpmaIddzt = IdDzt
   AND mpmaIdMpMod IN (SELECT docIdMpMod FROM TempMPDoc)
   AND mpmaDeleted = 0
ORDER BY 2, mpmaOrdine
'

EXEC (@SQLCommand)


/* MPAttributiControlli */

SET @SQLCommand = '
INSERT INTO TempMPAC (mpacIdMdlAtt, mpacIdDzt, dztNome, mpacValue)
SELECT mpacIdMdlAtt, mpacIdDzt, dztNome, mpacValue
  FROM MPAttributiControlli, DizionarioAttributi
 WHERE mpacIdMdlAtt IN (SELECT IdMdlAtt
                          FROM TempMPMA)
  AND mpacDeleted = 0
  AND mpacIdDzt = IdDzt
  AND dztNome NOT LIKE ''ATTR%''
ORDER BY 1
'

EXEC (@SQLCommand)

/* DizionarioAttributi */

SET @SQLCommand = '
INSERT INTO TempDzt (IdDzt, dztNome, dztValoreDef, tidNome, dztIdGum, dztIdUmsDefault, dztLunghezza, dztCifreDecimali,
                     dztFRegObblig, dztFAziende, dztFArticoli, dztFOFID, dztFValutazione, dztTabellaSpeciale, 
                     dztCampoSpeciale, dztFQualita, dztProfili, dztMultiValue, dztLocked, dztVersoNavig, dztInterno, 
                     dztTipologiaStorico, dztMemStorico, dztIsUnicode, ITA, UK)
SELECT IdDzt, dztNome, dztValoreDef, tidNome, dztIdGum, dztIdUmsDefault, dztLunghezza, dztCifreDecimali,
       dztFRegObblig, dztFAziende, dztFArticoli, dztFOFID, dztFValutazione, dztTabellaSpeciale, dztCampoSpeciale, 
       dztFQualita, dztProfili, dztMultiValue, dztLocked, dztVersoNavig, dztInterno, dztTipologiaStorico, 
       dztMemStorico, dztIsUnicode, ita.dscTesto AS ITA, uk.dsctesto AS UK
  FROM dizionarioattributi, descsi ita, descsi UK, TipiDati
 WHERE dztiddsc = ita.iddsc 
   AND ita.IdDsc = UK.IdDsc
   AND dztIdTid = IdTid
   AND dztDeleted = 0
   AND IdDzt IN (SELECT mpmaIdDzt FROM TempMPMA)
'

EXEC (@SQLCommand)

/* AppartenenzaAttributi */

SET @SQLCommand = '
INSERT INTO TempApAt (IdApAt, dztNome, apatIdApp)
SELECT IdApAt, dztNome, apatIdApp 
  FROM AppartenenzaAttributi, TempDzt
 WHERE apatIdDzt = IdDzt 
AND apatDeleted = 0
'
EXEC (@SQLCommand)

/* TipiDati */

SET @SQLCommand = '
INSERT INTO TempTid (IdTid, tidNome, tidTipoMem, tidTipoDom,  tidSistema, tidOper, mlngDesc_I, mlngDesc_UK)
SELECT IdTid, tidNome, tidTipoMem, tidTipoDom,  tidSistema, tidOper, tidNome AS mlngDesc_I, tidNome AS mlngDesc_UK
  FROM TipiDati
 WHERE tidNome IN (SELECT tidNome FROM TempDzt)
ORDER BY IdTid Desc   
'

EXEC (@SQLCommand)

/* TipiDatiRange */

SET @SQLCommand = '
INSERT INTO TempTdR (tidNome, tdrIdDsc, tdrRelOrdine, tdrCodice, tdrCodiceEsterno, tdrCodiceRaccordo, Ita, UK)
SELECT tidNome, tdrIdDsc, tdrRelOrdine, tdrCodice, tdrCodiceEsterno, tdrCodiceRaccordo, 
       Ita.dscTesto AS Ita, uk.dsctesto AS UK
  FROM tipidatirange, descsi ita, descsuk uk, TipiDati
 WHERE tdriddsc = ita.iddsc 
   AND ita.iddsc = uk.iddsc
   AND tdridtid IN (SELECT IdTid FROM TempTid)
   AND tdrdeleted = 0
   AND IdTid = tdrIdTid
ORDER BY tdrIdTid, tdrRelOrdine
'

EXEC (@SQLCommand)

/* Document */

SET @SQLCommand = '
INSERT INTO TempDoc (IdDcm, dcmDescription, dcmIType, dcmIsubType, dcmRelatedIdDcm, dcmInput, dcmTypeDoc, dcmStorico, 
                     dcmDetail,  dcmSendUnreadAdvise, dcmOption, grpName, dcmURL, dcmISubTypeRef)
SELECT IdDcm, dcmDescription, dcmIType, dcmIsubType, dcmRelatedIdDcm, dcmInput, 
       dcmTypeDoc, dcmStorico, dcmDetail,  dcmSendUnreadAdvise, dcmOption, grpName, 
       dcmURL, dcmISubTypeRef
  FROM Document, TempFncGrp 
 WHERE dcmisubtype IN (' + @strISubTpe + ')
   AND dcmDeleted = 0
    AND dcmIdGrp = IdGrp
'

EXEC (@SQLCommand)

/* CompanyTab */

SET @SQLCommand = '
INSERT INTO TempCT (IdCt, IdCtNew, ctIdMp, ctItype, ctIsubtype, ctIdMultiLng, ctProfile, ctFnzuPos, ctOrder, ctPath, 
                    ctParent, ctTabType, grpName, ctTabName, ctProgId)
SELECT IdCt, NULL AS IdCtNew, ctIdMp, ctItype, ctIsubtype, ctIdMultiLng, ctProfile, ctFnzuPos, ctOrder, ctPath, ctParent, ctTabType,
       grpName, ctTabName, ctProgId
  FROM CompanyTab, TempFncGrp
 WHERE ctIdGrp = idGrp
   AND ctDeleted = 0
   AND ctISubType IN (' + @strISubTpe + ')
UNION
SELECT IdCt, NULL AS IdCtNew, ctIdMp, ctItype, ctIsubtype, ctIdMultiLng, ctProfile, ctFnzuPos, ctOrder, ctPath, ctParent, ctTabType,
       NULL, ctTabName, ctProgId
  FROM CompanyTab
 WHERE ctIdGrp IS NULL
   AND ctDeleted = 0
   AND ctISubType IN (' + @strISubTpe + ')
'

EXEC (@SQLCommand)

/* CompanyArea */

SET @SQLCommand = '
INSERT INTO TempCA (caIdCt, caType, caIdMpMod, caOrder, caIdMultiLng, caRange, grpName, caAreaName)
SELECT caIdCt, caType, caIdMpMod, caOrder, caIdMultiLng, caRange, grpName, caAreaName
  FROM CompanyArea, TempFncGrp
 WHERE caIdCt IN (SELECT IdCt FROM TempCT)
   AND caIdGrp = IdGrp
   AND caDeleted = 0
UNION
SELECT caIdCt, caType, caIdMpMod, caOrder, caIdMultiLng, caRange, NULL, caAreaName
  FROM CompanyArea
 WHERE caIdCt IN (SELECT IdCt FROM TempCT)
   AND caIdGrp IS NULL
   AND caDeleted = 0
'
EXEC (@SQLCommand)

/* TabProps */

SET @SQLCommand = '
INSERT INTO TempTP (tpIdCt, tpItypeSource, tpISubTypeSource, tpAttrib, tpValue)
SELECT tpIdCt, tpItypeSource, tpISubTypeSource, tpAttrib, tpValue
  FROM TabProps
 WHERE tpIdCt IN (SELECT IdCt FROM TempCT)
   AND tpDeleted = 0
'

EXEC (@SQLCommand)

/* DocumentFields */

SET @SQLCommand = '
INSERT INTO TempDF (dfIType, dfISubType, dfFieldName)
SELECT dfIType, dfISubType, dfFieldName
  FROM DocumentFields
 WHERE dfIType = 55
   AND dfISubtype IN (' + @strISubTpe + ')
'

EXEC (@SQLCommand)

/* MPInheritFields */

SET @SQLCommand = '
INSERT INTO TempMPIF (mpifIdMp, mpifITypeSource, mpifISubTypeSource, mpifITypeDest, mpifISubTypeDest, mpifFieldNameSource,
                      mpifFieldNameDest)
SELECT mpifIdMp, mpifITypeSource, mpifISubTypeSource, mpifITypeDest, mpifISubTypeDest, mpifFieldNameSource,
       mpifFieldNameDest 
  FROM MPInheritFields
 WHERE mpifDeleted = 0
   AND (mpifISubTypeSource IN (' + @strISubTpe + ')
        OR mpifISubTypeDest IN (' + @strISubTpe + '))
ORDER BY 1 DESC
'

EXEC (@SQLCommand)

/* MPFolder */

SET @SQLCommand = '
INSERT INTO TempMF (mpfIdMp, mpfIType, mpfSubType, mpfIdMultilng, mpfSource, mpfCreateSubFolder, mpfHidden, mpfFnzuPos, mpfFunzionalita,
                    mpfIcona, mpfUse, mpfIdGrp, mpfClauseSQL, grpName)
SELECT mpfIdMp, mpfIType, mpfSubType, mpfIdMultilng, mpfSource, mpfCreateSubFolder, mpfHidden, mpfFnzuPos, mpfFunzionalita,
       mpfIcona, mpfUse, mpfIdGrp, mpfClauseSQL, grpName
  FROM MPFolder, TempFncGrp
 WHERE IdGrp = mpfIdGrp
   AND mpfSubType IN (' + @strISubTpe + ')
   AND mpfIType = 55
   AND mpfDeleted = 0
'

EXEC (@SQLCommand)

/* MPCommands */

SET @SQLCommand = '
INSERT INTO TempMPC (IdMpc, mpcIdGroup, mpcIType, mpcISubType, mpcName, mpcTypeCommand, mpcSystem, mpcUserFunz, mpcIcon, 
                     mpcParam1, mpcParam2, mpcOrdine, mpcLink, mpcSelection)
SELECT IdMpc, mpcIdGroup, mpcIType, mpcISubType, mpcName, mpcTypeCommand, mpcSystem, mpcUserFunz, mpcIcon, mpcParam1,
       mpcParam2, mpcOrdine, mpcLink, mpcSelection
  FROM MPCommands
 WHERE mpcDeleted = 0 
   AND mpciType = 55
   AND mpciSubType IN (' + @strISubTpe + ')
'

EXEC (@SQLCommand)

/* RegDefault */

SET @SQLCommand = '
INSERT INTO TempRD (rdIdMp, rdPath, rdKey, rdDefValue, rdiType, rdiSubType)
SELECT rdIdMp, rdPath, rdKey, rdDefValue, rdiType, rdiSubType
  FROM RegDefault
 WHERE rdISubType IN (' + @strISubTpe + ')
   AND rdIType = 55
   AND rdDeleted = 0
'

EXEC (@SQLCommand)

/* Process */

SET @SQLCommand = '
INSERT INTO TempPRC (prcIdMP, prcITypeSource, prcISubtypeSource, prcIdProcess, prcITypeDest, prcISubtypeDest, 
                     prcCondition, prcTypeCondition, prcOrder)
SELECT prcIdMP, prcITypeSource, prcISubtypeSource, prcIdProcess, prcITypeDest, prcISubtypeDest, prcCondition,
       prcTypeCondition, prcOrder
  FROM Process
 WHERE prcISubtypeSource IN (' + @strISubTpe + ')
    OR prcISubtypeDest IN (' + @strISubTpe + ')
'
EXEC (@SQLCommand)

/* ProcessAnag */

SET @SQLCommand = '
INSERT INTO TempPRCA (IdProcess, Descr)
SELECT IdProcess, Descr
  FROM ProcessAnag
 WHERE IdProcess IN (SELECT prcIdProcess FROM TempPRC)
'

EXEC (@SQLCommand)

/* ProcessActions */

SET @SQLCommand = '
INSERT INTO TempPA (IdPA, IdProcess, IdAct, paOrder)
SELECT IdPA, IdProcess, IdAct, paOrder
  FROM ProcessActions
 WHERE IdProcess IN (SELECT prcIdProcess FROM TempPRC)
'

EXEC (@SQLCommand)

/* ActionProp */

SET @SQLCommand = '
INSERT INTO TempAp (IdPA, prpAttrib, prpValue)
SELECT IdPA, prpAttrib, prpValue
  FROM ActionProp
 WHERE IdPa IN (SELECT IdPA FROM TempPA)
'

EXEC (@SQLCommand)

/* MPFolderColumns */

SET @SQLCommand = '
INSERT INTO TempMPFC (mpfcIdMp, mpfcIType, mpfcISubType, mpfcCaption, mpfcTypeCaption, mpfcTypeCol, mpfcTypeEdit,
                      mpfcFieldName, mpfcColWidth, mpfcSortType, mpfcKeyIcon, mpfcVisible, mpfcOrder, mpfcContext, 
                      mpfcNullBehaviour, mpfcUse)
SELECT mpfcIdMp, mpfcIType, mpfcISubType, mpfcCaption, mpfcTypeCaption, mpfcTypeCol, mpfcTypeEdit,
       mpfcFieldName, mpfcColWidth, mpfcSortType, mpfcKeyIcon, mpfcVisible, mpfcOrder, mpfcContext, mpfcNullBehaviour,
       mpfcUse
  FROM MPFolderColumns
 WHERE mpfcISubType IN (' + @strISubTpe + ')
   AND mpfcItype = 55
   AND mpfcDeleted = 0
'

EXEC (@SQLCommand)

IF @bGenInsert = 0
BEGIN
     SET NOCOUNT OFF
     RETURN 0
END

DECLARE crs CURSOR STATIC FOR SELECT name FROM sysobjects WHERE name IN ('TempAp', 'TempApAt', 'TempCA', 'TempCT', 'TempDF', 
                                                                  'TempDoc', 'TempDzt', 'TempFnc', 'TempFncGrp',
                                                                  'TempFNZU', 'TempFT', 'TempMF', 'TempMlng', 
                                                                  'TempMPAC', 'TempMPC', 'TempMPDoc', 'TempMPFC', 
                                                                  'TempMPG', 'TempMPIF', 'TempMpm', 'TempMPMA',
                                                                  'TempPA', 'TempPF', 'TempPRC', 'TempPRCA',
                                                                  'TempRD', 'TempTdR', 'TempTid', 'TempTP')
                                                                  
OPEN crs

FETCH NEXT FROM crs INTO @SQLCommand

WHILE @@FETCH_STATUS = 0
BEGIN
      PRINT '/* ' + @SQLCommand + ' */'
      EXEC sp_generate_inserts @SQLCommand
      FETCH NEXT FROM crs INTO @SQLCommand
END                                                                  

CLOSE crs
DEALLOCATE crs


SET NOCOUNT OFF



GO
