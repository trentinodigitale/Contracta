USE [AFLink_TND]
GO
/****** Object:  View [dbo].[V_Document]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[V_Document]
AS 
SELECT  di.IdDi AS ID, 
        dcm.dcmDescription AS DocumentDescription, 
        dcm.dcmIType AS DocumentType, 
        dcm.dcmISubType AS DocumentSubType, 
        dcm1.dcmItype AS RelatedDocumentType, 
        dcm1.dcmISubtype AS RelatedDocumentSubType, 
        di.diVersion AS DocumentVersion, 
        di.diAdviseStatusDescrFieldName AS DcmAdvStatusDescrFieldName, --DocumentAdviseStatusDescrFieldName, 
        di.diLinkFieldName AS DocumentLinkFieldName, 
        di.diAdviseStatusValueFieldName AS DcmAdvStatusValueFieldName, --DocumentAdviseStatusValueFieldName,
        diPriorityStatusFieldName AS PriorityStatusFieldName, 
        di.dideleted AS flagdeleted,
        di.diUltimaMod AS UltimaMod,
        di.diAttachInitPos AS diAttachInitPos	,
        di.diLinkFieldNameSource LinkFieldNameSource,
        dcm.dcmOption,
        dcm.dcmIdGrp
   FROM Document dcm, Document dcm1, DocumentInfo di
  WHERE di.diIdDcm = dcm.IdDcm 
    AND dcm.IdDcm = dcm1.dcmRelatedIdDcm
    AND di.diUltimaMod >= dcm.dcmUltimaMod
UNION ALL
SELECT  di.IdDi AS ID, 
        dcm.dcmDescription AS DocumentDescription, 
        dcm.dcmIType AS DocumentType, 
        dcm.dcmISubType AS DocumentSubType, 
        dcm1.dcmItype AS RelatedDocumentType, 
        dcm1.dcmISubtype AS RelatedDocumentSubType, 
        di.diVersion AS DocumentVersion, 
        di.diAdviseStatusDescrFieldName AS DcmAdvStatusDescrFieldName, --DocumentAdviseStatusDescrFieldName, 
        di.diLinkFieldName AS DocumentLinkFieldName, 
        di.diAdviseStatusValueFieldName AS DcmAdvStatusValueFieldName, --DocumentAdviseStatusValueFieldName,
        diPriorityStatusFieldName AS PriorityStatusFieldName, 
        di.dideleted AS flagdeleted,
        dcm.dcmUltimaMod AS UltimaMod,
        di.diAttachInitPos AS diAttachInitPos	,
        di.diLinkFieldNameSource LinkFieldNameSource,
        dcm.dcmOption,
        dcm.dcmIdGrp
   FROM Document dcm, Document dcm1, DocumentInfo di
  WHERE di.diIdDcm = dcm.IdDcm 
    AND dcm.IdDcm = dcm1.dcmRelatedIdDcm
    AND di.diUltimaMod < dcm.dcmUltimaMod
GO
