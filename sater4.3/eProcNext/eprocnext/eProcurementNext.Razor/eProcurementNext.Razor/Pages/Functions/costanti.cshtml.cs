namespace eProcurementNext.Razor.Pages.Functions
{
    public class costanti
    {
        //'------------------------------COSTANTI UTILIZZATE NELL'APPLICAZIONE----------------------------------

        //'----------------------------COSTANTI DELLA STRINGA DELLE FUNZIONALITA'---------------------
        public const int Administrator = 1;
        public const int buyer = 2;
        public const int supplier = 3;
        public const int SendRdo = 4;
        public const int CopyRdo = 5;
        public const int SendOff = 6;
        public const int CopyOffRic = 7;
        public const int Catalog = 8;
        public const int SendRIG = 9;
        public const int SendGPO = 10;
        public const int FnzuProfiliUtente = 11;
        public const int FnzuRIA = 12;
        public const int FnzuRAP = 13;
        public const int FnzuDAC = 14;
        public const int FnzuRIG = 15;
        public const int FnzuRdO = 16;
        public const int FnzuOrdineInArrivo = 17;
        public const int FnzuOffertaInArrivo = 18;
        public const int FnzuVDO = 19;
        public const int FnzuOrdine = 20;
        public const int FnzuProcuraOrdine = 21;
        public const int FnzuFornitoriAbituali = 22;
        public const int FnzuValutazioneFornitore = 23;
        public const int FnzuRPM = 24;
        public const int FnzuRIGinarrivo = 25;
        public const int FnzuGPO = 26;
        public const int FnzuRDOinarrivo = 27;
        public const int FnzuOfferta = 28;
        public const int FnzuOfid = 29;
        public const int FnzuOutSide = 30;
        public const int FnzuPromozione = 32;
        public const int FnzuProcurement = 43;
        public const int FnzuTransazioneaCatalogo = 44;
        public const int FnzuDelegatedApprover = 45;
        public const int FnzuDatiAzienda = 47;
        public const int FnzuModificaDatiAzienda = 48;
        public const int FnzuRda = 49;
        public const int FnzuRdaInArrivo = 50;
        public const int FnzuModificaCatalogo = 52;

        public const int FnzuGestioneArchivio = 53;
        public const int FnzuAziendeArchivio = 54;
        public const int FnzuModificaAziArchivio = 55;
        public const int FnzuProdottiArchivio = 56;
        public const int FnzuDocumentiArchivio = 57;

        public const int CatalogMP = 58;
        public const int FnzuModificaCatalogoMP = 59;

        public const int FnzuOffertaPromozionale = 60;
        public const int FnzuCatalogoInArrivo = 62;
        public const int FnzuAggiornaDatiAzi = 64;
        public const int FnzuOrdineSuCatalogo = 66;
        public const int FnzuGPOArrivo = 61;
        public const int FnzuOffertaDaProcurement = 63;
        public const int FnzuOrdineSuProcurement = 65;
        public const int FnzuOrdineSuPromozione = 67;
        public const int FnzuProcurementInArrivo = 68;

        public const int FnzuVisualizzaPercentuali = 96;
        public const int FnzuVariazionePercentuale = 97;
        public const int FnzuVisualizzaBilanciamento = 98;

        public const int FnzuGestioneArchivioSeller = 86;
        public const int FnzuDocumentiArchivioSeller = 87;

        public const int FnzuPda = 116;

        public const int FnzuModPlant = 129;
        public const int FnzuCMS = 300;//'-utilizzo pannello galleria immagini

        //'---------------------------Enumerato per la generalizzazione delle funzionalit� utente-------------
        //'che verranno ora reperite in base a questo valore al tipo e al sottotipo del documento-------------
        public const int FnzuCreate = 0;
        public const int FnzuSend = 1;
        public const int FnzuCopyTo = 2;
        public const int FnzuModify = 3;
        public const int FnzuProcura = 4;
        public const int FnzuNew = 5;
        public const int FnzuDelete = 6;
        public const int FnzuDocOrigine = 16;
        public const int FnzuAcquisizioneBev = 17;
        public const int FnzuChiusuraOrdine = 18;
        public const int FnzuChiusuraOrdineParziale = 19;
        public const int FnzuSpedizioneMerce = 20;
        public const int FnzuPdaPubblicazione = 21;
        public const int FnzuPdaScarto = 22;
        public const int FnzuPdaPunteggioEconomico = 23;
        public const int FnzuPdaPunteggioTecnico = 24;
        public const int FnzuPdaAssegnazione = 25;
        public const int FnzuModificaMerceologia = 30;
        public const int FnzuRicezioneMerce = 31;
        public const int FnzuModificaDescrizione = 32;
        public const int FnzuDisplayScadenzario = 33;
        public const int FnzuModificaUnitaMisura = 34;
        public const int FnzuSendMailToAzi = 35;
        public const int FnzuDecryptSection = 36;
        //'----------------------------COSTANTI DELLA STRINGA DELLE OPZIONI MY HOME PAGE'---------------------
        public const int DisplayTreeView = 1;
        public const int DisplayFolderActiveGroup = 2;
        public const int DisplayInBoxPlus = 3;
        public const int DisplayProfileBar = 4;
        public const int UseMigliaiaDecimali = 5;
        public const int FirstLoginUser = 6;
        public const int HomePageLight = 7;
        //'------------------------------------------------------------------------------------------


        //'-----------------COSTANTI UTILIZZATE PER LA COMPOSIZIONE DELLA PUB LEGALE NELLE COPERTINE---------
        public const string const_ValueKeyanonimo = "Azienda Anonima^Azienda Anonima"; //'valore di default per la formattazione della pub legale nella copertina in caso di anonimato
        public const string const_ValueKeyMitDest = "aziRagioneSociale#aziIdDscFormaSoc#AZILOGO"; //'valore di default per la formattazione della pub legale nella copertina in caso di non anonimato

        //'-----------------COSTANTI PER IL VALORE DI DEFAULT PER LA GESTIONE DI LUOGOPART E SEDIDEST
        public const string const_ValueLuogoPart_SediDest = "LOC;IND;STATO";

        //'----------------COSTANTI CHE IDENTIFICANO UNA DATA ILLIMITATA-----------------------------
        public const string CONST_DATAHIDE = "9999-12-31T00:00:00";
        public const string CONST_DATA_DEFAULT_SRIDOTTA = "2050-12-31";
        //'----------------COSTANTI CHE IDENTIFICANO I TIPI DI DOCUMENTO-----------------------------
        public const int CONST_ITYPEUNDEFINED = -1;
        public const int CONST_ITYPERADIX = 0;
        public const int CONST_ITYPERAP = 1;
        public const int CONST_ITYPEOFID = 2;
        public const int CONST_ITYPEVDO = 3;
        public const int CONST_ITYPERDO = 4;
        public const int CONST_ITYPEUSERPROFILE = 5;
        public const int CONST_ITYPECOMPANYPROFILE = 6;
        public const int CONST_ITYPETRASH = 7;
        public const int CONST_ITYPEUSERPROFILEREMOTE = 8;
        public const int CONST_ITYPEOFFERTE = 9;
        public const int CONST_ITYPEOFFERTEINARRIVO = 10;
        public const int CONST_ITYPERDOINARRIVO = 11;
        public const int CONST_ITYPEMSGINBOX = 12;
        public const int CONST_ITYPEMSGOUTBOX = 13;
        public const int CONST_ITYPEAFLMSG = 14;
        public const int CONST_ITYPERIG = 15;
        public const int CONST_ITYPEMOTIVAZIONISCARTO = 16;
        public const int CONST_ITYPERIGINARRIVO = 17;
        public const int CONST_ITYPEGPO = 18;
        public const int CONST_ITYPEGPOINARRIVO = 19;
        public const int CONST_ITYPEFORNITORIABITUALI = 20;
        public const int CONST_ITYPERICERCHESUPPLIER = 21;
        public const int CONST_ITYPEORDINI = 22;
        public const int CONST_ITYPEORDINIINARRIVO = 23;
        public const int CONST_ITYPEMSGSENDEDMAILBOX = 24;
        public const int CONST_ITYPERIA = 25;
        public const int CONST_ITYPERIAINARRIVO = 26;
        public const int CONST_ITYPEDAC = 27;
        public const int CONST_ITYPERIAINUSCITA = 28;
        public const int CONST_ITYPETRATTATIVA = 29;
        public const int CONST_ITYPERICHIESTAINCONTRO = 30;
        public const int CONST_ITYPEVALUTAZIONEFORNITORE = 31;
        public const int CONST_ITYPEPROMOZIONE = 32;
        public const int CONST_ITYPEOFFERTAPROMOZIONALE = 33;
        public const int CONST_ITYPETRANSAZIONECATALOGO = 34;
        public const int CONST_ITYPETRANSAZIONECATALOGOINARRIVO = 35;
        public const int CONST_ITYPEPROCUREMENT = 36;
        public const int CONST_ITYPEPROCUREMENTINARIVO = 37;
        public const int CONST_ITYPEPROCUREMENTSELLERINARRIVO = 38;
        public const int CONST_ITYPEOFIDSELLER = 39;
        public const int CONST_ITYPEVDOSELLER = 40;
        public const int CONST_ITYPECOMPANYPROFILECREATE = 41;
        public const int CONST_ITYPECOMPANYPROFILEMODIFY = 42;
        public const int CONST_ITYPECOMPANYPROFILEDELETE = 43;
        public const int CONST_ITYPECATALOG = 44;
        public const int CONST_ITYPECOMPANYSTRUCTURE = 45;
        public const int CONST_ITYPERDA = 46;
        public const int CONST_ITYPERDAINARRIVO = 47;
        public const int CONST_ITYPEGESTIONEARCHIVIO = 48;
        public const int CONST_ITYPEPERCENTUALEASSEGNAZIONE = 49;
        public const int CONST_ITYPEPUBLICORDERS = 50;
        public const int CONST_ITYPEPUBLICFOLDER = 51;
        public const int CONST_ITYPEVARIAZIONELISTINO = 52;
        public const int CONST_ITYPEPAP = 55;
        public const int CONST_ITYPEPDA = 60;

        public const int CONST_ITYPEPERCENTUALE = 53;
        public const int CONST_ITYPEVISUALIZZABILANCIAMENTO = 54;
        public const int CONST_ITYPEGENERIC = 55;
        public const int CONST_ITYPEMODIFICADATIAZI = -1;
        public const int CONST_ITYPEORDINESUCATALOGO = 35;
        public const int CONST_ITYPEOFFERTADAPROCUREMENT = 37;
        public const int CONST_ITYPEORDINESUPROMOZIONE = 33;
        public const int CONST_ITYPECAMBIORAGSOC = 212;
        public const int CONST_ITYPECAMBIOPLANT = 213;
        public const int CONST_ITYPESHIPMENTTRACKING = 218;


        public const int CONST_ISUBTYPELETTERADIASSEGNAZIONE = 200;
        public const int CONST_ISUBTYPEVARIAZIONELISTINO = 203;
        public const int CONST_ISUBTYPEFORNITORICONOAP = 204;
        public const int CONST_ISUBTYPELISTAPROGRAMMAZIONEOAP = 205;
        public const int CONST_ISUBTYPEARTICOLIOAP = 206;
        public const int CONST_ISUBTYPEPLANNINGOAPBUYER = 207;
        public const int CONST_ISUBTYPEPLANNINGOAPSELLER = 208;
        public const int CONST_ISUBTYPEMODIFYOAPSELLER = 209;
        public const int CONST_ISUBTYPEVARIEDFIELDSELLER = 210;
        public const int CONST_ISUBTYPEVARIEDFIELDBUYER = 211;
        public const int CONST_ISUBTYPELISTAOAPCONTOLAVORO = 214;
        public const int CONST_ISUBTYPEORDINERDA = 220;
        public const int CONST_ISUBTYPEORDINEDALISTINO = 221;
        public const int CONST_ISUBTYPEFORNOAPCONTOLAVORO = 215; //'fornitori conto lavoro
        public const int CONST_ISUBTYPEULTIMARISPOSTAVALIDA = 216;
        public const int CONST_ISUBTYPEFLEX = 218;

        public const int CONST_ISUBTYPESHIPMENTTRACKING = -1;
        public const int CONST_ISUBTYPEPAP = 6;
        public const int CONST_ISUBTYPEPAP_IDM = 7;
        public const int CONST_ISUBTYPEASN = 4;

        public const int CONST_ITYPE_MAIN = 0;
        public const int CONST_ISUBTYPE_MAIN = 0;

        //'---COSTANTI CHE IDENTIFICANO LE POSIZIONI PER GLI ATTACH PER RECUPERARE INFORMAZIONI SULLA AZIENDA ----
        public const int CONST_POSAZIENDARDO = 29;
        public const int CONST_POSAZIENDARDODEST = 11;
        public const int CONST_POSAZIENDARDOINARRIVO = 11;
        public const int CONST_POSAZIENDAOFFERTE = 16;
        public const int CONST_POSAZIENDAOFFERTEINARRIVO = 16;
        public const int CONST_POSAZIENDAOFFERTADAPROCUREMENT = 16;
        public const int CONST_POSAZIENDAORDINI = 16;
        public const int CONST_POSAZIENDAORDINIINARRIVO = 16;
        public const int CONST_POSAZIENDARIA = 1;
        public const int CONST_POSAZIENDARIADEST = 2;
        public const int CONST_POSAZIENDARIAINARRIVO = 1;
        public const int CONST_POSAZIENDADAC = 9;
        public const int CONST_POSAZIENDARIAINUSCITA = 9;
        public const int CONST_POSAZIENDARIG = 1;
        public const int CONST_POSAZIENDARIGINARRIVO = 1;
        public const int CONST_POSAZIENDAGPO = 1;
        public const int CONST_POSAZIENDAGPOINARRIVO = 1;
        public const int CONST_POSAZIENDARDA = 29;
        public const int CONST_POSAZIENDARDAINARRIVO = 29;
        public const int CONST_POSAZIENDATRANSAZIONECATALOGO = 29;
        public const int CONST_POSAZIENDATRANSAZIONECATALOGOINARRIVO = 16;
        public const int CONST_POSAZIENDAPROCUREMENT = 29;
        public const int CONST_POSAZIENDAPROCUREMENTINARRIVO = 11;
        public const int CONST_POSAZIENDAPROMOZIONE = 29;
        public const int CONST_POSAZIENDAPROMOZIONEINARRIVO = 16;
        public const int CONST_POSAZIENDAPDA = 3;

        //'---COSTANTI CHE IDENTIFICANO LE POSIZIONI PER GLI ATTACH PER RECUPERARE L'OGGETTO DEL MESSAGGIO ----
        public const int CONST_POSOGGETTORDO = 30;
        public const int CONST_POSITIONOGGETTORDA = 30;
        public const int CONST_POSITIONOGGETTOPDA = 4;
        public const int CONST_POSITIONNOTERDA = 31;
        public const int CONST_POSITIONNOTEPDA = 5;
        public const int CONST_POSOGGETTORDOINARRIVO = 16;
        public const int CONST_POSOGGETTOOFFERTE = 17;
        public const int CONST_POSOGGETTOOFFERTAINARRIVO = 17;
        public const int CONST_POSOGGETTOORDINE = 18;
        public const int CONST_POSOGGETTOORDINEINARRIVO = 18;
        public const int CONST_POSOGGETTORIA = 4;
        public const int CONST_POSOGGETTORIAINARRIVO = 3;
        public const int CONST_POSOGGETTODAC = 10;
        public const int CONST_POSOGGETTORIAINUSCITA = 10;
        public const int CONST_POSOGGETTORIG = 3;
        public const int CONST_POSOGGETTORIGINARRIVO = 2;
        public const int CONST_POSOGGETTOGPO = 4;
        public const int CONST_POSOGGETTOGPOINARRIVO = 4;
        public const int CONST_POSNOTEGPO = 5;
        public const int CONST_POSATTACHGPO = 6;
        public const int CONST_POSNOTEGPOINARRIVO = 5;
        public const int CONST_POSOGGETTORDA = 30;
        public const int CONST_POSOGGETTORDAINARRIVO = 1;
        public const int CONST_POSOGGETTOTRANSAZIONECATALOGO = 30;
        public const int CONST_POSOGGETTOTRANSAZIONECATALOGOINARRIVO = 17;
        public const int CONST_POSOGGETTOPROCUREMENT = 30;
        public const int CONST_POSOGGETTOPROCUREMENTINARIVO = 16;
        public const int CONST_POSOGGETTOPROMOZIONE = 30;
        public const int CONST_POSOGGETTOPROMOZIONEINARIVO = 17;
        public const int CONST_POSATTRIBUTI_RIA = 3;
        public const int CONST_POSBANDO_RDO = 33;
        public const int CONST_POSCRITERI_RDO = 34;
        public const int CONST_POSBANDO_RDOIA = 20;
        public const int CONST_POSCRITERI_RDOIA = 21;


        //'-------costanti Dragged usati nella rdo bis
        public const int MODEL_PRODUCT = 1;//'Modello di prodotto
        public const int DRAGGED = 2;//'dal tree view
        public const int MODEL_DOCUMENT = 4;//'Modello di documento
        public const int UDA = 8;//'Attributi d'iniziativa
        public const int COMMON_AREA = 16;//'Area comune
        public const int UDA_COMMON = 24;//'d'iniziativa e appartenente all'area comune
        public const int COMMON_1 = 17;//'d'iniziativa e appartenente all'area comune
        public const int COMMON_DRAGGED = 18;//'Dal tree wiev + area comune
        public const int COMMON_AREA_DOCUMENT = 20;//'Area comune + modello documento
        //'------------------------------------------------------------------------------------------
        //'----------------COSTANTI CHE IDENTIFICANO I MESSAGGI -----------------------------
        //'----------------ENUMERATIVO TYPE OFFER E ORDER--------------------------------------------
        public const string const_TypeOffer_Offerta = "0";
        public const string const_TypeOffer_Gpo = "1";
        public const string const_TypeOffer_Promozione = "2";
        public const string const_TypeOffer_Transazione = "3";
        public const string const_TypeOffer_Procurement = "4";
        public const string const_TypeOrder_RdainArrivo = "5";


        public const int CONST_NUM_LINK_1024 = 23;
        public const int CONST_NUM_LINK_800 = 15;
        public const int CONST_NUM_LINK_640 = 10;

        //'----------------------------COSTANTI CHE IDENTIFICANO LO STATO DEL MESSAGGIO'---------------------
        public const int CONST_STATENEWMESSAGE = 0;
        public const int CONST_STATESAVEDMESSAGE = 1;
        public const int CONST_STATESENDEDMESSAGE = 2;
        public const int CONST_STATECOPIEDMESSAGE = 3;
        public const int CONST_STATEINVALIDATEMESSAGE = 4;
        public const int CONST_STATERECOLLEDMESSAGE = 5;

        //'---------------------------- COSTANTI CHE IDENTIFICANO LO STATO DEL DOCUMENTO GENERICO' -------------
        //'---------------------------- in base ai valori del field "AdvancedState" ----------------------------
        public const int CONST_ADVSTATECONFIRMEDMESSAGE = 1;
        public const int CONST_ADVSTATEREJECTEDMESSAGE = 2;
        public const int CONST_ADVSTATEANNULLEDMESSAGE = 3;
        public const int CONST_ADVSTATEINAPPROVE = 4;
        public const int CONST_ADVSTATENOTAPPROVE = 5;
        public const int CONST_ADVSTATERETTIFICATO = 6;

        //'----------------ENUMERATIVO STATE OFFER-------------------------------------------
        public const int const_StateOffer_NonLavorata = 1;
        public const int const_StateOffer_Accettata = 2;
        public const int const_StateOffer_Scartata = 3;
        public const int const_StateOffer_ScartoNotificato = 4;

        //'----------------ENUMERATIVO DOCUMENT STATE----------------------------------------
        public const int const_DocumentState_DS_DELIVERED = 1;
        public const int const_DocumentState_DS_READ = 2;
        public const int const_DocumentState_DS_ASSIGNED = 3;

        //'----------------ENUMERATIVO STATEORDER----------------------------------------
        public const string CONST_STATEORDER_DAINVIARE = "0";
        public const string CONST_STATEORDER_INATTESADIAPPROVAZIONE = "1";
        public const string CONST_STATEORDER_DAAPPROVARE = "2";
        public const string CONST_STATEORDER_APPROVATO = "3";
        public const string CONST_STATEORDER_NONAPPROVATO = "4";
        public const string CONST_STATEORDER_INATTESADIRISPOSTA = "5";
        public const string CONST_STATEORDER_RICEVUTO = "6";
        public const string CONST_STATEORDER_LETTO = "7";
        public const string CONST_STATEORDER_ACCETTATO = "8";
        public const string CONST_STATEORDER_RIFIUTATO = "9";
        public const string CONST_STATEORDER_APPROVATORISERVA = "10";

        //'----------------ENUMERATIVO TYPECONTROLL----------------------------------------
        public const string CONST_TYPECONTROL_LABEL = "0";
        public const string CONST_TYPECONTROL_RTFLABEL = "1";
        public const string CONST_TYPECONTROL_COMPANYLOGO = "2";
        public const string CONST_TYPECONTROL_FRAME = "3";
        public const string CONST_TYPECONTROL_CHECKBOX = "4";
        public const string CONST_TYPECONTROL_TEXT = "5";
        public const string CONST_TYPECONTROL_DATA = "6";
        //'const CONST_TYPECONTROL_DATATIME						              = "7";
        //'const CONST_TYPECONTROL_COMBO							          = "8";
        //'const CONST_TYPECONTROL_COMBOBUTTON						          = "9";
        public const string CONST_TYPECONTROL_BOTTONE = "10";
        public const string CONST_TYPECONTROL_TEXTAREA = "17";
        public const string CONST_TYPECONTROL_CTL_LABEL = "18";
        public const string CONST_TYPECONTROL_DOMINI_CHIUSI_RICERCABILI = "19";
        public const string CONST_TYPECONTROL_CTLCOLOR = "25";
        public const string CONST_TYPECONTROL_ADDTIME = "26";
        public const string CONST_TYPECONTROL_WITH_BUTTON = "27";
        //'--nuovo inizio typecontrol
        public const string CONST_TYPECONTROL_BUTTONRESET = "100";
        public const string CONST_TYPECONTROL_RADIO = "105";
        public const string CONST_TYPECONTROL_CRITERIOQUIZ_C = "115";
        public const string CONST_TYPECONTROL_CRITERIOQUIZ_V = "120";

        //'----------------ENUMERATIVO STATEORDERARRIVO----------------------------------------
        public const string CONST_STATEORDERARRIVO_INATTESA = "0";
        public const string CONST_STATEORDERARRIVO_RICEVUTO = "1";
        public const string CONST_STATEORDERARRIVO_LETTO = "2";
        public const string CONST_STATEORDERARRIVO_ACCETTATO = "3";
        public const string CONST_STATEORDERARRIVO_RIFIUTATO = "4";
        public const string CONST_STATEORDERARRIVO_CONFERMARISERVA = "10";

        //'----------------------------COSTANTI CHE IDENTIFICANO LO STATETENDER DEL MESSAGGIO RDO'---------------------
        public const string CONST_STATETENDERANNULLATO = "3";

        //'----------------COSTANTI COMUNI----------------------------------------------------

        public const int CONST_NUMEROMESSAGGI_VISUALIZZATI = 20;
        public const int CONST_NUMERORIGHE_VISUALIZZATE = 20;
        public const int CONST_DEFAULTEXPIRYDATE = 9;
        public const int CONST_NUMROWPRINT_FIRSTPAGE = 20;


        //'----------------COSTANTI TIPI DATI FISSI----------------------------------------------------
        public const string CONST_TID_STRUTTURAAZIENDALE = "21";
        public const string CONST_TID_ATTACH = "35";
        public const string CONST_TID_FORMULA = "36";//'???????

        //'----------------ENUMERATIVO TIPODOM-----------------------------------------------------
        public const string CONST_TIPODOM_GERARCHICO = "G";
        public const string CONST_TIPODOM_APERTO = "A";
        public const string CONST_TIPODOM_CHIUSO = "C";
        public const int CONST_TIPOGERARCHIA_PAP = 16;

        //'----------------COSTANTI TIPO AFL MESSAGE----------------------------------------------------
        public const string CONST_AFLMSGGENERIC = "0";
        public const string CONST_AFLMSGORDERCONFIRM = "1";
        public const string CONST_AFLMSGORDERDISCARD = "2";
        public const string CONST_AFLMSGORDERREAD = "3";
        public const string CONST_AFLMSGORDERREMINDER = "4";
        public const string CONST_AFLMSGORDERDELIVERED = "5";
        public const string CONST_AFLMSGCHANGEIDSENDER = "6";
        public const string CONST_AFLMSGORDERAPPROVE = "7";
        public const string CONST_AFLMSGORDERNOTAPPROVE = "8";
        public const string CONSTAFLMSGLINK = "9";
        public const string CONST_AFLMSGCLOSETENDER = "10";
        public const string CONST_AFLMSGCANCELTENDER = "11";
        public const string CONST_AFLMSGNOTASSIGNEDTENDER = "12";
        public const string CONST_AFLMSGINVALID = "14";
        public const string CONST_AFLMSGDISCARD = "15";
        public const string CONST_AFLMSGCLOSEORDER = "16";
        public const string CONST_AFLMSGMULTIAPPROVE = "18";
        public const string CONST_AFLMSGNOTMULTIAPPROVE = "19";
        public const string CONST_AFLMSGNOTIFYMULTIAPPROVE = "20";
        public const string CONST_AFLMSGORDERCONFIRMRESERVE = "21";


        //'----------------ENUMERATIVO TIPOMEM----------------------------------------------------- 
        public const int TIPOMEM_LONG = 1;	//' (il Massimo � 2147483647)
        public const int TIPOMEM_MONEY = 2;
        public const int TIPOMEM_FLOAT = 3;
        public const int TIPOMEM_NVARCHAR = 4;
        public const int TIPOMEM_DATETIME = 5;
        public const int TIPOMEM_IDDSC = 6;	//' (long)
        public const int TIPOMEM_KEYS = 7;	//' (long)

        //'----------------ENUMERATIVO TIPO COLONNE----------------------------------------------------- 
        public const int CONST_GCN_EDITABLE_OPENEDNUMERIC = 0;
        public const int CONST_GCN_NOTEDITABLE = -1;
        public const int CONST_GCN_SHADOW = -2;
        public const int CONST_GCN_EDITABLE_OPENEDSTRING = -3;
        public const int CONST_GCN_EDITABLE_HIERARCHY = -4;
        public const int CONST_GCN_NOTEDITABLE_HIERARCHY = -5;
        public const int CONST_GCN_EDITABLE_STRUCTAZI = -6;
        public const int CONST_GCN_NOTEDITABLE_STRUCTAZI = -7;
        public const int CONST_GCN_NOTEDITABLE_CLOSED = -8;
        public const int CONST_GCN_EDITABLE_ATTACH = -9;
        public const int CONST_GCN_NOTEDITABLE_ATTACH = -10;
        public const int CONST_GCN_NOTEDITABLE_PERC = -11;
        public const int CONST_GCN_EDITABLE_PERC = -12;
        public const int CONST_GCN_NOTEDITABLE_FORMULA = -13;
        public const int CONST_GCN_EDITABLE_FORMULA = -14;

        //'----------------ENUMERATO ATTRIBUTO OBBLIGATORIO----------------------------------------- 
        public const int CONST_ATTRIB_NOT_OBBLIG = 0;
        public const int CONST_ATTRIB_OBBLIG = 1;

        //'----------------ENUMERATO POSIZIONE COLONNA ATTRIBUTO ----------------------------------------- 
        //'----------------di corredo a GetInfoAttributo in Recupera_Info.asp
        public const int CONST_POS_DZTLUNGHEZZA = 0;
        public const int CONST_POS_DZTCIFREDECIMALI = 1;
        public const int CONST_POS_DZTIDTID = 2;
        public const int CONST_POS_DZTTIPOMEM = 3;
        public const int CONST_POS_DZTTIPODOM = 4;
        public const int CONST_POS_DZTNOME = 5;

        //'----------------ENUMERATO ATTRIBUTO TRATTABILE----------------------------------------- 
        public const int CONST_ATTRIB_DEAL = 0;
        public const int CONST_ATTRIB_NOT_DEAL = 1;


        //'------------------COSTANTI per opzioni apertura finestre di explorer-------------
        public const string CONST_TOOLBAR = "no";
        public const string CONST_MENUBAR = "no";
        public const string CONST_MENUBARPRINT = "yes";
        public const string CONST_STATUS = "yes";
        public const string CONST_SCROLLBARS = "no";
        public const string CONST_RESIZABLE = "no";
        public const string CONST_LOCATION = "no";
        public const string CONST_DIRECTORIES = "no";
        public const string CONST_COPYHISTORY = "no";

        //'------------------COSTANTI PER DEFINIRE SEPARATORI NELLE STRINGHE ---------------------------------------

        public const string CONST_SEPARATOR1 = "#";
        //'------------------COSTANTI PER DEFINIRE I COLORI DELLE CELLE DI UNA TABELLA---------------------


        public const string CONST_COLORRIGAINSERITATABELLAPERCENTUALE = "#B7FFFF";
        public const string CONST_COLORRIGATABELLAPERCENTUALE = "#F7EFFF";
        public const string CONST_COLORRIGAERRATATABELLAPERCENTUALE = "#FF3300";
        public const string CONST_COLORRIGAERRATADATAINIDATAFINE = "#FF9966";
        public const string CONST_COLORRIGAERRATAARCOTEMPORALE = "#AE3300";

        //'------------------COSTANTI font face e size ---------------------------------------

        public const string CONST_FONTFACE = "Arial";
        public const int CONST_FONTSIZE = 10;
        public const int CONST_HEIGHT_CONTROL = 35;
        public const int CONST_WIDTH_CONTROL = 110;
        public const int CONST_ROW_CONTROL_TEXAREA = 3;
        public const int CONST_COL_CONTROL_TEXTAREA = 50;


        //'----------------------------COSTANTI PER LA VISUALIZZAZIONE O MENO DEGLI ALLEGATI NEGLI ATTACH---------------
        public const int CONST_ATTACH_NULL = -1;   //'non considerare il parametro
        public const int CONST_ATTACH_ALL = 0;    //'tutti gli attach
        public const int CONST_ATTACH_WITHOUT_ALLEGATI = 1;    //'attach senza allegati
        public const int CONST_ATTACH_ONLY_ALLEGATI = 2;	   //'attach solo allegati
        public const int CONST_ATTACH_NONE = 3;    //'nessuno attach

        //'rni 348
        public const int CONST_WIDTHCODEBAR = 100;
        public const int CONST_HEIGHTCODEBAR = 50;

        //'---------------------costante che indica la gestione da effettuare per i DC e UMS---------------------
        public const bool bDominiChiusiEstesi = false;

        //'-------------------------COSTANTI CHE IDENTIFICANO IL PROFILO AZIENDA----------------------------
        public const int CONST_AZIENDA_BUYER = 0;
        public const int CONST_AZIENDA_SELLER = 1;
        public const int CONST_AZIENDA_BUYER_SELLER = 2;
        public const int CONST_AZIENDA_PROSPECT = 3;
        public const int CONST_AZIENDA_WEBBUYER = 4;
        public const int CONST_AZIENDA_WEBSELLER = 5;
        public const int CONST_AZIENDA_WEBBUYER_SELLER = 6;

        //'------------------COSTANTI di ritorno delle chiamate alle funzioni ---------------------------------------
        public const int S_Ok = 0;
        public const int E_Fail = -1;

        public const string ORDINE_DA_RDA = "Ordine da Rda";
        public const string ORDINE_DA_RAP = "Ordine da Rap";

        //'-----------------DESCRIZIONE PER IL PRIMO ITEM ALL'INTERNO DELLA COMBO PLUG IN---------------------------
        public const string DESC_SELECT_PLUGIN = "Seleziona il plug in";

        //'-----------------DESCRIZIONE UTILIZZATA NEGLI ORDINI A PROGRAMMA---------------------------
        public const string DESC_ISCHANGE_OAP = "Variazioni";
        public const string DESC_SHOW_PREV = "Visualizza planning";
        public const string DESC_N_RETROACTIVITY = "Numero di retroattivit�";
        public const string DESC_TIPO_CRONOLOGIA = "Tipo di cronologia";
        public const string DESC_TIPO_DIFF_CALC = "Dato calcolo differenze";
        public const string DESC_LEGENDA = "Legenda";
        public const string DESC_PLANNING = "Planning";

        //'------------COSTANTI TIPO OPERAZIONE NEL DICTIONARY CONTENENTI LE CHIAVI REGDEFAULT---------------------------------------
        public const int CONST_INSERT_DICTREGDEFAULT = 1;
        public const int CONST_RELOADING_DICTREGDEFAULT = 2;
        public const int CONST_MODIFY_DICTREGDEFAULT = 3;
        public const int CONST_DELETE_KEYREGDEFAULT = 4;

        //'------------COSTANTI per gli attributi con valori si o no---------------------------------------
        public const string CONST_VALUEATTRIBUTEYES = "10099";
        public const string CONST_VALUEATTRIBUTENO = "10100";

        //'------------Costanti per gli ordini a programma----------------------------------------------
        public const string TYPECRONO_DATE = "Date"; //'Tipo di cronologia data
        public const string TYPECRONO_MOUNTH = "Mounth"; //'Tipo di cronologia mese
        public const string TYPECRONO_WEEK = "WEEK"; //'Tipo di cronologia settimana
        public const string CALC_DIFF_QO = "ScheduleRequiredQuantity"; //'tipo calcolo delle differenze sulle quantit�
        public const string CALC_DIFF_QTAPROGCONS = "CARPROGCONS"; //'tipo calcolo delle differenze sul cumulo
        public const int CONST_PURE_DATATYPE = 1; //'quando la data � espessa nel formato xml
        public const int CONST_WEEK_DATATYPE = 2; //'quando la data � espressa nel formato settimanale
        public const int CONST_MONTH_DATATYPE = 3; //'quado la data � espressa nel formato mensile
        public const string CONST_PURE_DATATYPE_STR = "1"; //'quando la data � espessa nel formato xml
        public const string CONST_WEEK_DATATYPE_STR = "2"; //'quando la data � espressa nel formato settimanale
        public const string CONST_MONTH_DATATYPE_STR = "3"; //'quado la data � espressa nel formato mensile

        public const string CONST_ARTICLESTYPEPERIODPATH = "OFFERTEPERIODOTIPOLOGIA"; //'descrizve il path relativo al modello della griglia articoli la cui tipologia data � settimanale o mensile.
        public const string ORDPROG_ORDERS = "VisualizeOrders";
        public const string ORDPROG_ARTICLES = "VisualizeArticles";
        public const int CONST_CHARCAPTIONSIZE = 8; //' size del carattere delle caption della griglia
        public const int CONST_CHARCAPTIONMAXLENGTH = 20; //'massima lunghezza delle descrizioni nelle caption della griglia
        public const string CONST_DETAIL_PROGRAM = "DetailsProgram"; //'per il dettaglio del programma
        public const string CONST_MODIFY_PROGRAM = "DetailsProgramModify";//' per la modifca del programma
        public const string CONST_REQUESTVARIATION = "RICHIESTAVARIAZIONE";
        public const string CONST_LASTVALIDRESPONSE = "ULTIMARISPOSTAVALIDA"; //'ultima risposta valida
        public const string CONST_LASTVALIDVARIATION = "LASTVALIDVARIATION"; //'ulktima variazione valida
        public const string CONST_VISUALIZEARTICLESBUYER = "VISUALIZEARTICLESBUYER"; //'visualizza articoli lato buyer
        public const int LIDMDL = 419;
        public const int CONST_NVIEDWFORN = 1;
        public const int CONST_NVIEDBUYER = 2;
        public const int CONST_MAX_ITEM_SELECTED = 15; //'massimo numero di elementi selezionabili nella griglia per il dettaglio
        public const int CODE_NOT_SEND_MSG = -2147220970;
        public const string DZTNOME_VARIATIONREQUESTSTATUS = "VariationRequestStatus"; //'dztnome relativo all'attributo VariationRequestStatus
        public const string CONST_REG_DEF_ACTIVEVARIATIONOAP = "ActiveVariationOAP";
        public const string CONST_REG_DEF_CONFIGURATIONPLANNING = "ConfigurationPlanning";
        public const string CONST_REG_DEF_NUMBERCOLUMNSPRINTDETAILS = "NumberColumnsPrintDetails";

        //'------------Costanti per la definizione delle dimensione dei frame nell'applicazione----------
        public const string CONST_HEIGHTFRAMEINTESTFOLDER = "55"; //' altezza dell'intestazione del folder
        public const string CONST_HEIGHTFRAMEFILTERFOLDER = "190"; //' altezza del filtro del folder

        //'------------Costante per la definizione della dimensione del frame Testata1 della Homepage----------
        public const string CONST_HEIGHTFRAMEHEADER = "40";

        //'------------Costante per la definizione del numero di celle della tabella contenitore della Testata1----------
        public const string CONST_NUMCOLUMNS_HEADER = "4";

        //'------------Costante per la definizione della dimensione del frame ProfileBar della Homepage----------
        public const string CONST_HEIGHTFRAMEPROFILE = "27";

        //'------------Costante per la definizione della larghezza del frame TreeView della Homepage----------
        public const string CONST_WIDTHFRAMEFUNCTIONSLIST = "199";

        //'--------------------Costante che indica la grandezza in punti del font utilizzato nelle
        //'intestazioni delle griglie
        public const string CONST_FONT_INTEST_GRIDCOLUMN = "6";
        public const string CONST_FONT_DESC_VERTICALMODEL = "6";
        public const string CONST_WIDTH_DESC_VERTICALMODEL = "30";

        //'---------------------------------------------------------------------------------------------------------------------------------------
        //'ampiezza del frame intestazione DI UN DOCUMENTO
        public const int CONST_WIDTHFRAMETESTATA = 167;
        public const int CONST_WIDTHFRAMETESTATAPRODOTTI = 30;
        public const int CONST_WIDTHFRAMETESTATAORDER = 170;
        public const int CONST_WIDTHFRAMETESTATARDA = 179;
        public const int CONST_OFFSETROWFRAMETESTATA = 35;
        //'---------------------------------------------------------------------------------------------------------------------------------------

        //'---------------------costante che indica se disegnare l'icona nei folder---------------------
        public const string CONST_SHOWICONINFOLDER = "0";
        //'-----------------------------------------------FINE------------------------------------------

        //'---------------------costante che indica la lunghezza del nome nella lista dei messaggi---------------------
        public const string CONST_LENGTH_NAME_MESSAGE = "20";
        //'---------------------costante che identifica la lunghezza del campo oggetto nella griglia di un folder------
        public const string CONST_LENGTH_TEXT_MESSAGE = "250";
        //'-----------------------------------------------FINE------------------------------------------

        //'---------------------costante che indica la lunghezza dei link nei documenti---------------------
        public const string CONST_LENGTH_LINK_DOCUMENT = "20";

        //'-----------------------------------------------FINE------------------------------------------

        //'---------------------costante che indica la lunghezza dei link---------------------
        public const string CONST_LENGTH_LINK = "20";

        //'---------------------costante che indica la DEFINIZIONE DELLE DIMENSIONI del logo dei dati azienda---------------------
        public const string CONST_WIDTH_COMPANYLOGO = "250";
        public const string CONST_HEIGTH_COMPANYLOGO = "140";

        //'-----------------costante per il refresh dell'aggiornamento del numero dei messaggi non letti--
        public const int CONST_TIMER_REFRESH_TREEVIEW = 1000000;

        //'--------------costante che indica il numero di cifre decimali di default da visualizzare nel calcolo del totale---------------
        public const int CONST_DEFAULT_CIFRE_DECIMALI = 2;
        //'--------------costante che indica la max length di default per gli attributi di tipo money e float---------------
        public const int CONST_FIX_LUNGHEZZA_MONEY = 6;
        //'--------------costante che indica la max length di default per gli attributi di tipo long---------------
        public const int CONST_FIX_LUNGHEZZA_LONG = 10;

        //'costante che mi dice le colonne di default da visualizzare nella stampa ridotta listino
        public const string CONST_SPRINT_ATTRIB_ARTICLE = "Codice Articolo#~Descrizione Articolo#~UnitMis#~CARLottiMinimi#~CARQTAnnua#~PrzUnOfferta#~CARDataIniListino#~CARDataFineListino";

        //'costante che indica il numero max di elementi di un listino fornitore.
        //'Viene utilizzata quando viene fatta la stampa ridotta dei listini aperti da dossier.
        public const int CONST_MAX_NUM_ARTICLES_CATALOG = 20000;

        //'costante contenente gli attributi condizioni di fornitura di default nella stampa ridotta
        public const string CONST_DEFAULT_ATTRIB_COND_FORNITURE_SRIDOTTA = "SediDest#~CarValGenerico#~CARResaGenerico#~CARSpedizioniGenerico#~CarCondPagGenerico#~CARImballiGenerico";

        //'costante contenente la prima posizione di un prodotto nella griglia
        public const string CONST_FIRST_ROWS_IN_GRID_PRODUCT = "2";

        //'costante contenente il numero degli attributi fissi dei messaggi:rdo/proc,promozione/transazione,rda,rda in arrivo
        public const int CONST_NUMBER_ATTRIB_FIX_RDO = 8;

        //'costante contenente il numero degli attributi fissi dei messaggi:rdo/proc in arrivo,off/prom in arrivo,ordine,ordine in arrivo
        public const int CONST_NUMBER_ATTRIB_FIX_RDOARRIVO = 6;

        //'costante contenente gli attributi da visualizzare nel tab utenti della rda
        public const string CONST_ATTIB_USERS_RDA = "Key#Name#CompanyRole";



        //'costante contenente il nome dei Tab della Rdo in arrivo
        public const string CONST_NAME_TAB_RDOINARRIVO = "Copertina#~Prodotti#~Bando#~Criteri#~Allegati#~Note";
        //'costante contenente il numero di Tab della rdo in arrivo
        public const int CONST_NUM_TAB_RDOINARRIVO = 5;

        //'costante contenente il nome dei Tab della TNA (ria in uscita)
        public const string CONST_NAME_TAB_TNA = "Copertina#~Attributi#~Allegati#~Note";
        //'costante contenente il numero di Tab della TNA (ria in uscita)
        public const int CONST_NUM_TAB_TNA = 3;

        //'costante contenente il nome dei Tab della TNA in arrivo(DAC)
        public const string CONST_NAME_TAB_DAC = "Copertina#~Attributi#~Allegati#~Note#~Valutazione";
        //'costante contenente il numero di Tab della TNA in arrivo(DAC)
        public const int CONST_NUM_TAB_DAC = 4;

        //'costante contenente il nome dei Tab della Rdo in arrivo versione precedente all 2.0
        public const string CONST_NAME_TAB_RDOINARRIVO_OLD = "Copertina#~Prodotti#~Allegati#~Note";
        //'costante contenente il numero di Tab della rdo in arrivo
        public const int CONST_NUM_TAB_RDOINARRIVO_OLD = 3;
        //'costante contenente il nome dei Tab della Rdo in arrivo
        public const string CONST_NAME_TAB_OFFERTAINARRIVO = "Copertina#~Prodotti#~Allegati#~Note";
        //'costante contenente il numero di Tab della rdo in arrivo
        public const int CONST_NUM_TAB_OFFERTAINARRIVO = 3;


        //'costante contenente il nome dei Tab della Rdo in arrivo
        public const string CONST_NAME_TAB_OFFERTA = "Copertina#~Prodotti#~Allegati#~Note";
        //'costante contenente il numero di Tab della rdo in arrivo
        public const int CONST_NUM_TAB_OFFERTA = 3;

        //'costante contenente il nome dei Tab della Pda
        public const int CONST_NUM_TAB_PDA = 4;

        //'costante contenente il numero di Tab della rdo
        public const int CONST_NUM_TAB_RDO_OLD = 4;

        //'costante contenente il numero di Tab della ria
        public const int CONST_NUM_TAB_RIA = 4;
        //'costante contenente il nome dei Tab della Ria
        public const string CONST_NAME_TAB_RIA = "Copertina#~Destinatari#~Attributi#~Allegati#~Note";

        //'costante contenente il numero di Tab della rdo
        public const int CONST_NUM_TAB_RDO = 6;
        //'costante contenente il numero di Tab della rda
        public const int CONST_NUM_TAB_RDA = 5;

        //'costante contenente il nome dei Tab della rda
        public const string CONST_NAME_TAB_RDA = "Copertina#~Prodotti#~Destinatari#~Allegati#~Note#~AllaFirma";
        //'costante contenente il nome dei Tab della Rdo
        public const string CONST_NAME_TAB_RDO = "Copertina#~Prodotti#~Destinatari#~Bando#~Criteri#~Allegati#~Note";
        //'costante contenente il nome dei Tab della Rdo
        public const string CONST_NAME_TAB_RDO_OLD = "Copertina#~Prodotti#~Destinatari#~Allegati#~Note";

        //'costante contenente il nome dei Tab della pda
        public const string CONST_NAME_TAB_PDA = "Copertina#~Prodotti#~Allegati#~Note";

        //'costanti per identificare il contesto da dove viene chiamata la sub campi
        //'per la gestione dei domini chiusi
        public const string CONST_CREA_RDO = "CREARDO";
        public const string CONST_NEW_RDO = "NUOVARDO";
        public const string CONST_NEW_PROMOTION = "NUOVAPROMOZIONE";
        public const string CONST_NEW_ARTICLE_IN_GRID = "INSERIMENTOARTICOLO";
        public const string CONST_NEW_ARTICLE_IN_GRID_FROM_CATALOG = "INSERIMENTOARTICOLOFROMCATALOG";
        public const string CONST_DOMINI_CHIUSI_RICERCABILI_DOCUMENTO = "DOCUMENTO";
        public const string CONST_DOMINI_CHIUSI_RICERCABILI_CATALOGO = "CATALOGO";
        public const string CONST_NEW_RAP = "RAP";
        public const string CONST_COMPANY_DATA = "DATIAZIENDA";

        //'costante gruppo ums valute
        public const int CONST_UMS_VALUTA = 6;


        //'costanti per allineamento dei campi per la gestione dei domini chiusi
        public const int CONST_ALIGN_TOP = 5;
        public const int CONST_ALIGN_LEFT = 1;
        public const int CONST_ALIGN_TOP_DOSSIER = -29;


        public const string pDay = "gio";
        public const string pWeek = "set";
        public const string pTenDays = "dec";
        public const string pMonth = "men";
        public const string pTwoMonths = "bim";
        public const string pThreeMonths = "tri";
        public const string pQuarter = "qua";
        public const string pHalfYear = "sem";
        public const string pYear = "ann";

        //' Enumerativo per il field  NegotiationState introdotto nella rda e rda in arrivo (RNI 399)
        public const int CONST_InitialState = 100;
        public const int CONST_SendedRdo = 200;
        public const int CONST_ReceivedOffer = 300;
        public const int CONST_ApprovingOrder = 400;
        public const int CONST_ConfirmedOrder = 500;
        public const int CONST_AnnullState = 999;

        //'----- Enumerativo per le PROPRIETA' di una SEZIONE sul DOCUMENTO GENERICO
        public const string CONST_CONTEXT_TREEVIEW = "CONTEXT_TREEVIEW"; //'propriet� per recuperare il contesto degli attributi
                                                                         //'dalla gerarchia attributi
        public const string CONST_SHOW_TREEVIEW = "SHOW_TREEVIEW";		//'1|0 visualizzare oppure no il treeview
        public const string CONST_CALCULATETOTAL = "CALCULATETOTALFORGRID";

        //'nome directosy che contiene le immagini dei codici a barra
        public const string CONST_FOLDERCODEBAR = "ImageCodeBar";

        //'------COSTANTI LARGHEZZA DI DEFAULT CAMPO TESTO------
        public const int CONST_SIZE_INPUT_TEXT = 40;
        public const int CONST_SIZE_INPUT_TEXT_LOCKED_DEFAULT = 80;
        public const int CONST_SIZE_INPUT_TEXT_LOCKED_MIN = 5;
        public const int CONST_SIZE_INPUT_TEXT_LOCKED_MAX = 100;

        //'-----------------------------------------------FINE------------------------------------------

        //'costanti per la larghezza di default della tabella dei folder
        public const int WIDTH_TABLE_FOLDER_0 = 1000; //'	CON RISOLUZIONE 1280X1024
        public const int WIDTH_TABLE_FOLDER_1 = 780;  //'	CON RISOLUZIONE 1024X768
        public const int WIDTH_TABLE_FOLDER_2 = 600;  //'	CON RISOLUZIONE 800X600

        //'costante per tipo persistenza documento
        public const string PERSISTENCETYPE_STANDARD = "1";
        public const string PERSISTENCETYPE_XMLSIGNED = "2";
        public const string PERSISTENCETYPE_XMLNOTSIGNED = "3";

        //'--enumerato stato asta
        public const int AUCTIONNOTSTARTED = 0; //'da iniziare
        public const int AUCTIONINPROGRESS = 1; //'in corso
        public const int AUCTIONFINISHED = 2; //'finita
        public const int AUCTIONCANCELED = 3; //'annullata

        //'--enumerato tipo anomalia per la PDAs
        public const string ANOMALIA_NOT_CALCULATE = "0"; //'calcolo anomalia da non effettuare
        public const string ANOMALIA_BASE_STANDARD = "1"; //'calcolo anomalia con base asta imputato
        public const string ANOMALIA_BASE_CALCULATE = "2"; //'calcolo anomalia con base asta calcolato

        //'--costante per errore esporta excel backoffice
        public const string STRING_ERROR_EXCEL = "ERRORE_AFLBACKOFFICE_EXPORT_EXCEL";

        public const string FORNITORENONATTIVO = "10100";
        public const string FORNITOREATTIVO = "10099";
        public const string FORNITOREINATTIVAZIONE_0 = "0";
        public const string FORNITOREINATTIVAZIONE_1 = "1";
        public const string FORNITOREINATTIVAZIONE_2 = "2";

        public const int MSG_INFO = 1; //'"info.gif"
        public const int MSG_ERR = 2; //'"err.gif"
        public const int MSG_ASK = 3; //'"ask.gif"
        public const int MSG_WARNING = 4; //'"warning.gif"


        public const string PDA_CriterioPrezzobasso = "15531";
        public const string PDA_OffertaVantaggiosa = "15532";
        public const string PDA_OffertaCOSTOFISSO = "25532";

        public const string PDA_OffAnomaleAutomatica = "16309"; //'--esculsione automatica
        public const string PDA_OffAnomaleValutazione = "16310"; //'--valutazione

        public const string PDA_ModalitadiPartecipazioneTradizionale = "16307"; //'--Tradizionale
        public const string PDA_ModalitadiPartecipazioneTelematica = "16308"; //'--Telematica

        public const string PDA_CriterioFormulazioneOffertePrezzo = "15536"; //'--prezzo
        public const string PDA_CriterioFormulazioneOffertePercentuale = "15537"; //'--percentuale


        //'--TIPO ESTENSIONE ASTA
        public const string MethodExtensionBase = "836490";
        public const string MethodExtensionExtended = "836491";
        public const string MethodExtensionTempoBase = "836492";

        public const int AUCTIONTIME_RILANCIOALBUIO = 5;


        //'--TIPOBANDO (FLUSSO UNICO)
        public const string TipoBandoAvviso = "1";
        public const string TipoBandoBando = "2";
        public const string TipoBandoInvito = "3";


        //'--ENUMERATO e SIGNIFICATO POS COLONNA MPMAOPZIONI ATTRIBUTI MODELLI 
        public const int PosAddDeleted = 11;



    }
}