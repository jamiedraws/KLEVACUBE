<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>
<%var isMobileEnabled = DtmContext.IsMobile && Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableMobile", false];
    var isDesktopEnabled = !DtmContext.IsMobile && Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableDesktop", false];
    var isEnabled = isMobileEnabled || isDesktopEnabled;
    var isAutoGenerate = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableAutoGenerate", false];
    var domainId = DtmContext.DomainId;
    var url = HttpContext.Current.Request.Url.ToString().ToLower();
    var isTestMode = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableTestMode", false];
    var isLiveMode = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.IsLive", false];
    var paypalMode = isTestMode && !isLiveMode ? "sandbox" : "production";
    var commitStatus = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.CommitStatus", false];
    var showOnProcessPayment = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.ShowOnProcessPayment", false];
    var isProcessPayment = DtmContext.PageCode.ToLower() == "processpayment";
    var excludedPageCodes = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.ExcludePageCodes", string.Empty];
    var excludedPages = string.IsNullOrWhiteSpace(excludedPageCodes) ? new List<string>() : excludedPageCodes.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
    var paymentType = (ViewData["PaymentType"] as string) ?? "PayPalEC";
    var domainsToExcludeSetting = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.ExcludeDomains", string.Empty];
    var domainsToExclude = domainsToExcludeSetting.Length == 0 ? new List<Guid>() : domainsToExcludeSetting.Split(',').ToList().Select(Guid.Parse).ToList();
    var domainsToIncludeSetting = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.IncludeDomains", string.Empty];
    var domainsToInclude = domainsToIncludeSetting.Length == 0 ? new List<Guid>() : domainsToIncludeSetting.Split(',').ToList().Select(Guid.Parse).ToList();

%>

