<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ClientSiteViewData>" %>
<%@ Import Namespace="Dtm.Framework.ClientSites" %>

<footer aria-label="Copyright and Policies" class="view footer section @print-only-hide">
	<div id="footer" class="view__anchor"></div>
	<div class="view__in section__in">
	<% 
		Html.RenderPartial("SitemapList");
	%>
	</div>
</footer>

<svg hidden>
	<symbol id="icon-chevron" x="0px" y="0px" viewBox="0 0 25.228 14.029">
		<g transform="translate(1.414 1.414)">
			<path d="M0,11.2,11.2,0m0,22.4L0,11.2" transform="translate(0 11.2) rotate(-90)" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
		</g>
	</symbol>
	<symbol id="icon-arrow" x="0px" y="0px" viewBox="0 0 32 24.1">
		<path d="M20,24.1L17.9,22l8.4-8.4H0v-3h26.2l-8.4-8.4L20,0l12,12.1L20,24.1z" />
	</symbol>
</svg>

<% var language = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["Language.LanguageType", "English"]; %>

<% if (DtmContext.Page.IsStartPageType) { %>
	<script src="/shared/js/jquery.min.js?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>"></script>
	<script src="/shared/js/common.js?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>&language=<%=language %>&cb=1"></script>

        <script>

            // store og alert method
            window.nativeAlert = window.alert;
            var _dtm = {};
            // set vse alert method
            _dtm.alert = function (data, target, cb) {
                // set callback function
                var cb = cb || function () { };
                // set fragment
                var frag = document.createDocumentFragment();
                // set validation summary error container
                var vse = document.createElement('div');
                // add classes to vse
                vse.className = 'validation-summary-errors o-box--msg-error';

                // set unordered list
                var ul = document.createElement('ul');
                // convert string into array based on line breaks
                var a = data.split('\n');

                // iterate each item
                for (var i = 0; i < a.length; i++) {
                    // check if item is blank
                    if (a[i] === '') {
                        // remove it from array
                        a.splice(i, 1);
                    } else {
                        // create html tags
                        var node = i === 0 ? document.createElement('span') : document.createElement('li');
                        // replace tabs
                        node.innerHTML = a[i].replace(/\t/g, '');
                        // check if item is required field
                        if (i !== 0) {
                            // add node to the ul
                            ul.appendChild(node);
                            // otherwise,
                        } else {
                            // add node to the fragment
                            vse.appendChild(node);
                        }
                    }
                }
                // add unordered list to the fragment
                vse.appendChild(ul);
                frag.appendChild(vse);

                // set array for potential error targets
                var e_target = target || [
                    $('#vse'),
                    $('form').find('span[style="color: #FF0000; font-weight: bold"]'),
                    $('form').find('span[style="color: rgb(255, 0, 0); font-weight: bold;"]'),
                    $('.vse')
                ];

                // check if error target is an array
                if ($.isArray(e_target)) {
                    // set error counter
                    var e_count = 0;

                    // cycle each target
                    $.each(e_target, function (index, value) {
                        // check if element exists
                        if (value.length > 0) {
                            // insert frag into element
                            value.html(vse);
                            e_target = value;
                        } else {
                            // otherwise, add this to error counter
                            e_count++;
                        }
                    });

                    // check if array length matches number of errors - means basically none of the above options exist
                    if (e_target.length === e_count) {
                        // prepend the frag to the form
                        $('form').prepend(frag);
                    }
                } else {
                    // insert the frag into custom target
                    e_target.html(frag);
                }

                // check if scroll override exists
                //if (e_target.data('vse-scroll') === undefined) {
                    // scroll to vse
                    $.scrollTo('.validation-summary-errors');
                //}

                $('[data-vse-button]').removeClass('hide');

                //Saving error message to pixelService
                var errors = {};

                for (var i = 0; i < a.length; i++) {

                    var message = a[i].replace('\t', '');

                    errors["Error " + i] = message;

                }

                $.post('/shared/services/pixelservice.ashx?at=error', errors);

                if (typeof errorsObj !== "undefined") {
                    triggerEvent('handleErrorValidationMapping', errorsObj);
                }


                return cb(data, e_target);

            };

            // redefine new alert method
            window.alert = function (data) {
        <%
            string validationHeaders = HttpUtility.HtmlDecode("Please correct the following issues|Corrija los siguientes problemas|Veuillez corriger les probl&egrave;mes suivants");
        %>
        // check if returned data contains validation from common.js
                var validationHeaders = "<%= validationHeaders %>";
                var result = (data && typeof (data) == "string" && data.match(validationHeaders)) || '';

                switch (result.length > 0) {
                    case true:
                        _dtm.alert(data, null, function (data, target) {
                            try {
                                _dtm.callbackAlert(data, target);
                            } catch (e) {
                                console.log(e.message);
                            }
                        });
                        break;
                    case false:
                        window.nativeAlert(data);
                        break;
                }
            };

            // streamline custom validation with common.js
            _dtm.includeValidation = function (data, target) {
                var vse = $('.validation-summary-errors ul');
                if (vse.length !== 1) {
                    vse.prepend($('<li class="error_msg">' + data + '</li>'));
                } else {
                    target.fadeSlideDown();
                }
            };
</script>

	<% if (DtmContext.PageCode == "CheckoutForm") { %>
		<% Html.RenderSnippet("ORDERFORMSCRIPT"); %>
	<% } %>
<% } %>



<%= Model.FrameworkVersion %>

<div hidden>
  <% 
	  Html.RenderSiteControls(SiteControlLocation.ContentTop);
	  Html.RenderSiteControls(SiteControlLocation.ContentBottom);
	  Html.RenderSiteControls(SiteControlLocation.PageBottom);
  %>
</div>