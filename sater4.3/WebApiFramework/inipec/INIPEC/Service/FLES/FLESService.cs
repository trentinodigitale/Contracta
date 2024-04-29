using INIPEC.Library;
using System;
using System.Collections.Generic;

namespace INIPEC.Service.FLES
{

    public class FLESService
    {

        public FLESService()
        {
        }

        int _idDoc;

        public List<string> getListaSchede()
        {
            List<string> ls = new List<string>();
            ls.Add("I1");
            ls.Add("SA1");
            return ls;
        }

        public string getPayloadI1(int idDoc, string idAppalto)
        {
            _idDoc = idDoc;

            object objScheda = compilaScheda(idDoc, "I1");
            BaseModelGeneric<SchedaGeneric<BodyI1>> baseModelI1 = new BaseModelGeneric<SchedaGeneric<BodyI1>>();
            baseModelI1.scheda = (SchedaGeneric<BodyI1>) objScheda;
            baseModelI1.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelI1);

            return json;
        }

        public string getPayloadSA1(int idDoc, string idAppalto)
        {
            _idDoc = idDoc;

            object objScheda = compilaScheda(idDoc, "SA1");
            var baseModelSA1 = new BaseModelGeneric<SchedaGeneric<BodySA1>>();
            baseModelSA1.scheda = (SchedaGeneric<BodySA1>)objScheda;
            baseModelSA1.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelSA1);

            return json;
        }

        private object compilaScheda(int idDoc, string tipoScheda)
        {
            switch (tipoScheda)
            {
                case "I1":
                    SchedaGeneric<BodyI1> schedaI1 = new SchedaGeneric<BodyI1>();
                    schedaI1.codice = new Codice() { idTipologica = "codiceScheda", codice = "I1" };
                    schedaI1.versione = "1.0";

                    FLESI1Service i1Service = new FLESI1Service();
                    AnacFormI1 anacFormI1 = i1Service.recuperaAnacFormI1(idDoc);

                    BodyI1 bodyI1 = new BodyI1();
                    schedaI1.body = bodyI1;
                    schedaI1.body.anacForm = anacFormI1;

                    return schedaI1;
                case "SA1":
                    SchedaGeneric<BodySA1> schedaSA1 = new SchedaGeneric<BodySA1>();
                    schedaSA1.codice = new Codice() { idTipologica = "codiceScheda", codice = "SA1" };
                    schedaSA1.versione = "1.0";

                    FLESSA1Service sa1Service = new FLESSA1Service();
                    AnacFormSA1 anacFormSA1 = sa1Service.recuperaAnacFormSA1(idDoc);

                    BodySA1 bodySA1 = new BodySA1();
                    schedaSA1.body = bodySA1;
                    schedaSA1.body.anacForm = anacFormSA1;

                    return schedaSA1;
                default:
                    throw new NotImplementedException();
            }
        }

        public void updateStato(int idRowScheda, string tipoScheda, string statoScheda)
        {
            string statoFunzionale = "Inviato";
            string statoBozza = "Inviato";
            if (statoScheda.ToUpper() == "ELABORATO")
            {
                statoFunzionale = "Confermato";
                statoBozza = "OK";
            }
            else if (statoScheda.ToUpper().Contains("ERRORE"))
            {
                statoFunzionale = "In Lavorazione";
                statoBozza = "Errore";
            }

            switch (tipoScheda)
            {
                case "I1":
                    FLESI1Service i1Service = new FLESI1Service();
                    i1Service.updateStato(idRowScheda, statoFunzionale, statoBozza);

                    // Aggiornamento stato contratto
                    if (statoFunzionale == "Confermato")
                    {
                        i1Service.updateStatoContratto(_idDoc);
                    }
                    break;
                case "SA1":
                    FLESSA1Service sa1Service = new FLESSA1Service();
                    sa1Service.updateStato(idRowScheda, statoFunzionale, statoBozza);
                    break;
                default:
                    throw new NotImplementedException();
            }
        }

    }
}