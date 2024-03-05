<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<Dtm.Framework.Base.Models.BaseClientViewData>" %>
<%@ Import Namespace="Dtm.Framework.ClientSites" %>
<%@ Import Namespace="Dtm.Framework.Base.Models" %>
<%
    var mergeName = SettingsManager.ContextSettings["Form.EnableFullName", "true"].ToLower();
    var mergeAddress = SettingsManager.ContextSettings["Form.EnableFullStreet", "true"].ToLower();
    var isMobile = DtmContext.IsMobile.ToString().ToLower();
    var language = SettingsManager.ContextSettings["DTM.ClientSites.Order.Language", "English"];
    var allowedCards = SettingsManager.ContextSettings["DTM.ClientSites.Order.AllowedCardTypes", "Visa,Mastercard,Amex,Discover"];
    var alwaysShowCardTypes = (ViewData["AlwaysShowCardTypes"] as string ?? "true").ToLower();
    var enableTransformLabels = SettingsManager.ContextSettings["Form.EnableTransformLabels", "true"].ToLower();
    var movePayment = SettingsManager.ContextSettings["Form.EnableMovePaymentToBilling", "false"].ToLower();
    var enableServerMode = SettingsManager.ContextSettings["Form.EnableGooglePlacesServerMode", false];
    var serverModeDelay = SettingsManager.ContextSettings["Form.GooglePlacesServerModeDelay", 1000];
    var apiKey = SettingsManager.ContextSettings["Google.PlacesApiKey", "AIzaSyBhtEs33yVV7l4K9pcx-Aph1rdEdXkT0uQ"];

    var requiresInternationalText = Model.Countries.Count() == 1 && Model.Countries.Any(c => c.CountryCode == "CAN");
    var zipText = requiresInternationalText ? "Postal Code" : "Zip Code";
    var stateText = requiresInternationalText ? "Province" : "State";

    bool addTerritories = Model.Countries.Count() == 1 && Model.Countries.Any(c => c.CountryCode == "USA");

    var territories = !addTerritories? new List<StateView>() :  new List<StateView>()  { new StateView{ StateCode = "GU", StateName = "Guam", CountryCode = "USA" },
                                new StateView{ StateCode = "VI", StateName = "Virgin Islands", CountryCode = "USA" },
                            new StateView{ StateCode = "PR", StateName = "Puerto Rico", CountryCode = "USA" }};

    var addressAutocompleteProvider = SettingsManager.ContextSettings["Form.AddressAutoCompleteProvider", "Google"].ToLower();

%>
<link href="/Shared/css/jquery-ui.custom.min.css?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>" rel="stylesheet" />
<style>
    .ui-menu {
        border-radius: 0.5em;
        line-height: 1.25;
        padding: 0;
        overflow: hidden;
        color: #1C3144;
        font-size: 1.25rem;
        font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
        border-color: hsl(0, 0%, 80%);
        box-shadow: 0 0 1em hsla(0, 0%, 0%, 0.2);
    }

    .ui-menu .ui-menu-item {
        display: block;
        padding: 1em 0;
        margin: 0 1.25em;
        width: auto;
        box-sizing: border-box;
    }

    .ui-menu .ui-menu-address {
        position: relative;
        display: flex;
        align-items: flex-end;
        transition: transform .3s ease-in-out, opacity .3s ease-in-out;
    }

    .ui-menu-address {
        transform: translateX(2%);
        opacity: .69;
    }

    .ui-menu-droppin {
        width: 1em;
        height: 1em;
        margin-right: 0.5em;
        position: relative;
        align-self: center;
        transition: transform .3s ease-in-out;
        transform-origin: 35% 40%;
    }

    .ui-menu-droppin::before,
    .ui-menu-droppin::after {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        margin: auto;
        transition: transform .3s ease-in-out, opacity .3s ease-in-out;
    }

    .ui-menu-droppin::before {
        background: url(/shared/images/icons/drop-pin.svg) no-repeat;
    }

    .ui-menu-droppin::after {
        background: url(/shared/images/icons/drop-pin-color.svg) no-repeat;
        opacity: 0;
    }

    .ui-menu-item:hover .ui-menu-droppin,
    .ui-state-focus .ui-menu-droppin {
        transform: rotate(-90deg);
        align-self: flex-end;
    }

    .ui-menu-item:hover .ui-menu-address,
    .ui-state-focus .ui-menu-address {
        transform: translateX(0);
        opacity: 1;
    }

    .ui-menu-item:hover .ui-menu-droppin::before,
    .ui-state-focus .ui-menu-droppin::before,
    .ui-menu-droppin::after {
        opacity: 0;
        transform: scale(0);
    }

    .ui-menu-droppin::before,
    .ui-state-focus .ui-menu-droppin::after,
    .ui-menu-item:hover .ui-menu-droppin::after {
        opacity: 1;
        transform: scale(1);
    }

    .ui-menu .ui-menu-item:not(:last-child) {
        border-bottom: 0.1em solid #ccc;
    }

    .ui-menu .ui-menu-logo {
        margin: 0;
        display: flex;
        align-items: center;
        opacity: 1;
    }

    .ui-menu-address > strong {
        margin-right: 0.5em;
    }

    .ui-menu-address > small {
        color: gray;
    }

    .ui-menu-logo img {
        max-width: 120px;
        width: auto;
    }

    .ui-menu .ui-state-focus,
    .ui-menu .ui-state-hover {
        background: none;
        color: currentColor;
        border: none;
        font-weight: inherit;
        cursor: pointer;
    }
