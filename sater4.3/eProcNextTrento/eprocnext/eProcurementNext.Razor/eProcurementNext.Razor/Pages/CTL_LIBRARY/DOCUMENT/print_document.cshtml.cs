using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.DOCUMENT
{
    public class print_documentModel : PageModel
    {


        public void OnGet()
        {
        }
        //'--INCLUDE DI FUNZIONI PER LA GESTIONE DELLE STAMPE PERSONALIZZATE SUL DOCUMENTO 

        //'-- Lista delle funzioni da utilizzare nelle stampe suddivise per sezioni
        //
        //'------------------------------
        //'-- TESTATA ( COPERTINA )
        //'------------------------------
        //'-- Public function DOC_Field( strSectionName, strAttrib )
        //'-- Public function DOC_FieldTecnical( strSectionName, strAttrib )
        //'-- Public Sub DOC_PubLegale( strSectionName, strAttrib)
        //'-- Public Sub DOC_PubLegalePlant( strSectionName, strAttrib)
        //'-- Public sub DOC_Logo( strSectionName, strAttrib,width,height)
        //
        //
        //'------------------------------
        //'-- DETTAGLI ( PRODOTTI )
        //'------------------------------
        //'-- Public function DOC_NumRow( strSectionName, "" )
        //'-- Public function DOC_FieldRow( strSectionName, strAttrib, strNumRiga )
        //
        //
        //'------------------------------
        //'-- APPROVAL ( sezione per ciclo di approvazione )
        //'------------------------------
        //'-- Public function DOC_NumRow( strSectionName, area )
        //'-- Public function DOC_GetRsArea( strSectionName,  Area )
        //'-- Public function DOC_FieldArea( strSectionName, strAttrib, Area , RecordSet )
        //
        //
        //'------------------------------
        //'-- Funzioni di uso comune
        //'------------------------------
        //'-- Public function AziInfo( azi , strAttrib)
        //'-- Public function AziOptional( azi , strAttrib)
        //'-- Public Sub SaltoPagina()
        //'-- Public Sub CNV( testo )
        //'-- Public sub FreeMemDocument
        //'-- Public function GetRS( strSql)
        //'-- Public function Relation( RelType , ValInput )
        //'-- Public Sub PubLegaleAZI( idAzi)
        //'-- 
        //
        //'DESC=funzione per il caricamneto del documento
        public static eProcurementNext.Document.CTLDOCOBJ.Document DOC_GetFromMem(string TypeDoc, string idDoc, eProcurementNext.Session.ISession session, HttpContext context, EprocResponse htmlToReturn)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.print_documentModel.DOC_GetFromMem(TypeDoc, idDoc, session, context, htmlToReturn);
        }
        //'DESC=funzione che carica il documento dalla base dati
        public static eProcurementNext.Document.CTLDOCOBJ.Document DOC_LoadFromDB(string TypeDoc, string idDoc, eProcurementNext.Session.ISession session, HttpContext context, EprocResponse htmlToReturn)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.print_documentModel.DOC_LoadFromDB(TypeDoc, idDoc, session, context, htmlToReturn);
        }
        public static eProcurementNext.Document.CTLDOCOBJ.Document PrintDocument(eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpContext context, HttpResponse Response, HttpRequest Request)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.print_documentModel.PrintDocument(session, htmlToReturn, context, Response, Request);
        }

        public static void addMetaTag(EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.print_documentModel.addMetaTag(htmlToReturn);
        }


    }
}
