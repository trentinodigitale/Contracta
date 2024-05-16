USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ReportDocGen]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReportDocGen] (@X VARCHAR(300))
AS
BEGIN 
   /*
	Autore: Albanese Michele
	Data:   2004 - 06 -05
	Scopo:  Estrazioni Informazioni Documento Generico
   */	
   IF NOT EXISTS (SELECT * FROM DOCUMENT WHERE DCMDESCRIPTION = @X AND DCMDELETED = 0)
   BEGIN
	PRINT 'DOCUMENTO NON ESISTENTE !!!'
	RETURN 
   END
	--DECLARE @X VARCHAR(20)
	--SET @X = 'INVITO'
	SELECT COL1,COL2,COL3,COL4,COL5,COL6,COL7
	       --Colonne di Ordinamento	
	       --,ORD_INT_COL1,ORD_TEXT_COL1,ORD_INT_COL2,ORD_TEXT_COL2,
	       --ORD_INT_COL3,ORD_TEXT_COL3,ORD_INT_COL4,ORD_TEXT_COL4,
	       --ORD_INT_COL5,ORD_TEXT_COL5,ORD_INT_COL6,ORD_TEXT_COL6,
	       --ORD_INT_COL7,ORD_TEXT_COL7
	FROM (
        SELECT 0 ORD,'DOCUMENTO ' COL1,'******************************' COL2,'******************************' COL3,'******************************' COL4,'******************************' COL5,'******************************' COL6,'******************************' COL7,
	       --COLONNE ORDINAMENTO 	
	       -1 ORD_INT_COL1,'-1' ORD_TEXT_COL1,  --Col1
	       -1 ORD_INT_COL2,'-1' ORD_TEXT_COL2,  --Col2
	       -1 ORD_INT_COL3,'-1' ORD_TEXT_COL3,  --Col3
	       -1 ORD_INT_COL4,'-1' ORD_TEXT_COL4,  --Col4
	       -1 ORD_INT_COL5,'-1' ORD_TEXT_COL5,  --Col5
	       -1 ORD_INT_COL6,'-1' ORD_TEXT_COL6,  --Col6
	       -1 ORD_INT_COL7,'-1' ORD_TEXT_COL7   --Col7
	UNION ALL
	SELECT 1,'<Descrizione Documento>','<Tipo>','<Sottotipo>','<Gruppo>','','','',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 2,CAST(DCMDESCRIPTION AS VARCHAR(100)),
		 CAST(DCMITYPE AS VARCHAR(100)),
	         CAST(DCMISUBTYPE AS VARCHAR(100)),
	         CAST(DCMIDGRP AS VARCHAR(100)),
	         CAST('' AS VARCHAR(100)),
	         CAST('' AS VARCHAR(100)),
		 CAST('' AS VARCHAR(100)),
		 -1,DCMDESCRIPTION,	--Col1
		 -1,'-1',		--Col2
		 -1,'-1',		--Col3
		 -1,'-1',		--Col4
		 -1,'-1',		--Col5
		 -1,'-1',		--Col6
		 -1,'-1'		--Col7
	FROM DOCUMENT 
	WHERE DCMDESCRIPTION = @X AND DCMDELETED = 0
	UNION ALL
	SELECT 3,'LISTA SEZIONI ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 4,'<CtIdmultilng>','<Tipo>','<Nome Sezione>','<Gruppo>','','','',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL 
	SELECT 5,CAST(C.CTIDMULTILNG AS VARCHAR(100)),CTTABTYPE,CTTABNAME,CAST(CTIDGRP AS VARCHAR(100)),'','','',
	-1,C.CTIDMULTILNG,	--Col1
	-1,'-1',		--Col2
	-1,'-1',		--Col3
	-1,'-1',		--Col4
	-1,'-1',		--Col5
	-1,'-1',		--Col6
	-1,'-1'			--Col7
	FROM DOCUMENT D,COMPANYTAB C  
	WHERE D.DCMDESCRIPTION = @X AND D.DCMITYPE = C.CTITYPE AND D.DCMISUBTYPE = C.CTISUBTYPE AND 
	      D.DCMDELETED = 0 AND C.CTDELETED = 0
	UNION ALL
	SELECT 6,'FUNZIONI SEZIONI ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 7,'<Gruppo Funzioni>','<Path Comando>','<Titolo>','<Posizione Permesso>','<Nome Comando>','<Parametri>','<Condizioni>',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL 
	SELECT 8,CAST(F.IDGRP AS VARCHAR(100)),FF.FNCNAME,FF.FNCCAPTION,CAST(FF.FNCUSERFUNZ AS VARCHAR(100)),FF.FNCCOMMAND,FF.FNCPARAM,FF.FNCCONDITION,
	F.IDGRP,'-1',		--Col1
	-1,FNCNAME,		--Col2
	-1,FNCCAPTION,		--Col3
	-1,'-1',		--Col4
	-1,'-1',		--Col5
	-1,'-1',		--Col6
	-1,'-1'			--Col7
	FROM DOCUMENT D,COMPANYTAB CT,FUNCTIONSGROUPS F,FUNCTIONS FF
	WHERE D.DCMITYPE = CT.CTITYPE AND D.DCMISUBTYPE = CT.CTISUBTYPE AND 
	      F.IDGRP = FF.FNCIDGRP AND CT.CTIDGRP = F.IDGRP  AND		
	      D.DCMDELETED = 0 AND CT.CTDELETED = 0 AND  F.GRPDELETED = 0 AND FF.FNCDELETED = 0 AND
	      D.DCMDESCRIPTION = @X
	UNION ALL
	SELECT 9,'FUNZIONI AREE ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 10,'<Gruppo Funzioni>','<Path Comando>','<Titolo>','<Posizione Permesso>','<Nome Comando>','<Parametri>','<Condizioni>',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 11,CAST(F.IDGRP AS VARCHAR(100)) IDGRP,FF.FNCNAME,FF.FNCCAPTION,CAST(FF.FNCUSERFUNZ AS VARCHAR(100)),FF.FNCCOMMAND,FF.FNCPARAM,FF.FNCCONDITION,
	F.IDGRP,'-1',		--Col1
	-1,FNCNAME,		--Col2
	-1,FNCCAPTION,		--Col3
	-1,'-1',		--Col4
	-1,'-1',		--Col5
	-1,'-1',		--Col6
	-1,'-1' 		--Col7
	FROM DOCUMENT D,COMPANYTAB CT,COMPANYAREA CA,FUNCTIONSGROUPS F,FUNCTIONS FF
	WHERE D.DCMITYPE = CT.CTITYPE AND D.DCMISUBTYPE = CT.CTISUBTYPE AND CT.IDCT = CA.CAIDCT AND CA.CAIDGRP = F.IDGRP AND 
	      F.IDGRP = FF.FNCIDGRP AND 		
	      D.DCMDELETED = 0 AND CT.CTDELETED = 0 AND CA.CADELETED = 0 AND F.GRPDELETED = 0 AND FF.FNCDELETED = 0 AND
	      D.DCMDESCRIPTION = @X
	UNION ALL
	SELECT 12,'FUNZIONI DOCUMENTO ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 13,'<Gruppo Funzioni>','<Path Comando>','<Titolo>','<Posizione Permesso>','<Nome Comando>','<Parametri>','<Condizioni>',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 14,CAST(F.IDGRP AS VARCHAR(100)) IDGRP,FF.FNCNAME,FF.FNCCAPTION,CAST(FF.FNCUSERFUNZ AS VARCHAR(100)),FF.FNCCOMMAND,FF.FNCPARAM,FF.FNCCONDITION,
	F.IDGRP,'-1',		--Col1
	-1,FNCNAME,		--Col2
	-1,FNCCAPTION,		--Col3
	-1,'-1',		--Col4
	-1,'-1',		--Col5
	-1,'-1',		--Col6
	-1,'-1'			--Col7
	FROM DOCUMENT D,FUNCTIONSGROUPS F,FUNCTIONS FF
	WHERE D.DCMDESCRIPTION = @X AND D.DCMIDGRP = F.IDGRP AND 
	      F.IDGRP = FF.FNCIDGRP AND FF.FNCDELETED = 0 AND	
	      F.GRPDELETED = 0 AND D.DCMDELETED = 0 
	UNION ALL 
	SELECT 15,'AREE ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL 
	SELECT 16,'<Titolo Sezione>','<Nome Area>','<Id Modello>','<Gruppo Funzioni>','<Tipo Area>','','',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 17,CTIDMULTILNG,CAAREANAME,CAST(CAIDMPMOD AS VARCHAR(100)),CAST(CAIDGRP AS VARCHAR(100)),
	       CATYPE,'','',
	-1,CTIDMULTILNG,		--Col1
	-1,CAAREANAME,			--Col2
	-1,'-1',			--Col3
	-1,'-1',			--Col4
	-1,'-1',			--Col5
	-1,'-1',			--Col6
	-1,'-1'				--Col7
	FROM DOCUMENT D,COMPANYTAB CT,COMPANYAREA CA
	WHERE D.DCMITYPE = CT.CTITYPE AND D.DCMISUBTYPE = CT.CTISUBTYPE AND CT.IDCT = CA.CAIDCT AND 
	      D.DCMDELETED = 0 AND CT.CTDELETED = 0 AND CA.CADELETED = 0 AND D.DCMDESCRIPTION = @X	
	UNION ALL
	SELECT 18,'PROPRIETA SEZIONI ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL 
	SELECT 19,'<Titolo Sezione>','<Attributo>','<Valore>','<Tipo Sorgente>','<Sottotipo Sorgente>','','',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL 
	SELECT 20,CAST(Ct.CTIDMULTILNG AS VARCHAR(100)),TPATTRIB,CAST(TPVALUE AS VARCHAR(100)),cast(tpItypeSource as varchar(100)),cast(tpISubTypeSource as varchar(100)),'','',
	-1,CTIDMULTILNG,		--Col1
	-1,TPATTRIB,			--Col2
	-1,'-1',			--Col3
	-1,'-1',			--Col4
	-1,'-1',			--Col5
	-1,'-1',			--Col6
	-1,'-1'				--Col7
	FROM DOCUMENT D,COMPANYTAB CT,TABPROPS TP
	WHERE D.DCMITYPE = CT.CTITYPE AND D.DCMISUBTYPE = CT.CTISUBTYPE AND CT.IDCT = TP.TPIDCT AND 
	      D.DCMDELETED = 0 AND CT.CTDELETED = 0 AND TP.TPDELETED = 0 AND D.DCMDESCRIPTION = @X
	UNION ALL 
	SELECT 21,'LISTA PROCESSI ','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 22,'<Prcidmp>','<Descrizione Processo>','<Azione Processo>','<Tipo Azione>','','','',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT DISTINCT 23,CAST(PRCIDMP AS VARCHAR(30)),DESCR,ACTDESCR,ACTTYPE,'','','',
	PRCIDMP,'-1',		--Col1
	-1,PA.DESCR,		--Col2
	-1,actdescr,		--Col3
	-1,'-1',		--Col4
	-1,'-1',		--Col5
	-1,'-1',		--Col6
	-1,'-1'			--Col7
	FROM DOCUMENT D,PROCESS P,PROCESSANAG PA,PROCESSACTIONS PAC,ACTIONS A,ACTIONPROP AC
	WHERE D.DCMDESCRIPTION = @X AND D.DCMITYPE = P.PRCITYPESOURCE AND D.DCMISUBTYPE = P.PRCISUBTYPESOURCE AND 
	      P.PRCIDPROCESS = PAC.IDPROCESS AND PAC.IDACT = A.IDACT AND PAC.IDPA = AC.IDPA AND 	
	      D.DCMDELETED = 0  AND P.PRCIDPROCESS = PA.IDPROCESS 
	UNION ALL
	SELECT 24,'PROPRIETA'' PROCESSI','******************************','******************************','******************************','******************************','******************************','******************************',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL 
	SELECT 25,'<Prcidmp>','<Descrizione Processo>','<Azione Processo>','<Proprietà>','<Valore>','','',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1',-1,'-1'
	UNION ALL
	SELECT 26,CAST(PRCIDMP AS VARCHAR(30)),DESCR,ACTDESCR,PRPATTRIB,PRPVALUE,'','',
	PRCIDMP,'-1',		--Col1
	-1,PA.DESCR,		--Col2
	-1,actdescr,		--Col3
	-1,'-1',		--Col4
	-1,'-1',		--Col5
	-1,'-1',		--Col6
	-1,'-1'			--Col7
	FROM DOCUMENT D,PROCESS P,PROCESSANAG PA,PROCESSACTIONS PAC,ACTIONS A,ACTIONPROP AC
	WHERE D.DCMDESCRIPTION = @X AND D.DCMITYPE = P.PRCITYPESOURCE AND D.DCMISUBTYPE = P.PRCISUBTYPESOURCE AND 
	      P.PRCIDPROCESS = PAC.IDPROCESS AND PAC.IDACT = A.IDACT AND PAC.IDPA = AC.IDPA AND 	
	      D.DCMDELETED = 0  AND P.PRCIDPROCESS = PA.IDPROCESS 
	) RISULTATO 
	ORDER BY ORD,ORD_INT_COL1,ORD_TEXT_COL1,ORD_INT_COL2,ORD_TEXT_COL2,ORD_INT_COL3,ORD_TEXT_COL3
END
GO
