using AutoMapper;
using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.WebAPI.Model;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]     //Questa route contiene il place holder [controller], così facendo la rotta risponderà al nome 'UserInfo'
    [ApiController]                 //mette una serie di comportamenti di default ai nostri controller. ad es. ci permette l'uso delle rotte
    public class UserInfoController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        private readonly IAuthHandlerCustom _authHandler;
        private readonly eProcurementNext.Session.ISession _session;

        private readonly int idpfu;


        public UserInfoController(
            ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
            eProcurementNext.Session.ISession session,
            IAuthHandlerCustom authHandler
            )
        {
            //Proprietà recuperate con la dependency injection
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
            _session = session;
            _authHandler = authHandler;

            try
            {
                _session.Load(_authHandler.Token);
            }
            catch
            {
                throw new AuthorizedException();
            }

            idpfu = CInt(_session["idpfu"]);

            if (idpfu <= 0)
            {
                throw new AuthorizedException();
            }

            if (!_session["SessionIsAuth"])
            {
                throw new AuthorizedException();
            }
        }

        /// <summary>
        /// Get: /api/v1/UserInfo
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        [HttpGet]
        [ProducesResponseType(typeof(UserInfoViewModel), StatusCodes.Status200OK)]
        public async Task<IActionResult> Get()
        {
            CommonDbFunctions cdb = new();
            Dictionary<string, object?> parColl = new()
            {
                { "@idpfu", idpfu }
            };
            TSRecordSet? rs = cdb.GetRSReadFromQuery_("select " +
                $"{AziendaInfoViewModel.tablePrefix}RagioneSociale, " +
                $"{AziendaInfoViewModel.tablePrefix}DataCreazione, " +
                $"{AziendaInfoViewModel.tablePrefix}PartitaIva, " +
                $"{AziendaInfoViewModel.tablePrefix}E_Mail, " +
                $"{AziendaInfoViewModel.tablePrefix}IndirizzoLeg, " +
                $"{AziendaInfoViewModel.tablePrefix}LocalitaLeg, " +
                $"{AziendaInfoViewModel.tablePrefix}ProvinciaLeg, " +
                $"{AziendaInfoViewModel.tablePrefix}StatoLeg, " +
                $"{AziendaInfoViewModel.tablePrefix}CapLeg, " +
                $"{AziendaInfoViewModel.tablePrefix}SitoWeb, " +
                $"{UserInfoViewModel.tablePrefix}Nome, " +
                $"{UserInfoViewModel.tablePrefix}RuoloAziendale, " +
                $"{UserInfoViewModel.tablePrefix}E_Mail, " +
                $"{UserInfoViewModel.tablePrefix}Tel, " +
                $"{UserInfoViewModel.tablePrefix}CodiceFiscale, " +
                $"{UserInfoViewModel.tablePrefix}LastLogin, " +
                $"{UserInfoViewModel.tablePrefix}DataCreazione " +
                "from ProfiliUtente join Aziende on pfuIdAzi = IdAzi where idpfu = @idpfu", ApplicationCommon.Application.ConnectionString, parColl);

            AziendaInfoViewModel aziendaInfoViewModel = new(
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}RagioneSociale"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}DataCreazione"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}PartitaIva"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}E_Mail"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}IndirizzoLeg"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}LocalitaLeg"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}ProvinciaLeg"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}StatoLeg"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}CapLeg"]),
                CStr(rs[$"{AziendaInfoViewModel.tablePrefix}SitoWeb"])
            );

            UserInfoViewModel userInfoViewModel = new(
                CStr(rs[$"{UserInfoViewModel.tablePrefix}Nome"]),
                CStr(rs[$"{UserInfoViewModel.tablePrefix}RuoloAziendale"]),
                CStr(rs[$"{UserInfoViewModel.tablePrefix}E_Mail"]),
                CStr(rs[$"{UserInfoViewModel.tablePrefix}Tel"]),
                CStr(rs[$"{UserInfoViewModel.tablePrefix}CodiceFiscale"]),
                CStr(rs[$"{UserInfoViewModel.tablePrefix}LastLogin"]),
                CStr(rs[$"{UserInfoViewModel.tablePrefix}DataCreazione"]),
                aziendaInfoViewModel
            );




            var result = new { status = "OK", result = JsonSerializer.Serialize(userInfoViewModel) };
            return Ok(result);

        }



    }
}
