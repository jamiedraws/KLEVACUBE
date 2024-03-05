<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>

<%
    var isMobileEnabled = DtmContext.IsMobile && Dtm.Framework.ClientSites.SettingsManager.ContextSettings["Stripe.EnableMobile", true];
    var isDesktopEnabled = !DtmContext.IsMobile && Dtm.Framework.ClientSites.SettingsManager.ContextSettings["Stripe.EnableDesktop", true];
    var publishableKey = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["Stripe.PublishableKey"];
    var isEnabled = isMobileEnabled || isDesktopEnabled;
%>

<%
    if (string.Equals(DtmContext.PageCode, "CheckoutForm", StringComparison.InvariantCultureIgnoreCase) || string.Equals(DtmContext.PageCode, "ProcessPayment", StringComparison.InvariantCultureIgnoreCase))
    {
        if (isEnabled && !string.IsNullOrEmpty(publishableKey)
                                && ((DtmContext.Page != null && DtmContext.Page.IsStartPageType) || DtmContext.Order.OrderStatusId != 3))
        {
            //if true will collect name/address info and pass as tokendata
            var passTokenData = Dtm.Framework.ClientSites.SettingsManager.ContextSettings["Stripe.PassTokenData", false];
%>
<script src="https://js.stripe.com/v3/"></script>
<script type="text/javascript" src="/Shared/js/ExpressCheckout.js?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>"></script>
<script>

    if (typeof (DtmShoppingCart) == "undefined") {
        function getItems(items) {
            var uniqueItems = new Array();
            $("[name*='ActionQuantity']").each(function (index, item) {
                var id;
                var itemIndex = (item.getAttribute('data-index') ? item.getAttribute('data-index') : (item.id || '').replace('ActionQuantity', ''));
                if ($('[name="ActionCode' + itemIndex + '"]').length == 0 || 'radio,checkbox'.indexOf($('[name="ActionCode' + itemIndex + '"]').attr('type')) >= 0) {
                    if ($('[name="ActionCode' + itemIndex + '"][data-upgrade]').length != 0) {
                        id = $('[name="ActionCode' + itemIndex + '"]').val();
                    } else {
                        id = $('[name="ActionCode' + itemIndex + '"]:checked').val();
                    }
                } else {
                    id = $('[name="ActionCode' + itemIndex + '"]').val();
                }
                if (id != null && id != '' && id != 'none') {
                    var qty = $(item).val();
                    var atr;
                    if ($('[name="ActionAttribute' + itemIndex + '"]').length == 0 || 'radio,checkbox'.indexOf($('[name="ActionAttribute' + itemIndex + '"]').attr('type')) >= 0) {
                        if ($('[name="ActionAttribute' + itemIndex + '"]').length == 1) {
                            atr = $('[name="ActionAttribute' + itemIndex + '"]:checked').val();
                        } else {
                            var allValues = new Array();
                            $.each($('[name="ActionAttribute' + itemIndex + '"]:checked'), function () {
                                allValues.push($(this).val());
                            });
                            atr = allValues.join(',');
                        }
                    } else {
                        if ($('[name="ActionAttribute' + itemIndex + '"]').length == 1) {
                            atr = $('[name="ActionAttribute' + itemIndex + '"]').val();
                        } else {
                            var allValues = new Array();
                            $.each($('[name="ActionAttribute' + itemIndex + '"]'), function () {
                                allValues.push($(this).val());
                            });
                            atr = allValues.join(',');
                        }
                    }
                    if (uniqueItems[id]) {
                        for (var ui = 0; ui < uniqueItems.length; ui++) {
                            var uitem = uniqueItems[ui];
                            if (uitem.id == id) {
                                uitem.qty += parseInt(qty);
                                break;
                            }
                        }
                    } else {
                        uniqueItems[id] = true;
                        uniqueItems[uniqueItems.length] = { id: id, qty: parseInt(qty), atr: atr };
                    }

                    if ($('[name="MatchProductQuantity' + itemIndex + '"]').length == 0 || 'radio,checkbox'.indexOf($('[name="MatchProductQuantity' + itemIndex + '"]').attr('type')) >= 0) {
                        var match = $('[name="MatchProductQuantity' + itemIndex + '"]:checked').val();
                    } else {
                        var match = $('[name="MatchProductQuantity' + itemIndex + '"]').val();
                    }
                    if (typeof match != "undefined" && match.length > 0) {
                        if (uniqueItems[match]) {
                            for (var ui = 0; ui < uniqueItems.length; ui++) {
                                var uitem = uniqueItems[ui];
                                if (uitem.id == match) {
                                    uitem.qty += parseInt(qty);
                                    break;
                                }
                            }
                        } else {
                            uniqueItems[match] = true;
                            uniqueItems[uniqueItems.length] = { id: match, qty: parseInt(qty), atr: atr };
                        }
                    }
                } else {
                    console.log('id was blank, skipping.')
                }
            });
            return uniqueItems;
        }

        var DtmShoppingCart = function () {
            var _firstRun;
            var self = this;
            self.scrollToTopPosition = parseFloat("<%= Dtm.Framework.ClientSites.SettingsManager.ContextSettings["OrderFormReview.ScrollToPosition", "-200"] %>");

            self.CurrentErrors = [];

            self.Count = function () {
                return self.Items().length;
            }

            self.Items = function () {
                return getItems();
            };

            self.SearchItems = function (pattern) {
                var items = getItems();
                var results = [];

                results["TotalQuantity"] = 0;

                for (var i = 0; i < items.length; i++) {
                    var item = items[i];
                    if (new RegExp(pattern).test(item.id)) {
                        results[results.length] = item;
                        results[item.id] = item;
                        results["TotalQuantity"] += item.qty;
                    }
                }
                return results;
            };

            self.SetItems = function (items) {
                setItems(items);
            }

            self.AddErrors = function (errorsArray) {
                var allErrors = self.CurrentErrors.concat(errorsArray);

                var uniqueErrors = [];
                for (var i = 0, l = allErrors.length; i < l; i++) {
                    if (uniqueErrors.indexOf(allErrors[i]) === -1) {
                        uniqueErrors.push(allErrors[i]);
                    }
                }
                self.DisplayErrors(uniqueErrors, true);
                self.ScrollToErrors();
            };

            self.RemoveErrors = function (errorsArray) {
                var currentErrors = self.CurrentErrors;

                var uniqueErrors = [];
                for (var i = 0, l = currentErrors.length; i < l; i++) {
                    var currentError = currentErrors[i];
                    var alreadyExists = false;
                    for (var j = 0; j < errorsArray.length; j++) {
                        var toRemoveError = errorsArray[j];

                        if (currentErrors.indexOf(toRemoveError) > -1 && currentError == toRemoveError) {
                            alreadyExists = true;
                        }
                    }

                    if (uniqueErrors.indexOf(currentError) === -1 && !alreadyExists) {
                        uniqueErrors.push(currentError);
                    }
                }
                self.DisplayErrors(uniqueErrors, true);
            };

            self.ScrollToErrors = function (customElement) {
                if (self.CurrentErrors.length > 0) {
                    var ele = getErrorElement();
                    $.scrollTo(ele, { top: self.scrollToTopPosition });
                } else if (customElement) {
                    $.scrollTo(customElement, { top: self.scrollToTopPosition });
                }
            };

            function getErrorElement() {
                var ele = $('form').find('span[style="color: #FF0000; font-weight: bold"]');

                if (ele.length == 0 && $('.vse').length > 0) {
                    ele = $('.vse');
                }
                return ele;
            }

            self.UpgradeItem = function (currentCode, newCode) {
                var items = self.Items();

                for (var i = 0; i < items.length; i++) {
                    var item = items[i];
                    if (item.id == currentCode) {
                        item.id = newCode;
                        break;
                    }
                }

                self.SetItems(items);
            };

            self.DisplayErrors = function (errorsArray, show) {
                if (errorsArray && errorsArray.length > 0) {
                    var ele = getErrorElement();

                    if (_firstRun) {
                        if (ele.children().length) {
                            $.each(ele.find('li'), function (index, item) {
                                errorsArray.push($(item).text());
                            });
                        }
                    }

                    var html = '<div class="validation-summary-errors"><span><%=Dtm.Framework.ClientSites.SettingsManager.ContextSettings["OrderFormReview.ErrorMessageText", "The following errors have occured:"]%></span>' +
                        '<ul>';
                    for (var i = 0; i < errorsArray.length; i++) {
                        if (html.indexOf(errorsArray[i]) < 0) {
                            html += '<li>' + errorsArray[i] + '</li>';
                        }
                    }
                    html += '</ul></div>';
                    self.CurrentErrors = errorsArray;

                    if (!_firstRun || show) {
                        ele.html(html);
                        self.ScrollToErrors();
                    } else {
                        _firstRun = false;
                    }

                } else if (!_firstRun || show) {
                    var ele = getErrorElement();
                    ele.html('');
                    self.CurrentErrors = [];
                }
            };
        };
        var _dtmShoppingCart = new DtmShoppingCart();
    }

    var StripeEngine = function () {
        var self = this;
        var hasToken = false;
        var isRunning = false;
        var tokenData = {};
        var stripeForm;

        //Stripe Js Elements 
        var stripe = Stripe('<%=publishableKey%>');
        var elements = stripe.elements();
        var card = elements.create('cardNumber', { placeholder: "<%=LabelsManager.Labels["StripeCardNumberPlaceholder", "#### #### #### ####"]%>" });
        var exp = elements.create('cardExpiry', { placeholder: "<%=LabelsManager.Labels["StripeCardExpirationDatePlaceholder", "MM/YY"]%>" });
        var cvc = elements.create('cardCvc', { placeholder: "<%=LabelsManager.Labels["StripeCardCVCPlaceholder", "###"]%>" });

        //Error Messages
        var selectProductErr = "<%=LabelsManager.Labels["StripeSelectProductErrorMsg", "Please select a product!"]%>"
        var createTokenDataErr = "<%=LabelsManager.Labels["StripeCreateTokenDataErr", "Please enter all Billing Information"]%>"
        var createTokenErr = "<%=LabelsManager.Labels["StripeCreateTokenErr", "There was a problem processing your card. Please make sure all card information is correct"]%>"

        //DTM Form elements
        var submitButton = $('#AcceptOfferButton').length == 0 ? $('[name=acceptOffer]') : $('#AcceptOfferButton');
        var form = submitButton.closest('form');
        var shoppingCart = typeof (_dtmShoppingCart) != "object" ? null : _dtmShoppingCart;

        var formPrepend = function (name, value) {
            if ($('#' + name).length > 0) {
                $('#' + name).val(value);
            } else {
                form.prepend('<input type="hidden" id="' + name + '" name="' + name + '" value="' + value + '" />');
            }
        };

        var createTokenData = function () {
            var fullname = $("#BillingFullName").length > 0 ? $("#BillingFullName").val() : $("#BillingFirstName").val() + " " + $("#BillingLastName").val();
            tokenData = {
                name: fullname,
                address_line1: $("#BillingStreet").val(),
                address_line2: $("#BillingStreet2").val(),
                address_city: $("#BillingCity").val(),
                address_state: $("#BillingState").val(),
                address_zip: $("#BillingZip").val(),
                address_country: $("#BillingCountry").val()
            }

            for (var prop in tokenData) {
                if (tokenData[prop].trim() == "") {
                    return false;
                }
            }

            return true;
        };

        var createPayToken = function () {
            if (hasToken) {
                isRunning = false;
                submitButton.trigger("click");
                return;
            }

            if ($("#Email").val().indexOf("digitaltargetmarketing.com") > -1) {
                $(".vse").html('')
                shoppingCart.CurrentErrors = [];


                formPrepend("Token", "tok_Test000");
                hasToken = true;
                isRunning = false;

                submitButton.trigger("click");
                return;
            }


            <%if (passTokenData)
    {%>
            stripe.createToken(card, tokenData).then(function (result) {
                handlePayTokenRecieved(result.token);
            });
            <%}
    else
    {%>
            stripe.createToken(card).then(function (result) {
                handlePayTokenRecieved(result);
            });
            <%}%>
        };

        var handlePayTokenRecieved = function (result) {
            console.log(result);
            var token = result.token;
            $(".vse").html('')
            shoppingCart.CurrentErrors = [];
            if (result.error || typeof (token) == "undefined" || typeof (token.id) == "undefined") {
                var message = typeof (result.error.message) != "undefined" && result.error.message != "" ? result.error.message : createTokenErr;
                shoppingCart.AddErrors([message]);
                $.post('/shared/services/pixelservice.ashx?at=error', { 'message': result.error, 'json': JSON.stringify(result) });
                isRunning = false;
                return false;
            }

            formPrepend("Token", token.id);
            hasToken = true;
            isRunning = false;

            submitButton.trigger("click");
        }



        var onSubmit = function (e) {
            e.preventDefault();
            formPrepend('PaymentType', 'Card');
            if (isRunning) {
                console.log("tokenizer already running..");
                return false;
            }

            isRunning = true;

<% if (DtmContext.Page != null && DtmContext.Page.IsStartPageType)
    { %>

            if (shoppingCart != null) {
                if (shoppingCart.Count() > 0) {
                    shoppingCart.RemoveErrors([selectProductErr]);
                } else {
                    shoppingCart.AddErrors([selectProductErr]);
                    isRunning = false;
                    return false;
                }
            }
<% }
    if (passTokenData)
    {%>
            var hasData = createTokenData();
            <%}%>

            if (typeof (hasData) != "undefined" && !hasData) {
                shoppingCart.AddErrors([createTokenDataErr]);
                isRunning = false;
                return false;
            }

            createPayToken();
        };

        self.init = function () {
            submitButton.removeClass('AcceptOfferButton');
            var isVisible = submitButton.is(':visible');
            var stripeSubmitButton = submitButton.clone()
                .attr('id', 'stripeSubmit')
                .attr('name', 'stripeSubmit')
                .addClass('AcceptOfferButton');
            submitButton.after(stripeSubmitButton);

            submitButton.empty();
            if (isVisible) {
                submitButton.hide();
                stripeSubmitButton.show();
            }

            registerEvent("OrderFormShownOnMobile", function () {
                var submitButton = $('#AcceptOfferButton').length == 0 ? $('[name=acceptOffer]') : $('#AcceptOfferButton');
                var isVisible = submitButton.is(':visible');
                var stripeSubmitButton = $('#stripeSubmit');
                if (isVisible && stripeSubmitButton.length > 0) {
                    submitButton.hide();
                    stripeSubmitButton.show();
                }
            });

            /* directly target the card number field and replace with the stripe version */
            $('#CardNumber').replaceWith('<div id="CardNumberHostedField" class="stripeHostedField"></div>');
            /* directly target the cvv2 field and replace with the stripe version */
            $('#CardCvv2').replaceWith('<div id="CardCvv2HostedField" class="stripeHostedField"></div>');
            /* directly target the card expiration field and replace with the stripe version */
            $('#CardExpirationMonth').replaceWith('<div id="CardExpirationHostedField" class="stripeHostedField"></div>');
            /* since stripe supports exp. date as input data instead of drop down, just remove this drop down */
            $('#CardExpirationYear').remove();

            card.mount("#CardNumberHostedField");
            exp.mount("#CardExpirationHostedField");
            cvc.mount("#CardCvv2HostedField");

            stripeForm = $(stripeSubmitButton).closest('form');

            if ($(stripeForm) != null && $(stripeForm).length > 0) {
                $(stripeForm).keypress(function (e) {
                    if (e.keyCode == 13) {
                        $(stripeSubmitButton).click();
                        return false;
                    }
                });
            }

            stripeSubmitButton.bind("click", onSubmit);

            if ($('#otCARD').length > 0) {
                $('#otCARD').val('card,stripe');
            } else if ($('#OrderType').length > 0 && $('#OrderType').attr('type') == 'hidden') {
                $('#OrderType').val('card,stripe');
            } else {
                formPrepend('OrderType', 'card,stripe');
            }

        };

    };

    var _stripeEngine = new StripeEngine();

    $(document).ready(function () {
        try {
            _stripeEngine.init();
            _expressCheckoutEngine.initialize();

        } catch (error) {
            console.log(error);
            $.post('/shared/services/pixelservice.ashx?at=error', { 'message': error });
        }
    });

    // if fwjs is supported, let's add our template styles to each form field so they're consistent with the other fields
    $('html').on('dtm/fwjs', function (get) {
        var $stripe = $('.stripeHostedField');

        $stripe
            .addClass(get.dtm.css.config.input.css + ' u-vw--100')
            .each(function () {
                // get each field
                var $this = $(this);
                // look for it's layout relationship on the page and maintain its structural integrity
                $this.siblings().css('display') === 'table-cell' ? $this.addClass('o-grid__col') : $this.addClass('o-grid--block');
            });
    });
</script>

<%
        }
    }
%>