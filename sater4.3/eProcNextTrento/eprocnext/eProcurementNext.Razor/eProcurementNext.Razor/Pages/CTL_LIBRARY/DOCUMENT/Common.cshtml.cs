using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.DOCUMENT
{
    public class CommonModel : PageModel
    {
        //'--ENUMRATO TIPO ATTRIBUTO

        public const int TIPOATTRIB_TEXT = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_TEXT;
        public const int TIPOATTRIB_NUMBER = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_NUMBER;
        public const int TIPOATTRIB_TEXTAREA = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_TEXTAREA;
        public const int TIPOATTRIB_DOMAIN = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_DOMAIN;
        public const int TIPOATTRIB_HIERARCHY = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_HIERARCHY;
        public const int TIPOATTRIB_DATE = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_DATE;
        public const int TIPOATTRIB_NUMBER_COLORED = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_NUMBER_COLORED;
        public const int TIPOATTRIB_DOMAIN_EXTENDED = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_DOMAIN_EXTENDED;
        public const int TIPOATTRIB_CHECKBOX = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_CHECKBOX;
        public const int TIPOATTRIB_RADIOBUTTON = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_RADIOBUTTON;
        public const int TIPOATTRIB_LABEL = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_LABEL;
        public const int TIPOATTRIB_FOTO = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_FOTO;
        public const int TIPOATTRIB_URL = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_URL;
        public const int TIPOATTRIB_MAIL = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_MAIL;
        public const int TIPOATTRIB_STATIC = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_STATIC;
        public const int TIPOATTRIB_HR = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_HR;
        public const int TIPOATTRIB_ATTACH = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_ATTACH;
        public const int TIPOATTRIB_LOGO_AZIENDA = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_LOGO_AZIENDA;
        public const int TIPOATTRIB_LEGALPUB = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_LEGALPUB;
        public const int TIPOATTRIB_DESC_DB = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_DESC_DB;
        public const int TIPOATTRIB_DATE_EXTENDED = eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TIPOATTRIB_DATE_EXTENDED;
        //-- deve essere invocata alla fine delle pagine per liberare la memoria dal docuemnto
        //da capire tipo Document
        public static eProcurementNext.Document.CTLDOCOBJ.Document? objDoc
        {
            get
            {
                return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.objDoc;
            }
            set
            {
                eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.objDoc = value;
            }
        }
        public void OnGet()
        {
        }
        public static void FreeMemDocument(eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.FreeMemDocument(session);
        }
        public static void FreeMemDocumentNoAbandon(eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.FreeMemDocumentNoAbandon(session);
        }

        public static void DOC_AttribValue(string strSectionName, string strAttrib, string strNumRiga, string strTechValue, EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_AttribValue(strSectionName, strAttrib, strNumRiga, strTechValue, htmlToReturn);
        }
        public static string DOC_FieldHTML(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldHTML(strSectionName, strAttrib);
        }
        //'-- dato il campo di una copertina si ritorna il valore visuale
        //'-- 	SE SERVE PORTARE IN OUTPUT UN CONTENUTO HTML DI UN FIELD SENZA FARNE L'ENCODE CHIAMARE IL METODO DOC_Field_NoEncode
        public static dynamic DOC_Field(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_Field(strSectionName, strAttrib);
        }

        public static string DOC_Field_NoEncode(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_Field_NoEncode(strSectionName, strAttrib);
        }

        public static string DOC_Field_LabelHTML(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_Field_LabelHTML(strSectionName, strAttrib);
        }
        //'-- dato il campo di una copertina si ritorna la label associata all'attributo
        public static string DOC_Field_Label(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_Field_Label(strSectionName, strAttrib);
        }

        public static string DOC_FieldTecnicalHTML(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldTecnicalHTML(strSectionName, strAttrib);
        }
        //'-- dato il campo di una copertina ritorna il valore tecnico
        public static dynamic DOC_FieldTecnical(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldTecnical(strSectionName, strAttrib);
        }

        public static string DOC_FieldRowHTML(string strSectionName, string strAttrib, int strNumRiga)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldRowHTML(strSectionName, strAttrib, strNumRiga);
        }
        public static string Myhtmlencode(string valore)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.Myhtmlencode(valore);
        }
        //'-- dato il campo di una sezione dettagli si ritorna il valore visuale
        public static string DOC_FieldRow(string strSectionName, string strAttrib, int strNumRiga)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldRow(strSectionName, strAttrib, strNumRiga);
        }

        public static string DOC_FieldRow_LabelHTML(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldRow_LabelHTML(strSectionName, strAttrib);
        }
        //'-- dato il campo di una sezione dettagli si ritorna la caption 
        public static string DOC_FieldRow_Label(string strSectionName, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldRow_Label(strSectionName, strAttrib);
        }

        public static string DOC_FieldRowTecnicalHTML(string strSectionName, string strAttrib, int strNumRiga)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldRowTecnicalHTML(strSectionName, strAttrib, strNumRiga);
        }
        //'-- dato il campo di una sezione dettagli si ritorna il valore tecnico
        public static dynamic DOC_FieldRowTecnical(string strSectionName, string strAttrib, int strNumRiga)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldRowTecnical(strSectionName, strAttrib, strNumRiga);
        }

        public static string DOC_FieldAreaHTML(string strSectionName, string strAttrib, string Area, TSRecordSet RS)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldAreaHTML(strSectionName, strAttrib, Area, RS);
        }
        //'-- data il campo di una sezione approvazione
        public static string DOC_FieldArea(string strSectionName, string strAttrib, string Area, TSRecordSet RS)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldArea(strSectionName, strAttrib, Area, RS);
        }
        //'-- data il campo di una sezione approvazione
        public static string DOC_FieldArea2(string strSectionName, string strAttrib, string Area)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldArea2(strSectionName, strAttrib, Area);
        }

        //'-- muove il record corrente sull'area di una sezione di tipo approvazione
        public static void DOC_AreaMoveRec(string strSectionName, string Area, string move)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_AreaMoveRec(strSectionName, Area, move);
        }
        //da capire tipo di ritorno della funzione da controllare
        public static TSRecordSet? DOC_GetRsArea(string strSectionName, string Area)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_GetRsArea(strSectionName, Area);
        }
        //'-- data il campo di una sezione dettagli si esegue la scrittura del valore testuale
        //capire tipo di ritorno
        public static int DOC_NumRow(string strSectionName, string area)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_NumRow(strSectionName, area);
        }
        //'-- ritorna il valore di un attributo sui dati azienda, ad esempio ragione sociale

        public static string AziInfo(string azi, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.AziInfo(azi, strAttrib);
        }
        //'-- ritorna il valore di un attributo sui dati opzionali azienda, ad esempio codice cliente

        public static string AziOptional(string azi, string strAttrib)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.AziOptional(azi, strAttrib);
        }

        /// <summary>
        /// ritorna il valore di un attributo sui dati opzionali azienda, ad esempio codice cliente
        /// </summary>
        /// <param name="RelType"></param>
        /// <param name="ValInput"></param>
        /// <returns></returns>
        public static string Relation(string RelType, string ValInput)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.Relation(RelType, ValInput);
        }

        public static string RelationTime(string RelType, string ValInput, DateTime t)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.RelationTime(RelType, ValInput, t);
        }
        //'-- ritorna un rs passata la query

        public static TSRecordSet GetRS(string strSql, Dictionary<string, object?>? SqlParameters = null)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetRS(strSql, SqlParameters);
        }

        //'DESC=disegna la pub legale di una azienda
        public static void DOC_PubLegale(string strSectionName, string strAttrib, EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_PubLegale(strSectionName, strAttrib, htmlToReturn);

        }
        public static void PubLegaleAZI(string idAzi, string strP, EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.PubLegaleAZI(idAzi, strP, htmlToReturn);
        }


        /// <summary>
        /// inserisce il salto pagina
        /// </summary>
        /// <param name="htmlToReturn"></param>
        public static void SaltoPagina(EprocResponse htmlToReturn)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.SaltoPagina(htmlToReturn);
        }

        /// <summary>
        /// inserisce nella tabella TRACE_MULTILINGUISMO le chiavi del vecchio multilinguismo
        /// </summary>
        /// <param name="strKey"></param>
        public static void TraceMultilinguismo(string strKey)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.TraceMultilinguismo(strKey);
        }
        public static void MsgError(string path, string ErrText, HttpResponse httpResponse)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.MsgError(path, ErrText, httpResponse);
        }
        public static void CheckCanSign(EprocResponse htmlToReturn, eProcurementNext.Session.ISession session, HttpContext HttpContext, HttpRequest Request)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.CheckCanSign(htmlToReturn, session, HttpContext, Request);
        }
        //'-- la funzione recupera dal parametro passato l'elemento 
        //'-- da stampare per poi chiamare la funzione specifica
        public static string GetHtmlData(string strDataElem, eProcurementNext.Session.ISession session)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlData(strDataElem, session);
        }
        //'-- la funzione recupera da un determinato elemento passato il suo valore ritornandolo come stringa
        //'-- vElem = è un array che contiene in zero il nome della sezione, in 1 il nome dell'area
        //'-- strDataElem = è una stringa che contiene la chiamata completa fatta per l'elemento richiesto fatta in questo modo:
        //'-- id='SECTIONNAME.ATTRIB' 
        //'-- format='year' format='month-literal' ecc...
        public static string GetHtmlDataFromSection(string strDataElem)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlDataFromSection(strDataElem);
        }
        //'-- dato il campo di una sezione CAPTION si ritorna il valore visuale
        public static string DOC_FieldFormat(string strSectionName, string strAttrib, string strFormat)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldFormat(strSectionName, strAttrib, strFormat);
        }
        //'--effettua la formattazione custom per le date
        public static string Date_Format(string strTechValue, string strFormat)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.Date_Format(strTechValue, strFormat);
        }
        //'--Restituisce html di una griglia secondo quanto indicato in strDataElem fatto come segue:
        //'--#DATADOC 
        //'--id='Commissione.griglia' 
        //'--filter='RuoloCommissione=15540'
        //'--orderby='ReceivedDataMsg'
        //'--col='NominativoCommissione' 
        //'--pagebreak='20'
        //'--commandbreak='@@@SALTOPAGINA@@@'
        //'--layout='list'
        //'--value='<li>Con nota prot.....del.....chiarimenti all’operatore economico<RAGSOC> in merito a <HISTORYMOTIVATION> ;</li>'
        //'--/#
        public static string GetHtmlData_Dettagli(string strSectionName, string strDataElem)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlData_Dettagli(strSectionName, strDataElem);
        }
        //'--restituisce una griglia rappresentata con una TABELLA
        //'-- strSectionName = NOME SEZIONE
        //'-- strDeletedRow = righe da non disegnare
        //'-- strRowsSort = ordine delle righe
        //'-- strColShow = col da visualizzare
        //'-- strColHide = col da nascondere
        //'-- strShowCell = indice riga  della cella da ritornare
        //'-- strPageBreak = quando fare il salto pagina
        //'-- strCommandBreak = direttiva per il salto pagina
        //'-- strReplace_Expression = replace da applicare alle colonne nella forma
        //'-- strTemplateRow = template di riga da utilizzare per disegnare la griglia:VERTICALE disegna ogni riga in verticale col=valore
        public static string GetHtmlData_Dettagli_TABLE(string strSectionName, string strDeletedRow, string strRowsSort, string strColShow, string strColHide, string strShowCell, string strPageBreak, string strCommandBreak, string strReplace_Expression, string strTemplateRow)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlData_Dettagli_TABLE(strSectionName, strDeletedRow, strRowsSort, strColShow, strColHide, strShowCell, strPageBreak, strCommandBreak, strReplace_Expression, strTemplateRow);
        }
        //'--restituisce una griglia rappresentata con una DIV e risolvendo un template per ogni riga
        //'-- strSectionName = NOME SEZIONE
        //'-- strDeletedRow = righe da non disegnare
        //'-- strRowsSort = ordine delle righe
        //'-- strColShow = col da visualizzare
        //'-- strColHide = col da nascondere
        //'-- strShowCell = indice riga  della cella da ritornare
        //'-- strPageBreak = quando fare il salto pagina
        //'-- strCommandBreak = direttiva per il salto pagina
        //'-- strReplace_Expression = replace da applicare alle colonne nella forma
        //'-- strTemplateRow = template di riga da utilizzare per disegnare la griglia
        public static string GetHtmlData_Dettagli_CUSTOM(string strSectionName, string strDeletedRow, string strRowsSort, string strColShow, string strColHide, string strShowCell, string strPageBreak, string strCommandBreak, string strReplace_Expression, string strTemplateRow)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlData_Dettagli_CUSTOM(strSectionName, strDeletedRow, strRowsSort, strColShow, strColHide, strShowCell, strPageBreak, strCommandBreak, strReplace_Expression, strTemplateRow);
        }
        public static string GetValueOfAttribElem(string strDataElem, string attr)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetValueOfAttribElem(strDataElem, attr);
        }
        public static string GetHtmlDataLegalPub(string strDataElem)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlDataLegalPub(strDataElem);
        }
        //'-- la funzione ritorna una stringa contenete tutte le righe che non rispettano la condizione passata
        //'-- gli indici delle righe sono racchiusi fra parentesi quadre esempio: "[1][12]"
        public static string GetDeletedRowsFromFilter(dynamic[,] MatriceProdotti, Dictionary<string, Field> cols, string strfilter)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetDeletedRowsFromFilter(MatriceProdotti, cols, strfilter);
        }
        //'-- la funzione ritorna una stringa con l'indice delle righe ordinato secondo il criterio richiesto
        //'-- gli indici delle righe sono separate da # esempio : "1#3#2"
        public static string GetSortedRowsFromCriteria(dynamic[,] MatriceProdotti, Dictionary<string, Field> cols, string strOrderby, string strVerso)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetSortedRowsFromCriteria(MatriceProdotti, cols, strOrderby, strVerso);
        }
        public static string BubbleSortNumbers(int[] iArray, string strVerso)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.BubbleSortNumbers(iArray, strVerso);
        }
        //'--restituisce una griglia rappresentata con una TABELLA
        //'-- PaginaCorrente = pagina da stampare
        //'-- strSectionName = NOME SEZIONE
        //'-- strDeletedRow = righe da non disegnare
        //'-- strRowsSort = ordine delle righe
        //'-- strColShow = col da visualizzare
        //'-- strColHide = col da nascondere
        //'-- strShowCell = indice riga  della cella da ritornare
        //'-- NumLineeForPage = numero linee da stampare per la pagina
        //'-- strCommandBreak = direttiva per il salto pagina
        //'-- strReplace_Expression = replace da applicare alle colonne nella forma
        //'-- strTemplateRow = template di riga da utilizzare per disegnare la griglia:
        //                     VERTICALE disegna ogni riga in verticale col=valore
        //                     ""(stringa vuota) disegna ogni riga per la griglia in ORIZZONTALE    
        //'-- NumLineeStampate = numero linee stampate nella pagina
        //'-- IndiceLastCol = indice di colonna da cui devo ripartire
        public static string GetHtmlData_Dettagli_TABLE_PERPAGINA(int PaginaCorrente, string strSectionName, string strDeletedRow, string strRowsSort, string strColShow, string strColHide, string strShowCell, int NumLineeForPage, string strCommandBreak, string strReplace_Expression, string strTemplateRow, ref int NumLineeStampate, ref int nNumLineeCurrent, int NumColDisplay, ref int LastRowDiplayed, ref int IndiceLastCol)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.GetHtmlData_Dettagli_TABLE_PERPAGINA(PaginaCorrente, strSectionName, strDeletedRow, strRowsSort, strColShow, strColHide, strShowCell, NumLineeForPage, strCommandBreak, strReplace_Expression, strTemplateRow, ref NumLineeStampate, ref nNumLineeCurrent, NumColDisplay, ref LastRowDiplayed, ref IndiceLastCol);
        }
        //'DESC=funzione per salvare valore attributo
        //'objDoc=documento
        //'strSectionName=nome sezione
        //'strAttrib=nome attributo
        //'nNumRiga=numero riga utilizzato per le griglie
        //'strTechValue= di input contiene il valore in forma tecnica
        public static void Save_DOC_AttribValue(string strSectionName, string strAttrib, string strNumRiga, string strTechValue)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.Save_DOC_AttribValue(strSectionName, strAttrib, strNumRiga, strTechValue);
        }
        /// <summary>
        /// Recupera il valore
        /// </summary>
        /// <param name="Contesto">stringa che identifica l'oggetto tecnico in cui faccio la chiamata: nomepagina.asp,ecc....</param>
        /// <param name="Oggetto">attributo o altro su cui voglio recuperare la proprietà</param>
        /// <param name="Prop">proprieta ( i nomi sono come quelli definiti sui modelli)</param>
        /// <param name="DefValue">valore didefault</param>
        /// <param name="Idpfu">default passare -1</param>
        /// <returns></returns>
        public static string? Get_Func_Property(string Contesto, string Oggetto, string Prop, string DefValue, int Idpfu = -1)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.Get_Func_Property(Contesto, Oggetto, Prop, DefValue, Idpfu);
        }
        public static string NL_To_BR(string value)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.NL_To_BR(value);
        }
        public static string xmlEncode(string str)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.xmlEncode(str);
        }
        //'DESC=funzione per salvare valore attributo
        //'objDoc=documento
        //'strSectionName=nome sezione
        //'strAttrib=nome attributo
        //'nNumRiga=numero riga utilizzato per le griglie
        //'strTechValue= di input contiene il valore in forma tecnica
        public static void Save_DOC_MatrixValue(string TIPO_DOC, string ID_DOC_IN_MEM, string strSectionName, int strNumCol, int strNumRiga, string strTechValue, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.Save_DOC_MatrixValue(TIPO_DOC, ID_DOC_IN_MEM, strSectionName, strNumCol, strNumRiga, strTechValue, session);
        }
        //'-- dato il campo di una sezione dettagli si ritorna il valore visuale
        public static string DOC_FieldIdRowTab(string strSectionName, int strNumRiga)
        {
            return eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT.CommonModel.DOC_FieldIdRowTab(strSectionName, strNumRiga);

        }

    }
}










