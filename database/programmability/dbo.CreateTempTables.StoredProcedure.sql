USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CreateTempTables]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[CreateTempTables]
AS

DECLARE @strCreate01          VARCHAR(8000)
DECLARE @strCreate02          VARCHAR(8000)

SET @strCreate01 = '
CREATE TABLE TempTdR(
	tidNome char(101) NULL,
	tdrIdDsc int NULL,
	tdrRelOrdine smallint NULL,
	tdrCodice varchar(20) NULL,
	tdrCodiceEsterno varchar(20) NULL,
	tdrCodiceRaccordo varchar(20) NULL,
	Ita nvarchar(4000) NULL,
	UK nvarchar(4000) NULL
)
CREATE TABLE TempTid(
	IdTid smallint NULL,
	IdTidNew smallint NULL,
	tidNome char(101) NULL,
	tidTipoMem tinyint NULL,
	tidTipoDom varchar(5) NULL,
	tidSistema bit NULL,
	tidOper bit NULL,
	mlngDesc_I nvarchar(4000) NULL,
	mlngDesc_UK nvarchar(4000) NULL
)
CREATE TABLE TempAp (
	IdPA int NULL,
	IdPANew int NULL,
	prpAttrib varchar (500) NULL,
	prpValue varchar (4000) NULL,
	prpValueNew varchar (4000) NULL
)
CREATE TABLE TempApAt (
	IdApAt int NULL,
	dztNome varchar (50) NULL,
	apatIdApp int NULL 
)
CREATE TABLE TempCA (
	caIdCt int NULL,
	caIdCtNew int NULL,
	caType char (1) NULL,
	caIdMpMod int NULL,
	caIdMpModNew int NULL,
	caOrder int NULL,
	caIdMultiLng char (101) NULL,
	caRange varchar (20) NULL,
	grpName char (101) NULL,
	caAreaName varchar (50) NULL 
)
CREATE TABLE TempCT (
	IdCt int NULL,
	IdCtNew int NULL,
	ctIdMp int NULL,
	ctItype smallint NULL,
	ctIsubtype smallint NULL,
	ctIsubtypeNew smallint NULL,
	ctIdMultiLng char (101) NULL,
	ctProfile varchar (20) NULL,
	ctFnzuPos int NULL,
	ctFnzuPosNew int NULL,
	ctOrder int NULL,
	ctPath varchar (100) NULL,
	ctParent int NULL,
	ctTabType varchar (10) NULL,
	grpName char (101) NULL,
	ctTabName varchar (50) NULL,
	ctProgId varchar (50) NULL 
)
CREATE TABLE TempDoc (
	IdDcm int NULL,
	IdDcmNew int NULL,
	dcmDescription char (101) NULL,
	dcmIType smallint NULL,
	dcmIsubType smallint NULL,
	dcmIsubTypeNew smallint NULL,
	dcmRelatedIdDcm int NULL,
	dcmInput bit NULL,
	dcmTypeDoc tinyint NULL,
	dcmStorico bit NULL,
	dcmDetail varchar (10) NULL,
	dcmSendUnreadAdvise bit NULL,
	dcmOption varchar (20) NULL,
	grpName char (101) NULL,
	dcmURL nvarchar (200) NULL,
	dcmISubTypeRef smallint NULL 
)
CREATE TABLE TempDzt (
	IdDzt int NULL,
	IdDztNew int NULL,
	dztNome varchar (50) NULL,
	dztValoreDef varchar (50) NULL,
	tidNome char (101) NULL,
	dztIdGum int NULL,
	dztIdUmsDefault int NULL,
	dztLunghezza smallint NULL,
	dztCifreDecimali tinyint NULL,
	dztFRegObblig bit NULL,
	dztFAziende bit NULL,
	dztFArticoli bit NULL,
	dztFOFID bit NULL,
	dztFValutazione bit NULL,
	dztTabellaSpeciale varchar (40) NULL,
	dztCampoSpeciale varchar (40) NULL,
	dztFQualita tinyint NULL,
	dztProfili varchar (20) NULL,
	dztMultiValue bit NULL,
	dztLocked bit NULL,
	dztVersoNavig varchar (5) NULL,
	dztInterno bit NULL,
	dztTipologiaStorico char (3) NULL,
	dztMemStorico smallint NULL,
	dztIsUnicode bit NULL,
	ITA nvarchar (4000) NULL,
	UK nvarchar (4000) NULL 
)
CREATE TABLE TempFNZU (
	FnzuPadre int NULL,
	FnzuPadreNew int NULL,
	FnzuFiglio int NULL,
	FnzuFiglioNew int NULL,
	FnzuIdMultiLng char (101) NULL,
	FnzuPos int NULL,
	FnzuPosNew int NULL,
	FnzuOrdine int NULL,
	FnzuOrdineNew int NULL,
	FnzuProfili varchar (20) NULL,
	FnzuIType smallint NULL,
	FnzuProfiloAzi varchar (20) NULL,
	FnzuSource varchar (50) NULL,
	FnzuIcona varchar (50) NULL,
	FnzuHidden bit NULL,
	FnzuISubType int NULL,
	FnzuISubTypeNew int NULL,
	FnzuUse tinyint NULL,
	FnzuIsPrimary bit NULL,
	FnzuCodice varchar (20) NULL,
	FnzuSystem bit NULL,
	FnzuUpdatePos bit NULL 
)
CREATE TABLE TempFT (
	IdFt int  NULL,
	ftIdPf int NULL,
	ftIdPfNew int NULL,
	ftIdDcm int NULL, 
	ftIdDcmNew int NULL 
)
CREATE TABLE TempFnc (
	IdFnc int NULL,
	grpName char (101) NULL,
	fncLocation varchar (10) NULL,
	fncName varchar (200) NULL,
	fncCaption char (101) NULL,
	fncIcon varchar (30) NULL,
	fncUserFunz int NULL,
	fncUserFunzNew int NULL,
	fncUse varchar (10) NULL,
	fncHide bit NULL,
	fncCommand varchar (100) NULL,
	fncParam varchar (500) NULL,
	fncParamNew varchar (500) NULL,
	fncCondition varchar (500) NULL,
	fncOrder int NULL 
)
CREATE TABLE TempFncGrp (
	IdGrp int  NULL,
	IdGrpNew int  NULL,
	grpName char (101) NULL 
)
CREATE TABLE TempMF (
	mpfIdMp int NULL,
	mpfIType smallint NULL,
	mpfSubType smallint NULL,
	mpfSubTypeNew smallint NULL,
	mpfIdMultilng char (101) NULL,
	mpfSource varchar (50) NULL,
	mpfCreateSubFolder tinyint NULL,
	mpfHidden bit NULL,
	mpfFnzuPos int NULL,
	mpfFnzuPosNew int NULL,
	mpfFunzionalita varchar (10) NULL,
	mpfIcona varchar (30) NULL,
	mpfUse varchar (10) NULL,
	mpfIdGrp int NULL,
	mpfClauseSQL varchar (1000) NULL,
	grpName char (101) NULL 
)
CREATE TABLE TempMPAC (
	mpacIdMdlAtt int NULL,
	mpacIdMdlAttNew int NULL,
	mpacIdDzt int NULL,
	dztNome varchar (50) NULL,
	mpacValue nvarchar (30) NULL 
)
CREATE TABLE TempMPC (
	IdMpc int  NULL,
	mpcIdGroup int NULL,
	mpcIdGroupNew int NULL,
	mpcIType smallint NULL,
	mpcISubType smallint NULL,
	mpcISubTypeNew smallint NULL,
	mpcName char (101) NULL,
	mpcTypeCommand smallint NULL,
	mpcSystem smallint NULL,
	mpcUserFunz int NULL,
	mpcUserFunzNew int NULL,
	mpcIcon varchar (30) NULL,
	mpcParam1 int NULL,
	mpcParam2 varchar (50) NULL,
	mpcOrdine smallint NULL,
	mpcLink varchar (500) NULL,
	mpcLinkNew varchar (500) NULL,
	mpcSelection smallint NULL 
)
CREATE TABLE TempMPDoc (
	docIdMp int NULL,
	docItype smallint NULL,
	docPath varchar (100) NULL,
	docIdMpMod int NULL,
	docIdMpModNew int NULL,
	docISubType smallint NULL,
	docISubTypeNew smallint NULL,
	docIsReplicable bit NULL 
)
CREATE TABLE TempMPFC (
	mpfcIdMp int NULL,
	mpfcIType smallint NULL,
	mpfcISubType smallint NULL,
	mpfcISubTypeNew smallint NULL,
	mpfcCaption char (101) NULL,
	mpfcTypeCaption tinyint NULL,
	mpfcTypeCol tinyint NULL,
	mpfcTypeEdit tinyint NULL,
	mpfcFieldName varchar (30) NULL,
	mpfcColWidth smallint NULL,
	mpfcSortType tinyint NULL,
	mpfcKeyIcon varchar (30) NULL,
	mpfcVisible tinyint NULL,
	mpfcOrder smallint NULL,
	mpfcContext tinyint NULL,
	mpfcNullBehaviour tinyint NULL,
	mpfcUse varchar (10) NULL 
)
CREATE TABLE TempMPG (
	IdMpg int  NULL,
	mpgIdMp int NULL,
	mpgIdGroup int NULL,
	mpgIdGroupNew int NULL,
	mpgGroupKey varchar (50) NULL,
	mpgGroupName char (101) NULL,
	mpgUserProfile varchar (20) NULL,
	mpgGroupType smallint NULL,
	mpgOrdine smallint NULL 
)
CREATE TABLE TempMPMA (
	IdMdlAtt int NULL,
	IdMdlNew int NULL,
	mpmaIdMpMod int NULL,
	mpmaIdMpModNew int NULL,
	mpmaIdDzt int NULL,
	dztNome varchar (50) NULL,
	mpmaRegObblig bit NULL,
	mpmaOrdine int NULL,
	mpmaValoreDef varchar (1000) NULL,
	mpmaLocked bit NULL,
	mpmaShadow bit NULL,
	mpmaOpzioni varchar (20) NULL,
	mpmaOper varchar (20) NULL 
)
CREATE TABLE TempMpm (
	IdMpMod int  NULL,
	IdMpModNew int  NULL,
	mpmIdMp int NULL,
	mpmDesc varchar (50) NULL,
	mpmTipo tinyint NULL,
	mpmidmpmodvisual int NULL 
)
CREATE TABLE TempPA (
	IdPA int NULL,
	IdPANew int NULL,
	IdProcess int NULL,
	IdProcessNew int NULL,
	IdAct char (10) NULL,
	paOrder int NULL 
)
CREATE TABLE TempPF (
	IdPf int NULL,
	IdPfNew int NULL,
	pfIdGrp int NULL,
	pfPath varchar (100) NULL,
	pfIdMultiLng char (101) NULL,
	pfFoglia bit NULL,
	grpName char (101) NULL,
	pfPos int NULL,
	pfPosNew int NULL
)
CREATE TABLE TempPRC (
	prcIdMP int NULL,
	prcITypeSource smallint NULL,
	prcISubtypeSource smallint NULL,
	prcISubtypeSourceNew smallint NULL,
	prcIdProcess int NULL,
	prcIdProcessNew int NULL,
	prcITypeDest smallint NULL,
	prcISubtypeDest smallint NULL,
	prcISubtypeDestNew smallint NULL,
	prcCondition varchar (500) NULL,
	prcTypeCondition varchar (10) NULL,
	prcOrder int NULL 
)
CREATE TABLE TempPRCA (
	IdProcess int NULL,
	IdProcessNew int NULL,
	Descr varchar (101) NULL 
)
'