<% 
    if (string.Equals(DtmContext.PageCode, "CheckoutForm", StringComparison.InvariantCultureIgnoreCase) || isProcessPayment)
    {
        if (domainsToInclude.Contains(domainId) || domainsToInclude.Count == 0 || DtmContext.IsStage)
        {%>

<%if (isAutoGenerate && isEnabled && ((isAutoGenerate && isEnabled) && (!isTestMode || (isTestMode && (url.Contains("dtmstage") || url.Contains("localhost"))))))
    { %>
<%if ((DtmContext.Page != null && (DtmContext.Page.IsStartPageType || showOnProcessPayment && isProcessPayment))
            && (!excludedPages.Any(p => string.Equals(p, DtmContext.PageCode, StringComparison.InvariantCultureIgnoreCase))))
    {
        var imageUpUrl = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.AcceptOfferButtonUpImageUrl"];
        var imageDownUrl = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.AcceptOfferButtonDownImageUrl"];
        var isImageOverrideEnabled = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableAcceptOfferButtonImageOverride", false];
        var radioButtonImageUrl = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.RadioButtonImageUrl"];
        var radioButtonHelpUrl = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.RadioButtonHelpUrl"];
        var enableIncontextCheckout = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableIncontextCheckout", false];
        var enablePayPalCreditButton = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnablePayPalCreditButton", false];
        var disableIfMultiPay = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.DisableIfMultipay", false] && !Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.EnableBillingAgreement", false];
        var disableMessage = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.DisabledMessage", "NOTE: PayPal not available for multipay option."];
        var paypalECDisclaimerText = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["PayPalEC.DisclaimerText", string.Empty];

%>
<link rel="stylesheet" href="/Shared/css/expresscheckout/expresscheckout.css?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>">
<style>
    .dtm .checkout-option .grayed {
        opacity: 0.3;
    }
</style>
<script type="text/javascript" src="/Shared/js/ExpressCheckout.js?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>"></script>
<script type="text/javascript">

    _expressCheckoutEngine.Register('<%=paymentType%>', 1, '<%=radioButtonImageUrl%>',
        '<%=imageUpUrl%>?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>', '<%=imageDownUrl%>?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>', '<%=imageUpUrl%>?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>', '<%=radioButtonHelpUrl%>');
    var $paymentType = $("#PaymentType");
    $(document).ready(function () {
        _expressCheckoutEngine.initialize();
    });

    registerEvent('_dtmExpressCheckoutPaymentClick', function (data) {
        if (data.detail.paymentType.match(/PayPal/i)) {

            var hasDisclaimer = typeof $('#disclaimer') != "undefined" && $('#disclaimer').length > 0;

            if ($paymentType.length === 0) { $paymentType = $("#PaymentType"); }

            <% if (string.Equals(paymentType, "PayPalEC", StringComparison.InvariantCultureIgnoreCase))
    {%>
            if ($paymentType.length > 0) {
                $paymentType.val("paypal");
            }
             <%}
    else
    {%>
            if ($paymentType.length > 0) {
                $paymentType.val("<%=paymentType%>");
            }
             <%} %>

            if (hasDisclaimer) {
                setTimeout(function () {
                    $.scrollTo('#disclaimer');
                }, 100);
            }
        }
    });

    <% if (disableIfMultiPay)
    {%>

    $(document).ready(function () {
        $('<p class="no-margin top-padding paypal__note" style="display:none;"><span style="color:red; font-weight: bold;"><%=disableMessage%></span></p>').insertAfter('#divPayPalEC label');
    });

    registerEvent("CartChange", function (data) {
        disablePayPalForMultiPay(data.detail.hasMultipay);
    });

    registerEvent("OfferChange", function (data) {
        disablePayPalForMultiPay(data.detail.hasMultipay);
    });

    $(document).ready(function () {
        if (typeof (handleCartChange) !== 'function') {
            $("[name*='ActionCode']").on("change", function () {
                let mulitpayAttr = $(this).attr("multipay");
                disablePayPalForMultiPay(mulitpayAttr);
            });
        }
    });

    function disablePayPalForMultiPay(hasMultipay) {
        let payPalRadio = $("#otPayPalEC");
        let payPalNote = $(".paypal__note");
        let cardRadio = $("#otCARD");
        let disabledProp = "disabled";
        let checkedProp = "checked";
        let inactiveClass = "grayed";

        if (hasMultipay) {
            payPalRadio.prop(disabledProp, true);
            payPalRadio.prop(checkedProp, false);
            payPalRadio.parent().addClass(inactiveClass);
            payPalNote.show();
            if (cardRadio.length > 0) {
                cardRadio.click();
            }
        } else {
            payPalRadio.prop(disabledProp, false);
            payPalRadio.parent().removeClass(inactiveClass);
            payPalNote.hide();
        }
    }
    <%}%>
</script>

<%if (enableIncontextCheckout)
    { %>
<style>
    #paypal-button,
    .zoid-outlet,
    .zoid-component-frame {
        width: 300px !important;
        margin: 0 auto;
    }
</style>
<script>

    addEventListener("DOMContentLoaded", function () {

        let paypalScript = document.createElement('script');
        paypalScript.type = 'text/javascript';
        paypalScript.src = "https://www.paypalobjects.com/api/checkout.js?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>";
        paypalScript.defer = true;
        // insert framework js into the DOM
        document.getElementsByTagName("body")[0].appendChild(paypalScript);

        let serializeScript = document.createElement('script');
        serializeScript.type = 'text/javascript';
        serializeScript.src = "/Shared/js/jquery.serialize.js?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>";
        serializeScript.defer = true;
        // insert framework js into the DOM
        document.getElementsByTagName("body")[0].appendChild(serializeScript);

    });
    let paypalECAuthorized = false;
    registerEvent('PaymentOptionSelected', function (data) {
        var acceptOffer = $('#AcceptOfferButton').length > 0 ? $('#AcceptOfferButton') : $('.AcceptOfferButton');
        if (/paypal/i.test(data.detail || '')) {
            if ($('#paypal-button').length == 0) {

                acceptOffer.after('<div id="paypal-button"></div>');
                paypal.Button.render({
                    env: '<%=paypalMode%>',
                    <%if (enablePayPalCreditButton)
    {%>
                    funding: {
                        allowed: [paypal.FUNDING.CREDIT],
                        disallowed: [paypal.FUNDING.CARD]
                    },
                    style: {
                        layout: 'vertical'
                    },
                    <%}%>
                    <%if (commitStatus)
    {%>
                    commit: true,
                    <%}%>
                    payment: function (resolve) {
                        var valid = true;

                        if (typeof (customPaypalValidation) === 'function') {
                            valid = customPaypalValidation();
                        }
                        if (valid && !paypalECAuthorized) {
                            var payload = $('form').serializeJSON();
                            payload["RemoteType"] = payload["OrderType"];

                            <%if (showOnProcessPayment)
    {%>
                            payload["acceptOffer"] = "true";

                            <%}%>
                            $.post('<%=Request.Url.PathAndQuery%>', payload, function (data) {
                                if (data.errors && data.errors.length > 0) {
                                    if (typeof _dtmShoppingCart != 'undefined') {
                                        _dtmShoppingCart.RemoveErrors(_dtmShoppingCart.CurrentErrors);
                                        _dtmShoppingCart.AddErrors(data.errors);
                                    } else {
                                        alert(data.errors.join());
                                    }
                                    resolve(null);

                                } else {
                                    resolve(data.details.token);
                                }
                            })
                                .error(function () {
                                    resolve(null);
                                });
                        } else {
                            resolve(null);
                        }
                    },
                    onAuthorize: function (data, actions) {
                        paypalECAuthorized = true;
                        $.facebox('<h1>' + (typeof (__processingMessage) == "undefined" ? "Processing Order . . ." : __processingMessage) + '</h1>');
                        return actions.redirect();
                    },
                    onCancel: function (data, actions) {
                        return actions.redirect();
                    },
                    onError: function (err) {
                        if (err && err.message.indexOf('Cannot read property \'indexOf\' of null') > -1) {
                            console.log("handled null token error.");
                        } else {
                            console.log(err);
                        }
                        paypal.checkout.closeFlow();
                    }
                }, '#paypal-button');
                $('#paypal-button').show();
                <% if (!string.IsNullOrWhiteSpace(paypalECDisclaimerText))
    { %>
                $('<p class="no-margin top-padding paypal__note fn--center" id="paypalEC-disclaimer"><span style="font-weight: bold;"><%=paypalECDisclaimerText%></span></p>').insertAfter('#paypal-button');
                <% } %>
                acceptOffer.hide();
            } else {
                $('#paypal-button').show();
                $('#paypalEC-disclaimer').show();
                acceptOffer.hide();
            }
        } else {
            $('#paypal-button').hide();
            $('#paypalEC-disclaimer').hide();
        }
    });

    <%if (showOnProcessPayment)
    {%>
    if (typeof _dtm.expressCheckout === "function") {

        $(window).on('load', function (e) {
            $('#paymentFormHeadline').text('CHOOSE YOUR PAYMENT METHOD');
            <%if (enableIncontextCheckout)
    { %>
            _dtm.expressCheckout({ addPayPalButton: false });
            <%}
    else
    {%>

            _dtm.expressCheckout();
    <%}%>
        });
    }
    <%}%>
</script>

<%}
    else
    { %>

<% if (!string.IsNullOrWhiteSpace(paypalECDisclaimerText))
    { %>
<script>
    $('<p class="no-margin top-padding paypal__note fn--center" id="paypalEC-disclaimer"><span style="font-weight: bold;"><%=paypalECDisclaimerText%></span></p>').insertAfter('#processOrderText');
    $("#paypalEC-disclaimer").hide();

    $(document).on('ready', function () {
        $('input[name="OrderType"]').on('change', function () {

            if (this.value == "PayPalEC") {
                $("#paypalEC-disclaimer").show();
            } else {
                $("#paypalEC-disclaimer").hide();
            }

        });
    });
</script>
<% } %>

<% } %>

<% 
                }
            }
        }
    }
%>