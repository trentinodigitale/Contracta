using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Schema;

namespace INIPEC.Library
{
    public enum Errors
    {
        XSDPath, 
        XMLPath,
        XSD, 
        ValidateXML,
        ReadXML,
        RuntimeException
    }

    public class XMLValidationOutput
    {
        public bool Esit { get; set; }
        public Errors Error { get; set; }
        public string RuntimeException { get; set; }
        public List<string> ValidationErrors { get; set; }
    }


    public class XMLValidation
    {
        public string BasePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory,"eForms", "XSD","schemas","maindoc");

	    /// <summary>
        /// ciao sono un summary
        /// </summary>
        /// <param name="Xml">ciao sono il parametro 1</param>
        /// <param name="Xsd">parametro 2</param>
        /// <param name="isXmlPath">parametro 33</param>
        /// <param name="isXsdPath">test</param>
        /// <returns>descrizione dell'output</returns>
		public XMLValidationOutput ValidateXML(string Xml, string Xsd, bool isXmlPath, bool isXsdPath)
        {
            //Istanzio gli oggetti e variabili
            XmlReaderSettings XSDsettings = new XmlReaderSettings();
            XMLValidationOutput Result = new XMLValidationOutput();
            Result.ValidationErrors = new List<string>();

            //Inizializzo il valore di output a true e RuntimeException come errore di default
            Result.Esit = true;
            Result.Error = Errors.RuntimeException;

            try
            {
                // Se l'XSD è da recuperare con un path e al percorso indicato non esiste il file interrompo il metodo e ritorno un errore
                if (isXsdPath && !File.Exists(Path.Combine(BasePath,Xsd)))
                {
                    Result.Error = Errors.XSDPath;
                    Result.Esit = false;
                    return Result;
                    //throw new Exception(Error_XSDPath);
                }
                /* Vado a creare gli elementi corretti in base all'input ricevuto per procedere alla validazione */
                else
                {
                    CreateXSD(XSDsettings, Xsd, isXsdPath, Result);
                }

                /* Avendo l'XSD vado ad eseguire la validazione dell'XML */
                if (isXmlPath)
                {
                    if (File.Exists(Path.Combine(BasePath,Xml)))
                    {
                        // Crea un oggetto XmlReader basato sulle impostazioni e sul file XML
                        using (XmlReader reader = XmlReader.Create(Xml, XSDsettings))
                        {
                            try
                            {
                                while (reader.Read()) { }
                            }
                            catch (XmlException ex)
                            {
                                //Se ci sono stati errori durante la lettura del file (file corrotto)
                                Result.Error = Errors.ReadXML;
                                Result.Esit = false;
                                Result.RuntimeException = ex.Message;
                                return Result;
                                //throw new Exception($"1#Errore di validazione nel documento XML: {ex.Message}");
                            }
                        }
                    }
                    else
                    {
                        Result.Error = Errors.XMLPath;
                        Result.Esit = false;
                        return Result;
                        //throw new Exception(Error_XMLPath);
                    }
                }
                else
                {
                    //Converto la stringa XML in un memorystream
                    byte[] byteArray = Encoding.UTF8.GetBytes(Xml ?? "");

                    using (MemoryStream stream = new MemoryStream(byteArray))
                    {
                        // Carica il documento XML e verifica la validità
                        using (XmlReader reader = XmlReader.Create(stream, XSDsettings))
                        {
                            try
                            {
                                while (reader.Read()) { }
                            }
                            catch (XmlException ex)
                            {
                                //Se ci sono stati errori durante la lettura del file (file corrotto)
                                Result.Error = Errors.ReadXML;
                                Result.Esit = false;
                                Result.RuntimeException = ex.Message;
                                return Result;
                                //throw new Exception($"{Error_ValidateXML} : {ex.Message}");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            //Se ci sono stati errori rispetto allo schema XSD
            if (Result.ValidationErrors.Count > 0)
            {
                Result.Error = Errors.ValidateXML;
                Result.Esit = false;
                //throw new Exception($"{Error_ValidateXML} : {string.Join(" ~~~ ", Result.ValidationErrors)}");
            }

            return Result;
        }

        private void CreateXSD(XmlReaderSettings settings, string Xsd, bool isXsdPath, XMLValidationOutput Result)
        {
            try
            {
                if (isXsdPath)
                {
                    // Aggiungo lo schema dell'XSD all'oggetto settings e setto il validationtype
                    string FullPath = Path.Combine(BasePath,Xsd);
                    settings.Schemas.Add(null, FullPath);
                }
                else
                {
                    // Converti la stringa XSD in un flusso
                    byte[] byteArray = System.Text.Encoding.UTF8.GetBytes(Xsd ?? "");
                    MemoryStream xsdStream = new MemoryStream(byteArray);

                    // Configura XmlReaderSettings
                    settings.Schemas.Add(null, XmlReader.Create(xsdStream));
                }

                //Parte di configurazione comune
                settings.ValidationType = ValidationType.Schema;
                settings.ValidationEventHandler += (sender, args) =>
                {
                    if (args.Severity == XmlSeverityType.Error)
                    {
                        // Aggiungo l'errore alla lista
                        Result.ValidationErrors.Add(args.Message);
                    }
                };

            }
            catch (Exception ex)
            {
                Result.Error = Errors.XSD;
                Result.Esit = false;
                Result.RuntimeException = ex.Message;
                //throw new Exception(Error_XSD);
            }
        }
    }
}