SET @strCreate02 = '
CREATE TABLE TempRD (
	rdIdMp int NULL,
	rdPath varchar (100) NULL,
	rdKey varchar (50) NULL,
	rdDefValue varchar (2000) NULL,
	rdiType smallint NULL,
	rdiSubType smallint NULL,
	rdiSubTypeNew smallint NULL 
)
CREATE TABLE TempTP (
	tpIdCt int NULL,
	tpIdCtNew int NULL,
	tpItypeSource smallint NULL,
	tpISubTypeSource smallint NULL,
	tpISubTypeSourceNew smallint NULL,
	tpAttrib varchar (500) NULL,
	tpValue varchar (500) NULL 
)
CREATE TABLE TempMlng (
	IdMultilng char (101) NULL,
	mlngDesc_I nvarchar (4000) NULL,
	mlngDesc_UK nvarchar (4000)NULL,
	mlngDesc_E nvarchar (4000) NULL,
	mlngDesc_FRA nvarchar (4000) NULL,
	mlngDesc_DE nvarchar (4000) NULL,
	mlngDesc_CN nvarchar NULL 
) 
CREATE TABLE TempDF (
	dfIType smallint NULL,
	dfISubtype smallint NULL,
	dfISubtypeNew smallint NULL,
	dfFieldName varchar (50) NULL 
)
CREATE TABLE TempMPIF(
	mpifIdMp int NULL,
	mpifITypeSource smallint NULL,
	mpifISubTypeSource smallint NULL,
	mpifISubTypeSourceNew smallint NULL,
	mpifITypeDest smallint NULL,
	mpifISubTypeDest smallint NULL,
	mpifISubTypeDestNew smallint NULL,
	mpifFieldNameSource varchar(30)  NULL,
	mpifFieldNameDest varchar(30)  NULL
)
'

EXEC DropTempTables
EXEC (@strCreate01)
EXEC (@strCreate02)
GO
