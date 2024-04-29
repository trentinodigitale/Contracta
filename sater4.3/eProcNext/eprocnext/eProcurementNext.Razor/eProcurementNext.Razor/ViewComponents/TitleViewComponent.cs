using eProcurementNext.Razor.Model;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor.ViewComponents
{
    public class TitleViewComponent : ViewComponent
    {
        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;

        private Title title;
        public TitleViewComponent(IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;

            HttpContext context = this._accessor.HttpContext;

            LoadSession(context, _session);
            title = new Model.Title();

        }

        public IViewComponentResult Invoke(bool newStyle)
        {
            var item = GetHtmlCode(newStyle);
            HtmlString tmp = new HtmlString(item.ToString());
            title.Content = tmp;
            return View(title);
        }


        private System.Text.StringBuilder GetHtmlCode()
        {
            System.Text.StringBuilder righe = new System.Text.StringBuilder();

            string tmp = $@"

            <div class=""main_top_1"">

				<ul class=""ul_main_top_elements"">
	
					<li class=""li_main_top_element_Title"">
			
						{_session["NOMEPORTALE"]}

					</li>
		
					<li class=""li_main_top_element_RagSociale"">
						<strong>Azienda</strong>
						{_session["RagSociale"]}
								
					</li>	
		
					<li class=""li_main_top_element_UserName"">
						<strong>Utente</strong>
						{_session["UserName"]}

					</li>

					<li class=""li_main_top_element_logout last"">
							<a href=""#logout"" onclick=""logout();"" class=""link_logout""><strong>Logout</strong></a>
					</li>

					<!--li class=""li_main_top_element_logout last"">
							<a href=""/logoutTemp.asp"" onclick=""logout();"" class=""link_logout""><strong>Logout</strong></a>
					</li-->
				</ul>

			</div>
			";
            righe.Append(tmp);
            return righe;
        }

        private System.Text.StringBuilder GetHtmlCode(bool newStyle)
        {
            if (newStyle == false)
            {
                return GetHtmlCode();
            }

            System.Text.StringBuilder righe = new System.Text.StringBuilder();

            string tmp = $@"

            <div class=""header-btn-lg pr-0"">
						<div class=""widget-content p-0"">
							<div class=""widget-content-wrapper"">
								<div class=""widget-content-left"">
									<div class=""btn-group"">
										<a data-toggle=""dropdown"" aria-haspopup=""true"" aria-expanded=""false"" class=""p-0 btn"">
											<img width=""42"" src=""assets/images/avatars/8.jpg"" alt="""">
											<i class=""fa fa-angle-down ms-2 opacity-8""></i>
										</a>
										<div tabindex=""-1"" role=""menu"" aria-hidden=""true"" class=""rm-pointers dropdown-menu-lg dropdown-menu dropdown-menu-right"">
											<div class=""dropdown-menu-header"">
												<div class=""dropdown-menu-header-inner bg-danger"">
													<div class=""menu-header-image opacity-2"" style=""background-image: url('assets/images/dropdown-header/city3.jpg');""></div>
													<div class=""menu-header-content text-left"">
														<div class=""widget-content p-0"">
															<div class=""widget-content-wrapper"">
																<div class=""widget-content-left me-3"">
																	<img width=""42"" class=""rounded-circle""
																		 src=""assets/images/avatars/8.jpg""
																		 alt="""">
																</div>
																<div class=""widget-content-left"">
																	<div class=""widget-heading li_main_top_element_UserName"">{_session["UserName"]}
																	</div>
																</div>
																<div class=""widget-content-right me-2 li_main_top_element_logout last"">
																	<a href=""/logoutTemp.asp"" onclick=""logout();"" class=""link_logout btn-pill btn-shadow btn-shine btn btn-light""><strong>Logout</strong></a>
																</div>
															</div>
														</div>
													</div>
												</div>
											</div>
											<div class=""scroll-area-xs"" style=""height: 150px;"">
												<div class=""scrollbar-container ps"">
													<div id=""main_top_toolbar"">
														<ul class=""nav flex-column"" >
															<li class=""nav-item-header nav-item"">Attività:
															</li>
															<li class=""nav-item"">
																<a id=""TOOLBAR_HOMELIGHT_CambioPassword"" class=""button_link nav-link""  onclick=""Javascript:try{{ CloseAllSub( 'TOOLBAR_HOMELIGHT' ); }}catch(e){{}};NewDocumentAndReset( 'CHANGE_PWD');return false;""  href=""#"" title=""Cambio Password#200"">Cambio Password</a>
															</li>
															<li class=""nav-item"">
																<a id=""TOOLBAR_HOMELIGHT_Anagrafica"" class=""button_link nav-link""  onclick=""Javascript:try{{ CloseAllSub( 'TOOLBAR_HOMELIGHT' ); }}catch(e){{}};ShowDocumentAndReset( 'SCHEDA_ANAGRAFICA','&lt;ID_AZI&gt;');return false;""  href=""#"" title=""Anagrafica"">Anagrafica</a>
															</li>
															<li class=""last nav-item"">
															<a id=""TOOLBAR_HOMELIGHT_Utente"" class=""button_link nav-link""  onclick=""Javascript:try{{ CloseAllSub( 'TOOLBAR_HOMELIGHT' ); }}catch(e){{}};ShowDocumentAndReset( 'USER_DOC_READONLY','&lt;ID_USER&gt;');return false;""  href=""#"" title=""Utente"">Utente</a></li>
														</ul>
														<script type=""text/javascript"">
														var TOOLBAR_HOMELIGHT_subMenu = new Array( 0 );
														var TOOLBAR_HOMELIGHT_subMenuNum = 0;
														var TOOLBAR_HOMELIGHT_OnMenu='';
														var TOOLBAR_HOMELIGHT_OnSubMenu='';
														var TOOLBAR_HOMELIGHT_TraceMenu='';
														</script>
													</div>
												</div>
											</div>
											
											
											
										</div>
									</div>
								</div>
								<div class=""widget-content-left  ms-3 header-user-info"">
									<div class=""widget-heading li_main_top_element_Title pb-1"">
										{_session["NOMEPORTALE"]}
									</div>
									<div class=""widget-subheading li_main_top_element_UserName pb-1"">
										<strong>Utente: </strong>{_session["UserName"]}
									</div>
									<div class=""widget-subheading li_main_top_element_RagSociale"">
										<strong>Azienda: </strong>{_session["RagSociale"]}
									</div>
								</div>
							</div>
						</div>
					</div>
			";
            righe.Append(tmp);
            return righe;
        }
    }
}