</style> 
<% if (!enableServerMode && addressAutocompleteProvider == "google")
    { %>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=places&key=<%=apiKey %>"></script>
<% } %>
<style>
    <% if ( !DtmContext.IsMobile ) { %>
    /* This allows Google suggestion box to expand fluidly and prevent cut-off text */
    .pac-container {
        width: auto !important;
    }
    <% } %>
</style>
<script> 
    if (typeof (AddressEngine) != "function") {
        var AddressEngine = function (config) {
            var self = this;

            self.IsInitial = true;
            self.labels = [];
            self.placeholders = [];
            self.countries = [];
            self.territories = [];
            self.alwaysShowCardTypes = true;
            self.config = config || {};
            self.allowSearch = false;
            self.disable = false;
            self.sessionId = '<%=Guid.NewGuid() %>';
            self.PlacesChoiceId = "";

                <%foreach (var territory in territories)
    {%>
            self.territories[self.territories.length] = {
                code: '<%=territory.StateCode%>',
                name: '<%=territory.StateName%>',
                twoDigit: '<%=territory.StateCode%>',
                threeDigit: ''
            };
                <%}%>

            <%foreach (var country in Model.Countries)
            {%>
            self.countries[self.countries.length] = {
                code: '<%=country.CountryCode%>',
                name: '<%=country.CountryName%>',
                twoDigit: '<%=country.TwoDigitCode%>',
                threeDigit: '<%=country.CountryCode%>'
            };
            <%}%>

            self.states = [];
            <%foreach (var state in Model.States)
    {%>
            self.states[self.states.length] = {
                code: '<%=state.StateCode%>',
                name: '<%=state.StateName%>',
                twoDigit: '<%=state.StateCode%>'
            };
            <%}%>

            var defaultLanguage = {
                type: 'English',
                CardNumberLabel: 'Card Number',
                CardNumberPlaceholder: '#### #### #### ####',
                CardExpirationLabel: 'Expiration Date',
                CardExpirationPlaceholder: 'MM/YYYY',
                CardCvv2Label: 'CVV2',
                CardCvv2Placeholder: '###',
                FullNameLabel: 'Full Name',
                FullNamePlaceholder: '*Full Name',
                FirstNameLabel: 'First Name',
                FirstNamePlaceholder: '*First Name',
                LastNameLabel: 'Last Name',
                LastNamePlaceholder: '*Last Name',
                FullStreetLabel: 'Address',
                FullStreetPlaceholder: '*Address',
                StreetLabel: 'Address',
                StreetPlaceholder: '*Address',
                Street2Label: 'Address 2',
                Street2Placeholder: 'Suite / Apt',
                CityLabel: 'City',
                CityPlaceholder: '*City',
                ZipLabel: '<%= zipText %>',
                ZipPlaceholder: '*<%= zipText %>',
                StateLabel: '<%= stateText %>',
                StatePlaceholder: '*<%= stateText %>',
                CountryLabel: 'Country',
                CountryPlaceholder: '*Country',
                PhoneLabel: 'Phone',
                PhonePlaceholder: '*Phone',
                EmailLabel: 'Email',
                EmailPlaceholder: '*Email'
            };
            var labels = [
                {
                    type: "<%=SettingsManager.ContextSettings["Form.UseLabelManager", false] ? "LM" : "" %>",
                    CardNumberLabel: '<%=LabelsManager.Labels["CardNumberLabel", ""]%>',
                    CardNumberPlaceholder: '<%=LabelsManager.Labels["CardNumberPlaceholder", ""]%>',
                    CardExpirationLabel: '<%=LabelsManager.Labels["CardExpirationLabel", ""]%>',
                    CardExpirationPlaceholder: '<%=LabelsManager.Labels["CardExpirationPlaceholder", ""]%>',
                    CardCvv2Label: '<%=LabelsManager.Labels["CardCvv2Label", ""]%>',
                    CardCvv2Placeholder: '<%=LabelsManager.Labels["CardCvv2Placeholder", ""]%>',
                    FullNameLabel: '<%=LabelsManager.Labels["FullNameLabel", ""]%>',
                    FullNamePlaceholder: '<%=LabelsManager.Labels["FullNamePlaceholder", ""]%>',
                    FirstNameLabel: '<%=LabelsManager.Labels["FirstNameLabel", ""]%>',
                    FirstNamePlaceholder: '<%=LabelsManager.Labels["FirstNamePlaceholder", ""]%>',
                    LastNameLabel: '<%=LabelsManager.Labels["LastNameLabel", ""]%>',
                    LastNamePlaceholder: '<%=LabelsManager.Labels["LastNamePlaceholder", ""]%>',
                    FullStreetLabel: '<%=LabelsManager.Labels["FullStreetLabel", ""]%>',
                    FullStreetPlaceholder: '<%=LabelsManager.Labels["FullStreetPlaceholder", ""]%>',
                    StreetLabel: '<%=LabelsManager.Labels["StreetLabel", ""]%>',
                    StreetPlaceholder: '<%=LabelsManager.Labels["StreetPlaceholder", ""]%>',
                    Street2Label: '<%=LabelsManager.Labels["Street2Label", ""]%>',
                    Street2Placeholder: '<%=LabelsManager.Labels["Street2Placeholder", ""]%>',
                    CityLabel: '<%=LabelsManager.Labels["CityLabel", ""]%>',
                    CityPlaceholder: '<%=LabelsManager.Labels["CityPlaceholder", ""]%>',
                    ZipLabel: '<%=LabelsManager.Labels["ZipLabel", ""]%>',
                    ZipPlaceholder: '<%=LabelsManager.Labels["ZipPlaceholder", ""]%>',
                    StateLabel: '<%=LabelsManager.Labels["StateLabel", ""]%>',
                    StatePlaceholder: '<%=LabelsManager.Labels["StatePlaceholder", ""]%>',
                    CountryLabel: '<%=LabelsManager.Labels["CountryLabel", ""]%>',
                    CountryPlaceholder: '<%=LabelsManager.Labels["CountryPlaceholder", ""]%>',
                    PhoneLabel: '<%=LabelsManager.Labels["PhoneLabel", ""]%>',
                    PhonePlaceholder: '<%=LabelsManager.Labels["PhonePlaceholder", ""]%>',
                    EmailLabel: '<%=LabelsManager.Labels["EmailLabel", ""]%>',
                    EmailPlaceholder: '<%=LabelsManager.Labels["EmailPlaceholder", ""]%>',
                },
                defaultLanguage,
                {
                    type: 'French',
                    CardNumberLabel: 'Numéro de carte',
                    CardNumberPlaceholder: '#### #### #### ####',
                    CardExpirationLabel: 'Date d\'expiration',
                    CardExpirationPlaceholder: 'MM/YYYY',
                    CardCvv2Label: 'CVV2',
                    CardCvv2Placeholder: '###',
                    FullNameLabel: 'Nom complet',
                    FullNamePlaceholder: '*Nom complet',
                    FirstNameLabel: 'Prénom',
                    FirstNamePlaceholder: '*Prénom',
                    LastNameLabel: 'Nom de famille',
                    LastNamePlaceholder: '*Nom de famille',
                    FullStreetLabel: 'Adresse de la rue',
                    FullStreetPlaceholder: '*Adresse',
                    StreetLabel: 'Adresse',
                    StreetPlaceholder: '*Adresse',
                    Street2Label: 'Adresse 2',
                    Street2Placeholder: 'Suite / Apt',
                    CityLabel: 'Ville',
                    CityPlaceholder: '*Ville',
                    ZipLabel: 'Le code postal',
                    ZipPlaceholder: '*Le code postal',
                    StateLabel: 'Etat',
                    StatePlaceholder: '*Etat',
                    CountryLabel: 'Pays',
                    CountryPlaceholder: '*Pays',
                    PhoneLabel: 'Téléphone',
                    PhonePlaceholder: '*Numéro de téléphone',
                    EmailLabel: 'Email',
                    EmailPlaceholder: '*email@domain.com'
                },
                {
                    type: 'Spanish',
                    CardNumberLabel: 'Número de tarjeta',
                    CardNumberPlaceholder: '#### #### #### ####',
                    CardExpirationLabel: 'Vencimiento',
                    CardExpirationPlaceholder: 'MM/YYYY',
                    CardCvv2Label: 'CVV2',
                    CardCvv2Placeholder: '###',
                    FullNameLabel: 'Nombre completo',
                    FullNamePlaceholder: '*Nombre completo',
                    FirstNameLabel: 'Nombre de pila',
                    FirstNamePlaceholder: '*Nombre de pila',
                    LastNameLabel: 'Apellido',
                    LastNamePlaceholder: '*Apellido',
                    FullStreetLabel: 'Dirección',
                    FullStreetPlaceholder: '*Dirección',
                    StreetLabel: 'Dirección',
                    StreetPlaceholder: '*Dirección',
                    Street2Label: 'Dirección 2',
                    Street2Placeholder: 'Suite / Apt',
                    CityLabel: 'Ciudad',
                    CityPlaceholder: '*Ciudad',
                    ZipLabel: 'Código postal',
                    ZipPlaceholder: '*Código postal',
                    StateLabel: 'Estado',
                    StatePlaceholder: '*Estado',
                    CountryLabel: 'País',
                    CountryPlaceholder: '*País',
                    PhoneLabel: 'Teléfono',
                    PhonePlaceholder: '*Teléfono',
                    EmailLabel: 'Correo electrónico',
                    EmailPlaceholder: '*Correo electrónico'
                }
            ];

            self.isMatch = function (a, b) {
                return a != null && b != null
                    && a.toUpperCase().trim() == b.toUpperCase().trim();
            };

            self.getCountryCode = function (value) {
                for (var i = 0; i < self.countries.length; i++) {
                    var country = self.countries[i];
                    if (self.isMatch(country.twoDigit, value)
                        || self.isMatch(country.threeDigit, value)
                        || self.isMatch(country.name, value)) {
                        return country.code;
                    }
                }
                return value;
            }

            self.getStateCode = function (value) {
                for (var i = 0; i < self.states.length; i++) {
                    var state = self.states[i];
                    if (self.isMatch(state.twoDigit, value)
                        || self.isMatch(state.name, value)) {
                        return state.code;
                    }
                }
                return value;
            }

            function getAddressType(target) {
                if (target.attr('name').indexOf('Shipping') >= 0)
                    return 'Shipping';
                return 'Billing';
            };

            self.setAddress = function (target, data) {
                var addressType = getAddressType(target);

                var cleanValue = function (name, value) {
                    if (name.indexOf('Country') >= 0) {
                        value = self.getCountryCode(value);
                    }
                    if (name.indexOf('State') >= 0) {
                        value = self.getStateCode(value);
                    }
                    return value;
                };

                var setInputValue = function (name, value) {
                    var id = addressType + name;
                    var ele = $('#' + id);
                    var isValidValue = false;
                    value = cleanValue(name, value);
                    if (ele.length > 0) {
                        if (ele.is('select')) {
                            if ($("#" + id + " option[value='" + value + "']").length != 0) {
                                isValidValue = true;
                            }
                        } else if (ele.is('input')) {
                            isValidValue = true;

                        }
                    }
                    if (isValidValue && value != null) {
                        ele.val(value.trim());
                    }
                    return ele;
                };

                setInputValue('FullStreet', data.Street + ' ' + data["Street2"]);
                setInputValue('Street', data.Street);
                setInputValue('Street2', data["Street2"]);
                setInputValue('City', data.City);
                setInputValue('Country', data.Country);
                setInputValue('State', data.State);
                setInputValue('Zip', data.PostalCode).trigger('keyup');

                if (typeof triggerEvent == 'function') {
                    triggerEvent("GoogleAutoComplete_AddressUpdated");
                }
                
            }

            self.setFormLanguage = function (language) {
                var collection = null;
                for (var i = 0; i < labels.length; i++) {
                    var languageCollection = labels[i];
                    if (languageCollection.type == "LM" || languageCollection.type.toLowerCase() == language.toLowerCase()) {
                        collection = languageCollection;
                        break;
                    }
                }
                if (collection == null) {
                    collection = defaultLanguage;
                }
                self.labels = collection;

                self.processLabels();
            };

            self.processLabel = function (type, name) {
                var id = type + name;
                var fieldCt = $('#' + id + 'Ct');
                if (config.enableTransformLabels) {
                    if (fieldCt.length > 0) {
                        var fieldLabel = fieldCt.find('label.label');
                        if (fieldLabel.length == 0) {
                            fieldLabel = fieldCt.find('label:first');
                        }
                        if (fieldLabel.length > 0) {
                            var newLabel = self.labels[name + 'Label'];
                            if (typeof (newLabel) != "undefined") {
                                var isRequired = fieldLabel.find('span:contains("*")').length > 0;
                                var template = (isRequired ? '<span class="requiredIcon">*</span>' : '') + newLabel + '<span class="labelColon">:</span>';
                                fieldLabel.html(template);
                            }
                        }
                    }
                }

                var item = $('#' + id);
                if (item.length > 0) {
                    if (item.is('select')) {
                        if (item.find(':first').text().indexOf('Choose') > -1) {
                            item.find(':first').text('Choose ' + self.labels[name + 'Label']);
                        }
                    } else if (item.is('input')) {
                        item.attr('placeholder', self.labels[name + 'Placeholder']);
                    }
                }
            };

            self.processLabels = function () {
                var addressFormItems = ['FullName', 'FirstName', 'LastName', 'FullStreet', 'Street', 'Street2', 'City', 'Zip', 'State', 'Country'];
                var addressTypes = ['Billing', 'Shipping'];
                for (var i = 0; i < addressFormItems.length; i++) {
                    var addressFormItem = addressFormItems[i];
                    for (var j = 0; j < addressTypes.length; j++) {
                        var type = addressTypes[j];
                        self.processLabel(type, addressFormItem);
                    }
                }
                var formItems = ['Phone', 'Email', 'CardNumber', 'CardExpiration', 'CardCvv2'];
                for (var k = 0; k < formItems.length; k++) {
                    var formItem = formItems[k];
                    self.processLabel('', formItem);
                }
            };

            function mutatePaymentForm() {
                var billingInfo = $("#billingInformation");
                var paymentInfo = $("#paymentForm");
                var paymentInfoParent = paymentInfo.parent();
                billingInfo.parent().prepend(paymentInfo);
                paymentInfoParent.prepend(billingInfo);
                if ($('#productSelection').val() != undefined) {
                    billingInfo.parent().prepend($('#productSelection'));
                }
            }

            self.onNameChange = function () {
                var value = $(this).val();
                var type = getAddressType($(this));

                if (value) {
                    value = value.replace(/\s+/gi, ' ').trim();
                    var results = value.split(' ');

                    var firstName = results.length > 0 ? $.trim(results[0]) : '';
                    var lastName = value.substr(results[0].length, value.length).trim();
                    $("#" + type + "FirstName").val(firstName);
                    $("#" + type + "LastName").val(lastName);
                }
            };

            self.greyCards = function () {
                if (!self.alwaysShowCardTypes) {
                    $('#visaImg').attr('src', '/shared/images/visa-g.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                    $('#amexImg').attr('src', '/shared/images/amex-g.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                    $('#discoverImg').attr('src', '/shared/images/discover-g.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                    $('#mastercardImg').attr('src', '/shared/images/mastercard-g.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                }
            };

            self.showAllCardsInColor = function () {
                $('#visaImg').attr('src', '/shared/images/payment/raster/visa.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                $('#amexImg').attr('src', '/shared/images/payment/raster/amex.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                $('#discoverImg').attr('src', '/shared/images/payment/raster/discover.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                $('#mastercardImg').attr('src', '/shared/images/payment/raster/mastercard.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
            };

            self.evaluateCardType = function () {
                if ($('#CardNumber').val()) {
                    var cardNumber = $('#CardNumber');
                    self.greyCards();
                    if (cardNumber.val()[0] === "4") {
                        $('#visaImg').attr('src', '/shared/images/payment/raster/visa.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                        $('#CardType').val("V");
                    } else if (cardNumber.val()[0] === "3") {
                        $('#amexImg').attr('src', '/shared/images/payment/raster/amex.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                        $('#CardType').val("AX");
                    } else if (cardNumber.val()[0] === "6") {
                        $('#discoverImg').attr('src', '/shared/images/payment/raster/discover.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                        $('#CardType').val("D");
                    } else if (cardNumber.val()[0] === "5") {
                        $('#mastercardImg').attr('src', '/shared/images/payment/raster/mastercard.png?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>');
                        $('#CardType').val("M");
                    } else {
                        $('#CardType').val("M");
                    }
                } else {
                    self.showAllCardsInColor();
                }
            };

            self.drawPayment = function (target) {
                var cardTypeHost = $(target);
                if (cardTypeHost.length > 0) {
                    cardTypeHost.find('img').remove();
                }
                self.greyCards();

                var cardNumber = $('#CardNumber');

                $('#CardTypeCt').remove();
                if ($('#CardType').length == 0) {
                    cardNumber.parent().append("<input type='hidden' id='CardType' name='CardType' />");
                }
                if (cardNumber.length > 0) {
                   cardNumber.on('keyup change input', self.evaluateCardType);
                }

                var allowedCards = config.payment.allowedCards;
                if (allowedCards == "" || allowedCards == null) {
                    allowedCards = ["visa", "mastercard", "amex", "discover"];
                } else {
                    allowedCards = allowedCards.split(',');
                }
                
                for (var i = 0; i < allowedCards.length; i++) {
                    var allowedCardType = allowedCards[i].toLowerCase();
                    var cardImage = cardTypeHost.find('#' + allowedCardType + 'Img');
                    if (cardImage.length > 0) {
                        cardImage.show();
                    } else {
                        cardTypeHost.append("<img id='" + allowedCardType + "Img' src='/shared/images/payment/" + allowedCardType + ".svg?v=<%= Dtm.Framework.ClientSites.Web.DtmContext.ApplicationVersion %>' loading='lazy' alt='" + allowedCardType + " accepted.' width='37'>");
                    }
                }
            };

            self.transform = function () {
                if (config.mergeName) {
                    var twoBecomeOne = function (type, label, placeholder) {
                        var firstName = $('#' + type + 'FirstNameCt');
                        var firstNameValue = typeof $('#' + type + 'FirstName').val() == "undefined" ? "" : $('#' + type + 'FirstName').val() ;
                        var lastName = $('#' + type + 'LastNameCt');
                        var lastNameValue = typeof $('#' + type + 'LastName').val() == "undefined" ? "" : $('#' + type + 'LastName').val();
                        if (firstName.length > 0 && lastName.length > 0) {
                            /* @NOTE: let CSS template handle whether the labeling should be displayed or not */
                            var hasVisibleLabel = $("#" + type + "FirstNameCt").find('label:first').is(':visible');
                            var classes = $("#" + type + "FirstNameCt").find('input:first').attr('class');
                            var template = "<div id='" + type + "FullNameCt' class='fldCt required'>" +
                                "<label class='label' style='" + (hasVisibleLabel ? '' : '') + "'><span class='requiredIcon'>*</span>" + label + "<span class='labelColon'>:</span></label>" +
                                "<span class='fld'><input id='" + type + "FullName' maxlength='100' name='" + type + "FullName' type='text' placeholder='" + placeholder + "' value='' class='" + classes + "'></span>" +
                                "</div>" +
                                "<input id='" + type + "FirstName' name='" + type + "FirstName' type='hidden' value='"+ firstNameValue +"' >" +
                                "<input id='" + type + "LastName' name='" + type + "LastName' type='hidden' value='" + lastNameValue +"'>";
                            var deployTo = ($("#" + type.toLowerCase() + "Information").length > 0 ? $("#" + type.toLowerCase() + "Information") : null) || $("#" + type + "FirstNameCt").parent()
                            deployTo
                                .find("#" + type + "FirstNameCt")
                                .before(template);
                            $("#" + type + "FirstNameCt").remove();
                            $("#" + type + "LastNameCt").remove();
                            $("#" + type + "FullName").on('change input keyup blur', self.onNameChange);
                        }
                    };

                    twoBecomeOne('Billing', self.labels["FullNameLabel"], self.labels["FullNamePlaceholder"]);
                    twoBecomeOne('Shipping', self.labels["FullNameLabel"], self.labels["FullNamePlaceholder"]);
                }

                if (config.mergeAddress) {
                    var allForOne = function (type) {
                        var allowHiding = $('#' + type + 'Street').val() == '';
                        var checkAndHide = function (name) {
                            if ($('#' + type + name + 'Ct').length > 0 && allowHiding) {
                                $('#' + type + name + 'Ct').hide();
                            }
                        };
                        checkAndHide('Street2');
                        checkAndHide('City');
                        checkAndHide('State');
                        checkAndHide('Zip');
                        checkAndHide('Country');

                        if ($('#' + type + 'Street').length > 0) {
                            $('#' + type + 'Street').on('blur input change', function () {
                                var checkAndShow = function (name) {
                                    if ($('#' + type + name + 'Ct').length > 0 && !$('#' + type + name + 'Ct').is(':visible')) {
                                        $('#' + type + name + 'Ct').show();
                                    }
                                };
                                checkAndShow('Street2');
                                checkAndShow('City');
                                checkAndShow('State');
                                checkAndShow('Zip');
                                checkAndShow('Country');
                            });
                        }
                    };

                    allForOne('Billing');
                }

                if (config.movePayment) {
                    mutatePaymentForm();
                }

                if (config.payment) {
                    self.drawPayment('.ccImage, #cc');
                }

                self.setFormLanguage(config.language);
            };

            self.addressAutocomplete = function () {
                if (config.enableServerMode) {
                    <%if (enableServerMode && addressAutocompleteProvider == "google")
    {%>         

                    //get latitude/longitude 
                    $.ajax({
                        type: "GET",
                        url: "/Shared/Services/GetLatLong.ashx",
                        success: function (loc) {

                            var locationObject = JSON.parse(loc);
                            var locationInput = $('<input>')
                                .attr('name', 'location')
                                .attr('id', 'location')
                                .attr('type', 'hidden');
                            if (locationObject.IsValid) {
                                var latitude = locationObject.Latitude;
                                var longitude = locationObject.Longitude;
                                var finalValue = latitude + "," + longitude;
                                
                                locationInput.attr('value', finalValue);

                            } else {

                                if (locationObject.Disable){
                                    locationInput.attr('value', 'false');
                                    $('#BillingStreet, #ShippingStreet').autocomplete("destroy");
                                    self.disable = true;
                                }
                            }
                            $('form').append(locationInput);
                        },
                        error: function (e) {
                            console.log("Could not retrieve location");
                        }

                    });
                   

                    var enableAutoCompleteDelay = parseInt(<%=serverModeDelay%>);
                    var cache = {};

                    $('#BillingStreet, #ShippingStreet').autocomplete({
                        source: function (request, response) {
                            var term = request.term;
                            if (term in cache) {
                                response(cache[term]);
                                return;
                            }
                            var latlong = $('#location').val() == 'false' ? "0,0" : $('#location').val();

                            if (typeof getCookie("gpac") == "undefined") {
                                createSessionCookie(self.sessionId);
                            }

                            if(hasValidCharacters(request.term)){
                                $.post("/Shared/Services/GooglePlaces.ashx",
                                    { a: 'q', av: request.term, l: latlong, s:getCookie("gpac") },
                                    function (data) {
                                        for (var i = 0; i < data.length; i++) {
                                            data[i]["label"] = data[i]["Description"];
                                            data[i]["value"] = data[i]["Description"];
                                            data[i]["id"] = data[i]["Place_Id"];
                                        }
                                        cache[term] = data;
                                        response(data);
                                    });
                            }
                        },
                        minLength: 5,
                        search: function (event, ui) {
                            if (!self.allowSearch) {
                                event.preventDefault();
                            } else {
                                $('#BillingStreet, #ShippingStreet').attr('autocomplete', 'new-password');
                            }
                        },
                        focus: function (event, ui) {
                            if (ui.item.Id == "LOGO") {
                                $(this).val('');
                                event.preventDefault();
                            }
                        },
                        select: function (event, ui) {
                            var ele = $(this);

                            var addressId = (ui.item.id == "LOGO") ? null : ui.item.id;

                            if (addressId != null) {
                                if (self.PlacesChoiceId != addressId) {
                                    self.PlacesChoiceId = addressId;
                                    if (addressId in cache) {
                                        self.setAddress(ele, cache[addressId]);
                                        return;
                                    }
                                    var latlong = $('#location').val() == 'false' ? "0,0" : $('#location').val();
                                    $.post("/Shared/Services/GooglePlaces.ashx",
                                        { a: 'lu', av: addressId, l: latlong, s: getCookie("gpac") },
                                        function (data) {
                                            cache[addressId] = data;
                                            self.setAddress(ele, data);
                                        });
                                } else {
                                    event.preventDefault();
                                }
                            } else {
                                event.preventDefault();
                            }
                        }

                    });
                    //Add PoweredByGoogle footer
                    var addressElements = ["BillingStreet", "ShippingStreet"];

                    $.each(addressElements, function (index, ele) {
                        $('#' + ele).autocomplete("instance")._renderMenu = function (ul, items) {
                            var that = this;

                            if (items[items.length - 1].Description != "LOGO") {
                                items.push({
                                    Description: "LOGO",
                                    Id: "LOGO",
                                    Place_Id: "LOGO",
                                    id: "LOGO",
                                    label: "LOGO",
                                    value: "LOGO"
                                });
                            }
                            $.each(items, function (index, item) {
                                that._renderItemData(ul, item);
                            });                       
                            if ($(ul).children('li:last-child').html() == "LOGO") {
                                $(ul).children('li:last-child')
                                    .addClass('ui-state-disabled')
                                    .addClass('ui-menu-logo')
                                    .addClass('ui-menu-item')
                                    .empty()
                                    .append('<img src="/Shared/images/powered_by_google.png">');
                            } 
                        };                   
                    });         

                    
                    var enableAutoComplete = debounce(function () {
                        self.allowSearch = true;

                        if (!self.disable) {
                            if ($('#BillingStreet').is(':focus')) {
                                $("#BillingStreet").autocomplete("search");
                            }
                            if ($('#ShippingStreet').is(':focus')) {
                                $("#ShippingStreet").autocomplete("search");
                            }
                            
                        }

                    }, enableAutoCompleteDelay);

                    $("#BillingStreet, #ShippingStreet").on('keyup', enableAutoComplete);

                    
                    <%}%>
                } else {
                    var initialize = function () {
                        var acRaw = [];
                        var allowedCountries = [];
                        acRaw = acRaw.concat(self.countries);
                        if (self.territories && self.territories.length > 0) {
                            acRaw = acRaw.concat(self.territories);
                        }

                        for (var i = 0; i < acRaw.length; i++) {
                            allowedCountries.push(acRaw[i].twoDigit);
                        }

                        var componentRestrictions = self.countries && self.countries.length == 1 ? { country: allowedCountries } : null;
                        var payload = {
                            autocomplete: 'false'
                        };
                        if (componentRestrictions != null) {
                            payload['componentRestrictions'] = componentRestrictions;
                        }

                        var linkAddress = function (addressType) {
                            if ($('#' + addressType + 'Street').length == 0) return;
                            var input = document.getElementById(addressType + 'Street');
                            var autocomplete = new google.maps.places.Autocomplete(input, payload);

                            google.maps.event.addListener(autocomplete, 'place_changed', function () {
                                var place = autocomplete.getPlace();

                                if (!place.geometry) {
                                    // User entered the name of a Place that was not suggested and
                                    // pressed the Enter key, or the Place Details request failed.
                                    return;
                                }

                                var addressTypes = ['street_number', 'route', 'locality', 'postal_code', 'administrative_area_level_1', 'country'];
                                var address = { Street: '', City: '', PostalCode: '', State: '', Country: '' };
                                var usTerritory =  ["PR", "GU", "VI" ];
                                var isUsTerritory = false;
                                var isUSA = false;
                                
                                for (var i = 0; i < place.address_components.length; i++) {
                                    var component = place.address_components[i];
                                    var type = component.types[0];
                                    var value = component["short_name"];
                                    if (addressTypes.indexOf(type) > -1) {

                                        if(type== 'country')
                                        {
                                            if (usTerritory.indexOf(value) > -1)
                                            {
                                                isUsTerritory = true;
                                                isUSA = true;
                                                break;
                                            }
                                            if (value == "US")
                                            {
                                                isUSA = true;
                                            }
                                        }
                                    }
                                }

                                for (var i = 0; i < place.address_components.length; i++) {
                                    var component = place.address_components[i];
                                    var type = component.types[0];
                                    var value = component["short_name"];
                                    if (addressTypes.indexOf(type) > -1) {
                                        switch (type) {
                                            case 'street_number':
                                                address.Street = value + ' ' + address.Street;
                                                break;
                                            case 'route':
                                                address.Street = address.Street + value;
                                                break;
                                            case 'locality':
                                                address.City = value;
                                                break;
                                            case 'postal_code':
                                                address.PostalCode = value;
                                                break;
                                            case 'administrative_area_level_1':
                                                address.State = value;
                                                break;
                                            case 'country':
                                                address.Country = value;
                                                break;
                                        }
                                    }
                                }

                                if (isUsTerritory)
                                {
                                    var state = address.State;
                                    var country = address.Country
                                    address.State = country;
                                    address.Country = "USA";
                                }

                                //If NOT USA , zip field changes to type 'text' to show keyboard on mobile devices
                                if (isUSA) {
                                    if ($('#BillingZip').length) {
                                        $('#BillingZip').attr("type", "tel");
                                    }
                                    if ($('#ShippingZip').length) {
                                        $('#ShippingZip').attr("type", "tel");
                                    }                                   
                                }
                                else {
                                    if ($('#BillingZip').length) {
                                        $('#BillingZip').attr("type", "text");
                                    }
                                    if ($('#ShippingZip').length) {
                                        $('#ShippingZip').attr("type", "text");
                                    }
                                }

                                self.setAddress($('#' + addressType + 'Street'), address);
                            });

                            google.maps.event.addDomListener(input, 'keydown', function (e) {
                                if (e.keyCode == 13) {
                                    e.preventDefault();
                                }
                            });
                        };
                        linkAddress('Billing');
                        linkAddress('Shipping');
                    };
                    try {
                        <%if (addressAutocompleteProvider == "google")
    {%>
                        google.maps.event.addDomListener(window, 'load', initialize);
                        <%}%>
                    } catch (error) {
                        console.error('Google Maps not loaded: ' + error);
                    }

                }
            };

            self.defaultValues = function () {
                var valueType = ["Billing", "Shipping"];

                valueType.forEach(function (type) {

                    var firstName = typeof $('#' + type + 'FirstName').val() == "undefined"  ? "" : $('#' + type + 'FirstName').val();
                    var lastName = typeof $('#' + type + 'LastName').val() == "undefined"? "" : $('#' + type + 'LastName').val();

                    if (firstName.length > 0 && lastName.length > 0) {
                        var fullName = firstName + ' ' + lastName;
                        
                        $('#' + type + 'FullName').val(fullName).trigger('change');
                        
                    }
                });

            };

            this.initialize = function () {
                if (self.IsInitial) {
                    self.IsInitial = false;

                    self.transform();
                    self.addressAutocomplete();
                    self.defaultValues();
                }
            };

            $(document).ready(function () {
                self.initialize();

                if (config.enableServerMode) {
                  //  $('#BillingStreet, #ShippingStreet').attr('autocomplete', 'new-password');
                }
            });
        };

        var _addressEngine = new AddressEngine({
            mergeName: "<%=mergeName %>" == "true",
            mergeAddress: "<%=mergeAddress %>" == "true",
            isMobile: "<%=isMobile %>" == "true",
            language: "<%=language%>",
            payment: {
                allowedCards: "<%=allowedCards%>",
                alwaysShowCardTypes: "<%=alwaysShowCardTypes%>" == "true"
            },
            enableTransformLabels: "<%=enableTransformLabels %>" == "true",
            movePayment: "<%=movePayment %>" == "true",
            enableServerMode: "<%=enableServerMode.ToString().ToLower()%>" == "true"
        });
        if (typeof (registerEvent) === "function") {
            registerEvent('ECDrawFormComplete', function () {
                _addressEngine.drawPayment('.ccImage');
                if ($('#cc').length > 0 && !$('#cc').is(':visible')) {
                    $('#cc').remove();
                }
            });
        }
    }

function debounce(func, wait, immediate) {
    var timeout;
    return function () {
        var context = this, args = arguments;
        var later = function () {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
}

function createCookie(name, value, minutes) {
    if (minutes) {
        var date = new Date();
        date.setTime(date.getTime() + (minutes * 60 * 1000));
        var expires = "; expires=" + date.toGMTString();
    } else {
        var expires = "";
    }
    document.cookie = name + "=" + value + expires + "; path=/";
}

function getCookie(name) {
    var value = "; " + document.cookie;
    var parts = value.split("; " + name + "=");
    if (parts.length == 2) return parts.pop().split(";").shift();
}

function createSessionCookie(sessionId) {
    var sessionTokenExists = document.cookie.indexOf("gpac=");
    if (sessionTokenExists <= -1) {
        var date = new Date();
        var timeStamp = date.getTime();
        timeStamp = timeStamp.toString();
        createCookie("gpac", sessionId + "-" + timeStamp, 4);
    }
}

function hasValidCharacters(text) {
    /* Regex for letters, numbers, spaces, underscores, hyphen, period*/
    var pattern = new RegExp('^(?:[A-Za-z0-9 _.-]+)(?:[A-Za-z0-9 _.-]*)$');
    var isRegexMatch = pattern.test(text);
   
    return isRegexMatch;
       
}

<%if(addressAutocompleteProvider == "smarty streets"){%>

    $(window).on('load', function () {
        $('#BillingStreet').on("focus", function () { $(this).attr('autocomplete', 'section-bill billing new-password'); });
        $('#ShippingStreet').on("focus", function () { $(this).attr('autocomplete', 'section-ship shipping new-password'); });
        var cache = {};
        $('#BillingStreet, #ShippingStreet').autocomplete({
            create: function (e, u) {
                $('#BillingStreet').attr('autocomplete', 'section-bill billing address-line1');
                $('#ShippingStreet').attr('autocomplete', 'section-ship shipping address-line1');
            },
            source: function (request, response) {
                var term = request.term;
                if (term in cache) {
                    response(cache[term]);
                    return;
                }
                $.post("/Shared/Services/SmartyStreets.ashx",
                    {
                        a: term
                    },
                    function (data, status) {

                        if (status == "success") {

                            if (data.suggestions != null && data.suggestions.length > 0) {
                                var finalData = $.map(data.suggestions, function (item) {
                                    return {
                                        label: item.street_line + ' ' + item.secondary + ' , ' + item.city + ', ' + item.state,
                                        value: item.street_line,
                                        city: item.city,
                                        state: item.state,
                                        zipcode: item.zipcode,
                                        street2: item.secondary
                                    };
                                });

                                cache[term] = finalData;
                                response(finalData);
                            }
                        }
                    });
            },
            select: function (event, ui) {

                var name = event.target.name;
                var type = name.replace("Street", "");

                $('#' + type + 'Zip').val(ui.item.zipcode);
                $('#' + type + 'City').val(ui.item.city);
                $('#' + type + 'State').val(ui.item.state);
                $('#' + type + 'Country').val("USA");
                $('#' + type + 'Street2').val(ui.item.street2);

                if (typeof triggerEvent == 'function') {
                    triggerEvent("GoogleAutoComplete_AddressUpdated");
                }

            },

            minLength: 5
        });
        
        var hasAutoCompleteFields = typeof $('#BillingStreet, #ShippingStreet').data('ui-autocomplete') != "undefined";
        
        if (hasAutoCompleteFields){
            $('#BillingStreet, #ShippingStreet').data('ui-autocomplete')._renderItem = function (ul, item) {
                
                //Each list item is rendered here
                return $("<li/>")
                    .append($("<span/>", {
                        class: "ui-menu-address",
                        html: $("<span/>", {
                            class: "ui-menu-droppin"
                        })
                    }).append($("<strong/>", {
                        text: item.value + " " + item.street2
                    })).append($("<small/>", {
                        text: item.city + " " + item.state + " " + item.zipcode
                    })))
                    .attr("value", item.value)
                    //Add Custom attributes, classes here
                    .appendTo(ul);
            }; 
        }
    });
    

<%}%>
</script>
